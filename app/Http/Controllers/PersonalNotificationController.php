<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PersonalNotificationController extends Controller
{
    public function index(Request $request)
    {
        // Fetch standard Laravel notifications for the user
        // Order by created_at desc is default for notifications relationship usually, but let's be explicit if needed.
        // The 'notifications' relationship is provided by Notifiable trait.
        return $request->user()->notifications()->latest()->paginate(20);
    }
}
