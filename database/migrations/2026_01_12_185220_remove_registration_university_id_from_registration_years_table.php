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
        Schema::table('registration_years', function (Blueprint $table) {
            $table->dropForeign(['registration_university_id']);
            $table->dropColumn('registration_university_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('registration_years', function (Blueprint $table) {
            $table->foreignId('registration_university_id')->constrained()->cascadeOnDelete();
        });
    }
};
