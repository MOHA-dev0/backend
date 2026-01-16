<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubjectResource\Pages;
use App\Filament\Resources\SubjectResource\RelationManagers;
use App\Models\Subject;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SubjectResource extends Resource
{
    protected static ?string $model = Subject::class;

    protected static ?string $navigationIcon = 'heroicon-o-book-open';
    protected static ?string $navigationGroup = 'الهيكل الأكاديمي';
    protected static ?int $navigationSort = 10;

    public static function getModelLabel(): string
    {
        return 'مادة';
    }

    public static function getPluralModelLabel(): string
    {
        return 'المواد';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                // University Selection
                Forms\Components\Select::make('university_id')
                    ->label('الجامعة')
                    ->options(\App\Models\University::all()->pluck('name', 'id'))
                    ->live()
                    ->afterStateHydrated(function (Forms\Components\Select $component, $record) {
                        if ($record && $record->academicYear) {
                            $component->state($record->academicYear->university_id);
                        }
                    })
                    ->afterStateUpdated(fn(Forms\Set $set) => $set('academic_year_id', null))
                    ->required()
                    ->searchable()
                    ->preload()
                    ->dehydrated(false),

                // Academic Year Selection (Filtered by University)
                Forms\Components\Select::make('academic_year_id')
                    ->label('السنة الدراسية')
                    ->options(function (Forms\Get $get) {
                        $universityId = $get('university_id');
                        if (!$universityId) {
                            return [];
                        }
                        // Direct filter by university_id
                        return \App\Models\AcademicYear::where('university_id', $universityId)->pluck('name', 'id');
                    })
                    ->searchable()
                    ->preload()
                    ->required(),

                Forms\Components\Select::make('course_type')
                    ->label('نوع المقرر')
                    ->options([
                        'gold' => 'مقرر ذهبي',
                        'silver' => 'مقرر فضي',
                    ])
                    ->default('silver')
                    ->required()
                    ->native(false),

                Forms\Components\TextInput::make('name')
                    ->label('اسم المادة')
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('code')
                    ->label('الكود')
                    ->maxLength(255),

                Forms\Components\Select::make('exam_type')
                    ->label('نظام الامتحان')
                    ->options([
                        'automation' => 'أتمتة',
                        'essay' => 'مقالي',
                    ])
                    ->default('automation')
                    ->required(),

                Forms\Components\Toggle::make('is_optional')
                    ->label('مادة اختيارية')
                    ->onColor('success')
                    ->offColor('danger')
                    ->default(false)
                    ->inline(false), // Ensure it takes its own space or aligns differently

                Forms\Components\Section::make('أسعار الاشتراك')
                    ->schema([
                        Forms\Components\TextInput::make('price_unit')
                            ->label('سعر الوحدة')
                            ->numeric()
                            ->default(0),
                        Forms\Components\TextInput::make('price_question')
                            ->label('سعر السؤال')
                            ->numeric()
                            ->default(0),
                        Forms\Components\TextInput::make('price_audio')
                            ->label('سعر الصوتيات')
                            ->numeric()
                            ->default(0),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->reorderable('sort_order')
            ->defaultSort('sort_order')
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('المادة')
                    ->searchable(),
                Tables\Columns\TextColumn::make('academicYear.name')
                    ->label('السنة')
                    ->sortable(),
                Tables\Columns\TextColumn::make('course_type')
                    ->label('نوع المقرر')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'gold' => 'مقرر ذهبي',
                        'silver' => 'مقرر فضي',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'gold' => 'warning', // Gold-ish usually yellow/warning in filament
                        'silver' => 'gray',
                        default => 'gray',
                    })
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_optional')
                    ->boolean()
                    ->label('Optional?'),
                Tables\Columns\TextColumn::make('code')
                    ->searchable(),
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
            'index' => Pages\ListSubjects::route('/'),
            'create' => Pages\CreateSubject::route('/create'),
            'edit' => Pages\EditSubject::route('/{record}/edit'),
        ];
    }
}
