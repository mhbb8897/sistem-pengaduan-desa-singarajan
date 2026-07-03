<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Handle login user dan return Bearer Token
     */
    public function login(Request $request): JsonResponse
    {
        // Validasi input
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|min:6',
        ]);

        // Cari user
        $user = User::where('email', $request->email)->first();

        // Cek password
        if (! $user || ! Hash::check($request->password, $user->password)) {

            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
                'errors' => [
                    'email' => [
                        'Kredensial yang diberikan tidak valid.',
                    ],
                ],
            ], 401);
        }

        // Optional cek user aktif
        if (
            isset($user->is_active)
            && ! $user->is_active
        ) {

            return response()->json([
                'success' => false,
                'message' => 'Akun Anda tidak aktif.',
            ], 403);
        }
        // Hapus token lama
        $user->tokens()->delete();
        // Generate HMAC key
        $user->hmac_session_key = bin2hex(random_bytes(32));
        $user->save();
        // Generate token baru
        $token = $user
            ->createToken('mobile')
            ->plainTextToken;

        // Response success
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',

            'data' => [

                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role ?? 'user',
                ],
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 3 * 60 * 60,
                'hmac_session_key' => $user->hmac_session_key,
            ],
        ], 200);
    }

    /**
     * Handle logout user
     */
    public function logout(Request $request): JsonResponse
    {
        // $request
        //     ->user()
        //     ->currentAccessToken()
        //     ->delete();

        $user = $request->user();

        $user->hmac_session_key = null;

        $user->save();

        $user->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ], 200);
    }
}
