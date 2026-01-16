<?php

namespace App\Filament\Resources\VoucherResource\Pages;

use App\Filament\Resources\VoucherResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateVoucher extends CreateRecord
{
    protected static string $resource = VoucherResource::class;

    protected static bool $canCreateAnother = false;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function handleRecordCreation(array $data): \Illuminate\Database\Eloquent\Model
    {
        $mode = $data['creation_mode'];
        $amount = $data['amount'];

        if ($mode === 'direct') {
            return \Illuminate\Support\Facades\DB::transaction(function () use ($data, $amount) {
                // 1. Create Used Voucher (Receipt)
                $voucher = static::getModel()::create([
                    'code' => 'DEP-' . strtoupper(\Illuminate\Support\Str::random(12)),
                    'amount' => $amount,
                    'is_used' => true,
                    'user_id' => $data['user_id'],
                    'batch_id' => 'DIRECT-' . time(),
                ]);

                // 2. Update User Balance
                $user = \App\Models\User::find($data['user_id']);
                if ($user) {
                    $user->increment('balance', $amount);

                    // 3. Create Wallet Transaction
                    \App\Models\WalletTransaction::create([
                        'user_id' => $user->id,
                        'amount' => $amount,
                        'type' => 'deposit',
                        'description' => 'إيداع مباشر من لوحة التحكم (قسيمة #' . $voucher->id . ')',
                    ]);
                }

                return $voucher;
            });
        }

        // Generate Mode
        $quantity = (int) ($data['quantity'] ?? 1);
        $batchId = \Illuminate\Support\Str::random(8); // Fixed syntax from previous snippet if any
        $vouchers = [];
        $lastVoucher = null;

        // If specific code provided
        if ($quantity === 1 && !empty($data['code'])) {
            $lastVoucher = static::getModel()::create([
                'code' => $data['code'],
                'amount' => $amount,
                'is_used' => false,
                'batch_id' => $batchId,
            ]);
            return $lastVoucher;
        }

        // Bulk Logic
        for ($i = 0; $i < $quantity; $i++) {
            $vouchers[] = [
                'code' => strtoupper(\Illuminate\Support\Str::random(12)),
                'amount' => $amount,
                'is_used' => false,
                'batch_id' => $batchId,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        static::getModel()::insert($vouchers);

        // Return latest
        return static::getModel()::where('batch_id', $batchId)->latest()->first();
    }


}
