<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\ComplaintMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ComplaintMessageController extends Controller
{
    /**
     * GET /api/complaints/{id}/messages
     * Ambil semua pesan dalam pengaduan
     */
    public function index(int $id): JsonResponse
    {
        $user = Auth::user();
        $complaint = Complaint::find($id);

        if (! $complaint) {
            return response()->json(['success' => false, 'message' => 'Pengaduan tidak ditemukan'], 404);
        }

        // Hak akses: Admin boleh lihat semua, User hanya boleh lihat miliknya
        if (! $user->hasRole('super_admin') && $complaint->user_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak'], 403);
        }

        $messages = ComplaintMessage::with('user')
            ->where('complaint_id', $id)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($msg) {
                return [
                    'id' => $msg->id,
                    'message' => $msg->message,
                    'created_at' => $msg->created_at->toISOString(),
                    'sender_name' => $msg->user->name,
                    // Pastikan sender_role diambil dari kolom di database
                    'sender_role' => $msg->sender_role,
                    'is_read' => (bool) $msg->is_read,
                ];
            });

        return response()->json(['success' => true, 'data' => $messages]);
    }

    public function store(Request $request, int $id): JsonResponse
    {
        $user = Auth::user();
        $complaint = Complaint::find($id);

        if (! $complaint) {
            return response()->json(['success' => false, 'message' => 'Pengaduan tidak ditemukan'], 404);
        }

        // Validasi akses kirim pesan
        if (! $user->hasRole('super_admin') && $complaint->user_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak'], 403);
        }

        $validated = $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        // ✅ Tentukan role secara eksplisit sesuai permintaan Anda
        $senderRole = $user->hasRole('super_admin') ? 'super_admin' : 'user';

        $message = ComplaintMessage::create([
            'complaint_id' => $id,
            'user_id' => $user->id,
            'sender_role' => $senderRole, // Akan tersimpan 'super_admin' atau 'user'
            'message' => $validated['message'],
            'is_read' => false,
        ]);

        $complaint->touch();

        return response()->json([
            'success' => true,
            'message' => 'Pesan berhasil dikirim',
            'data' => [
                'id' => $message->id,
                'message' => $message->message,
                'created_at' => $message->created_at->toISOString(),
                'sender_name' => $user->name,
                'sender_role' => $senderRole,
            ],
        ], 201);
    }
}
