<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$universities = \App\Models\University::all();

echo "Universities found: " . $universities->count() . "\n";

foreach ($universities as $uni) {
    echo "Uni: {$uni->name} (ID: {$uni->id})\n";
    $faculties = $uni->faculties;
    echo "  Faculties: " . $faculties->count() . "\n";

    foreach ($faculties as $faculty) {
        echo "    - Faculty: {$faculty->name} (ID: {$faculty->id})\n";
        $yearsCount = \App\Models\AcademicYear::where('faculty_id', $faculty->id)->count();
        echo "      -> Academic Years: {$yearsCount}\n";
    }
}
