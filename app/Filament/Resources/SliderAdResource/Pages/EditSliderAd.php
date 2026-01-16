<?php

namespace App\Filament\Resources\SliderAdResource\Pages;

use App\Filament\Resources\SliderAdResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSliderAd extends EditRecord
{
    protected static string $resource = SliderAdResource::class;

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
