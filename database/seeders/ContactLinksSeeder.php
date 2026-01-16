<?php

namespace Database\Seeders;

use App\Models\ImportantLink;
use Illuminate\Database\Seeder;

class ContactLinksSeeder extends Seeder
{
    public function run(): void
    {
        $links = [
            [
                'title' => 'اتصل بنا (Phone)',
                'url' => 'tel:+963000000000',
                'type' => 'social',
                'icon' => 'phone',
                'color' => '#CDC346', // Gold
                'sort_order' => 1,
            ],
            [
                'title' => 'WhatsApp',
                'url' => 'https://wa.me/963000000000',
                'type' => 'social',
                'icon' => 'whatsapp',
                'color' => '#25D366', // Green
                'sort_order' => 2,
            ],
            [
                'title' => 'صفحة الفيس (Facebook Page)',
                'url' => 'https://facebook.com/your-page',
                'type' => 'social',
                'icon' => 'facebook',
                'color' => '#1877F2', // Blue
                'sort_order' => 3,
            ],
            [
                'title' => 'مجموعة الفيس (Facebook Group)',
                'url' => 'https://facebook.com/groups/your-group',
                'type' => 'social',
                'icon' => 'facebook',
                'color' => '#1877F2', // Blue
                'sort_order' => 4,
            ],
            [
                'title' => 'Telegram',
                'url' => 'https://t.me/your-channel',
                'type' => 'social',
                'icon' => 'telegram',
                'color' => '#0088CC', // Light Blue
                'sort_order' => 5,
            ],
            [
                'title' => 'Instagram',
                'url' => 'https://instagram.com/your-account',
                'type' => 'social',
                'icon' => 'instagram',
                'color' => '#E4405F', // Pink/Red
                'sort_order' => 6,
            ],
            [
                'title' => 'YouTube',
                'url' => 'https://youtube.com/your-channel',
                'type' => 'social',
                'icon' => 'youtube',
                'color' => '#FF0000', // Red
                'sort_order' => 7,
            ],
        ];

        foreach ($links as $link) {
            ImportantLink::updateOrCreate(
                ['title' => $link['title'], 'type' => 'social'], // Match by title + type to avoid dupes
                $link
            );
        }
    }
}
