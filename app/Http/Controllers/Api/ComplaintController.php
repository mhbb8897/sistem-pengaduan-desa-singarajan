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
        // 1. Validasi Ketat: Hanya Foto & Max 5MB
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'message' => 'required|string|max:2000',   // Deskripsi
            'lokasi' => 'required|string|max:150',    // Lokasi
            'attachment_path' => 'required|image|mimes:jpg,jpeg,png|max:5120', // 5MB
        ]);

        try {
            $user = Auth::user();
            $attachmentPath = null;
            $paths = [];
            if ($request->hasFile('attachments')) {
                foreach ($request->file('attachments') as $file) {
                    $paths[] = $file->store('record', 'public'); // Simpan semua path ke array
                }
            }
            // 2. Simpan ke folder 'record' sesuai struktur Anda
            if ($request->hasFile('attachment')) {
                // Menyimpan ke: storage/app/public/record/
                $attachmentPath = $request->file('attachment')->store('record', 'public');
            }

            // 3. Gabungkan semua input dinamis ke dalam Map untuk dienkripsi
            // Ini agar Flutter bisa melakukan looping otomatis nantinya
            $dynamicData = [
                'deskripsi' => $validated['message'],
                'lokasi' => $validated['lokasi'],
            ];

            // Tangkap field tambahan dari kategori (jika ada di request)
            // Contoh: nama_perangkat_desa, nama_layanan_unit, dll
            foreach ($request->except(['title', 'category', 'message', 'lokasi', 'attachment']) as $key => $value) {
                if (! empty($value)) {
                    $dynamicData[$key] = $value;
                }
            }

            // --- PROSES ENKRIPSI HYBRID (AES-RSA) ---
            $aesKey = Str::random(32);
            $iv = Str::random(16);

            $dataToEncrypt = json_encode($dynamicData);

            $aes = new AES('cbc');
            $aes->setKey($aesKey);
            $aes->setIV($iv);
            $encryptedContent = base64_encode($aes->encrypt($dataToEncrypt));

            $publicKeyPath = storage_path('app/public.pem');
            if (! file_exists($publicKeyPath)) {
                return response()->json(['success' => false, 'message' => 'Public key tidak ditemukan'], 500);
            }

            $publicKey = RSA::load(file_get_contents($publicKeyPath));
            $encryptedAesKey = base64_encode($publicKey->encrypt($aesKey));

            // 4. Simpan ke Database
            $complaint = Complaint::create([
                'user_id' => $user->id,
                'title' => $validated['title'],
                'category' => $validated['category'],
                'status' => 'diajukan',
                'attachment_path' => json_encode($paths), // Menyimpan 'record/namafile.jpg'
                'encrypted_content' => $encryptedContent,
                'encrypted_aes_key' => $encryptedAesKey,
                'iv' => base64_encode($iv),
                'is_read' => false,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengaduan berhasil dikirim secara aman',
                'data' => [
                    'id' => $complaint->id,
                    'title' => $complaint->title,
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal enkripsi/simpan: '.$e->getMessage(),
            ], 500);
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
                    // Pastikan URL mengarah ke storage link
                    'attachment_url' => $complaint->attachment_path
                        ? url('storage/'.$complaint->attachment_path)
                        : null,
                    'decrypted_content' => $complaint->decrypted_content,
                ];
            });

        return response()->json(['success' => true, 'data' => $complaints]);
    }

    public function debugDecryptedData(): JsonResponse
    {
        $complaints = Complaint::orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($complaint) {
                return [
                    'id' => $complaint->id,
                    'title' => $complaint->title,
                    'category' => $complaint->category,
                    // ✅ Tambahkan URL gambar di sini agar bisa tampil di Flutter/Browser
                    'attachment_url' => $complaint->attachment_path
                        ? url('storage/'.$complaint->attachment_path)
                        : null,
                    'raw_decrypted_json' => $complaint->decrypted_content,
                    'status_dekripsi' => empty($complaint->decrypted_content) ? 'Gagal' : 'Berhasil',
                    'created_at' => $complaint->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'info' => 'Menampilkan data lengkap beserta bukti pendukung',
            'data' => $complaints,
        ]);
    }
}
