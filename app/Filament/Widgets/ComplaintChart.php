<?php

namespace App\Filament\Widgets;

use App\Models\Complaint;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class ComplaintChart extends ChartWidget
{
    protected static ?string $heading = 'Grafik Pengaduan 30 Hari Terakhir';

    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $labels = [];
        $data = [];

        for ($i = 29; $i >= 0; $i--) {

            $date = Carbon::now()->subDays($i);

            $labels[] = $date->format('d M');

            $data[] = Complaint::whereDate('created_at', $date)->count();
        }

        return [
            'datasets' => [
                [
                    'label' => 'Jumlah Pengaduan',
                    'data' => $data,
                ],
            ],

            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
