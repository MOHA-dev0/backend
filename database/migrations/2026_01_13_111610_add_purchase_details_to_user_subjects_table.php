<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('user_subjects', function (Blueprint $table) {
            $table->boolean('has_units')->default(false)->after('price_paid');
            $table->boolean('has_questions')->default(false)->after('has_units');
            $table->boolean('has_audio')->default(false)->after('has_questions');
            
            // Make access_type nullable since we're moving to granular access
            $table->string('access_type')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_subjects', function (Blueprint $table) {
            $table->dropColumn(['has_units', 'has_questions', 'has_audio']);
        });
    }
};
