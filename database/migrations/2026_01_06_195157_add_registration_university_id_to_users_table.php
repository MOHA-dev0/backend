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
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('registration_university_id')->nullable()->constrained('registration_universities')->nullOnDelete();

            // Drop the old FK constraint if it exists to avoid errors when inserting IDs that don't match 'universities'
            // We use array syntax for dropForeign
            $table->dropForeign(['university_id']);

            // Make university_id nullable
            $table->unsignedBigInteger('university_id')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['registration_university_id']);
            $table->dropColumn('registration_university_id');
            // Re-adding the old FK might fail if data is inconsistent, so skipping strict reverse for now or adding basic FK
        });
    }
};
