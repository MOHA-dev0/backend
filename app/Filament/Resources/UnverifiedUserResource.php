<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UnverifiedUserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class UnverifiedUserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-plus';
    protected static ?string $navigationGroup = 'إدارة المستخدمين';
    protected static ?string $navigationLabel = 'مستخدمين غير موثقين';
    protected static ?int $navigationSort = 3;

    public static function getModelLabel(): string
    {
        return 'مستخدم غير موثق';
    }

    public static function getPluralModelLabel(): string
    {
        return 'المستخدمين غير الموثقين';
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('status', 'unverified');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('الاسم')
                    ->disabled(),
                Forms\Components\TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->disabled(),
                Forms\Components\Select::make('status')
                    ->label('الحالة')
                    ->options([
                        'verified' => 'موثوق',
                        'unverified' => 'غير موثوق',
                    ])
                    ->required(),
                Forms\Components\Select::make('type')
                    ->label('نوع الاشتراك')
                    ->options([
                        'vip_free' => 'vip Free',
                    ])
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
                Tables\Columns\TextColumn::make('phone')
                    ->label('رقم الهاتف')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ التسجيل')
                    ->dateTime('d/m/Y h:i A')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color('warning')
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'unverified' => 'غير موثوق',
                        default => $state,
                    }),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\Action::make('verify')
                    ->label('توثيق الحساب')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(fn(User $record) => $record->update(['status' => 'verified'])),
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
            UserResource\RelationManagers\MessagesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUnverifiedUsers::route('/'),
            'create' => Pages\CreateUnverifiedUser::route('/create'),
            'edit' => Pages\EditUnverifiedUser::route('/{record}/edit'),
        ];
    }
}
