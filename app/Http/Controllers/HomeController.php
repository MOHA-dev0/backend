<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SliderAd;

class HomeController extends Controller
{
    public function getSliderAds()
    {
        return response()->json(
            SliderAd::where('is_active', true)
                ->orderBy('sort_order')
                ->get()
        );
    }

    public function serveStorageFile($path)
    {
        $path = str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $path);
        $filePath = storage_path('app' . DIRECTORY_SEPARATOR . 'public' . DIRECTORY_SEPARATOR . $path);

        \Illuminate\Support\Facades\Log::info("Serving file: " . $path);
        \Illuminate\Support\Facades\Log::info("Full path: " . $filePath);

        if (!file_exists($filePath)) {
            \Illuminate\Support\Facades\Log::error("File not found: " . $filePath);
            abort(404);
        }

        // Clear output buffer to remove potential PHP warnings/text
        if (ob_get_length()) {
            ob_end_clean();
        }

        // Aggressively clear ALL output buffers
        while (ob_get_level()) {
            ob_end_clean();
        }

        // Raw PHP Headers to bypass Laravel Response overhead
        header('Content-Description: File Transfer');
        header('Content-Type: ' . mime_content_type($filePath));
        header('Content-Disposition: inline; filename="' . basename($filePath) . '"');
        // header('Content-Length: ' . filesize($filePath)); // REMOVED: Causing connection close if mismatch
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, OPTIONS');
        header('Connection: close');
        header('Pragma: public');
        header('Cache-Control: must-revalidate');
        header('Expires: 0');

        flush(); // Flush headers
        readfile($filePath);
        exit; // Terminate script immediately to prevent any extra output
    }
}
