<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SliderAdResource\Pages;
use App\Filament\Resources\SliderAdResource\RelationManagers;
use App\Models\SliderAd;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SliderAdResource extends Resource
{
    protected static ?string $model = SliderAd::class;

    protected static ?string $navigationIcon = 'heroicon-o-photo';
    protected static ?string $navigationGroup = 'المحتوى';
    protected static ?int $navigationSort = 1;

    public static function getModelLabel(): string
    {
        return 'إعلان';
    }

    public static function getPluralModelLabel(): string
    {
        return 'إعلانات السلايدر';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('عنوان الإعلان')
                    ->maxLength(255),
                Forms\Components\FileUpload::make('image_url')
                    ->label('الصورة')
                    ->image()
                    ->imageEditor()
                    ->directory('slider-ads')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('link')
                    ->label('رابط (اختياري)')
                    ->maxLength(255),
                Forms\Components\TextInput::make('sort_order')
                    ->label('الترتيب')
                    ->numeric()
                    ->default(0),
                Forms\Components\Toggle::make('is_active')
                    ->label('فعال')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image_url')
                    ->label('الصورة'),
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('فعال'),
                Tables\Columns\TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
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
            'index' => Pages\ListSliderAds::route('/'),
            'create' => Pages\CreateSliderAd::route('/create'),
            'edit' => Pages\EditSliderAd::route('/{record}/edit'),
        ];
    }
}
