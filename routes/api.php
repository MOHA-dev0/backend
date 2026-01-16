<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\AppSetting;
use App\Http\Controllers\AuthController;

Route::get('/user', function (Request $request) {
    return $request->user()->load(['university', 'registrationUniversity', 'academicYear']);
})->middleware('auth:sanctum');

Route::get('/check-intl', function () {
    return response()->json([
        'intl_loaded' => extension_loaded('intl'),
        'php_ini' => php_ini_loaded_file(),
    ]);
});

Route::get('/lookups/register', [\App\Http\Controllers\LookupController::class, 'getRegisterLookups']);
Route::get('/slider-ads', [\App\Http\Controllers\HomeController::class, 'getSliderAds']);
Route::get('/course-types', [\App\Http\Controllers\Api\CourseTypeController::class, 'index']);
Route::get('/settings', function () {
    return \App\Models\AppSetting::current();
});

Route::get('/links', function () {
    return \App\Models\ImportantLink::orderBy('sort_order', 'asc')->orderBy('id', 'asc')->get();
});

Route::prefix('auth')->group(function () {
    Route::post('/check-status', [AuthController::class, 'checkStatus']);
    Route::post('/send-otp', [AuthController::class, 'sendOtp']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/register', [AuthController::class, 'register']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/update-profile', [AuthController::class, 'updateProfile']);
    Route::post('/auth/verify-account', [AuthController::class, 'verifyAccount']); // Moved here
    Route::post('/wallet/redeem', [\App\Http\Controllers\WalletController::class, 'redeem']);
    Route::post('/store/purchase-subject', [\App\Http\Controllers\StoreController::class, 'purchaseSubject']);
    Route::get('/subjects', [\App\Http\Controllers\SubjectController::class, 'index']);
    Route::get('/subjects/{id}', [\App\Http\Controllers\SubjectController::class, 'show']);
    Route::get('/academic-years', [\App\Http\Controllers\AcademicYearController::class, 'index']);

    // Chat Routes
    Route::get('/chat/messages', [\App\Http\Controllers\ChatController::class, 'index']);
    Route::post('/chat/messages', [\App\Http\Controllers\ChatController::class, 'store']);
    Route::post('/complaints', [\App\Http\Controllers\ComplaintController::class, 'store']);
    Route::get('/notifications', [\App\Http\Controllers\SystemNotificationController::class, 'index']);
    Route::get('/personal-notifications', [\App\Http\Controllers\PersonalNotificationController::class, 'index']);
});
