<?php

namespace App\Filament\Resources\AppSettingResource\Pages;

use App\Filament\Resources\AppSettingResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListAppSettings extends ListRecords
{
    protected static string $resource = AppSettingResource::class;

    public function mount(): void
    {
        $setting = \App\Models\AppSetting::current();

        $this->redirect(\App\Filament\Resources\AppSettingResource::getUrl('edit', ['record' => $setting]));
    }

    protected function getHeaderActions(): array
    {
        return [];
    }
}
