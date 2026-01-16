<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->messages()->orderBy('created_at', 'asc')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'message' => 'required|string',
        ]);

        $message = $request->user()->messages()->create([
            'message' => $request->message,
            'is_admin' => false,
            'is_read' => false,
        ]);

        return response()->json($message, 201);
    }
}
