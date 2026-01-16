<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Title extends Model
{
    protected $fillable = ['name', 'gender_id'];

    public function gender()
    {
        return $this->belongsTo(Gender::class);
    }
}
