<?php

namespace App\Filament\Resources\UnverifiedUserResource\Pages;

use App\Filament\Resources\UnverifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListUnverifiedUsers extends ListRecords
{
    protected static string $resource = UnverifiedUserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
