<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class University extends Model
{
    protected $guarded = [];

    public function faculties()
    {
        return $this->hasMany(Faculty::class);
    }

    public function academicYears()
    {
        return $this->hasMany(AcademicYear::class);
    }
}
