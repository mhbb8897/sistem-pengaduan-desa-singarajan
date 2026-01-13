<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json([
                'status' => false,
                'reason' => 'EMAIL_NOT_FOUND',
                'message' => 'Email tidak terdaftar',
            ], 404);
        }

        if (! Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => false,
                'reason' => 'WRONG_PASSWORD',
                'message' => 'Password salah',
            ], 401);
        }

        if ($user->role === 'admin') {
            return response()->json([
                'status' => false,
                'reason' => 'ROLE_BLOCKED',
                'message' => 'Admin tidak boleh login ke aplikasi mobile',
            ], 403);
        }

        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'user' => $user,
            'token' => $user->createToken('mobile')->plainTextToken,
        ]);
    }
}
