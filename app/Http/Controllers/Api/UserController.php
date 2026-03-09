<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException; // ✅ IMPORT INI HARUS ADA!

class UserController extends Controller
{
    // Request Register user
    public function registerUser(Request $request)
    {
        try {
            // ✅ Validasi Input
            $validator = Validator::make($request->all(), [
                'name' => [
                    'required',
                    'string',
                    'min:3',
                    'max:255',
                ],
                // ✅ EMAIL - rule email hanya untuk field email
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    'unique:users,email',
                ],

                'password' => [
                    'required',
                    'confirmed', // ✅ Memastikan password == password_confirmation
                    Password::min(6)
                        ->letters()
                        ->mixedCase()
                        ->numbers(),
                ],
                'password_confirmation' => 'required',
            ], [
                // ✅ Custom Error Messages (Opsional, agar lebih user-friendly)
                'name.required' => 'Nama wajib diisi',
                'name.min' => 'Nama minimal 3 karakter',
                'name.max' => 'Nama maksimal 255 karakter',
                'email.required' => 'Email wajib diisi',
                'email.email' => 'Format email tidak valid',
                'email.unique' => 'Email sudah terdaftar',
                'password.required' => 'Password wajib diisi',
                'password.confirmed' => 'Konfirmasi password tidak cocok',
                'password.min' => 'Password minimal 6 karakter',
                'password_confirmation.required' => 'Konfirmasi password wajib diisi',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // ✅ Buat User Baru
            $user = User::create([
                'name' => ucwords(strtolower(trim($request->name))), // Format: Huruf Kapital Di Setiap Kata
                'email' => strtolower(trim($request->email)),
                'password' => Hash::make($request->password),
                // ✅ Tambahkan field lain jika ada di tabel users:
                // 'name' => $request->name ?? '',
                // 'phone' => $request->phone ?? '',
            ]);

            // ✅ Response Sukses
            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil, silakan login',
                'data' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'created_at' => $user->created_at,
                ],
            ], 201);

        } catch (Exception$e) {
            // ✅ Log error untuk debugging (tidak expose ke client)
            \Log::error('Register Error: '.$e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server. Silakan coba lagi.',
            ], 500);
        }
    }

    /**
     * POST /api/user/editprofile
     * Update profile user: name, email, dan password
     */
    public function updateProfile(Request $request)
    {
        try {
            $user = Auth::user();

            // ✅ Validasi input (hanya name, email, password)
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    Rule::unique('users')->ignore($user->id),
                ],
                'password' => 'nullable|string|min:8|confirmed',
            ]);

            // ✅ Update data user
            $user->name = $validated['name'];
            $user->email = $validated['email'];

            // ✅ Handle password jika diisi
            if (! empty($validated['password'])) {
                $user->password = Hash::make($validated['password']);
            }

            $user->save();

            // ✅ Response dengan data terbaru (tanpa menampilkan password)
            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui profil: '.$e->getMessage(),
            ], 500);
        }
    }
}
