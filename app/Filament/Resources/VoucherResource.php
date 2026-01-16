<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VoucherResource\Pages;
use App\Filament\Resources\VoucherResource\RelationManagers;
use App\Models\Voucher;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class VoucherResource extends Resource
{
    protected static ?string $model = Voucher::class;

    protected static ?string $navigationIcon = 'heroicon-o-ticket';
    protected static ?string $navigationGroup = 'المحفظة';
    protected static ?int $navigationSort = 2;

    public static function getModelLabel(): string
    {
        return 'قسيمة';
    }

    public static function getPluralModelLabel(): string
    {
        return 'القسائم';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('طريقة الإضافة')
                    ->schema([
                        Forms\Components\Radio::make('creation_mode')
                            ->label('الوضع')
                            ->options([
                                'direct' => 'إيداع مباشر (رصيد لمستخدم)',
                                'generate' => 'توليد قسائم (للتوزيع)',
                            ])
                            ->default('direct')
                            ->reactive()
                            ->required(),
                    ]),

                Forms\Components\Section::make('التفاصيل')
                    ->schema([
                        Forms\Components\TextInput::make('amount')
                            ->label('المبلغ (ل.س)')
                            ->required()
                            ->numeric()
                            ->columnSpanFull(),

                        // Direct Mode Fields
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload() // For better UX if list isn't huge, or require search
                            ->required(fn(Forms\Get $get) => $get('creation_mode') === 'direct')
                            ->visible(fn(Forms\Get $get) => $get('creation_mode') === 'direct')
                            ->columnSpanFull(),

                        // Generate Mode Fields
                        Forms\Components\TextInput::make('quantity')
                            ->label('الكمية')
                            ->numeric()
                            ->default(1)
                            ->minValue(1)
                            ->maxValue(1000)
                            ->required(fn(Forms\Get $get) => $get('creation_mode') === 'generate')
                            ->visible(fn(Forms\Get $get) => $get('creation_mode') === 'generate'),

                        Forms\Components\TextInput::make('code')
                            ->label('الكود (اختياري)')
                            ->placeholder('اتركه فارغاً للتوليد التلقائي')
                            ->visible(fn(Forms\Get $get) => $get('creation_mode') === 'generate' && (int) $get('quantity') === 1)
                            ->maxLength(255),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')->searchable()->copyable(),
                Tables\Columns\TextColumn::make('amount')->money('SYP')->sortable(),
                Tables\Columns\IconColumn::make('is_used')->boolean(),
                Tables\Columns\TextColumn::make('user.name')->label('استخدم بواسطة')->searchable(),
                Tables\Columns\TextColumn::make('batch_id')->label('رقم الدفعة')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->label('تاريخ الإنشاء')->dateTime(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_used')->label('تم الاستخدام'),
            ])
            ->headerActions([
                // Removed custom action
            ])
            ->actions([
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
            'index' => Pages\ListVouchers::route('/'),
            'create' => Pages\CreateVoucher::route('/create'),
            'edit' => Pages\EditVoucher::route('/{record}/edit'),
        ];
    }
}
