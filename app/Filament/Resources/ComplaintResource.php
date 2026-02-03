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
use Filament\Support\Enums\MaxWidth;
use Filament\Tables\Actions\Action;
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
            ->actions([
                Action::make('viewDetail')
                    ->label('Lihat')
                    ->icon('heroicon-o-eye')
                    ->modalWidth(MaxWidth::ThreeExtraLarge)
                    ->modalHeading('View Complaint')
                    // 1. Tampilan Detail Menggunakan View Custom
                    ->modalContent(fn (Complaint $record) => view('filament.pages.complaint-modal-detail', ['record' => $record]))

                    // 2. Form untuk Update Status di bagian bawah modal
                    ->form([
                        \Filament\Forms\Components\Select::make('status')
                            ->options([
                                'diajukan' => 'Diajukan',
                                'diproses' => 'Diproses',
                                'selesai' => 'Selesai',
                            ])
                            ->required()
                            ->label('Update Status Pengaduan'),
                    ])
                    ->fillForm(fn (Complaint $record): array => [
                        'status' => $record->status,
                    ])
                    ->action(function (array $data, Complaint $record): void {
                        $record->update([
                            'status' => $data['status'],
                        ]);

                        \Filament\Notifications\Notification::make()
                            ->title('Status berhasil diperbarui')
                            ->success()
                            ->send();
                    })
                    ->modalSubmitActionLabel('Simpan Perubahan Status'),
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
        ];
    }
}
