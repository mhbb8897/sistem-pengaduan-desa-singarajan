<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;

class NewsController extends Controller
{
    // 📌 GET /api/news
    public function index()
    {
        return response()->json([
            'status' => true,
            'data' => News::latest()->get()->map(function ($news) {
                return [
                    'id' => $news->id,
                    'title' => $news->title,
                    'content' => $news->content,
                    'image_url' => asset(
                        'storage/'.str_replace('\\', '/', $news->image)
                    ),
                    'created_at' => $news->created_at,
                ];
            }),
        ], 200);
    }
}
