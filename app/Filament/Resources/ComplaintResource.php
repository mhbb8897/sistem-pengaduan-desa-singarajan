<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ComplaintResource\Pages;
use App\Models\Complaint;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ComplaintResource extends Resource
{
    protected static ?string $model = Complaint::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')->label('Pelapor')->searchable(),
                TextColumn::make('title')->label('Judul'),
                TextColumn::make('category')->badge(),
                TextColumn::make('status')->badge(),
                TextColumn::make('created_at')->dateTime(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->options([
                        'Fasilitas' => 'Fasilitas',
                        'Kinerja Perangkat' => 'Kinerja Perangkat',
                        'Pelanggaran HAM' => 'Pelanggaran HAM',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(), // WAJIB untuk melihat hasil dekripsi
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Section::make('Informasi Pengaduan')
                ->schema([
                    TextEntry::make('title')->label('Judul'),
                    TextEntry::make('category')->label('Kategori'),
                    TextEntry::make('status')->badge(),
                    TextEntry::make('created_at')->dateTime(),
                ])
                ->columns(2),

            Section::make('Data Terdekripsi (AES + RSA)')
                ->description('Data ini hanya dapat dibaca oleh admin melalui private key.')
                ->schema([
                    Grid::make(2)->schema([

                        TextEntry::make('decrypted_content.lokasi')
                            ->label('📍 Lokasi Kejadian'),

                        TextEntry::make('decrypted_content.waktu_kejadian')
                            ->label('🕒 Waktu Kejadian'),

                        TextEntry::make('decrypted_content.pelaku')
                            ->label('👤 Pihak Terlibat')
                            ->visible(fn ($record) => ! empty($record->decrypted_content['pelaku'] ?? null)
                            ),

                        TextEntry::make('decrypted_content.deskripsi')
                            ->label('📝 Isi Pengaduan')
                            ->columnSpanFull()
                            ->prose(),
                    ]),
                ]),
            Section::make('Percakapan')
                ->schema([
                    RepeatableEntry::make('messages')
                        ->schema([
                            TextEntry::make('sender_role')->badge(),
                            TextEntry::make('message'),
                            TextEntry::make('created_at')->since(),
                        ]),
                ]),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListComplaints::route('/'),
            'create' => Pages\CreateComplaint::route('/create'),
            'edit' => Pages\EditComplaint::route('/{record}/edit'),
            // 'view' => Pages\ViewComplaint::route('/{record}/view'),
        ];
    }
}
