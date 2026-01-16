<?php

namespace App\Filament\Resources\UnverifiedUserResource\Pages;

use App\Filament\Resources\UnverifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditUnverifiedUser extends EditRecord
{
    protected static string $resource = UnverifiedUserResource::class;

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
