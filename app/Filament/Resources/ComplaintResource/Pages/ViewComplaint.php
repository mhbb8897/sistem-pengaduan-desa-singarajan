<?php

namespace App\Filament\Resources\ComplaintResource\Pages;

use App\Filament\Resources\ComplaintResource;
use Filament\Resources\Pages\ViewRecord;

class ViewComplaint extends ViewRecord
{
    protected static string $resource = ComplaintResource::class;

    protected function hasFooterActions(): bool
    {
        return true;
    }

    protected function getFooterActions(): array
    {
        return [

        ];
    }

    protected function getFooterWidgets(): array
    {
        return [
            ComplaintMessages::class,
        ];
    }
}
