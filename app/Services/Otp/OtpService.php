<?php

namespace App\Services\Otp;

interface OtpService
{
    public function send(string $phone, string $code): void;
}
