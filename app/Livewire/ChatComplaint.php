<?php

namespace App\Livewire;

use App\Models\Complaint;
use App\Models\ComplaintMessage;
use Livewire\Component;

class ChatComplaint extends Component
{
    public $recordId;

    public $message = '';

    // Gunakan Polling agar pesan baru dari sisi lain muncul otomatis
    public function render()
    {
        $aduan = Complaint::with('messages')->find($this->recordId);

        return view('livewire.chat-complaint', [
            'messages' => $aduan->messages,
        ]);
    }

    public function sendMessage()
    {
        $this->validate(['message' => 'required']);

        ComplaintMessage::create([
            'complaint_id' => $this->recordId,
            'user_id' => auth()->id(),
            'message' => $this->message,
            'sender_role' => auth()->user()->hasRole('super_admin') ? 'super_admin' : 'user',
        ]);

        $this->message = ''; // Reset input
    }
}
