<?php

namespace App\Livewire;

use Livewire\Component;

class ChatComplaint extends Component
{
    public $recordId;

    public $message = '';

    // Gunakan Polling agar pesan baru dari sisi lain muncul otomatis
    // wire:poll.5s akan refresh komponen setiap 5 detik
    public function render()
    {
        $aduan = \App\Models\Complaint::with('messages')->find($this->recordId);

        return view('livewire.chat-complaint', [
            'messages' => $aduan->messages,
        ]);
    }

    public function sendMessage()
    {
        $this->validate(['message' => 'required']);

        \App\Models\ComplaintMessage::create([
            'complaint_id' => $this->recordId,
            'user_id' => auth()->id(),
            'message' => $this->message,
            'sender_role' => auth()->user()->hasRole('admin') ? 'admin' : 'user',
        ]);

        $this->message = ''; // Reset input
    }

    // public function render()
    // {
    //     return view('livewire.chat-complaint');
    // }
}
