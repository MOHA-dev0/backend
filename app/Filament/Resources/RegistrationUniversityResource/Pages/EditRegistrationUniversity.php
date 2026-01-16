<?php

namespace App\Filament\Resources\RegistrationUniversityResource\Pages;

use App\Filament\Resources\RegistrationUniversityResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRegistrationUniversity extends EditRecord
{
    protected static string $resource = RegistrationUniversityResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
