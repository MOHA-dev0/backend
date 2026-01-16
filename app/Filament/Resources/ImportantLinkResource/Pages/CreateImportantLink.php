<?php

namespace App\Filament\Resources\ImportantLinkResource\Pages;

use App\Filament\Resources\ImportantLinkResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateImportantLink extends CreateRecord
{
    protected static string $resource = ImportantLinkResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
