<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('titles', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->timestamps();
        });

        Schema::create('genders', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->timestamps();
        });

        Schema::create('governorates', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->timestamps();
        });

        // Seed Default Arabic Data
        DB::table('titles')->insert([
            ['name' => 'السيد'],
            ['name' => 'السيدة'],
            ['name' => 'الآنسة'],
            ['name' => 'الدكتور'],
            ['name' => 'الأستاذ'],
        ]);

        DB::table('genders')->insert([
            ['name' => 'ذكر'],
            ['name' => 'أنثى'],
        ]);

        DB::table('governorates')->insert([
            ['name' => 'دمشق'],
            ['name' => 'ريف دمشق'],
            ['name' => 'حلب'],
            ['name' => 'حمص'],
            ['name' => 'حماة'],
            ['name' => 'اللاذقية'],
            ['name' => 'طرطوس'],
            ['name' => 'إدلب'],
            ['name' => 'درعا'],
            ['name' => 'السويداء'],
            ['name' => 'القنيطرة'],
            ['name' => 'دير الزور'],
            ['name' => 'الحسكة'],
            ['name' => 'الرقة'],
        ]);

        // Optional: Update Universities to Arabic if they exist (just common ones for demo)
        // Note: This assumes IDs 1 and 2 exist from previous seeds. 
        // If not, it won't crash, just affect nothing.
        // REMOVED FOR CLEAN INSTALL
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('titles');
        Schema::dropIfExists('genders');
        Schema::dropIfExists('governorates');
    }
};
