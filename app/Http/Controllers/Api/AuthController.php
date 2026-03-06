<?php

namespace App\Http\Controllers\Api; // ✅ Gunakan namespace Api

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller // ✅ Nama Controller lebih standar
{
    /**
     * Handle login user dan return Bearer Token
     */
    public function login(Request $request): JsonResponse
    {
        // 1️⃣ Validasi input
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|min:6',
        ]);

        // 2️⃣ Cari user
        $user = User::where('email', $request->email)->first();

        // 3️⃣ Cek password & status user
        if (! $user || ! Hash::check($request->password, $user->password)) {
            // ✅ Gunakan Response 401 (Unauthorized)
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
                'errors' => [
                    'email' => ['Kredensial yang diberikan tidak valid.'],
                ],
            ], 401);
        }

        // Optional: Cek jika user tidak aktif
        if (isset($user->is_active) && ! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak aktif. Hubungi administrator.',
            ], 403); // 403 Forbidden
        }

        // 4️⃣ Hapus token lama (opsional, untuk keamanan)
        // Mencegah satu user memiliki terlalu banyak token aktif
        $user->tokens()->delete();

        // 5️⃣ Buat token baru menggunakan Sanctum
        $token = $user->createToken('auth_token')->plainTextToken;

        // 6️⃣ Response success dengan data user & token
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role ?? 'user', // Tambahkan role jika ada
                ],
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 3 * 60 * 60, // Sanctum token tidak expire kecuali di-set manual
            ],
        ], 200);
    }

    /**
     * Handle logout user
     */
    public function logout(Request $request): JsonResponse
    {
        // Hapus token saat ini
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ], 200);
    }
}
