<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ComplaintSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('complaints')->insert([
            'user_id' => 2,
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
