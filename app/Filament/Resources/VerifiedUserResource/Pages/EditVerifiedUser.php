<?php

namespace App\Filament\Resources\VerifiedUserResource\Pages;

use App\Filament\Resources\VerifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditVerifiedUser extends EditRecord
{
    protected static string $resource = VerifiedUserResource::class;

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
