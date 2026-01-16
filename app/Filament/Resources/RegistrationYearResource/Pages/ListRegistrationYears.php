<?php

namespace App\Filament\Resources\RegistrationYearResource\Pages;

use App\Filament\Resources\RegistrationYearResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRegistrationYears extends ListRecords
{
    protected static string $resource = RegistrationYearResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
