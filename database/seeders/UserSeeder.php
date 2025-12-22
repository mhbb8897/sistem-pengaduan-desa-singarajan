<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('users')->insert([
            [
                'name' => 'Admin Sistem',
                'email' => 'admin@example.com',
                'password' => Hash::make('password'),
                'encrypted_identity' => 'encrypted_identity_admin',
                'encrypted_aes_key' => 'encrypted_key_admin',
                'hmac_signature' => 'hmac_admin',
                'iv' => 'iv_admin',
                'role' => 'admin',
                'created_at' => now()
            ],
            [
                'name' => 'User Pengadu',
                'email' => 'user@sexample.com',
                'password' => Hash::make('password'),
                'encrypted_identity' => 'encrypted_identity_user',
                'encrypted_aes_key' => 'encrypted_key_user',
                'hmac_signature' => 'hmac_user',
                'iv' => 'iv_user',
                'role' => 'user',
                'created_at' => now()
            ]
        ]);
    }
}
