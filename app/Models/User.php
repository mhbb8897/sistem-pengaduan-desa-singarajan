<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name', 'email', 'password'];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = ['password', 'remember_token'];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    protected static function booted()
    {
        static::created(function ($user) {
            // Hanya buat jika belum ada, dan tidak akan diupdate lagi
            UserSecureProfile::firstOrCreate(
                ['user_id' => $user->id], // Kriteria pencarian
                [
                    'rsa_public_key' => Str::upper(Str::random(4)),
                    'rsa_private_key' => Str::upper(Str::random(4)),
                    'aes_key' => Str::upper(Str::random(4)),
                    'hmac_signature' => Str::upper(Str::random(4)),
                    'iv' => Str::upper(Str::random(4)),
                ],
            );
        });
    }

    // Relation
    public function secureProfile()
    {
        return $this->hasOne(UserSecureProfile::class);
    }
}
