<?php

namespace App\Filament\Resources\ComplaintResource\Pages;

use App\Filament\Resources\ComplaintResource;
use App\Models\ComplaintMessage;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Pages\EditRecord;

class EditComplaint extends EditRecord
{
    protected static string $resource = ComplaintResource::class;

    protected static ?string $pollingInterval = '10s';

    protected static bool $isLazy = true;

    public function form(Form $form): Form
    {
        return $form->schema([

            /* ===============================
             * INFORMASI PENGADUAN (READ ONLY)
             * =============================== */
            Section::make('Informasi Pengaduan')
                ->schema([
                    Grid::make(2)->schema([
                        TextInput::make('title')
                            ->label('Judul')
                            ->disabled(),

                        TextInput::make('category')
                            ->label('Kategori')
                            ->disabled(),

                        TextInput::make('status')
                            ->label('Status Saat Ini')
                            ->disabled(),

                        TextInput::make('created_at')
                            ->label('Tanggal Pengaduan')
                            ->disabled(),
                    ]),
                ]),

            /* ===============================
             * DATA TERDEKRIPSI (READ ONLY)
             * =============================== */
            Section::make('Data Terdekripsi (AES + RSA)')
                ->schema([
                    Grid::make(2)->schema([
                        TextInput::make('decrypted_content.lokasi')
                            ->label('📍 Lokasi Kejadian')
                            ->disabled()
                            ->dehydrated(false)
                            ->formatStateUsing(fn ($record) => $record->decrypted_content['lokasi'] ?? '-'),

                        TextInput::make('decrypted_content.waktu_kejadian')
                            ->label('🕒 Waktu Kejadian')
                            ->disabled()
                            ->dehydrated(false)
                            ->formatStateUsing(fn ($record) => $record->decrypted_content['waktu_kejadian'] ?? '-'),

                        TextInput::make('decrypted_content.pelaku')
                            ->label('👤 Pihak Terlibat')
                            ->disabled()
                            ->dehydrated(false)
                            ->formatStateUsing(fn ($record) => $record->decrypted_content['pelaku'] ?? '-'),

                        Textarea::make('decrypted_content.deskripsi')
                            ->label('📝 Isi Pengaduan')
                            ->rows(4)
                            ->disabled()
                            ->dehydrated(false)
                            ->formatStateUsing(fn ($record) => $record->decrypted_content['deskripsi'] ?? '-'),
                    ]),
                ]),

            /* ===============================
             * RIWAYAT PESAN (READ ONLY)
             * =============================== */

            Section::make('Riwayat Percakapan')
                ->schema([
                    Repeater::make('messages')
                        ->relationship('messages')
                        ->schema([
                            TextInput::make('sender_role')
                                ->label('Pengirim')
                                ->disabled(),

                            Textarea::make('message')
                                ->label('Pesan')
                                ->rows(2)
                                ->disabled(),
                        ])
                        ->disabled()
                        ->dehydrated(false)
                        ->columnSpanFull(),
                ]),

            Section::make('Balas Pengaduan')
                ->schema([
                    Textarea::make('reply_message')
                        ->label('Pesan Balasan')
                        ->rows(4)
                        ->required()
                        ->dehydrated(false),
                ])
                ->headerActions([
                    \Filament\Forms\Components\Actions\Action::make('kirim')
                        ->label('Kirim Balasan')
                        ->action('save'),
                ]),

            /* ===============================
             * UBAH STATUS (AKTIF)
             * =============================== */
            Section::make('Ubah Status Laporan')
                ->schema([
                    Select::make('status')
                        ->label('Status Baru')
                        ->options([
                            'diajukan' => 'Diajukan',
                            'diproses' => 'Diproses',
                            'selesai' => 'Selesai',
                        ])
                        ->required(),
                ]),

            /* ===============================
             * BALAS PESAN (AKTIF)
             * =============================== */
            //     Section::make('Balas Pengaduan')
            //         ->schema([
            //             Textarea::make('reply_message')
            //                 ->label('Pesan Balasan')
            //                 ->rows(4)
            //                 ->required(),
            //         ]),
        ]);
    }

    /**
     * Simpan balasan setelah update
     */
    protected function afterSave(): void
    {
        if (! empty($this->data['reply_message'])) {
            ComplaintMessage::create([
                'complaint_id' => $this->record->id,
                'user_id' => auth()->id(),
                'sender_role' => 'admin',
                'message' => $this->data['reply_message'],
            ]);
            $this->dispatch('$refresh');
        }
    }
}
