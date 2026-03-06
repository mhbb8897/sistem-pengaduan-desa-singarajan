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

        // Validasi: user hanya bisa akses chat di pengaduan miliknya
        $complaint = Complaint::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (! $complaint) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan',
            ], 404);
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
                    'sender_role' => $msg->sender_role, // 'user' atau 'super_admin'
                    'is_read' => $msg->is_read ?? false,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * POST /api/complaints/{id}/messages
     * Kirim pesan baru
     */
    public function store(Request $request, int $id): JsonResponse
    {
        $user = Auth::user();

        $validated = $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        // Validasi: user hanya bisa kirim pesan ke pengaduan miliknya
        $complaint = Complaint::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (! $complaint) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan',
            ], 404);
        }

        // Tentukan role pengirim
        $senderRole = $user->hasRole('super_admin') ? 'super_admin' : 'user';

        $message = ComplaintMessage::create([
            'complaint_id' => $id,
            'user_id' => $user->id,
            'sender_role' => $senderRole,
            'message' => $validated['message'],
            'is_read' => false,
        ]);

        // Update updated_at pada complaint agar status terbaru
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
