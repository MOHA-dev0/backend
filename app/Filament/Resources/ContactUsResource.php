<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ContactUsResource\Pages;
use App\Models\ImportantLink;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ContactUsResource extends Resource
{
    protected static ?string $model = ImportantLink::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static ?string $navigationGroup = 'الدعم الفني';
    protected static ?string $navigationLabel = 'معلومات التواصل';
    protected static ?string $modelLabel = 'رابط تواصل';
    protected static ?string $pluralModelLabel = 'معلومات التواصل';

    // Ensure this resource uses a different slug so it doesn't conflict with ImportantLinkResource
    protected static ?string $slug = 'contact-us-links';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('type', 'social');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Hidden::make('type')
                    ->default('social'),

                Forms\Components\TextInput::make('title')
                    ->label('العنوان')
                    ->required()
                    ->placeholder('مثال: WhatsApp, Facebook')
                    ->maxLength(255),

                Forms\Components\TextInput::make('url')
                    ->label('الرابط (URL)')
                    ->helperText('لأرقام الهاتف استخدم: tel:+963912345678')
                    ->required()
                    ->maxLength(255),

                Forms\Components\Select::make('icon')
                    ->label('الأيقونة')
                    ->options([
                        'whatsapp' => 'WhatsApp',
                        'facebook' => 'Facebook',
                        'telegram' => 'Telegram',
                        'instagram' => 'Instagram',
                        'youtube' => 'YouTube',
                        'phone' => 'هاتف (Phone)',
                        'web' => 'موقع (Web)',
                    ])
                    ->required()
                    ->searchable(),

                Forms\Components\ColorPicker::make('color')
                    ->label('لون الزر')
                    ->required(),

                Forms\Components\Toggle::make('is_active')
                    ->label('نشط (إظهار في التطبيق)')
                    ->default(true),

            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->description(fn(ImportantLink $record): string => $record->url),

                Tables\Columns\TextColumn::make('icon')
                    ->label('الأيقونة')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\ColorColumn::make('color')
                    ->label('اللون'),

                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('نشط'),
            ])
            ->defaultSort('sort_order', 'asc')
            ->reorderable('sort_order')
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                // No bulk actions to prevent accidental deletion
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListContactUs::route('/'),
            'edit' => Pages\EditContactUs::route('/{record}/edit'),
        ];
    }
}
