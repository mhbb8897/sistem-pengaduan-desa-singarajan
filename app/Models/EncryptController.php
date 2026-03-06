<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EncryptController extends Model
{
    public function getPublicKey()
    {
        return response()->json([
            'public_key' => file_get_contents(storage_path('app/public.pem')),
        ]);
    }
}
