<?php

namespace App\Filament\Resources\RegistrationUniversityResource\Pages;

use App\Filament\Resources\RegistrationUniversityResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRegistrationUniversities extends ListRecords
{
    protected static string $resource = RegistrationUniversityResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
