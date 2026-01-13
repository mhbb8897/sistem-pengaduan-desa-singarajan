<?php

use App\Http\Controllers\Api\AuthController;
use App\Models\EncryptController;
use Illuminate\Support\Facades\Route;

Route::get('/get-public-key', [EncryptController::class, 'getPublicKey']);
Route::post('/loginuser', [AuthController::class, 'login']);
Route::get('/ping', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API terhubung',
    ]);
});
// EncryptionController.php
