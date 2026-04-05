<div class="space-y-6">
    {{-- Section Informasi Pengaduan --}}
    <x-filament::section>
        <x-slot name="heading">
            {{ __('Informasi Pengaduan') }}
        </x-slot>

        <div class="grid grid-cols-1 gap-4 text-sm md:grid-cols-2">
            {{-- Info Item Reusable --}}
            @php
$infoItems = [
    ['label' => 'Pelapor', 'value' => $record->user->name, 'type' => 'text'],
    ['label' => 'Kategori', 'value' => $record->category, 'type' => 'badge', 'color' => 'gray'],
    ['label' => 'Status', 'value' => $record->status, 'type' => 'badge', 'color' => 'warning'],
    ['label' => 'Waktu Laporan', 'value' => $record->created_at->format('d M Y, H:i'), 'type' => 'text'],
];
            @endphp

            @foreach($infoItems as $item)
                <div>
                    <p class="text-sm text-gray-500 dark:text-gray-400">{{ $item['label'] }}</p>
                    @if($item['type'] === 'badge')
                        <x-filament::badge :color="$item['color']" class="w-fit">
                            {{ $item['value'] }}
                        </x-filament::badge>
                    @else
                        <p class="font-medium text-gray-950 dark:text-white">{{ $item['value'] }}</p>
                    @endif
                </div>
            @endforeach
        </div>
    </x-filament::section>

    {{-- Section Data Terdekripsi --}}
    <div class="p-6 rounded-xl border border-gray-200 dark:border-white/10 bg-white dark:bg-gray-900 shadow-sm">
        <div class="flex items-center justify-between mb-6 pb-4 border-b border-gray-100 dark:border-white/5">
            <h3 class="text-sm font-bold text-gray-950 dark:text-white uppercase tracking-wider">
                Detail Laporan: {{ $record->title }}
            </h3>
            <x-filament::badge color="success" icon="heroicon-m-lock-open" size="sm">
                Decrypted (AES-256)
            </x-filament::badge>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 text-sm">
            @php
$content = $record->decrypted_content ?? [];
$mainTextKeys = ['deskripsi', 'kronologi', 'keterangan_lainnya'];
$excludedKeys = array_merge($mainTextKeys, ['bukti_pendukung']);
            @endphp

            {{-- Metadata Fields --}}
            @foreach($content as $key => $value)
                @if(!in_array($key, $excludedKeys))
                    <div class="space-y-1">
                        <p class="text-xs font-semibold text-gray-500 uppercase">{{ str_replace('_', ' ', $key) }}</p>
                        <p class="text-gray-950 dark:text-gray-200">{{ $value ?? '-' }}</p>
                    </div>
                @endif
            @endforeach

            {{-- Bukti Pendukung --}}
            @if(isset($content['bukti_pendukung']) && $content['bukti_pendukung'])
                <div class="col-span-full pt-4">
                    <p class="text-xs font-semibold text-gray-500 uppercase mb-3">📁 Bukti Pendukung</p>

                    @php
                        // Pecah string menjadi array berdasarkan koma dan spasi
                        $files = explode(', ', $content['bukti_pendukung']);
                    @endphp

                    <div class="flex flex-wrap gap-4">
                        @foreach($files as $file)
                            @php $fileName = trim($file); @endphp
                            <div
                                class="group relative inline-block p-1 bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg shadow-sm overflow-hidden">
                                <a href="{{ asset('storage/record/' . $fileName) }}" target="_blank"
                                    class="block overflow-hidden rounded-md">

                                    {{-- Menampilkan Image Preview --}}
                                    <img src="{{ asset('storage/record/' . $fileName) }}"
                                        class="h-32 w-auto object-cover transition duration-300 group-hover:scale-110" alt="Bukti Pengaduan"
                                        onerror="this.src='{{ asset('images/placeholder-error.png') }}';">

                                    {{-- Overlay saat hover --}}
                                    <div
                                        class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                        <x-filament::icon icon="heroicon-m-magnifying-glass-plus" class="w-6 h-6 text-white" />
                                    </div>
                                </a>

                                {{-- Nama file (Opsional, kecil di bawah) --}}
                                <p class="text-[10px] text-gray-400 mt-1 max-w-[120px] truncate px-1">
                                    {{ $fileName }}
                                </p>
                            </div>
                        @endforeach
                    </div>
            </div>  @endif

            {{-- Long Text Fields --}}
            @foreach($mainTextKeys as $textKey)
                @if(isset($content[$textKey]))
                    <div class="col-span-full pt-4">
                        <p class="text-xs font-semibold text-gray-500 uppercase mb-2">📝 {{ str_replace('_', ' ', $textKey) }}
                        </p>
                        <div
                            class="p-4 rounded-lg bg-gray-50 dark:bg-white/5 text-gray-800 dark:text-gray-300 ring-1 ring-gray-200 dark:ring-white/10">
                            {{ $content[$textKey] }}
                        </div>
                    </div>
                @endif
            @endforeach
        </div>
    </div>

    {{-- Section Chat --}}
    <div class="space-y-4">
        <h3 class="text-sm font-bold text-primary-600 dark:text-primary-400 uppercase tracking-tight">
            {{ __('Percakapan') }}
        </h3>
        <div class="p-1">
            @livewire('chat-complaint', ['recordId' => $record->id])
        </div>
    </div>
</div>