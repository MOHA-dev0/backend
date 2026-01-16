<?php

namespace App\Filament\Resources\SliderAdResource\Pages;

use App\Filament\Resources\SliderAdResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateSliderAd extends CreateRecord
{
    protected static string $resource = SliderAdResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }


}
