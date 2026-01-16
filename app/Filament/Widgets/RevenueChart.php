<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\WalletTransaction;
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;

class RevenueChart extends ChartWidget
{
    protected static ?string $heading = 'Revenue (Last 30 Days)';
    protected static string $color = 'info';

    protected function getData(): array
    {
        // Requires 'flowframe/laravel-trend' package ideally, or manual grouping.
        // For prototype, we'll manually group or just show basic data.
        // Assuming we rely on basic Carbon grouping.

        $data = WalletTransaction::where('type', 'purchase')
            ->selectRaw('DATE(created_at) as date, SUM(amount) * -1 as total')
            ->groupBy('date')
            ->orderBy('date')
            ->limit(30)
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Income (SYP)',
                    'data' => $data->map(fn($row) => $row->total)->toArray(),
                ],
            ],
            'labels' => $data->map(fn($row) => $row->date)->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
