<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VerificationRequest extends Model
{
    protected $guarded = [];

    protected $casts = [
        'documents' => 'array',
        'birth_date' => 'date',
    ];
}
