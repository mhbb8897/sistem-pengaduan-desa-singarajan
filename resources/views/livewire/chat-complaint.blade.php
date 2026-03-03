<div class="space-y-4 max-w-full" wire:poll.5s>
    {{-- List Percakapan --}}
    <div
        class="max-h-80 max-w-full overflow-y-auto space-y-4 p-4 rounded-xl border border-gray-200 dark:border-white/10 bg-gray-50 dark:bg-white/5">
        @forelse($messages as $msg)
                    @php
    $isAdmin = $msg->user->hasRole('super_admin');
                    @endphp

                    <div wire:key="msg-{{ $msg->id }}" class="flex-1 flex-row items-start max-w-full">

                        <div @class([
        'max-w-full rounded-2xl px-4 py-3 shadow-sm text-sm',
        'bg-white dark:bg-gray-800 border-l-4 border-primary-500' => $isAdmin,
        'bg-primary-600 text-white rounded-tr-none' => !$isAdmin,
    ])>
                            <div class="flex items-center gap-2 mb-1">
                                <span @class([
        'text-xs font-bold uppercase tracking-wide',
        'text-primary-600 dark:text-primary-400' => $isAdmin,
        'text-primary-100' => !$isAdmin,
    ])>
                                    {{ $msg->user->name }}
                                </span>

                                <x-filament::badge :color="$isAdmin ? 'primary' : 'gray'" size="xs">
                                    {{ $isAdmin ? 'PETUGAS' : 'PELAPOR' }}
                                </x-filament::badge>
                            </div>

                            <p @class([
        'leading-relaxed',
        'text-gray-900 dark:text-gray-200' => $isAdmin,
        'text-white' => !$isAdmin,
    ])>
                                {{ $msg->message }}
                            </p>

                            <div @class([
        'mt-2 text-[10px]',
        'text-gray-500' => $isAdmin,
        'text-primary-200' => !$isAdmin,
    ])>
                                {{ $msg->created_at->diffForHumans() }}
                            </div>
                        </div>
                    </div>
        @empty
            <div class="text-center py-4 text-gray-500 text-sm italic">
                Belum ada percakapan.
            </div>
        @endforelse
    </div>

    {{-- Input Area --}}
        {{-- Form Input (Gunakan tombol full yang tadi) --}}
        <form wire:submit.prevent="sendMessage">
            <x-filament::input.wrapper class="overflow-hidden">
                <x-filament::input type="text" wire:model="message" placeholder="Tulis balasan..." required
                    class="border-none shadow-none focus:ring-0" />
                <x-slot name="suffix" class="!p-0">
                    <div class="h-full flex items-stretch">
                        <x-filament::button type="submit" color="warning"
                            class="!h-auto self-stretch rounded-none !border-0 px-6">
                            Kirim
                        </x-filament::button>
                    </div>
                </x-slot>
            </x-filament::input.wrapper>
        </form>
</div>