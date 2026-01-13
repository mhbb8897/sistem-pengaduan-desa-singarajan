<div class="space-y-6 text-gray-200">
    {{-- Section Informasi Pengaduan --}}
    <div class="p-4 bg-gray-900 border border-gray-800 rounded-xl">
        <h3 class="mb-4 text-xs font-bold text-gray-400 uppercase">Informasi Pengaduan</h3>
        <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
                <p class="text-gray-500">Judul</p>
                <p class="font-medium text-white">{{ $record->title }}</p>
            </div>
            <div>
                <p class="text-gray-500">Kategori</p>
                <p class="font-medium text-white">{{ $record->category }}</p>
            </div>
            <div>
                <p class="text-gray-500">Status</p>
                <span class="px-2 py-1 text-xs text-yellow-500 bg-yellow-900 rounded-md uppercase">{{ $record->status }}</span>
            </div>
            <div>
                <p class="text-gray-500">Created at</p>
                <p class="font-medium text-white">{{ $record->created_at->format('M d, Y H:i:s') }}</p>
            </div>
        </div>
    </div>

    {{-- Section Data Terdekripsi --}}
    <div class="p-4 bg-gray-900 border border-gray-800 rounded-xl">
        <h3 class="mb-1 text-xs font-bold text-gray-400 uppercase">Data Terdekripsi (AES + RSA)</h3>
        <p class="mb-4 text-[10px] text-gray-500 italic">Hanya admin yang dapat mendekripsi data ini.</p>
        <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
                <p class="text-gray-500">📍 Lokasi Kejadian</p>
                <p class="text-white">{{ $record->decrypted_content['lokasi'] ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">🕒 Waktu Kejadian</p>
                <p class="text-white">{{ $record->decrypted_content['waktu_kejadian'] ?? '-' }}</p>
            </div>
            <div class="col-span-2">
                <p class="text-gray-500">📝 Isi Pengaduan</p>
                <div class="p-3 mt-1 bg-gray-800 rounded-lg text-gray-300">
                    {{ $record->decrypted_content['deskripsi'] ?? 'Tidak ada deskripsi' }}
                </div>
            </div>
        </div>
    </div>

    {{-- Section Percakapan (Livewire) --}}
    <div>
        <h3 class="mb-2 text-xs font-bold text-gray-400 uppercase">Percakapan</h3>
        @livewire('chat-complaint', ['recordId' => $record->id])
    </div>
    
    <hr class="border-gray-800">
</div>