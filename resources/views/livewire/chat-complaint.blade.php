<div class="space-y-4" wire:poll.5s>
    {{-- List Percakapan --}}
    <div class="max-h-64 overflow-y-auto space-y-3 p-2 bg-gray-900 rounded-lg">
        @foreach($messages as $msg)
            <div
                class="p-3 rounded-lg {{ $msg->sender_role === 'admin' ? 'bg-gray-800 border-l-4 border-yellow-500' : 'bg-gray-700' }}">
                <div class="flex justify-between items-center mb-1">
                    <span class="text-xs font-bold uppercase text-yellow-500">{{ $msg->sender_role }}</span>
                    <span class="text-[10px] text-gray-400">{{ $msg->created_at->diffForHumans() }}</span>
                </div>
                <p class="text-sm text-gray-200">{{ $msg->message }}</p>
            </div>
        @endforeach
    </div>

    {{-- Form Balas --}}
    <div class="flex gap-2">
        <input type="text" wire:model.defer="message" placeholder="Tulis balasan..." class="flex-1 rounded-lg text-sm
                       bg-gray-800 text-white
                       placeholder-gray-400
                       focus:ring-yellow-500 focus:border-yellow-500">
        <button wire:click="sendMessage" class="px-4 py-2 bg-yellow-600 hover:bg-yellow-500
                       text-white rounded-lg text-sm font-bold">
            Kirim
        </button>
    </div>
</div>