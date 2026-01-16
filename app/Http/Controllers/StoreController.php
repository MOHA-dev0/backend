<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StoreController extends Controller
{
    public function purchaseSubject(Request $request)
    {
        $request->validate([
            'subject_id' => 'required|exists:subjects,id',
            'buy_units' => 'boolean',
            'buy_questions' => 'boolean',
            'buy_audio' => 'boolean',
        ]);

        $user = $request->user();
        $subject = \App\Models\Subject::findOrFail($request->subject_id);

        // Check if user already owns this subject
        $existing = $user->subjects()->where('subject_id', $subject->id)->first();
        
        // Calculate prices
        $priceUnit = $request->buy_units ? (float) $subject->price_unit : 0;
        $priceQuestion = $request->buy_questions ? (float) $subject->price_question : 0;
        $priceAudio = $request->buy_audio ? (float) $subject->price_audio : 0;

        // Count selected items
        $selectedCount = ($request->buy_units ? 1 : 0) + ($request->buy_questions ? 1 : 0) + ($request->buy_audio ? 1 : 0);
        
        if ($selectedCount === 0) {
            return response()->json(['message' => 'يرجى اختيار عنصر واحد على الأقل'], 400);
        }

        // Calculate subtotal
        $subtotal = $priceUnit + $priceQuestion + $priceAudio;

        // Get discount from settings
        $settings = \App\Models\AppSetting::current();
        $discountPercent = 0;
        if ($selectedCount === 2) {
            $discountPercent = $settings->discount_2_items ?? 0;
        } elseif ($selectedCount >= 3) {
            $discountPercent = $settings->discount_3_items ?? 0;
        }

        $discountAmount = $subtotal * ($discountPercent / 100);
        $finalPrice = $subtotal - $discountAmount;

        // Check balance
        if ($user->balance < $finalPrice) {
            return response()->json([
                'message' => 'رصيدك غير كافٍ',
                'required' => $finalPrice,
                'current' => $user->balance
            ], 400);
        }

        try {
            DB::transaction(function () use ($user, $subject, $finalPrice, $request, $existing) {
                // Deduct Balance
                $user->decrement('balance', $finalPrice);

                if ($existing) {
                    // Update existing record
                    $updateData = [];
                    if ($request->buy_units) $updateData['has_units'] = true;
                    if ($request->buy_questions) $updateData['has_questions'] = true;
                    if ($request->buy_audio) $updateData['has_audio'] = true;
                    
                    $user->subjects()->updateExistingPivot($subject->id, $updateData);
                } else {
                    // Create new record
                    $user->subjects()->attach($subject->id, [
                        'access_type' => null,
                        'price_paid' => $finalPrice,
                        'has_units' => $request->buy_units ?? false,
                        'has_questions' => $request->buy_questions ?? false,
                        'has_audio' => $request->buy_audio ?? false,
                    ]);
                }

                // Log Transaction
                $items = [];
                if ($request->buy_units) $items[] = 'الوحدات';
                if ($request->buy_questions) $items[] = 'الأسئلة';
                if ($request->buy_audio) $items[] = 'الصوتيات';
                
                $user->transactions()->create([
                    'amount' => -$finalPrice,
                    'type' => 'purchase',
                    'description' => "شراء {$subject->name}: " . implode(', ', $items),
                ]);
            });

            return response()->json([
                'message' => 'تمت عملية الشراء بنجاح',
                'balance' => $user->refresh()->balance,
            ]);

        } catch (\Exception $e) {
            \Log::error('Purchase failed: ' . $e->getMessage());
            return response()->json(['message' => 'فشلت العملية، يرجى المحاولة لاحقاً'], 500);
        }
    }
}
