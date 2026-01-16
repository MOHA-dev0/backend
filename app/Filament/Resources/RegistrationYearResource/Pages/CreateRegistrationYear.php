<?php

namespace App\Filament\Resources\RegistrationYearResource\Pages;

use App\Filament\Resources\RegistrationYearResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateRegistrationYear extends CreateRecord
{
    protected static string $resource = RegistrationYearResource::class;

    public static function canCreateAnother(): bool
    {
        return false;
    }
}
