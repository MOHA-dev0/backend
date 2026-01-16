<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VerifiedUserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class VerifiedUserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-check-badge';
    protected static ?string $navigationGroup = 'إدارة المستخدمين';
    protected static ?string $navigationLabel = 'المستخدمون الموثقون';
    protected static ?int $navigationSort = 2;

    public static function getModelLabel(): string
    {
        return 'مستخدم موثق';
    }

    public static function getPluralModelLabel(): string
    {
        return 'المستخدمين الموثقين';
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('status', 'verified');
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
                    ->label('حالة الحساب')
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
                Forms\Components\TextInput::make('balance')
                    ->label('الرصيد')
                    ->numeric(),
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
                Tables\Columns\TextColumn::make('status')
                    ->label('حالة الحساب')
                    ->badge()
                    ->color('success')
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'verified' => 'موثوق',
                        default => $state,
                    }),
                Tables\Columns\SelectColumn::make('type')
                    ->label('نوع الاشتراك')
                    ->options([
                        'vip_free' => 'vip Free',
                    ])
                    ->selectablePlaceholder(false)
                    ->searchable(),
                Tables\Columns\TextColumn::make('balance')
                    ->label('الرصيد')
                    ->numeric()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\Action::make('revoke')
                    ->label('إلغاء التوثيق')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->action(fn(User $record) => $record->update(['status' => 'unverified'])),
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
            'index' => Pages\ListVerifiedUsers::route('/'),
            'create' => Pages\CreateVerifiedUser::route('/create'),
            'edit' => Pages\EditVerifiedUser::route('/{record}/edit'),
        ];
    }
}
