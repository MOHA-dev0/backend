<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CountriesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\Country::truncate();

        $countries = [
            // Priority: Arab Countries
            ['name' => 'الجمهورية العربية السورية', 'phone_code' => '+963', 'is_active' => true],
            ['name' => 'الإمارات العربية المتحدة', 'phone_code' => '+971', 'is_active' => true],
            ['name' => 'المملكة العربية السعودية', 'phone_code' => '+966', 'is_active' => true],
            ['name' => 'جمهورية مصر العربية', 'phone_code' => '+20', 'is_active' => true],
            ['name' => 'الجمهورية العراقية', 'phone_code' => '+964', 'is_active' => true],
            ['name' => 'المملكة الأردنية الهاشمية', 'phone_code' => '+962', 'is_active' => true],
            ['name' => 'الجمهورية اللبنانية', 'phone_code' => '+961', 'is_active' => true],
            ['name' => 'دولة الكويت', 'phone_code' => '+965', 'is_active' => true],
            ['name' => 'دولة قطر', 'phone_code' => '+974', 'is_active' => true],
            ['name' => 'مملكة البحرين', 'phone_code' => '+973', 'is_active' => true],
            ['name' => 'سلطنة عمان', 'phone_code' => '+968', 'is_active' => true],
            ['name' => 'الجمهورية اليمنية', 'phone_code' => '+967', 'is_active' => true],
            ['name' => 'دولة فلسطين', 'phone_code' => '+970', 'is_active' => true],
            ['name' => 'الجمهورية الجزائرية', 'phone_code' => '+213', 'is_active' => true],
            ['name' => 'المملكة المغربية', 'phone_code' => '+212', 'is_active' => true],
            ['name' => 'الجمهورية التونسية', 'phone_code' => '+216', 'is_active' => true],
            ['name' => 'دولة ليبيا', 'phone_code' => '+218', 'is_active' => true],
            ['name' => 'جمهورية السودان', 'phone_code' => '+249', 'is_active' => true],
            ['name' => 'الجمهورية الموريتانية', 'phone_code' => '+222', 'is_active' => true],
            ['name' => 'جمهورية الصومال', 'phone_code' => '+252', 'is_active' => true],
            ['name' => 'جمهورية جيبوتي', 'phone_code' => '+253', 'is_active' => true],
            ['name' => 'جمهورية جزر القمر', 'phone_code' => '+269', 'is_active' => true],

            // Priority: Europe/Others requested
            ['name' => 'الجمهورية التركية', 'phone_code' => '+90', 'is_active' => true],
            ['name' => 'جمهورية ألمانيا الاتحادية', 'phone_code' => '+49', 'is_active' => true],

            // Others (Examples - set active to false or true as needed)
            ['name' => 'الولايات المتحدة الأمريكية', 'phone_code' => '+1', 'is_active' => true],
            ['name' => 'المملكة المتحدة', 'phone_code' => '+44', 'is_active' => true],
            ['name' => 'الجمهورية الفرنسية', 'phone_code' => '+33', 'is_active' => true],
            ['name' => 'روسيا الاتحادية', 'phone_code' => '+7', 'is_active' => true],
        ];

        foreach ($countries as $country) {
            \App\Models\Country::create($country);
        }
    }
}
