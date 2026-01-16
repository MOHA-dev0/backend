<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SystemNotification;

class SystemNotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $notifications = SystemNotification::where('is_active', true)
            ->where(function ($query) use ($user) {
                // Logic: 
                // 1. target_type = 'all'
                // OR
                // 2. target_type = 'segment' AND matches status/type
                
                $query->where('target_type', 'all')
                    ->orWhere(function ($q) use ($user) {
                        $q->where('target_type', 'segment')
                          ->where(function ($segmentQ) use ($user) {
                              
                              // Check Status Filter
                              $segmentQ->where(function ($sq) use ($user) {
                                  $sq->whereNull('filter_status')
                                     ->orWhere('filter_status', $user->status);
                              });

                              // Check Type Filter
                              $segmentQ->where(function ($tq) use ($user) {
                                  $tq->whereNull('filter_user_type')
                                     ->orWhere('filter_user_type', $user->type);
                              });
                          });
                    });
            })
            ->latest()
            ->paginate(20);

        return response()->json($notifications);
    }
}
