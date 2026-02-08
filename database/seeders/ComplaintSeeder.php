<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\RSA;

class ComplaintSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Mengambil 5 user random
        $users = User::role('user')->inRandomOrder()->limit(5)->get();

        if ($users->count() < 5) {
            $this->command->error('User dengan role USER kurang dari 5. Pastikan UserSeeder sudah dijalankan.');

            return;
        }

        // 2. Load RSA Public Key
        $publicKeyPath = storage_path('app/public.pem');
        if (! file_exists($publicKeyPath)) {
            $this->command->error('Public key tidak ditemukan.');

            return;
        }

        $publicKey = RSA::load(file_get_contents($publicKeyPath));

        // 3. Data simulasi
        $sampleComplaints = [
            ['title' => 'Kerusakan Jalan Umum', 'category' => 'Fasilitas Umum', 'content' => ['lokasi' => 'Jl. Mawar RT 01', 'deskripsi' => 'Jalan berlubang.', 'waktu_kejadian' => '2023-10-27']],
            ['title' => 'Pelayanan Tidak Profesional', 'category' => 'Kinerja Perangkat Desa', 'content' => ['perangkat' => 'Staff Admin', 'deskripsi' => 'Petugas tidak ada.', 'tanggal' => '2023-10-25']],
            ['title' => 'Pengurusan Surat Terlambat', 'category' => 'Layanan Publik', 'content' => ['jenis_layanan' => 'Surat Domisili', 'deskripsi' => 'Lebih dari 2 minggu.', 'pengajuan' => '2023-10-10']],
            ['title' => 'Dugaan Pelanggaran HAM', 'category' => 'Pelanggaran HAM', 'content' => ['kronologi' => 'Penangkapan tanpa surat.', 'pelaku' => 'Oknum', 'lokasi' => 'Balai Desa']],
            ['title' => 'Gangguan Ketertiban Warga', 'category' => 'Keluhan Sosial', 'content' => ['deskripsi' => 'Keributan malam.', 'lokasi' => 'RT 04 RW 02', 'waktu' => '22:00']],
        ];

        // 4. Loop SATU KALI saja
        foreach ($sampleComplaints as $index => $data) {

            // Logika Enkripsi
            $aesKey = random_bytes(32); // AES-256
            $iv = random_bytes(16);

            $aes = new AES('cbc');
            $aes->setKey($aesKey);
            $aes->setIV($iv);

            $plaintext = json_encode($data['content']);
            $ciphertext = $aes->encrypt($plaintext);

            // Enkripsi AES Key dengan RSA
            $encryptedAesKey = $publicKey->encrypt($aesKey);

            // Simpan ke Database
            DB::table('complaints')->insert([
                'user_id' => $users[$index]->id, // Menggunakan index untuk mapping ke user
                'title' => $data['title'],
                'category' => $data['category'],
                'status' => 'diajukan',
                'encrypted_content' => base64_encode($ciphertext),
                'encrypted_aes_key' => base64_encode($encryptedAesKey),
                'iv' => base64_encode($iv),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('Berhasil membuat 5 data pengaduan terenkripsi.');
    }
}
