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
        Schema::table('units', function (Blueprint $table) {
            $table->string('audio_url')->nullable()->after('is_free');
            $table->string('audio_title')->nullable()->after('audio_url');
            $table->integer('audio_duration')->nullable()->after('audio_title'); // Duration in seconds
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('units', function (Blueprint $table) {
            $table->dropColumn(['audio_url', 'audio_title', 'audio_duration']);
        });
    }
};
