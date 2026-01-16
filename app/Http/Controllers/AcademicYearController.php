<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AcademicYear;

class AcademicYearController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Ensure user belongs to a university
        if (!$user || !$user->university_id) {
            return response()->json(['data' => []]);
        }

        $academicYears = AcademicYear::where('university_id', $user->university_id)
            ->with(['subjects' => function ($q) {
                // Eager load nested relationships if needed, e.g., courseType
                // $q->with('courseType'); // Removed, using course_type column
                // You might want to filter active subjects only
                // $q->where('is_active', true);
            }])
            ->orderBy('sort_order', 'asc')
            ->get();

        // Transform data to group subjects by course type if needed here, 
        // or let the frontend handle the grouping (Gold/Silver).
        // Since the UI requires splitting by Gold/Silver, sending the raw structure 
        // and letting Flutter filter is usually more flexible.

        return response()->json(['data' => $academicYears]);
    }
}
