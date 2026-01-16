<?php

namespace App\Filament\Resources\ImportantLinkResource\Pages;

use App\Filament\Resources\ImportantLinkResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditImportantLink extends EditRecord
{
    protected static string $resource = ImportantLinkResource::class;

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
