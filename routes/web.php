<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/admin/login');
});

Route::get('/debug-pdf/{filename}', function ($filename) {
    $path = 'unit-files/' . $filename;
    if (!\Illuminate\Support\Facades\Storage::disk('public')->exists($path)) {
        return 'File not found in storage: ' . $path;
    }
    $fullPath = \Illuminate\Support\Facades\Storage::disk('public')->path($path);
    return response()->download($fullPath);
});

Route::get('/cors-storage/{path}', [App\Http\Controllers\HomeController::class, 'serveStorageFile'])->where('path', '.*');
Route::get('/media/{path}', [App\Http\Controllers\HomeController::class, 'serveStorageFile'])->where('path', '.*');
Route::get('/debug-test', function () {
    return 'Laravel Routing is Working';
});
