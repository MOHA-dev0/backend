<?php

namespace App\Filament\Resources\RegistrationYearResource\Pages;

use App\Filament\Resources\RegistrationYearResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRegistrationYear extends EditRecord
{
    protected static string $resource = RegistrationYearResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
