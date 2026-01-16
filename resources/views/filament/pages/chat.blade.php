<x-filament-panels::page>
    <div class="flex gap-6 h-[calc(100vh-12rem)] min-h-[600px] overflow-hidden rounded-[2rem] bg-white dark:bg-[#0f1013] shadow-2xl ring-1 ring-gray-950/5 dark:ring-white/5" wire:poll.3s="refreshComponent" dir="rtl">
        
        {{-- Sidebar --}}
        <div class="w-80 flex flex-col border-l border-gray-100 dark:border-white/5 bg-gray-50/50 dark:bg-white/[0.02]">
            {{-- Header --}}
            <div class="px-6 py-5 flex items-center justify-between">
                <div>
                    <h2 class="text-xl font-bold bg-gradient-to-l from-blue-600 to-indigo-500 bg-clip-text text-transparent">المحادثات</h2>
                    <p class="text-[11px] font-medium text-gray-400 mt-1 uppercase tracking-wider">الرسائل الواردة</p>
                </div>
                <div class="p-2 bg-blue-50 dark:bg-white/5 rounded-xl">
                    <x-heroicon-o-chat-bubble-left-right class="w-5 h-5 text-blue-600 dark:text-blue-400" />
                </div>
            </div>

            {{-- Search Placeholder (Visual Only) --}}
            <div class="px-5 mb-4">
                <div class="h-10 bg-white dark:bg-white/5 rounded-xl border border-gray-100 dark:border-white/5 flex items-center px-3 gap-2">
                    <x-heroicon-o-magnifying-glass class="w-4 h-4 text-gray-400" />
                    <span class="text-xs text-gray-400">بحث عن طالب...</span>
                </div>
            </div>
            
            {{-- Users List --}}
            <div class="flex-1 overflow-y-auto px-3 pb-4 space-y-1 [&::-webkit-scrollbar]:w-1 [&::-webkit-scrollbar-thumb]:bg-gray-200 dark:[&::-webkit-scrollbar-thumb]:bg-white/10 [&::-webkit-scrollbar-thumb]:rounded-full">
                @forelse($this->users as $user)
                <button 
                    wire:click="selectUser({{ $user->id }})"
                    class="w-full text-right p-3 rounded-2xl transition-all duration-300 group relative overflow-hidden {{ $selectedUserId == $user->id ? 'bg-white dark:bg-white/10 shadow-lg shadow-gray-200/50 dark:shadow-none ring-1 ring-gray-200 dark:ring-white/10' : 'hover:bg-white/60 dark:hover:bg-white/5' }}"
                >
                    <div class="flex items-start gap-3 relative z-10">
                        {{-- Avatar --}}
                        <div class="relative shrink-0">
                            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 p-[2px]">
                                <div class="w-full h-full rounded-full bg-white dark:bg-gray-900 flex items-center justify-center">
                                    <span class="font-bold text-sm text-gray-700 dark:text-gray-200">{{ substr($user->name, 0, 1) }}</span>
                                </div>
                            </div>
                        </div>

                        {{-- Text --}}
                        <div class="flex-1 min-w-0 pt-0.5">
                            <div class="flex items-center justify-between mb-0.5">
                                <h4 class="text-sm font-bold text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">{{ $user->name }}</h4>
                                <span class="text-[10px] text-gray-400">{{ $user->messages->first()?->created_at->format('H:i') }}</span>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 truncate opacity-80 font-medium">
                                {{ $user->messages->first()?->message }}
                            </p>
                        </div>
                    </div>
                </button>
                @empty
                    <div class="flex flex-col items-center justify-center py-10 text-gray-400">
                        <x-heroicon-o-inbox class="w-12 h-12 mb-3 opacity-20" />
                        <span class="text-xs">لا توجد محادثات</span>
                    </div>
                @endforelse
            </div>
        </div>

        {{-- Chat Area --}}
        <div class="flex-1 flex flex-col bg-white/50 dark:bg-[#0f1013] relative">
            @if($this->selectedUser)
                {{-- Header --}}
                <div class="px-6 py-4 flex items-center justify-between border-b border-gray-100 dark:border-white/5 bg-white/80 dark:bg-[#0f1013]/90 backdrop-blur-xl absolute top-0 left-0 right-0 z-20">
                    <div class="flex items-center gap-4">
                        <div class="flex -space-x-2 space-x-reverse overflow-hidden">
                            <div class="w-10 h-10 rounded-full ring-2 ring-white dark:ring-gray-900 bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                                <span class="font-bold text-gray-600 dark:text-gray-300">{{ substr($this->selectedUser->name, 0, 1) }}</span>
                            </div>
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-900 dark:text-white text-base">{{ $this->selectedUser->name }}</h3>
                            <div class="flex items-center gap-1.5">
                                <span class="relative flex h-2 w-2">
                                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                                  <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                                </span>
                                <span class="text-xs text-gray-500 font-medium tracking-wide">متصل الآن</span>
                            </div>
                        </div>
                    </div>
                    
                    <button wire:click="$set('selectedUserId', null)" class="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-full transition-colors">
                        <x-heroicon-o-x-mark class="w-6 h-6" />
                    </button>
                </div>

                {{-- Messages --}}
                <div class="flex-1 overflow-y-auto p-6 pt-24 space-y-6 [&::-webkit-scrollbar]:w-1.5 [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-thumb]:bg-gray-200 dark:[&::-webkit-scrollbar-thumb]:bg-white/10 [&::-webkit-scrollbar-thumb]:rounded-full">
                    <div class="flex justify-center mb-8">
                        <span class="px-3 py-1 bg-gray-100 dark:bg-white/5 rounded-full text-[10px] font-bold text-gray-400 dark:text-gray-500 tracking-widest text-center shadow-inner">
                            {{ today()->format('d M Y') }} - بداية المحادثة
                        </span>
                    </div>

                    @foreach($this->messages as $msg)
                        <div class="group flex w-full {{ $msg->is_admin ? 'justify-end' : 'justify-start' }} animate-in fade-in slide-in-from-bottom-2 duration-300">
                            <div class="max-w-[70%] relative flex gap-2 {{ $msg->is_admin ? 'flex-row-reverse' : 'flex-row' }}">
                                {{-- Avatar Mini --}}
                                <div class="shrink-0 w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center self-end mb-1 shadow-sm">
                                    @if($msg->is_admin)
                                        <x-heroicon-m-user class="w-4 h-4 text-blue-500" />
                                    @else
                                        <span class="text-xs font-bold text-gray-500">{{ substr($msg->user->name, 0, 1) }}</span>
                                    @endif
                                </div>
                                
                                <div class="flex flex-col {{ $msg->is_admin ? 'items-end' : 'items-start' }}">
                                    <div class="px-5 py-3 shadow-md text-sm leading-relaxed
                                        {{ $msg->is_admin 
                                            ? 'bg-gradient-to-br from-blue-600 to-indigo-600 text-white rounded-2xl rounded-bl-none shadow-blue-500/20' 
                                            : 'bg-white dark:bg-[#1a1c21] text-gray-800 dark:text-gray-200 border border-gray-100 dark:border-white/5 rounded-2xl rounded-br-none' 
                                        }}">
                                        {{ $msg->message }}
                                    </div>
                                    <span class="text-[10px] bg-transparent text-gray-400 font-medium mt-1 px-1">
                                        {{ $msg->created_at->format('h:i A') }}
                                        @if($msg->is_admin) • <span class="text-blue-500">تم الإرسال</span> @endif
                                    </span>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>

                {{-- Input Area --}}
                <div class="p-4 bg-white dark:bg-[#0f1013] border-t border-gray-100 dark:border-white/5 relative z-20">
                    <form wire:submit.prevent="sendMessage" class="relative max-w-4xl mx-auto">
                        <div class="relative bg-gray-50 dark:bg-[#15171b] rounded-[24px] border border-gray-100 dark:border-gray-800 focus-within:ring-2 focus-within:ring-blue-500/20 focus-within:border-blue-500/50 transition-all shadow-sm flex items-end p-1.5 gap-2">
                            
                            {{-- Textarea --}}
                            <textarea 
                                wire:model.defer="messageInput"
                                placeholder="اكتب رسالتك..." 
                                class="flex-1 bg-transparent border-0 focus:ring-0 text-sm text-gray-800 dark:text-white placeholder-gray-400 py-3 px-4 min-h-[48px] max-h-32 resize-none scrollbar-hide"
                                rows="1"
                            ></textarea>

                             {{-- Actions --}}
                             <div class="flex items-center gap-1 pb-1">
                                <button type="button" class="p-2 text-gray-400 hover:text-blue-500 hover:bg-white dark:hover:bg-white/5 rounded-full transition-colors">
                                    <x-heroicon-o-paper-clip class="w-5 h-5" />
                                </button>
                                <button 
                                    type="submit"
                                    class="p-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg shadow-blue-500/30 transition-all hover:scale-105 active:scale-95 flex items-center justify-center group"
                                    wire:loading.attr="disabled"
                                >
                                    <x-heroicon-s-paper-airplane class="w-5 h-5 -ml-0.5 transform rotate-180 group-hover:-translate-x-0.5 transition-transform" />
                                </button>
                             </div>
                        </div>
                    </form>
                </div>

            @else
                {{-- Empty State --}}
                <div class="flex-1 flex flex-col items-center justify-center p-12 bg-white/50 dark:bg-[#0f1013] text-center">
                    <div class="relative mb-8 group cursor-pointer">
                        <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full blur-2xl opacity-20 group-hover:opacity-30 transition-opacity"></div>
                        <div class="w-32 h-32 bg-white dark:bg-[#15171b] rounded-full border border-gray-100 dark:border-white/5 flex items-center justify-center relative shadow-2xl transform group-hover:scale-110 transition-transform duration-500">
                            <x-heroicon-o-chat-bubble-left-right class="w-16 h-16 text-gray-300 dark:text-white/20" />
                        </div>
                        {{-- Floating Elements --}}
                        <div class="absolute -right-4 top-0 w-12 h-12 bg-blue-500 rounded-2xl flex items-center justify-center text-white shadow-lg animate-bounce delay-100">
                            <x-heroicon-s-user class="w-6 h-6" />
                        </div>
                         <div class="absolute -left-2 bottom-0 w-10 h-10 bg-indigo-500 rounded-full flex items-center justify-center text-white shadow-lg animate-bounce delay-700">
                            <x-heroicon-s-chat-bubble-oval-left-ellipsis class="w-5 h-5" />
                        </div>
                    </div>
                    
                    <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-3">مركز المحادثات</h2>
                    <p class="text-gray-500 dark:text-gray-400 max-w-md mx-auto leading-relaxed text-sm">
                        مرحباً بك في لوحة تحكم الدعم الفني.
                        <br class="hidden md:block" />
                        اختر محادثة من القائمة للبدء في الرد على استفسارات الطلاب.
                    </p>
                </div>
            @endif
        </div>
    </div>
</x-filament-panels::page>