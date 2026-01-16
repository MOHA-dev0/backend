<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. App Settings: Discounts
        Schema::table('app_settings', function (Blueprint $table) {
            if (!Schema::hasColumn('app_settings', 'discount_2_items')) {
                $table->integer('discount_2_items')->default(0)->after('share_text');
            }
            if (!Schema::hasColumn('app_settings', 'discount_3_items')) {
                $table->integer('discount_3_items')->default(0)->after('discount_2_items');
            }
        });

        // 2. Subjects: Subscription Prices
        Schema::table('subjects', function (Blueprint $table) {
            if (!Schema::hasColumn('subjects', 'price_unit')) {
                $table->decimal('price_unit', 10, 2)->default(0)->after('image_url');
            }
            if (!Schema::hasColumn('subjects', 'price_question')) {
                $table->decimal('price_question', 10, 2)->default(0)->after('price_unit');
            }
            if (!Schema::hasColumn('subjects', 'price_audio')) {
                $table->decimal('price_audio', 10, 2)->default(0)->after('price_question');
            }
        });

        // 3. Units: Details & Locking
        Schema::table('units', function (Blueprint $table) {
            if (!Schema::hasColumn('units', 'google_doc_url')) {
                $table->string('google_doc_url')->nullable()->after('title');
            }
            if (!Schema::hasColumn('units', 'page_count')) {
                $table->integer('page_count')->default(0)->after('google_doc_url');
            }
            if (!Schema::hasColumn('units', 'is_free')) {
                $table->boolean('is_free')->default(false)->after('page_count');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tables', function (Blueprint $table) {
            //
        });
    }
};
