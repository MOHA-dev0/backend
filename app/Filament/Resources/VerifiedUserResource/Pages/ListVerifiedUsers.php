<?php

namespace App\Filament\Resources\VerifiedUserResource\Pages;

use App\Filament\Resources\VerifiedUserResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListVerifiedUsers extends ListRecords
{
    protected static string $resource = VerifiedUserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
