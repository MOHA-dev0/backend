<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\RegistrationUniversity;
use App\Models\University;
use App\Models\Title;
use App\Models\Gender;
use App\Models\Governorate;
use App\Models\AcademicYear;
use App\Models\Country;

class LookupController extends Controller
{
    public function getRegisterLookups()
    {
        return response()->json([
            'titles' => Title::with('gender')->get(),
            'genders' => Gender::all(),
            'governorates' => Governorate::all(),
            'universities' => University::all(), // Content Universities (Simple Fetch)
            'registration_universities' => RegistrationUniversity::all(), // Registration Universities
            'academic_years' => \App\Models\RegistrationYear::orderBy('sort_order')->get(),
            'countries' => Country::where('is_active', true)->get(),
        ]);
    }
}
