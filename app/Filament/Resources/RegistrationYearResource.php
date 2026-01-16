<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RegistrationYearResource\Pages;
use App\Filament\Resources\RegistrationYearResource\RelationManagers;
use App\Models\RegistrationYear;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class RegistrationYearResource extends Resource
{
    protected static ?string $model = RegistrationYear::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'الهيكل الأكاديمي';
    protected static ?string $navigationLabel = 'سنوات التسجيل';
    protected static ?int $navigationSort = 3;

    public static function getModelLabel(): string
    {
        return 'سنة تسجيل';
    }

    public static function getPluralModelLabel(): string
    {
        return 'سنوات التسجيل';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('اسم السنة')
                    ->required()
                    ->maxLength(255)
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('اسم السنة')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->reorderable('sort_order')
            ->defaultSort('sort_order')
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
            'index' => Pages\ListRegistrationYears::route('/'),
            'create' => Pages\CreateRegistrationYear::route('/create'),
            'edit' => Pages\EditRegistrationYear::route('/{record}/edit'),
        ];
    }
}
