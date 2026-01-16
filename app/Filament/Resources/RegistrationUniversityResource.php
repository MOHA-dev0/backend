<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RegistrationUniversityResource\Pages;
use App\Filament\Resources\RegistrationUniversityResource\RelationManagers;
use App\Models\RegistrationUniversity;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class RegistrationUniversityResource extends Resource
{
    protected static ?string $model = RegistrationUniversity::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';
    protected static ?string $navigationGroup = 'الهيكل الأكاديمي';
    protected static ?string $navigationLabel = 'جامعات التسجيل';
    protected static ?string $modelLabel = 'جامعة';
    protected static ?string $pluralModelLabel = 'جامعات التسجيل';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('اسم الجامعة')
                    ->required()
                    ->maxLength(255)
                    ->columnSpanFull(),
                Forms\Components\Hidden::make('type')
                    ->default('traditional'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable(),
            ])
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
            'index' => Pages\ListRegistrationUniversities::route('/'),
            'create' => Pages\CreateRegistrationUniversity::route('/create'),
            'edit' => Pages\EditRegistrationUniversity::route('/{record}/edit'),
        ];
    }
}
