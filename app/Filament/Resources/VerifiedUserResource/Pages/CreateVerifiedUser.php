<?php

namespace App\Filament\Resources\VerifiedUserResource\Pages;

use App\Filament\Resources\VerifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateVerifiedUser extends CreateRecord
{
    protected static string $resource = VerifiedUserResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }


}
