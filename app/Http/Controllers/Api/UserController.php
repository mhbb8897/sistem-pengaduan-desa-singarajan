<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Log; // ✅ IMPORT INI HARUS ADA!

class UserController extends Controller
{
    // Request Register user
    public function registerUser(Request $request)
    {
        try {
            // 1. LOG DATA MASUK (Password disembunyikan demi keamanan)
            Log::info('===== REGISTER USER REQUEST =====');
            Log::info('Data Payload:', $request->except(['password', 'password_confirmation']));

            // ✅ Validasi Input
            $validator = Validator::make($request->all(), [
                'name' => [
                    'required',
                    'string',
                    'min:3',
                    'max:255',
                ],
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    'unique:users,email',
                ],
                'password' => [
                    'required',
                    'confirmed',
                    Password::min(8)
                        ->letters()
                        ->mixedCase()
                        ->numbers(),
                ],
                'password_confirmation' => 'required',
            ], [
                // ✅ Custom Error Messages
                'name.required' => 'Nama wajib diisi',
                'name.min' => 'Nama minimal 3 karakter',
                'name.max' => 'Nama maksimal 255 karakter',
                'email.required' => 'Email wajib diisi',
                'email.email' => 'Format email tidak valid',
                'email.unique' => 'Email sudah terdaftar',
                'password.required' => 'Password wajib diisi',
                'password.confirmed' => 'Konfirmasi password tidak cocok',
                'password.min' => 'Password minimal 8 karakter',
                'password_confirmation.required' => 'Konfirmasi password wajib diisi',
            ]);

            if ($validator->fails()) {
                // 2. LOG ERROR VALIDASI (Untuk melihat aturan mana yang gagal)
                Log::warning('REGISTER VALIDATION FAILED:', $validator->errors()->toArray());

                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // ✅ Buat User Baru
            $user = User::create([
                'name' => ucwords(strtolower(trim($request->name))),
                'email' => strtolower(trim($request->email)),
                'password' => Hash::make($request->password),
            ]);

            // 3. LOG SUKSES
            Log::info('REGISTER SUCCESS:', ['user_id' => $user->id, 'email' => $user->email]);

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

        } catch (Exception $e) {
            // ✅ Log error untuk debugging internal server
            Log::error('REGISTER ERROR: '.$e->getMessage());
            Log::error('Stack Trace: '.$e->getTraceAsString());

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
            Log::info('===== UPDATE PROFILE =====');
            Log::info('Request', $request->all());

            $user = Auth::user();

            if (! $user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan.',
                ], 401);
            }

            /*
            |--------------------------------------------------------------------------
            | 1. KUMPULKAN ATURAN VALIDASI SECARA DINAMIS
            |--------------------------------------------------------------------------
            */
            $rules = [];

            if ($request->filled('name')) {
                $rules['name'] = 'string|max:255';
            }

            if ($request->filled('email')) {
                // Validasi format email & cek unik kecuali untuk user ini sendiri
                $rules['email'] = 'email|max:255|unique:users,email,'.$user->id;
            }

            if ($request->filled('password')) {
                $rules['current_password'] = 'required';
                $rules['password'] = [
                    'required',
                    'confirmed',
                    Password::min(8)
                        ->letters()
                        ->mixedCase()
                        ->numbers(),
                ];
            }

            // Jika tidak ada data apapun yang dikirim untuk diupdate
            if (empty($rules)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak ada data yang dikirim untuk diperbarui.',
                ], 400);
            }

            // Eksekusi validasi sekaligus (mengumpulkan semua error jika ada)
            $request->validate($rules);

            /*
            |--------------------------------------------------------------------------
            | 2. PROSES UPDATE DATA
            |--------------------------------------------------------------------------
            */
            $isChanged = false;

            if ($request->filled('name')) {
                $user->name = trim($request->name);
                $isChanged = true;
            }

            if ($request->filled('email')) {
                $newEmail = strtolower(trim($request->email));
                if ($newEmail !== $user->email) {
                    $user->email = $newEmail;
                    $isChanged = true;
                }
            }

            if ($request->filled('password')) {
                // Cek kecocokan password lama
                if (! Hash::check($request->current_password, $user->password)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Password lama salah.',
                    ], 422);
                }

                $user->password = Hash::make($request->password);
                $isChanged = true;
            }

            /*
            |--------------------------------------------------------------------------
            | 3. SIMPAN PERUBAHAN
            |--------------------------------------------------------------------------
            */
            if ($isChanged) {
                $user->save();
                Log::info('UPDATE PROFILE BERHASIL', ['user_id' => $user->id]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui.',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);

        } catch (Exception $e) {
            Log::error('UPDATE PROFILE ERROR: '.$e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server.',
            ], 500);
        }
    }
}
