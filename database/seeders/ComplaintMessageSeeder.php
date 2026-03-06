<?php

namespace Database\Seeders;

use App\Models\Complaint;
use App\Models\ComplaintMessage;
use App\Models\User;
use Illuminate\Database\Seeder;

class ComplaintMessageSeeder extends Seeder
{
    public function run(): void
    {
        $complaint = Complaint::first();
        $user = User::whereDoesntHave('roles', function ($query) {
            $query->where('name', 'super_admin');
        })->first() ?? User::first();

        // 3. Ambil Super Admin menggunakan scope dari Spatie/Shield
        // Nama role default Filament Shield adalah 'super_admin'
        $admin = User::role('super_admin')->first();

        // Jika tidak ada super_admin, fallback ke user pertama

        if (! $complaint) {
            return;
        }

        // Pesan dari user
        ComplaintMessage::create([
            'complaint_id' => $complaint->id,
            'user_id' => $user->id,
            'message' => 'Saya ingin menanyakan tindak lanjut dari pengaduan ini.',
        ]);

        // Balasan dari admin
        ComplaintMessage::create([
            'complaint_id' => $complaint->id,
            'user_id' => $admin->id,
            'message' => 'Pengaduan sedang kami proses, mohon menunggu.',
        ]);
    }
}
