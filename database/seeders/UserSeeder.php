<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\UserSecureProfile;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Buat role jika belum ada
        $roles = ['super_admin', 'user'];
        foreach ($roles as $role) {
            Role::firstOrCreate(['name' => $role]);
        }

        // Helper untuk create user
        $createUser = function ($name, $email, $role) {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make('password'),
                'created_at' => now(), // default password
            ]);
            $user->assignRole($role);
            // UserSecureProfile::create([
            //     'user_id' => $user->id,
            //     'encrypted_identity' => Str::upper(Str::random(4)),
            //     'encrypted_aes_key' => Str::upper(Str::random(4)),
            //     'hmac_signature' => Str::upper(Str::random(4)),
            //     'iv' => Str::upper(Str::random(4)),
            // ]);
        };
        $createUser('User 1', 'user1@example.com', 'user');
        $createUser('User 2', 'user2@example.com', 'user');
    }
}
