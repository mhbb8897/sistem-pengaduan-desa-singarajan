<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\RSA;

class ComplaintController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        // 1. Validasi: Pastikan field 'attachments' ada
        $validated = $request->validate([
            'title' => 'required|string',
            'category' => 'required|string',
            'message' => 'required|string',
            'lokasi' => 'required|string',
        ]);

        try {
            $user = Auth::user();
            $storedFiles = [];

            // 2. ✅ PERBAIKAN: Proses Upload File secara eksplisit
            // Flutter mengirim 'attachments[]', Laravel membacanya sebagai 'attachments'
            if ($request->hasFile('attachments')) {
                $files = $request->file('attachments');
                foreach ($files as $file) {
                    // Simpan file ke folder public/complaints
                    $path = $file->store('record', 'public');
                    // Masukkan nama file (hasil enkripsi sistem/hash) ke array
                    $storedFiles[] = basename($path);
                }
            }

            // 3. Gabungkan ke data untuk dienkripsi AES
            $dynamicData = [
                'deskripsi' => $request->message,
                'lokasi' => $request->lokasi,
                // ✅ Masukkan list nama file ke dalam enkripsi
                'bukti_pendukung' => ! empty($storedFiles) ? implode(', ', $storedFiles) : null,
            ];

            // Tambahkan field dinamis lainnya jika ada
            foreach ($request->except(['title', 'category', 'message', 'lokasi', 'attachments']) as $key => $value) {
                $dynamicData[$key] = $value;
            }

            // --- PROSES ENKRIPSI HYBRID ---
            $aesKey = Str::random(32);
            $iv = Str::random(16);
            $dataToEncrypt = json_encode($dynamicData);

            $aes = new AES('cbc');
            $aes->setKey($aesKey);
            $aes->setIV($iv);
            $encryptedContent = base64_encode($aes->encrypt($dataToEncrypt));

            // Enkripsi AES Key dengan RSA Public Key
            $publicKey = RSA::load(file_get_contents(storage_path('app/public.pem')));
            $encryptedAesKey = base64_encode($publicKey->encrypt($aesKey));

            // 4. Simpan ke Database
            $complaint = Complaint::create([
                'user_id' => $user->id,
                'title' => $validated['title'],
                'category' => $validated['category'],
                'encrypted_content' => $encryptedContent,
                'encrypted_aes_key' => $encryptedAesKey,
                'iv' => base64_encode($iv),
                'status' => 'diajukan',
            ]);

            return response()->json(['success' => true, 'message' => 'Data terenkripsi disimpan'], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function index(): JsonResponse
    {
        $user = Auth::user();
        $complaints = Complaint::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($complaint) {
                return [
                    'id' => $complaint->id,
                    'reporter_name' => $complaint->user->name,
                    'title' => $complaint->title,
                    'status' => $complaint->status,
                    'category' => $complaint->category,
                    'created_at' => $complaint->created_at->toISOString(),
                    'decrypted_content' => $complaint->decrypted_content,
                ];
            });

        return response()->json(['success' => true, 'data' => $complaints]);
    }

    // // Edit Complaint
    public function update(Request $request, $id): JsonResponse
    {
        $complaint = Complaint::findOrFail($id);

        // Validasi pemilik laporan
        if ($complaint->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses.',
            ], 403);
        }

        // Hanya status diajukan yang boleh diedit
        if ($complaint->status !== 'diajukan') {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak dapat diubah karena sudah diproses.',
            ], 422);
        }

        $validated = $request->validate([
            'title' => 'required|string',
            'category' => 'required|string',
            'message' => 'required|string',
            'lokasi' => 'required|string',
            'attachments.*' => 'nullable|file|max:5120',
        ]);

        try {

            /*
            |--------------------------------------------------------------------------
            | Ambil data lama hasil dekripsi
            |--------------------------------------------------------------------------
            */

            $oldData = $complaint->decrypted_content;

            if (is_string($oldData)) {
                $oldData = json_decode($oldData, true);
            }

            $storedFiles = [];

            /*
            |--------------------------------------------------------------------------
            | Jika upload bukti baru
            |--------------------------------------------------------------------------
            */

            if ($request->hasFile('attachments')) {

                // Hapus file lama
                if (! empty($oldData['bukti_pendukung'])) {

                    $oldFiles = explode(',', $oldData['bukti_pendukung']);

                    foreach ($oldFiles as $file) {

                        $file = trim($file);

                        $fullPath = storage_path(
                            'app/public/record/'.$file
                        );

                        if (file_exists($fullPath)) {
                            unlink($fullPath);
                        }
                    }
                }

                // Simpan file baru
                foreach ($request->file('attachments') as $file) {

                    $path = $file->store('record', 'public');

                    $storedFiles[] = basename($path);
                }

            } else {

                // Tetap gunakan file lama
                if (! empty($oldData['bukti_pendukung'])) {

                    $storedFiles = array_map(
                        'trim',
                        explode(',', $oldData['bukti_pendukung'])
                    );
                }
            }

            /*
            |--------------------------------------------------------------------------
            | Susun ulang data terenkripsi
            |--------------------------------------------------------------------------
            */

            $dynamicData = [
                'deskripsi' => $validated['message'],
                'lokasi' => $validated['lokasi'],
                'bukti_pendukung' => count($storedFiles)
                    ? implode(', ', $storedFiles)
                    : null,
            ];

            /*
            |--------------------------------------------------------------------------
            | Enkripsi AES
            |--------------------------------------------------------------------------
            */

            $aesKey = Str::random(32);
            $iv = Str::random(16);

            $aes = new AES('cbc');
            $aes->setKey($aesKey);
            $aes->setIV($iv);

            $encryptedContent = base64_encode(
                $aes->encrypt(json_encode($dynamicData))
            );

            /*
            |--------------------------------------------------------------------------
            | Enkripsi AES Key dengan RSA
            |--------------------------------------------------------------------------
            */

            $publicKey = RSA::load(
                file_get_contents(storage_path('app/public.pem'))
            );

            $encryptedAesKey = base64_encode(
                $publicKey->encrypt($aesKey)
            );

            /*
            |--------------------------------------------------------------------------
            | Update Database
            |--------------------------------------------------------------------------
            */

            $complaint->update([
                'title' => $validated['title'],
                'category' => $validated['category'],
                'encrypted_content' => $encryptedContent,
                'encrypted_aes_key' => $encryptedAesKey,
                'iv' => base64_encode($iv),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengaduan berhasil diperbarui.',
                'data' => [
                    'id' => $complaint->id,
                    'title' => $complaint->title,
                    'category' => $complaint->category,
                    'status' => $complaint->status,
                ],
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function debugDecryptedData(): JsonResponse
    {
        $complaints = Complaint::orderBy('created_at', 'desc')
            ->limit(50)
            ->get()
            ->map(function ($complaint) {
                return [
                    'id' => $complaint->id,
                    'title' => $complaint->title,
                    'category' => $complaint->category,
                    'raw_decrypted_json' => $complaint->decrypted_content,
                    'status_dekripsi' => empty($complaint->decrypted_content) ? 'Gagal' : 'Berhasil',
                    'created_at' => $complaint->created_at,
                ];
            });

        // ✅ TAMBAHKAN RETURN DI SINI:
        return response()->json([
            'success' => true,
            'message' => 'Data debug dekripsi berhasil diambil',
            'count' => $complaints->count(),
            'data' => $complaints,
        ], 200);
    }

    // public function update(Request $request, $id): JsonResponse
    // {
    //     $complaint = Complaint::findOrFail($id);

    //     // Pastikan pemilik laporan
    //     if ($complaint->user_id !== Auth::id()) {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Anda tidak memiliki akses.',
    //         ], 403);
    //     }

    //     // Hanya boleh edit jika masih diajukan
    //     if ($complaint->status !== 'diajukan') {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Pengaduan tidak dapat diubah karena sudah diproses.',
    //         ], 422);
    //     }

    //     $validated = $request->validate([
    //         'title' => 'required|string',
    //         'category' => 'required|string',
    //         'message' => 'required|string',
    //         'lokasi' => 'required|string',
    //     ]);

    //     try {

    //         $dynamicData = [
    //             'deskripsi' => $validated['message'],
    //             'lokasi' => $validated['lokasi'],
    //         ];

    //         // Enkripsi ulang data
    //         $aesKey = Str::random(32);
    //         $iv = Str::random(16);

    //         $aes = new AES('cbc');
    //         $aes->setKey($aesKey);
    //         $aes->setIV($iv);

    //         $encryptedContent = base64_encode(
    //             $aes->encrypt(json_encode($dynamicData))
    //         );

    //         $publicKey = RSA::load(
    //             file_get_contents(storage_path('app/public.pem'))
    //         );

    //         $encryptedAesKey = base64_encode(
    //             $publicKey->encrypt($aesKey)
    //         );

    //         $complaint->update([
    //             'title' => $validated['title'],
    //             'category' => $validated['category'],
    //             'encrypted_content' => $encryptedContent,
    //             'encrypted_aes_key' => $encryptedAesKey,
    //             'iv' => base64_encode($iv),
    //         ]);

    //         return response()->json([
    //             'success' => true,
    //             'message' => 'Pengaduan berhasil diperbarui.',
    //             'data' => [
    //                 'id' => $complaint->id,
    //                 'title' => $complaint->title,
    //                 'category' => $complaint->category,
    //                 'status' => $complaint->status,
    //             ],
    //         ]);

    //     } catch (\Exception $e) {

    //         return response()->json([
    //             'success' => false,
    //             'message' => $e->getMessage(),
    //         ], 500);
    //     }
    // }

}
