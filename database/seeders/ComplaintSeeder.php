<?php

namespace Database\Seeders;

use App\Models\Complaint;
use App\Models\User;
use Illuminate\Database\Seeder;
use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\RSA;

class ComplaintSeeder extends Seeder
{
    public function run(): void
    {
        // Mengambil random user
        $user = User::role('user')->inRandomOrder()->first();
        // Mengambil user pertama
        // $user = User::role('user')->first();

        if (! $user) {
            $this->command->error('Tidak ada user dengan role USER.');

            return;
        }

        // 2️⃣ Ambil RSA Public Key (digunakan untuk enkripsi AES key)
        $publicKeyPath = storage_path('app/public.pem');
        if (! file_exists($publicKeyPath)) {
            $this->command->error('Public key tidak ditemukan. Generate key terlebih dahulu.');

            return;
        }

        $publicKey = RSA::load(file_get_contents($publicKeyPath));

        // 3️⃣ Data simulasi pengaduan (plaintext)
        $sampleComplaints = [
            [
                'title' => 'Kerusakan Jalan Desa',
                'category' => 'Fasilitas',
                'content' => [
                    'lokasi' => 'Jl. Mawar RT 01',
                    'deskripsi' => 'Jalan berlubang parah menyebabkan kecelakaan.',
                    'waktu_kejadian' => '2023-10-27 08:00',
                ],
            ],
            [
                'title' => 'Dugaan Pelanggaran Prosedur',
                'category' => 'Pelanggaran HAM',
                'content' => [
                    'kronologi' => 'Terjadi penangkapan tanpa surat tugas.',
                    'pelaku' => 'Oknum perangkat desa',
                    'lokasi' => 'Balai Desa',
                    'pihak_terlibat' => 'Warga sekitar',
                ],
            ],
        ];

        foreach ($sampleComplaints as $data) {

            // ==============================
            // 🔐 PROSES ENKRIPSI HIBRIDA
            // ==============================

            // A️⃣ Generate AES Session Key & IV
            $aesKey = random_bytes(32); // AES-256
            $iv = random_bytes(16); // IV untuk AES-CBC

            // B️⃣ Enkripsi konten pengaduan menggunakan AES
            $aes = new AES('cbc');
            $aes->setKey($aesKey);
            $aes->setIV($iv);

            $plaintext = json_encode($data['content']);
            $ciphertext = $aes->encrypt($plaintext);

            // C️⃣ Enkripsi AES key menggunakan RSA Public Key
            $encryptedAesKey = $publicKey->encrypt($aesKey);

            // ==============================
            // 💾 SIMPAN KE DATABASE
            // ==============================
            Complaint::create([
                'user_id' => $user->id,
                'title' => $data['title'],
                'category' => $data['category'],
                'status' => 'diajukan',

                // Data terenkripsi
                'encrypted_content' => base64_encode($ciphertext),
                'encrypted_aes_key' => base64_encode($encryptedAesKey),
                'iv' => base64_encode($iv),

                'attachment_path' => null,
            ]);
        }
    }
}
