<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CountryResource\Pages;
use App\Models\Country;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CountryResource extends Resource
{
    protected static ?string $model = Country::class;

    protected static ?string $navigationIcon = 'heroicon-o-globe-alt';
    protected static ?string $navigationLabel = 'الدول';
    protected static ?string $modelLabel = 'دولة';
    protected static ?string $pluralModelLabel = 'الدول';
    protected static ?string $navigationGroup = 'إعدادات النظام';
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('اسم الدولة')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('phone_code')
                    ->label('رمز الهاتف')
                    ->placeholder('+963')
                    ->required()
                    ->maxLength(10)
                    ->extraInputAttributes(['dir' => 'ltr', 'style' => 'text-align: left']), // Force Left Alignment for Phone Code
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('اسم الدولة')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone_code')
                    ->label('رمز الهاتف')
                    ->alignment('center')
                    ->extraAttributes(['dir' => 'ltr']) // Keep LTR for text direction, but allow center alignment
                    ->searchable(),
                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('نشط')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListCountries::route('/'),
            'create' => Pages\CreateCountry::route('/create'),
            'edit' => Pages\EditCountry::route('/{record}/edit'),
        ];
    }
}
