<?php

namespace App\Filament\Resources\SliderAdResource\Pages;

use App\Filament\Resources\SliderAdResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSliderAds extends ListRecords
{
    protected static string $resource = SliderAdResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
