<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ImportantLinkResource\Pages;
use App\Filament\Resources\ImportantLinkResource\RelationManagers;
use App\Models\ImportantLink;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ImportantLinkResource extends Resource
{
    protected static ?string $model = ImportantLink::class;

    protected static ?string $navigationIcon = 'heroicon-o-link';
    protected static ?string $navigationGroup = 'المحتوى';
    protected static ?string $navigationLabel = 'روابط مهمة';
    protected static ?string $modelLabel = 'رابط';
    protected static ?string $pluralModelLabel = 'الروابط المهمة';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('type', '!=', 'social');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('عنوان الرابط')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('url')
                    ->label('الرابط (URL)')
                    ->required()
                    ->url()
                    ->maxLength(255),
                Forms\Components\Select::make('type')
                    ->label('النوع')
                    ->options([
                        'university' => 'روابط الجامعة',
                        'explanation' => 'روابط الشروحات',
                    ])
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'university' => 'info',
                        'explanation' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('url')
                    ->label('الرابط')
                    ->limit(50)
                    ->url(fn($record) => $record->url)
                    ->openUrlInNewTab(),
            ])

            ->reorderable('sort_order')
            ->defaultSort('sort_order', 'asc')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListImportantLinks::route('/'),
            'create' => Pages\CreateImportantLink::route('/create'),
            'edit' => Pages\EditImportantLink::route('/{record}/edit'),
        ];
    }
}
