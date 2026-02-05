<?php

use App\Http\Controllers\Login;
use App\Models\EncryptController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\NewsController;

Route::get('/get-public-key', [EncryptController::class, 'getPublicKey']);
Route::post('/loginuser', [Login::class, 'login']);
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
Route::put('/news/{id}', [NewsController::class, 'update']);
Route::delete('/news/{id}', [NewsController::class, 'destroy']);
