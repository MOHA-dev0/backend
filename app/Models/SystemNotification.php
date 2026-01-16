<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SystemNotification extends Model
{
    protected $fillable = [
        'title',
        'body',
        'image',
        'link',
        'target_type',
        'filter_status',
        'filter_user_type',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
    //
}
