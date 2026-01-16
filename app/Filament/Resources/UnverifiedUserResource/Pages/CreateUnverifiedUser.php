<?php

namespace App\Filament\Resources\UnverifiedUserResource\Pages;

use App\Filament\Resources\UnverifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateUnverifiedUser extends CreateRecord
{
    protected static string $resource = UnverifiedUserResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }


}
