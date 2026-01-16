import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class CustomCacheManager {
  static const key = 'customCacheKey';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(
        httpClient: RetryHttpClient(http.Client()),
      ),
    ),
  );
}

class RetryHttpClient extends http.BaseClient {
  final http.Client _inner;

  RetryHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add Keep-Alive header to help with connection parsing
    request.headers['Connection'] = 'keep-alive';
    
    int retries = 5; // Increased retries
    int delayMs = 1000; // Start with 1 second

    while (true) {
      try {
        return await _inner.send(request);
      } catch (e) {
        if (retries == 0) {
          // debugPrint('DEBUG: Final Retry Failed for ${request.url}: $e');
          rethrow;
        }
        
        // debugPrint('DEBUG: Connection failed, retrying ($retries left) in ${delayMs}ms... Error: $e');
        
        retries--;
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Exponential backoff (1s, 2s, 4s...)
      }
    }
  }
}
