<?php

namespace App\Filament\Widgets;

use App\Models\Complaint;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected int|string|array $columnSpan = 'full';

    protected function getStats(): array
    {
        return [
            Stat::make('Total Pengaduan', Complaint::count())
                ->description('Semua pengaduan')
                ->descriptionIcon('heroicon-m-document-text')
                ->chart([7, 9, 12, 10, 14, 18, Complaint::count()])
                ->color('primary'),

            Stat::make('Diproses', Complaint::where('status', 'diproses')->count())
                ->description('Sedang ditindaklanjuti')
                ->descriptionIcon('heroicon-m-arrow-path')
                ->chart([7, 9, 12, 10, 14, 18, Complaint::count()])
                ->color('info'),

            Stat::make('Selesai', Complaint::where('status', 'selesai')->count())
                ->description('Pengaduan selesai')
                ->descriptionIcon('heroicon-m-check-circle')
                ->chart([7, 9, 12, 10, 14, 18, Complaint::count()])
                ->color('success'),

        ];
    }
}
