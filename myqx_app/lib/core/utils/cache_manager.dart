import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/services/spotify_search_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App version constant for cache invalidation
const String appVersion = '1.0.0';
const String lastVersionKey = 'last_app_version';

/// Utility class to manage cache across the application
class CacheManager {
  // Singleton pattern
  static final CacheManager _instance = CacheManager._internal();
  
  factory CacheManager() {
    return _instance;
  }
  
  CacheManager._internal();

  /// Clear all caches in the application
  Future<void> clearAllCaches() async {
    try {
      // Clear search service caches
      final searchService = SearchService();
      searchService.clearRatingsCache();
      debugPrint('[DEBUG] Rating caches cleared');
      
      // Clear spotify search service caches
      final spotifySearchService = SpotifySearchService();
      spotifySearchService.clearCache();
      debugPrint('[DEBUG] Spotify search cache cleared');
    } catch (e) {
      debugPrint('[ERROR] Failed to clear caches: $e');
    }
  }
  
  /// Clear only search-related caches
  Future<void> clearSearchCaches() async {
    try {
      final spotifySearchService = SpotifySearchService();
      spotifySearchService.clearCache();
      debugPrint('[DEBUG] Spotify search cache cleared');
    } catch (e) {
      debugPrint('[ERROR] Failed to clear search caches: $e');
    }
  }
    /// Clear only ratings caches
  Future<void> clearRatingCaches() async {
    try {
      final searchService = SearchService();
      searchService.clearRatingsCache();
      debugPrint('[DEBUG] Rating caches cleared');
    } catch (e) {
      debugPrint('[ERROR] Failed to clear rating caches: $e');
    }
  }
  
  /// Checks if app version has changed and clears caches if necessary
  /// Returns true if caches were cleared, false otherwise
  Future<bool> checkAndClearCachesOnVersionChange() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastVersion = prefs.getString(lastVersionKey);
      
      // If version changed or first install, clear all caches
      if (lastVersion != appVersion) {
        debugPrint('[DEBUG] App version changed from $lastVersion to $appVersion');
        debugPrint('[DEBUG] Clearing all caches due to version change');
        
        await clearAllCaches();
        await prefs.setString(lastVersionKey, appVersion);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ERROR] Failed to check app version: $e');
      return false;
    }
  }
}
