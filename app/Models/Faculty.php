<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Faculty extends Model
{
    protected $guarded = [];

    public function university()
    {
        return $this->belongsTo(University::class);
    }

    public function academicYears()
    {
        return $this->hasMany(AcademicYear::class);
    }
}
