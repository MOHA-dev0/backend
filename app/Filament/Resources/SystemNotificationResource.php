<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SystemNotificationResource\Pages;
use App\Filament\Resources\SystemNotificationResource\RelationManagers;
use App\Models\SystemNotification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SystemNotificationResource extends Resource
{
    protected static ?string $model = SystemNotification::class;

    protected static ?string $navigationIcon = 'heroicon-o-bell';
    protected static ?string $navigationGroup = 'المحتوى';
    protected static ?int $navigationSort = 2;

    public static function getModelLabel(): string
    {
        return 'إشعار';
    }

    public static function getPluralModelLabel(): string
    {
        return 'إشعارات النظام';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('محتوى الإشعار')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('عنوان الإشعار')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Textarea::make('body')
                            ->label('نص الإشعار')
                            ->required()
                            ->columnSpanFull(),
                        Forms\Components\FileUpload::make('image')
                            ->label('صورة (اختياري)')
                            ->image()
                            ->directory('notifications'),
                        Forms\Components\TextInput::make('link')
                            ->label('رابط (اختياري)')
                            ->url(),
                    ])->columns(2),

                Forms\Components\Section::make('الاستهداف')
                    ->schema([
                        Forms\Components\Select::make('target_type')
                            ->label('نوع الاستهداف')
                            ->options([
                                'all' => 'جميع المستخدمين',
                                'segment' => 'شريحة محددة',
                            ])
                            ->default('all')
                            ->live()
                            ->required(),

                        Forms\Components\Grid::make(2)
                            ->schema([
                                Forms\Components\Select::make('filter_status')
                                    ->label('حالة الحساب')
                                    ->options([
                                        'verified' => 'موثوق',
                                        'unverified' => 'غير موثوق',
                                        'restricted' => 'محجوب',
                                    ]),
                                Forms\Components\Select::make('filter_user_type')
                                    ->label('نوع الاشتراك')
                                    ->options([
                                        'vip_free' => 'vip Free',
                                        // future types can be added here
                                    ]),
                            ])
                            ->visible(fn(Forms\Get $get) => $get('target_type') === 'segment'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('مفعل')
                            ->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('target_type')
                    ->label('الاستهداف')
                    ->badge()
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'all' => 'الكل',
                        'segment' => 'شريحة',
                        default => $state,
                    }),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('الحالة')
                    ->boolean(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
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
            ])
            ->defaultSort('created_at', 'desc');
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
            'index' => Pages\ListSystemNotifications::route('/'),
            'create' => Pages\CreateSystemNotification::route('/create'),
            'edit' => Pages\EditSystemNotification::route('/{record}/edit'),
        ];
    }
}
