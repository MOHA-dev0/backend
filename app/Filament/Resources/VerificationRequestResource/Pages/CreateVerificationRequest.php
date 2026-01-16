<?php

namespace App\Filament\Resources\VerificationRequestResource\Pages;

use App\Filament\Resources\VerificationRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateVerificationRequest extends CreateRecord
{
    protected static string $resource = VerificationRequestResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
