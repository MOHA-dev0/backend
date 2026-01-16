<?php

namespace App\Filament\Resources\SystemNotificationResource\Pages;

use App\Filament\Resources\SystemNotificationResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateSystemNotification extends CreateRecord
{
    protected static string $resource = SystemNotificationResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
