<?php

namespace App\Services\Otp;

use Illuminate\Support\Facades\Log;

class LogOtpService implements OtpService
{
    public function send(string $phone, string $code): void
    {
        Log::info("OTP SENT to {$phone}: {$code}");
    }
}
