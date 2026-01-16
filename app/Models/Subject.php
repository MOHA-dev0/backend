<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    protected $guarded = [];

    protected $casts = [
        'is_optional' => 'boolean',
        'is_free' => 'boolean',
        'price_unit' => 'decimal:2',
        'price_question' => 'decimal:2',
        'price_audio' => 'decimal:2',
    ];

    protected $appends = ['exam_type_label'];

    public function academicYear()
    {
        return $this->belongsTo(AcademicYear::class);
    }

    // public function courseType() { ... } Removed
    
    public function getIsGoldAttribute()
    {
        return $this->course_type === 'gold';
    }

    public function units()
    {
        return $this->hasMany(Unit::class);
    }

    public function getExamTypeLabelAttribute()
    {
        return match ($this->exam_type) {
            'automation' => 'أتمتة',
            'essay' => 'مقالي',
            default => 'أتمتة',
        };
    }
}
