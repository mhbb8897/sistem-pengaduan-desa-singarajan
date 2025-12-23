<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_secure_profiles', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('encrypted_identity', 10)->nullable(false)->unique();
            $table->string('encrypted_aes_key', 10)->nullable(false)->unique();
            $table->string('hmac_signature', 10)->nullable(false)->unique();
            $table->string('iv', 10)->nullable(false)->unique();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_secure_profiles');
    }
};
