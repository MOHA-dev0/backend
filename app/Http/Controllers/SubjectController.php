<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = \App\Models\Subject::with(['academicYear.university', 'courseType']);

        // Filter by Registration Year (App sends year_id which is RegistrationYear ID)
        if ($request->has('year_id')) {
            $registrationYear = \App\Models\RegistrationYear::find($request->year_id);
            if ($registrationYear) {
                // Filter Subjects where AcademicYear Name matches RegistrationYear Name
                $query->whereHas('academicYear', function ($q) use ($registrationYear) {
                    $q->where('name', 'LIKE', '%' . $registrationYear->name . '%');
                });
            }
        }

        // Optional: Filter by User's Content University if set (Legacy support or if needed)
        // If the user has a university_id (content university), we scope by it.
        // But since we are decoupling, we might want to relax this or ensure it matches the new structure.
        // For now, let's update it to use the direct relationship if university_id exists.
        if ($user && $user->university_id) {
            $query->whereHas('academicYear', function ($q) use ($user) {
                $q->where('university_id', $user->university_id);
            });
        }

        $subjects = $query->get();

        return response()->json(['data' => $subjects]);
    }

    public function show(Request $request, $id)
    {
        $subject = \App\Models\Subject::with(['units.lessons'])->findOrFail($id);
        
        // Get user's subscription for this subject
        $user = $request->user();
        $userAccess = null;
        
        if ($user) {
            $subscription = $user->subjects()
                ->where('subject_id', $subject->id)
                ->first();
            
            if ($subscription) {
                $userAccess = [
                    'has_units' => (bool) $subscription->pivot->has_units,
                    'has_questions' => (bool) $subscription->pivot->has_questions,
                    'has_audio' => (bool) $subscription->pivot->has_audio,
                ];
            }
        }

        $data = $subject->toArray();
        $data['user_access'] = $userAccess;

        return response()->json(['data' => $data]);
    }
}
