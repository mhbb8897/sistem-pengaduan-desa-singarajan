<?php
use Illuminate\Support\Facades\Route;

Route::get('/get-public-key', [EncryptionController::class, 'getPublicKey']);

// EncryptionController.php
