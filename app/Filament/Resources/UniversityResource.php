<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UniversityResource\Pages;
use App\Filament\Resources\UniversityResource\RelationManagers;
use App\Models\University;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class UniversityResource extends Resource
{
    protected static ?string $model = University::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';
    protected static ?string $navigationGroup = 'الهيكل الأكاديمي';
    protected static ?int $navigationSort = 11;

    protected static ?string $modelLabel = 'جامعة';

    protected static ?string $pluralModelLabel = 'الجامعات';


    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Select::make('type')
                    ->label('النوع')
                    ->options([
                        'traditional' => 'تقليدي',
                        'virtual' => 'افتراضي',
                    ])
                    ->required()
                    ->default('traditional'),
                Forms\Components\FileUpload::make('logo_url')
                    ->label('الشعار')
                    ->image(),
                Forms\Components\Toggle::make('has_calculator')
                    ->label('تفعيل حاسبة العلامات')
                    ->default(true),
                Forms\Components\TextInput::make('years_count')
                    ->label('عدد السنوات الدراسية')
                    ->numeric()
                    ->default(4)
                    ->minValue(1)
                    ->maxValue(7)
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'traditional' => 'تقليدي',
                        'virtual' => 'افتراضي',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('years_count')
                    ->label('السنوات')
                    ->sortable(),
                Tables\Columns\ToggleColumn::make('has_calculator')
                    ->label('حاسبة'),
                Tables\Columns\TextColumn::make('logo_url')
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
            'index' => Pages\ListUniversities::route('/'),
            'create' => Pages\CreateUniversity::route('/create'),
            'edit' => Pages\EditUniversity::route('/{record}/edit'),
        ];
    }
}
