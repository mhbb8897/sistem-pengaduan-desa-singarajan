<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserSecureProfile extends Model
{
    protected $fillable = ['user_id', 'encrypted_identity', 'encrypted_aes_key', 'hmac_signature', 'iv'];
    // Relation
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
