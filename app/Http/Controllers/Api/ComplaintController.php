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
                    'title' => $complaint->title,
                    'status' => $complaint->status,
                    'category' => $complaint->category,
                    'created_at' => $complaint->created_at->toISOString(),
                    'decrypted_content' => $complaint->decrypted_content,
                ];
            });

        return response()->json(['success' => true, 'data' => $complaints]);
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
}
