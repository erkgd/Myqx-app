import 'package:flutter/material.dart';
import 'dart:collection';

/// Service to manage memory usage and optimize performance by
/// implementing smart caching strategies and resource management
class PerformanceService {
  // Singleton pattern
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  // LRU Cache for profile images with a maximum size
  final int _maxImageCacheSize = 30; // Maximum number of profile images to cache
  final LinkedHashMap<String, ImageProvider> _imageCache = LinkedHashMap();
  
  // Track memory usage of cached resources
  int _estimatedCacheSize = 0; // in KB
  final int _maxCacheSize = 10 * 1024; // 10MB in KB
  
  // Cache for profile data
  final Map<String, DateTime> _dataExpiryTimes = {};
  
  /// Get a cached image or load it from network
  ImageProvider getProfileImage(String url) {
    // Check if already cached
    if (_imageCache.containsKey(url)) {
      // Move to end of LRU list (mark as recently used)
      final image = _imageCache.remove(url);
      _imageCache[url] = image!;
      return image;
    }
    
    // Not cached, load new image
    final image = NetworkImage(url);
    
    // Manage cache size using LRU (Least Recently Used) algorithm
    if (_imageCache.length >= _maxImageCacheSize) {
      // Remove oldest entry (first in LinkedHashMap)
      _imageCache.remove(_imageCache.keys.first);
    }
    
    // Add to cache
    _imageCache[url] = image;
    
    return image;
  }
  
  /// Register data with an expiry time
  void registerCachedData(String key, int sizeInKB, {Duration expiry = const Duration(minutes: 15)}) {
    _dataExpiryTimes[key] = DateTime.now().add(expiry);
    _estimatedCacheSize += sizeInKB;
    
    // Schedule cleanup if cache gets too big
    if (_estimatedCacheSize > _maxCacheSize) {
      _performCleanup();
    }
  }
  
  /// Check if cached data is still valid
  bool isDataValid(String key) {
    if (!_dataExpiryTimes.containsKey(key)) return false;
    
    final expiryTime = _dataExpiryTimes[key];
    return expiryTime != null && expiryTime.isAfter(DateTime.now());
  }
  
  /// Perform memory cleanup
  void _performCleanup() {
    debugPrint('[PERFORMANCE] Performing cache cleanup');
    
    // Remove expired data entries
    final now = DateTime.now();
    final expiredKeys = _dataExpiryTimes.keys
        .where((key) => _dataExpiryTimes[key]?.isBefore(now) ?? true)
        .toList();
    
    for (final key in expiredKeys) {
      _dataExpiryTimes.remove(key);
      // Reduce estimated size (approximate as we don't track individual sizes)
      _estimatedCacheSize = (_estimatedCacheSize * 0.8).toInt(); // Reduce by 20%
    }
    
    // Clear the image cache if it's still too big
    if (_estimatedCacheSize > _maxCacheSize * 0.8) { // If still using > 80%
      _imageCache.clear();
      _estimatedCacheSize = (_estimatedCacheSize * 0.5).toInt(); // Reduce by 50%
    }
    
    debugPrint('[PERFORMANCE] Cleanup complete. Estimated cache size: $_estimatedCacheSize KB');
  }
  
  /// Optimize images for display to reduce memory usage
  String optimizeImageUrl(String originalUrl, {int? width, int? height}) {
    // Many image services allow resizing via URL parameters
    // Example implementation for Spotify images
    if (originalUrl.contains('scdn.co')) {
      // Spotify images can be resized like i.scdn.co/image/[id]?width=300
      if (width != null) {
        return '$originalUrl?width=$width';
      }
    }
    
    return originalUrl;
  }
  
  /// Pre-warm the app by loading common resources
  Future<void> prewarmApp() async {
    debugPrint('[PERFORMANCE] Pre-warming app');
    // Load common images, fonts, or other resources that will be needed
    // This can be called at app startup or during idle time
  }
  
  /// Schedule deferred work for when the UI is idle
  void scheduleDeferredWork(Function callback) {
    // Use a microtask to run work after the current frame is completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        callback();
      });
    });
  }
}
