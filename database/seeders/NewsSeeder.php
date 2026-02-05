<?php

namespace Database\Seeders;

use App\Models\News;
use Illuminate\Database\Seeder;

class NewsSeeder extends Seeder
{
    public function run(): void
    {
        News::insert([
            [
                'title' => 'Gotong Royong Desa',
                'content' => 'Kegiatan gotong royong membersihkan lingkungan desa.',
                'image' => 'news/fake-news.png',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'Pembangunan Jalan Desa',
                'content' => 'Pembangunan jalan desa tahap kedua telah dimulai.',
                'image' => 'news/fake-news.png',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'Pelatihan UMKM',
                'content' => 'Pelatihan UMKM bagi warga desa untuk meningkatkan ekonomi.',
                'image' => 'news/fake-news.png',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
