<?php

use App\Http\Controllers\Login;
use App\Models\EncryptController;
use Illuminate\Support\Facades\Route;

Route::get('/get-public-key', [EncryptController::class, 'getPublicKey']);
Route::post('/loginuser', [Login::class, 'login']);
Route::get('/ping', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API terhubung',
    ]);
});
