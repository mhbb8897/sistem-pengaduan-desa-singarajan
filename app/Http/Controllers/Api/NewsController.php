<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class NewsController extends Controller
{
    // 📌 GET /api/news
    public function index()
    {
        return response()->json([
            'status' => true,
            'data' => News::latest()->get()
        ]);
    }

    // 📌 GET /api/news/{id}
    public function show($id)
    {
        $news = News::find($id);

        if (!$news) {
            return response()->json([
                'status' => false,
                'message' => 'Berita tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'data' => $news
        ]);
    }

    // 📌 POST /api/news
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required',
            'image' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $imagePath = $request->file('image')->store('news', 'public');

        $news = News::create([
            'title'   => $request->input('title'),
            'content' => $request->input('content'),
            'image' => $imagePath,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Berita berhasil ditambahkan',
            'data' => $news
        ], 201);
    }

    // 📌 PUT /api/news/{id}
    public function update(Request $request, $id)
    {
        $news = News::find($id);

        if (!$news) {
            return response()->json([
                'status' => false,
                'message' => 'Berita tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('image')) {
            Storage::disk('public')->delete($news->image);
            $news->image = $request->file('image')->store('news', 'public');
        }

        $news->update([
            'title'   => $request->input('title'),
            'content' => $request->input('content'),
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Berita berhasil diperbarui',
            'data' => $news
        ]);
    }

    // 📌 DELETE /api/news/{id}
    public function destroy($id)
    {
        $news = News::find($id);

        if (!$news) {
            return response()->json([
                'status' => false,
                'message' => 'Berita tidak ditemukan'
            ], 404);
        }

        Storage::disk('public')->delete($news->image);
        $news->delete();

        return response()->json([
            'status' => true,
            'message' => 'Berita berhasil dihapus'
        ]);
    }
}
