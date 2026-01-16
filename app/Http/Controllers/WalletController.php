<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function redeem(Request $request)
    {
        $request->validate([
            'code' => 'required|string|exists:vouchers,code',
        ]);

        $user = $request->user();

        try {
            DB::transaction(function () use ($user, $request) {
                // Lock voucher for update
                $voucher = \App\Models\Voucher::where('code', $request->code)
                    ->lockForUpdate()
                    ->firstOrFail();

                if ($voucher->is_used) {
                    throw new \Exception('This voucher has already been used.');
                }

                // Update Voucher
                $voucher->update([
                    'is_used' => true,
                    'user_id' => $user->id,
                ]);

                // Update User Balance
                $user->increment('balance', $voucher->amount);

                // Create Transaction Log
                $user->transactions()->create([
                    'amount' => $voucher->amount,
                    'type' => 'deposit',
                    'description' => "Redeemed voucher: {$voucher->code}",
                ]);
            });

            return response()->json([
                'message' => 'Voucher redeemed successfully',
                'balance' => $user->refresh()->balance,
            ]);

        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }
}
