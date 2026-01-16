<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Illuminate\Support\Facades\File;

class OtpLogs extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    
    protected static ?string $navigationLabel = 'رسائل التحقق OTP';
    
    protected static ?string $title = 'سجل رسائل التحقق';
    
    protected static ?int $navigationSort = 1;

    protected static string $view = 'filament.pages.otp-logs';

    /**
     * Get the data passed to the view
     */
    protected function getViewData(): array
    {
        return [
            'logs' => $this->getOtpLogs(),
        ];
    }

    /**
     * Parse the log file and extract OTPs
     */
    protected function getOtpLogs(): array
    {
        $logFile = storage_path('logs/laravel.log');

        if (!File::exists($logFile)) {
            return [];
        }

        // Get file content
        $content = File::get($logFile);
        
        $logs = [];

        // Regex to match: [2026-01-09 16:36:13] local.INFO: OTP SENT to +963268: 894260
        // Group 1: Timestamp
        // Group 2: Phone
        // Group 3: Code
        $pattern = '/\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] local\.INFO: OTP SENT to ([+0-9]+): (\d+)/';

        if (preg_match_all($pattern, $content, $matches, PREG_SET_ORDER)) {
            foreach ($matches as $match) {
                $logs[] = [
                    'date' => $match[1],
                    'phone' => $match[2],
                    'code' => $match[3],
                ];
            }
        }

        // Return reversed (newest first)
        return array_reverse($logs);
    }
}
