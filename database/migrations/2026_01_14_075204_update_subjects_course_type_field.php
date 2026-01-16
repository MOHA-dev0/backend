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
        Schema::table('subjects', function (Blueprint $table) {
            // Drop foreign key first if it exists. 
            // We assume standard naming: subjects_course_type_id_foreign
             try {
                $table->dropForeign(['course_type_id']);
            } catch (\Exception $e) {}
            
            $table->dropColumn('course_type_id');
            $table->string('course_type')->default('silver'); // 'gold' or 'silver'
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
             $table->unsignedBigInteger('course_type_id')->nullable();
             $table->dropColumn('course_type');
        });
    }
};
