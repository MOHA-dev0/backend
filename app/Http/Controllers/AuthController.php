<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserDevice;
use App\Services\Otp\OtpService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    protected $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    public function checkStatus(Request $request)
    {
        $request->validate([
            'phone' => 'required|numeric',
            'device_uuid' => 'required|string',
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (!$user) {
            return response()->json(['status' => 'NEW_USER']);
        }

        // Check Device Fingerprint
        $device = $user->devices()->where('device_uuid', $request->device_uuid)->first();

        if (!$device) {
            // Return ACTIVE to prompt for OTP. verifyOtp will handle the session stealing.
            return response()->json(['status' => 'ACTIVE']);
        }

        return response()->json(['status' => 'ACTIVE']);
    }

    public function sendOtp(Request $request)
    {
        $request->validate(['phone' => 'required|numeric']);

        $otp = rand(100000, 999999);
        // In production, store OTP in Cache with 5 min expiry
        cache()->put("otp_{$request->phone}", $otp, now()->addMinutes(5));

        \Illuminate\Support\Facades\Log::info("OTP for {$request->phone}: {$otp}");

        $this->otpService->send($request->phone, (string) $otp);

        return response()->json(['message' => 'OTP sent successfully']);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|numeric',
            'otp' => 'required|numeric',
            'device_uuid' => 'required|string',
            'device_name' => 'nullable|string',
        ]);

        $cachedOtp = cache()->get("otp_{$request->phone}");

        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json(['message' => 'Invalid or expired OTP'], 401);
        }

        // Retrieve or Create User (in case of registration flow, this might need split)
        // Ideally, verifyOtp is for login. 
        // For NEW_USER, they should call 'register' which also verifies OTP.

        $user = User::where('phone', $request->phone)->first();

        if ($user) {
            // Session Stealing Logic:
            // 1. Revoke all previous tokens (Force logout on other devices)
            $user->tokens()->delete();

            // 2. Remove all previous device records
            $user->devices()->delete();

            // 3. Register THIS new device
            $user->devices()->create([
                'device_uuid' => $request->device_uuid,
                'device_name' => $request->device_name ?? 'Unknown Device',
                'last_active_ip' => $request->ip(),
            ]);

            // 4. Proceed to login
        } else {
            return response()->json(['message' => 'User not found. Please register.'], 404);
        }

        cache()->forget("otp_{$request->phone}");
        $token = $user->createToken('auth_token')->plainTextToken;

        $user->load(['university', 'registrationUniversity', 'academicYear']);

        return response()->json(['token' => $token, 'user' => $user]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'phone' => 'required|numeric|unique:users,phone',
            'otp' => 'required|numeric',
            'first_name' => 'required|string',
            'second_name' => 'required|string',
            'university_id' => 'nullable|exists:universities,id',
            'registration_university_id' => 'nullable|exists:registration_universities,id',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'gender' => 'required|string',
            'governorate' => 'required|string',
            'title' => 'required|string',
            'address' => 'required|string',
            'device_uuid' => 'required|string',
            'device_name' => 'nullable|string',
        ]);

        $cachedOtp = cache()->get("otp_{$request->phone}");

        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json(['message' => 'Invalid or expired OTP'], 401);
        }

        $user = User::create([
            'name' => $request->first_name . ' ' . $request->second_name,
            'second_name' => $request->second_name,
            'phone' => $request->phone,
            'email' => $request->phone . '@law-app.com',
            'password' => Hash::make(Str::random(16)),
            'university_id' => $request->university_id,
            'registration_university_id' => $request->registration_university_id,
            'academic_year_id' => $request->academic_year_id,
            'title' => $request->title,
            'gender' => $request->gender,
            'governorate' => $request->governorate,
            'address' => $request->address,
        ]);

        // Helper to remove device from any other user (Steal Device logic for clean registration)
        \App\Models\UserDevice::where('device_uuid', $request->device_uuid)->delete();

        // Register Device
        $user->devices()->create([
            'device_uuid' => $request->device_uuid,
            'device_name' => $request->device_name ?? 'Unknown Device',
            'last_active_ip' => $request->ip(),
        ]);

        cache()->forget("otp_{$request->phone}");
        $token = $user->createToken('auth_token')->plainTextToken;

        $user->load(['university', 'registrationUniversity', 'academicYear']);

        return response()->json(['token' => $token, 'user' => $user]);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'university_id' => 'sometimes|exists:universities,id',
            'registration_university_id' => 'sometimes|exists:registration_universities,id',
            'academic_year_id' => 'sometimes|exists:academic_years,id',
        ]);

        $user = $request->user();
        if ($request->has('university_id')) {
            $user->university_id = $request->university_id;
        }
        if ($request->has('registration_university_id')) {
            $user->registration_university_id = $request->registration_university_id;
        }
        if ($request->has('academic_year_id')) {
            $user->academic_year_id = $request->academic_year_id;
        }
        $user->save();

        $user->load(['university', 'registrationUniversity', 'academicYear']);

        return response()->json(['message' => 'Profile updated', 'user' => $user->load('university')]);
    }
    public function verifyAccount(Request $request)
    {
        $request->validate([
            'university_id_number' => 'required|string',
            'birth_date' => 'required|date',
            'documents' => 'required|array|min:1|max:5',
            'documents.*' => 'image|max:10240', // 10MB max
        ]);

        $user = $request->user();

        // Store Documents
        $documentPaths = [];
        if ($request->hasFile('documents')) {
            foreach ($request->file('documents') as $file) {
                // Store in 'verification_docs' folder
                $path = $file->store('verification_docs', 'public');
                $documentPaths[] = $path;
            }
        }

        // Update User Profile with verification data
        // Assuming we have columns or a separate table.
        // For now, I'll store them in JSON column or fields.
        // User migration doesn't have these fields yet?
        // Checking User model. If not, I'll add them or store in a 'verification_request' table.
        // A 'verification_requests' table is cleaner.

        \App\Models\VerificationRequest::create([
            'user_id' => $user->id,
            'university_id_number' => $request->university_id_number,
            'birth_date' => $request->birth_date,
            'documents' => json_encode($documentPaths),
            'status' => 'pending',
        ]);

        // Update user status
        $user->update(['status' => 'pending_verification']);

        return response()->json(['message' => 'Verification request submitted successfully']);
    }
}
