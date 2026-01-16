<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use App\Models\User;
use App\Models\Subject;
use App\Models\WalletTransaction;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Users', User::count())
                ->description('Registered students')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->chart([7, 2, 10, 3, 15, 4, 17])
                ->color('success'),

            Stat::make('Total Revenue', number_format(WalletTransaction::where('type', 'purchase')->sum('amount') * -1) . ' SYP')
                ->description('Total course sales')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('primary'),

            Stat::make('Active Vouchers', \App\Models\Voucher::where('is_used', false)->count())
                ->description('Available for use')
                ->color('warning'),
        ];
    }
}
