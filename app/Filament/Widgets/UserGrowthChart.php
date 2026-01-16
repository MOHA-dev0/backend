<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\User;

class UserGrowthChart extends ChartWidget
{
    protected static ?string $heading = 'New Registrations (Last 30 Days)';
    protected static string $color = 'success';

    protected function getData(): array
    {
        // Requires 'flowframe/laravel-trend' package ideally.
        // Manual grouping by date.

        $data = User::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->groupBy('date')
            ->orderBy('date')
            ->limit(30)
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'New Users',
                    'data' => $data->map(fn($row) => $row->count)->toArray(),
                ],
            ],
            'labels' => $data->map(fn($row) => $row->date)->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
