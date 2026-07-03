<?php

namespace App\Filament\Widgets;

use App\Models\Complaint;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class LatestComplaints extends TableWidget
{
    protected static ?string $heading = 'Pengaduan Terbaru';

    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 3;

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Complaint::query()->latest()
            )

            ->columns([

                TextColumn::make('title')
                    ->label('Judul')
                    ->searchable(),

                TextColumn::make('category')
                    ->label('Kategori')
                    ->badge(),

                TextColumn::make('status')
                    ->badge()
                    ->colors([
                        'warning' => 'baru',
                        'info' => 'diproses',
                        'success' => 'selesai',
                    ]),

                TextColumn::make('user.name')
                    ->label('Pelapor'),

                TextColumn::make('created_at')
                    ->label('Tanggal')
                    ->dateTime('d M Y H:i'),
            ]);
    }
}
