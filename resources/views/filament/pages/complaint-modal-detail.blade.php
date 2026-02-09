<div class="space-y-6 text-gray-200">
    {{-- Section Informasi Pengaduan (Identitas Pelapor) --}}
    <div class="p-4 bg-gray-900 border border-gray-800 rounded-xl">
        <h3 class="mb-4 text-xs font-bold text-gray-400 uppercase tracking-widest">Informasi Pengaduan</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
                <p class="text-gray-500">Pelapor</p>
                <p class="font-medium text-white">{{ $record->user->name }}</p>
            </div>
            <div>
                <p class="text-gray-500">Kategori</p>
                <span class="px-2 py-0.5 text-xs font-semibold bg-blue-900 text-blue-300 rounded-full">
                    {{ $record->category }}
                </span>
            </div>
            <div>
                <p class="text-gray-500">Status</p>
                <span
                    class="px-2 py-1 text-xs text-yellow-500 bg-yellow-900/50 border border-yellow-700 rounded-md uppercase">
                    {{ $record->status }}
                </span>
            </div>
            <div>
                <p class="text-gray-500">Waktu Laporan</p>
                <p class="font-medium text-white">{{ $record->created_at->format('d M Y, H:i') }}</p>
            </div>
        </div>
    </div>

    {{-- Section Data Terdekripsi --}}
    <div class="p-4 bg-gray-900 border border-gray-800 rounded-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest">Detail Laporan: {{ $record->title }}
            </h3>
            <span class="text-[10px] text-green-500 flex items-center gap-1">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                        d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z">
                    </path>
                </svg>
                Decrypted (AES-256)
            </span>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4 text-sm">
            @php
                $mainTextKeys = ['deskripsi', 'kronologi', 'keterangan_lainnya'];
                $content = $record->decrypted_content ?? [];
                // Kunci yang tidak ingin ditampilkan di loop atas (karena punya tempat khusus)
                $excludedKeys = array_merge($mainTextKeys, ['bukti_pendukung']); 
            @endphp

            {{-- 1. Generate Otomatis Field (Kecuali Deskripsi & Bukti) --}}
            @foreach($content as $key => $value)
                @if(!in_array($key, $excludedKeys))
                    <div>
                        <p class="text-gray-500 capitalize">{{ str_replace('_', ' ', $key) }}</p>
                        <p class="text-white font-medium">{{ $value ?? '-' }}</p>
                    </div>
                @endif
            @endforeach

            {{-- 2. Tampilan Bukti Pendukung (Mengambil file fake-news.png) --}}
            @if(isset($content['bukti_pendukung']))
                <div class="col-span-full mt-2">
                    <p class="text-gray-500 capitalize mb-2">📁 Bukti Pendukung</p>
                    <div class="p-2 bg-gray-800/30 border border-gray-700 rounded-lg inline-block">
                        {{-- Sesuai struktur folder Anda: storage/app/public/news/fake-news.png --}}
                        <a href="{{ asset('storage/news/fake-news.png') }}" target="_blank" class="group relative block">
                            <img src="{{ asset('storage/news/fake-news.png') }}"
                                class="max-w-xs rounded border border-gray-600 shadow-md group-hover:opacity-75 transition-all"
                                alt="Bukti Pengaduan">
                            <div
                                class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                <span class="bg-black/50 text-white px-2 py-1 rounded text-xs">Klik untuk memperbesar</span>
                            </div>
                        </a>
                    </div>
                </div>
            @endif

            {{-- 3. Description --}}
            @foreach($mainTextKeys as $textKey)
                @if(isset($content[$textKey]))
                    <div class="col-span-full mt-2">
                        <p class="text-gray-500 capitalize">📝 {{ str_replace('_', ' ', $textKey) }}</p>
                        <div class="p-3 mt-1 bg-gray-800/50 border border-gray-700 rounded-lg text-gray-200 leading-relaxed">
                            {{ $content[$textKey] }}
                        </div>
                    </div>
                @endif
            @endforeach
        </div>
    </div>
    {{-- Section Livewire Chat and Send Message--}}

    <div>
        <h3 class="mb-2 text-xs font-bold text-gray-400 uppercase">Percakapan</h3>
        @livewire('chat-complaint', ['recordId' => $record->id])
    </div>
</div>