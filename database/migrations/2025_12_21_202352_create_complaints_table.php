<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Metadata (Plaintext untuk Query & Filter)
            $table->string('title'); 
            $table->string('category'); // Fasilitas, Pelanggaran HAM, dll
            $table->enum('status', ['diajukan', 'diproses', 'selesai'])->default('diajukan');

            // Data Keamanan (Encrypted)
            $table->longText('encrypted_content'); // Payload JSON terenkripsi AES
            $table->text('encrypted_aes_key');    // Kunci AES terenkripsi RSA
            $table->string('iv');                  // IV untuk AES

            // Data Tambahan
            $table->string('attachment_path')->nullable(); 
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};