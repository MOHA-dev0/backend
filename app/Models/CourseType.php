<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourseType extends Model
{
    protected $fillable = [
        'name',
        'color',
        'sort_order',
        'is_active',
        'university_id',
        'academic_year_id',
    ];

    public function university()
    {
        return $this->belongsTo(University::class);
    }

    public function academicYear()
    {
        return $this->belongsTo(AcademicYear::class);
    }
}
