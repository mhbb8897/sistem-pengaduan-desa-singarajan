<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserSecureProfile extends Model
{
    protected $primaryKey = 'user_id';
    protected $fillable = ['user_id', 'rsa_public_key', 'rsa_private_key', 'aes_key', 'hmac_signature', 'iv'];
    // Beritahu Laravel bahwa Primary Key ini tidak auto-increment
    public $incrementing = false;
    // Relation
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
