<?php

namespace App\Filament\Traits;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Filament\Notifications\Notification;

trait HandlesGoogleDocConversion
{
    protected function handleGoogleDocConversion(array $data): array
    {
        // Check if user provided google_doc_url BUT NO file_url
        if (!empty($data['google_doc_url']) && empty($data['file_url'])) {

            // Extract Google Doc ID
            preg_match('/document\/d\/([a-zA-Z0-9-_]+)/', $data['google_doc_url'], $matches);

            if (isset($matches[1])) {
                $fileId = $matches[1];
                $exportUrl = "https://docs.google.com/document/d/{$fileId}/export?format=pdf";

                try {
                    $response = Http::get($exportUrl);

                    if ($response->successful()) {
                        $filename = 'unit-files/' . Str::random(40) . '.pdf';
                        Storage::disk('public')->put($filename, $response->body());

                        // Set the file_url to the new file
                        $data['file_url'] = $filename;

                        // CLEAR the Google Doc URL so the app sees only the PDF
                        $data['google_doc_url'] = null;

                        Notification::make()
                            ->title('تم التحويل تلقائياً')
                            ->body('تم تحويل رابط Google Doc إلى PDF وبدء التحميل.')
                            ->success()
                            ->send();
                    } else {
                        Notification::make()
                            ->title('تحذير التحويل')
                            ->body('فشل تحويل Google Doc. تأكد أن الرابط عام.')
                            ->warning()
                            ->send();
                    }
                } catch (\Exception $e) {
                    Notification::make()
                        ->title('خطأ في التحويل')
                        ->body('حدث خطأ أثناء الاتصال بـ Google.')
                        ->danger()
                        ->send();
                }
            }
        }

        return $data;
    }
}
