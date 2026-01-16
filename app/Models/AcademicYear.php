<?php

namespace App\Models;

use App\Models\Faculty;
use App\Models\Subject;
use Illuminate\Database\Eloquent\Model;

class AcademicYear extends Model
{

    protected $fillable = ['name', 'university_id', 'faculty_id', 'sort_order'];

    public function university()
    {
        return $this->belongsTo(University::class);
    }

    public function faculty()
    {
        return $this->belongsTo(Faculty::class);
    }

    public function subjects()
    {
        return $this->hasMany(Subject::class);
    }
}
