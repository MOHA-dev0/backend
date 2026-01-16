<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class Chat extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static string $view = 'filament.pages.chat';
    protected static ?string $navigationLabel = 'الدعم الفني';
    protected static ?string $title = 'الدعم الفني';
    protected static ?string $navigationGroup = 'الدعم';

    public $selectedUserId = null;
    public $messageInput = '';

    public function mount()
    {
        // Auto-select first user if available
        $firstUser = \App\Models\User::has('messages')->first();
        if ($firstUser) {
            $this->selectedUserId = $firstUser->id;
        }
    }

    public function getListeners()
    {
        return ['refreshComponent' => '$refresh'];
    }

    public function refreshComponent()
    {
        $this->dispatch('$refresh');
    }

    public function getUsersProperty()
    {
        // Get users who have messages, ordered by latest message
        return \App\Models\User::whereHas('messages')
            ->with([
                'messages' => function ($q) {
                    $q->latest()->limit(1);
                }
            ])
            ->get()
            ->sortByDesc(function ($user) {
                return $user->messages->first()?->created_at;
            });
    }

    public function getSelectedUserProperty()
    {
        return $this->selectedUserId
            ? \App\Models\User::find($this->selectedUserId)
            : null;
    }

    public function getMessagesProperty()
    {
        if (!$this->selectedUserId)
            return [];

        return \App\Models\Message::where('user_id', $this->selectedUserId)
            ->with('user')
            ->orderBy('created_at', 'asc')
            ->get();
    }

    public function selectUser($userId)
    {
        $this->selectedUserId = $userId;
    }

    public function sendMessage()
    {
        if (!$this->selectedUserId || empty(trim($this->messageInput)))
            return;

        \App\Models\Message::create([
            'user_id' => $this->selectedUserId,
            'message' => $this->messageInput,
            'is_admin' => true,
            'is_read' => false,
        ]);

        $this->messageInput = '';
    }
}
