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
            [
                'title' => 'Kerusakan Jalan Mawar',
                'category' => 'Fasilitas Umum',
                'content' => [
                    'lokasi' => 'Jl. Mawar RT 01',
                    'deskripsi' => 'Jalan berlubang parah menghambat akses warga.',
                    'waktu_kejadian_diketahui' => '2023-10-27 08:00',
                    'bukti_pendukung' => 'foto_jalan_rusak.jpg',
                ],
            ],
            [
                'title' => 'Staf Administrasi Tidak Ramah',
                'category' => 'Kinerja Perangkat Desa',
                'content' => [
                    'nama_perangkat_desa' => 'Andi (Staf Admin)',
                    'deskripsi' => 'Pelayanan sangat lambat dan petugas meninggalkan meja saat jam kerja.',
                    'lokasi' => 'Loket Pendaftaran',
                    'tanggal_dan_waktu_kejadian' => '2023-10-25 10:30',
                    'bukti_pendukung' => 'foto_jalan_rusak.jpg',
                ],
            ],
            [
                'title' => 'Keterlambatan KTP',
                'category' => 'Layanan Publik',
                'content' => [
                    'nama_layanan_unit' => 'Disdukcapil / Layanan KTP',
                    'deskripsi' => 'Sudah 3 bulan KTP tidak kunjung selesai tanpa kejelasan.',
                    'lokasi' => 'Kecamatan ABC',
                    'tanggal_dan_waktu_kejadian' => '2023-10-10',
                    'bukti_pendukung' => 'foto_jalan_rusak.jpg',
                ],
            ],
            [
                'title' => 'Keterlambatan KTP',
                'category' => 'Layanan Publik',
                'content' => [
                    'nama_layanan_unit' => 'Disdukcapil / Layanan KTP',
                    'deskripsi' => 'Sudah 3 bulan KTP tidak kunjung selesai tanpa kejelasan.',
                    'lokasi' => 'Kecamatan ABC',
                    'tanggal_dan_waktu_kejadian' => '2023-10-10',
                    'bukti_pendukung' => 'foto_jalan_rusak.jpg',
                ],
            ],
            [
                'title' => 'Gangguan Suara Musik Malam Hari',
                'category' => 'Keluhan Sosial',
                'content' => [
                    'deskripsi' => 'Tetangga menyalakan musik dengan volume tinggi hingga dini hari.',
                    'lokasi' => 'Blok B Nomor 12',
                    'tanggal_dan_waktu_kejadian' => 'Setiap Malam Jumat',
                    'bukti_pendukung' => 'foto_jalan_rusak.jpg',
                ],
            ], ];
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

            // Insert
            DB::table('complaints')->insert([
                'user_id' => $users[$index]->id, // Mapping to unique user
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
