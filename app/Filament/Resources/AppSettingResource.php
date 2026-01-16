<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AppSettingResource\Pages;
use App\Filament\Resources\AppSettingResource\RelationManagers;
use App\Models\AppSetting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class AppSettingResource extends Resource
{
    protected static ?string $model = AppSetting::class;

    protected static ?string $navigationIcon = 'heroicon-o-cog';
    protected static ?string $navigationGroup = 'إعدادات النظام';
    protected static ?string $navigationLabel = 'الإعدادات العامة';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canGloballySearch(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('قانوني ومشاركة')
                    ->schema([
                        Forms\Components\RichEditor::make('privacy_policy')->label('سياسة الخصوصية')->columnSpanFull(),
                        Forms\Components\RichEditor::make('terms_of_use')->label('شروط الاستخدام')->columnSpanFull(),
                        Forms\Components\TextInput::make('share_link')
                            ->label('رابط المشاركة')
                            ->url()
                            ->required()
                            ->default('https://alrasikhoon.com'),
                        Forms\Components\Textarea::make('share_text')
                            ->label('نص المشاركة')
                            ->rows(3)
                            ->default('حمل تطبيق الراسخون الآن!'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('primary_color')
                    ->label('اللون الأساسي'),
                Tables\Columns\TextColumn::make('secondary_color')
                    ->label('اللون الثانوي'),
                Tables\Columns\TextColumn::make('font_family')
                    ->label('الخط'),
                Tables\Columns\ImageColumn::make('splash_image_url')
                    ->label('صورة البداية'),
                Tables\Columns\IconColumn::make('maintenance_mode')
                    ->label('وضع الصيانة')
                    ->boolean(),
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
            'index' => Pages\ListAppSettings::route('/'),
            'create' => Pages\CreateAppSetting::route('/create'),
            'edit' => Pages\EditAppSetting::route('/{record}/edit'),
        ];
    }
}
