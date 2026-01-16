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
        Schema::table('users', function (Blueprint $table) {
            $table->string('second_name')->nullable()->after('name');
            $table->foreignId('university_id')->nullable()->constrained()->nullOnDelete()->after('second_name');
            $table->foreignId('academic_year_id')->nullable()->constrained()->nullOnDelete()->after('university_id');
            $table->string('title')->nullable()->after('academic_year_id'); // e.g., Mr, Mrs
            $table->string('gender')->nullable()->after('title'); // male, female
            $table->string('governorate')->nullable()->after('gender');
            $table->text('address')->nullable()->after('governorate');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['university_id']);
            $table->dropForeign(['academic_year_id']);
            $table->dropColumn([
                'second_name',
                'university_id', 
                'academic_year_id',
                'title',
                'gender', 
                'governorate', 
                'address'
            ]);
        });
    }
};
