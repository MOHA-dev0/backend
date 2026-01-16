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
        Schema::table('subjects', function (Blueprint $table) {
            if (!Schema::hasColumn('subjects', 'course_type_id')) {
                $table->foreignId('course_type_id')->nullable()->constrained('course_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('subjects', 'is_optional')) {
                $table->boolean('is_optional')->default(false);
            }
            if (!Schema::hasColumn('subjects', 'sort_order')) {
                $table->integer('sort_order')->default(0);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            //
        });
    }
};
