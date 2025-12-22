<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('email', 100)->unique();
            $table->string('password', 255);

            $table->text('encrypted_identity');
            $table->text('encrypted_aes_key');
            $table->string('hmac_signature', 255);
            $table->string('iv', 64);

            $table->enum('role', ['admin', 'user'])->default('user');
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('last_login')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
