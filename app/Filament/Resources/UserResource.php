<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Filament\Resources\UserResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationGroup = 'إدارة المستخدمين';
    protected static ?int $navigationSort = 1;

    public static function getModelLabel(): string
    {
        return 'مستخدم';
    }

    public static function getPluralModelLabel(): string
    {
        return 'المستخدمين';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('الاسم الأول')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('second_name')
                    ->label('الاسم الثاني')
                    ->maxLength(255)
                    ->default(null),
                Forms\Components\TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel()
                    ->maxLength(255)
                    ->default(null),
                Forms\Components\TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email()
                    ->required()
                    ->maxLength(255),
                Forms\Components\Select::make('status')
                    ->label('حالة الحساب')
                    ->options([
                        'verified' => 'موثوق',
                        'unverified' => 'غير موثوق',
                        'restricted' => 'محجوب',
                    ])
                    ->required()
                    ->default('unverified'),
                Forms\Components\Select::make('type')
                    ->label('نوع الاشتراك')
                    ->options([
                        'vip_free' => 'vip Free',
                    ])
                    ->required()
                    ->default('vip_free'),
                Forms\Components\TextInput::make('balance')
                    ->label('الرصيد')
                    ->numeric()
                    ->default(0.00),

                Forms\Components\TextInput::make('password')
                    ->label('كلمة المرور')
                    ->password()
                    ->required()
                    ->maxLength(255)
                    ->visibleOn('create'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('رقم الهاتف')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ التسجيل')
                    ->dateTime('d/m/Y h:i A')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('حالة الحساب')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'verified' => 'success',
                        'unverified' => 'warning',
                        'restricted' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'verified' => 'موثوق',
                        'unverified' => 'غير موثوق',
                        'restricted' => 'محجوب',
                        default => $state,
                    })
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('نوع الاشتراك')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'vip_free' => 'success',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'vip_free' => 'vip Free',
                        default => $state,
                    })
                    ->searchable(),
                Tables\Columns\TextColumn::make('balance')
                    ->label('الرصيد')
                    ->numeric()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('حالة الحساب')
                    ->options([
                        'verified' => 'موثوق',
                        'unverified' => 'غير موثوق',
                        'restricted' => 'محجوب',
                    ]),
                Tables\Filters\SelectFilter::make('type')
                    ->label('نوع الاشتراك')
                    ->options([
                        'vip_free' => 'vip Free',
                    ]),
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
            RelationManagers\MessagesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
