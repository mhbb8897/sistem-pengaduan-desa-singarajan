<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ComplaintController;
use App\Http\Controllers\Api\ComplaintMessageController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\UserController;
use App\Models\EncryptController;
use Illuminate\Support\Facades\Route;

// Route::get('/get-public-key', [EncryptController::class, 'getPublicKey']);
// Login
Route::post('/loginuser', [AuthController::class, 'login']);
Route::get('/ping', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API terhubung',
    ]);
});

// News API
Route::get('/news', [NewsController::class, 'index']);
Route::get('/news/{id}', [NewsController::class, 'show']);
Route::post('/news', [NewsController::class, 'store']);
// Register
Route::post('/user/registeruser', [UserController::class, 'registerUser']);
// Blok Testing
Route::get('/debug-raw-complaints', [ComplaintController::class, 'debugRawData']);
// Route Bebas Akses (Tanpa Login)
Route::get('/debug-decrypted-complaints', [ComplaintController::class, 'debugDecryptedData']);

Route::middleware(['auth:sanctum', 'hmac', 'blocking.superadminaccess',
])->group(function () {
    // ✅ Complaints
    Route::get('/complaint_data', [ComplaintController::class, 'index']); // List pengaduan user
    Route::post('/complaints', [ComplaintController::class, 'store']);    // Buat pengaduan baru
    Route::get('/complaints/{id}', [ComplaintController::class, 'show']); // Detail pengaduan
    // ✅ Complaint Messages (Chat)
    Route::get('/complaints/{id}/messages', [ComplaintMessageController::class, 'index']); // List chat
    Route::post('/complaints/{id}/messages', [ComplaintMessageController::class, 'store']); // Kirim pesan
    // Profile
    Route::post('/user/editprofile', [UserController::class, 'updateProfile']);
    // Edit Complaint
    Route::put('/complaints/{id}', [ComplaintController::class, 'update']);
});
