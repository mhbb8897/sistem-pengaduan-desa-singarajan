<div class="space-y-4" wire:poll.5s>
    {{-- List Percakapan --}}
    <div class="max-h-64 overflow-y-auto space-y-3 p-2 bg-gray-900 rounded-lg">
        @foreach($messages as $msg)
            @php
                // Logika pengecekan role super_admin untuk styling
                $isAdmin = $msg->user->hasRole('super_admin');
            @endphp
            <div wire:key="msg-{{ $msg->id }}"
                class="p-3 rounded-lg {{ $isAdmin ? 'bg-gray-800 border-l-4 border-yellow-500' : 'bg-gray-700' }}">

                <div class="flex justify-between items-center mb-1">
                    <div class="flex items-center gap-2">
                        {{-- MENAMPILKAN NAMA USER ASLI --}}
                        <span class="text-xs font-bold uppercase {{ $isAdmin ? 'text-yellow-500' : 'text-blue-400' }}">
                            {{ $msg->user->name }}
                        </span>

                        {{-- Label Role Badge --}}
                        <span
                            class="text-[9px] px-1.5 py-0.5 rounded border {{ $isAdmin ? 'border-yellow-700 text-yellow-600' : 'border-blue-700 text-blue-500' }}">
                            {{ $isAdmin ? 'PETUGAS' : 'PELAPOR' }}
                        </span>
                    </div>
                    <span class="text-[10px] text-gray-400">{{ $msg->created_at->diffForHumans() }}</span>
                </div>

                <p class="text-sm text-gray-200">{{ $msg->message }}</p>
            </div>
        @endforeach
    </div>

    {{-- Form Balas --}}
    {{-- Menggunakan wire:submit.prevent agar menekan ENTER juga bisa mengirim pesan tanpa menutup modal --}}
    <form wire:submit.prevent="sendMessage" class="flex gap-2">
        <input type="text" wire:model="message" placeholder="Tulis balasan..."
            class="flex-1 rounded-lg text-sm bg-gray-800 text-white placeholder-gray-400 border-gray-700 focus:ring-yellow-500 focus:border-yellow-500">

        <button type="submit"
            class="px-4 py-2 bg-yellow-600 hover:bg-yellow-500 text-white rounded-lg text-sm font-bold border-none transition-colors">
            Kirim
        </button>
    </form>
</div>