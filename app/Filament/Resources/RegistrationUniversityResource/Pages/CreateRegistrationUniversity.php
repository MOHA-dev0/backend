<?php

namespace App\Filament\Resources\RegistrationUniversityResource\Pages;

use App\Filament\Resources\RegistrationUniversityResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateRegistrationUniversity extends CreateRecord
{
    protected static string $resource = RegistrationUniversityResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
