<?php

// app/Http/Controllers/Api/ComplaintController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ComplaintController extends Controller
{
    /**
     * GET /api/complaint_data
     * List semua pengaduan milik user yang login
     */
    public function index(): JsonResponse
    {
        $user = Auth::user();

        $complaints = Complaint::with(['user', 'messages'])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($complaint) {
                return [
                    'id' => $complaint->id,
                    'title' => $complaint->title,
                    'message' => $complaint->description ?? $complaint->message,
                    'status' => $complaint->status, // 'diajukan', 'diproses', 'selesai'
                    'created_at' => $complaint->created_at->toISOString(),
                    'category' => $complaint->category,
                    'attachment_url' => $complaint->attachment_url
                        ? asset('storage/'.$complaint->attachment_url)
                        : null,
                    'is_read' => $complaint->is_read ?? false,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $complaints,
        ]);
    }

    /**
     * POST /api/complaints
     * Buat pengaduan baru
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'category' => 'nullable|string|max:100',
            'attachment' => 'nullable|image|max:2048', // Max 2MB
        ]);

        $user = Auth::user();
        $attachmentPath = null;

        // Handle upload file
        if ($request->hasFile('attachment')) {
            $attachmentPath = $request->file('attachment')->store('complaints', 'public');
        }

        $complaint = Complaint::create([
            'user_id' => $user->id,
            'title' => $validated['title'],
            'description' => $validated['message'],
            'category' => $validated['category'] ?? 'Umum',
            'status' => 'diajukan', // Default status
            'attachment_url' => $attachmentPath,
            'is_read' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan berhasil dibuat',
            'data' => [
                'id' => $complaint->id,
                'title' => $complaint->title,
                'status' => $complaint->status,
            ],
        ], 201);
    }

    /**
     * GET /api/complaints/{id}
     * Detail satu pengaduan
     */
    public function show(int $id): JsonResponse
    {
        $user = Auth::user();

        $complaint = Complaint::with(['user', 'messages.user'])
            ->where('id', $id)
            ->where('user_id', $user->id) // Keamanan: user hanya bisa lihat punya sendiri
            ->first();

        if (! $complaint) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $complaint->id,
                'title' => $complaint->title,
                'message' => $complaint->description,
                'status' => $complaint->status,
                'created_at' => $complaint->created_at->toISOString(),
                'category' => $complaint->category,
                'attachment_url' => $complaint->attachment_url
                    ? asset('storage/'.$complaint->attachment_url)
                    : null,
            ],
        ]);
    }

    /**
     * PATCH /api/complaints/{id}/read
     * Tandai pengaduan sudah dibaca
     */
    public function markAsRead(int $id): JsonResponse
    {
        $user = Auth::user();

        $complaint = Complaint::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (! $complaint) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan',
            ], 404);
        }

        $complaint->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan ditandai sebagai dibaca',
        ]);
    }
}
