<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;

class ComplaintSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::where('email', 'user@system.test')->first();

        if (!$user) {
            throw new \Exception('User pengadu tidak ditemukan');
        }

        DB::table('complaints')->insert([
            'user_id' => $user->id,
            'encrypted_content' => 'encrypted_complaint_content',
            'encrypted_aes_key' => 'encrypted_complaint_key',
            'hmac_signature' => 'hmac_complaint',
            'iv' => 'iv_complaint',
            'category' => 'Pelayanan',
            'status' => 'diajukan',
            'created_at' => now()
        ]);
    }
}
