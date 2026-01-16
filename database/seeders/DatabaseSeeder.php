<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin User
        try {
            $admin = User::firstOrCreate(
                ['email' => 'admin@admin.com'],
                [
                    'name' => 'Admin System',
                    'password' => Hash::make('password'),
                    // 'phone' => '0900000000', // Removed due to missing column
                ]
            );
            $this->command->info("User Created");
        } catch (\Throwable $e) {
            $this->command->error("User Error: " . $e->getMessage());
        }

        // 2. University - REMOVED DEMO DATA
        try {
            $this->command->info("Skipping Demo Data Seeding (Clean Install)");
        } catch (\Throwable $e) {
            //
        }
    }
}
