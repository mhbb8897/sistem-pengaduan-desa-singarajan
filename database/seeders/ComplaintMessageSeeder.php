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
        $user = User::first();
        $admin = User::skip(1)->first() ?? $user;

        if (! $complaint) {
            return;
        }

        // Pesan dari user
        ComplaintMessage::create([
            'complaint_id' => $complaint->id,
            'user_id' => $user->id,
            'sender_role' => 'user',
            'message' => 'Saya ingin menanyakan tindak lanjut dari pengaduan ini.',
        ]);

        // Balasan dari admin
        ComplaintMessage::create([
            'complaint_id' => $complaint->id,
            'user_id' => $admin->id,
            'sender_role' => 'admin',
            'message' => 'Pengaduan sedang kami proses, mohon menunggu.',
        ]);
    }
}
