<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VerificationRequestResource\Pages;
use App\Filament\Resources\VerificationRequestResource\RelationManagers;
use App\Models\VerificationRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class VerificationRequestResource extends Resource
{
    protected static ?string $model = VerificationRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-check';
    protected static ?string $navigationGroup = 'إدارة المستخدمين';
    protected static ?int $navigationSort = 4;

    public static function getModelLabel(): string
    {
        return 'طلب توثيق';
    }

    public static function getPluralModelLabel(): string
    {
        return 'طلبات التوثيق';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required()
                    ->disabled()
                    ->label('الطالب'),
                Forms\Components\TextInput::make('university_id_number')
                    ->label('الرقم الجامعي')
                    ->required(),
                Forms\Components\DatePicker::make('birth_date')
                    ->label('تاريخ الميلاد')
                    ->required(),
                Forms\Components\TextInput::make('status')
                    ->label('الحالة')
                    ->disabled(),
                Forms\Components\FileUpload::make('documents')
                    ->label('المستندات')
                    ->multiple()
                    ->disk('public')
                    ->directory('verification_docs')
                    ->visibility('public')
                    ->openable()
                    ->downloadable()
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('اسم الطالب')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('university_id_number')
                    ->label('الرقم الجامعي')
                    ->searchable(),
                Tables\Columns\TextColumn::make('birth_date')
                    ->label('المواليد')
                    ->date(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->since(),
                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                        default => $state,
                    }),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ])
                    ->label('تصفية حسب الحالة'),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('قبول وتوثيق')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn($record) => $record->status === 'pending')
                    ->action(function ($record) {
                        $record->update(['status' => 'approved']);
                        // Update User Status
                        $record->user->update(['status' => 'verified']); // Or 'active' + is_verified flag? User model uses status 'verified'.
            
                        // Send Notification?
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('رفض')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn($record) => $record->status === 'pending')
                    ->action(function ($record) {
                        $record->update(['status' => 'rejected']);
                        $record->user->update(['status' => 'active']); // Revert to active or specific status
                    }),
                Tables\Actions\ViewAction::make(),
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
            'index' => Pages\ListVerificationRequests::route('/'),
            'create' => Pages\CreateVerificationRequest::route('/create'),
            'edit' => Pages\EditVerificationRequest::route('/{record}/edit'),
        ];
    }
}
