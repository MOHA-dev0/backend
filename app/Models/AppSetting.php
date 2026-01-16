<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    protected $guarded = [];

    public static function current()
    {
        return self::firstOrCreate([
            'id' => 1
        ], [
            'primary_color' => '#1877F2',
            'secondary_color' => '#FFD700',
            'font_family' => 'Inter',
            'splash_image_url' => null,
            'maintenance_mode' => false,
            'privacy_policy' => '<h1>Privacy Policy</h1><p>Update this content in dashboard.</p>',
            'terms_of_use' => '<h1>Terms of Use</h1><p>Update this content in dashboard.</p>',
            'share_link' => 'https://alrasikhoon.com',
            'share_text' => 'Check out Al-Rasikhoon App!',
        ]);
    }
}
