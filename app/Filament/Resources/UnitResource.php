<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UnitResource\Pages;
use App\Filament\Resources\UnitResource\RelationManagers;
use App\Models\Unit;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class UnitResource extends Resource
{
    protected static ?string $model = Unit::class;

    protected static ?string $navigationGroup = 'الهيكل الأكاديمي';
    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationLabel = 'الوحدات';
    protected static ?int $navigationSort = 14;

    public static function getModelLabel(): string
    {
        return 'وحدة';
    }

    public static function getPluralModelLabel(): string
    {
        return 'الوحدات';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الوحدة')
                    ->schema([
                        Forms\Components\Select::make('subject_id')
                            ->label('المادة')
                            ->relationship('subject', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Forms\Components\TextInput::make('title')
                            ->label('عنوان الوحدة')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('page_count')
                            ->label('عدد الصفحات')
                            ->numeric()
                            ->default(0),
                        Forms\Components\Toggle::make('is_free')
                            ->label('وحدة مجانية (Unlocked)')
                            ->default(false),
                    ])->columns(2),

                Forms\Components\Section::make('ملف المحتوى (Word/PDF)')
                    ->description('يمكنك رفع ملف أو إدخال رابط Google Doc')
                    ->schema([
                        Forms\Components\TextInput::make('google_doc_url')
                            ->label('رابط Google Doc')
                            ->url()
                            ->placeholder('https://docs.google.com/document/d/...')
                            ->helperText('أدخل رابط ملف Google Docs للعرض المباشر'),
                        Forms\Components\FileUpload::make('file_url')
                            ->label('أو رفع ملف (PDF/Word)')
                            ->directory('unit-files')
                            ->maxSize(51200) // 50MB in KB
                            ->helperText('الحد الأقصى 50 ميجابايت - PDF أو Word'),
                    ]),

                Forms\Components\Section::make('التسجيل الصوتي')
                    ->description('رفع ملخص صوتي للوحدة')
                    ->schema([
                        Forms\Components\FileUpload::make('audio_url')
                            ->label('ملف الصوت')
                            ->directory('unit-audios')
                            ->maxSize(102400) // 100MB in KB
                            ->helperText('الحد الأقصى 100 ميجابايت - MP3, WAV, M4A'),
                        Forms\Components\TextInput::make('audio_title')
                            ->label('عنوان التسجيل')
                            ->placeholder('مثال: ملخص صوتي للوحدة')
                            ->maxLength(255),
                        Forms\Components\TextInput::make('audio_duration')
                            ->label('المدة (بالثواني)')
                            ->numeric()
                            ->placeholder('مثال: 300 للـ 5 دقائق')
                            ->helperText('اختياري - لعرض مدة التسجيل'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('subject.name')
                    ->label('المادة')
                    ->sortable()
                    ->searchable()
                    ->limit(20),
                Tables\Columns\IconColumn::make('is_free')
                    ->boolean()
                    ->label('مجاني'),
                Tables\Columns\TextColumn::make('page_count')
                    ->numeric()
                    ->label('صفحات'),
                Tables\Columns\IconColumn::make('has_file')
                    ->label('ملف')
                    ->boolean()
                    ->getStateUsing(fn($record) => !empty($record->google_doc_url) || !empty($record->file_url))
                    ->trueIcon('heroicon-o-document-text')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('gray'),
                Tables\Columns\IconColumn::make('has_audio')
                    ->label('صوت')
                    ->boolean()
                    ->getStateUsing(fn($record) => !empty($record->audio_url))
                    ->trueIcon('heroicon-o-speaker-wave')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('warning')
                    ->falseColor('gray'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->reorderable('sort_order')
            ->defaultSort('sort_order')
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
            'index' => Pages\ListUnits::route('/'),
            'create' => Pages\CreateUnit::route('/create'),
            'edit' => Pages\EditUnit::route('/{record}/edit'),
        ];
    }
}
