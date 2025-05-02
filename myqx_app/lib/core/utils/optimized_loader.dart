import 'package:flutter/material.dart';

/// Helper class to optimize loading of large content
class OptimizedLoader {
  /// Load large datasets in chunks to avoid blocking the UI
  static Future<List<T>> loadListInChunks<T>({
    required List<T> items,
    required Function(List<T> loadedItems) onChunkLoaded,
    int chunkSize = 5,
    Duration chunkDelay = const Duration(milliseconds: 100),
  }) async {
    final totalItems = items.length;
    final chunks = (totalItems / chunkSize).ceil();
    List<T> processedItems = [];

    for (int i = 0; i < chunks; i++) {
      final start = i * chunkSize;
      final end = (start + chunkSize < totalItems) ? start + chunkSize : totalItems;
      final chunk = items.sublist(start, end);
      
      processedItems.addAll(chunk);
      onChunkLoaded(processedItems);
      
      // Yield to UI thread
      if (i < chunks - 1) {
        await Future.delayed(chunkDelay);
      }
    }
    
    return processedItems;
  }
  
  /// Execute tasks one by one with UI updates in between
  static Future<void> executeTasksSequentially({
    required List<Future Function()> tasks,
    Function? onTaskComplete,
    Duration delayBetweenTasks = const Duration(milliseconds: 50),
  }) async {
    for (int i = 0; i < tasks.length; i++) {
      await tasks[i]();
      
      if (onTaskComplete != null) {
        onTaskComplete(i);
      }
      
      // Small delay to let UI breathe
      if (i < tasks.length - 1) {
        await Future.delayed(delayBetweenTasks);
      }
    }
  }
  
  /// Prioritize loading of critical UI elements first
  static Future<void> loadWithPriority({
    required Future Function() highPriorityTask,
    required List<Future Function()> lowPriorityTasks,
    Function? onHighPriorityComplete,
    Function? onTaskComplete,
  }) async {
    // Execute high priority task first
    await highPriorityTask();
    if (onHighPriorityComplete != null) {
      onHighPriorityComplete();
    }
    
    // Then execute low priority tasks
    await executeTasksSequentially(
      tasks: lowPriorityTasks,
      onTaskComplete: onTaskComplete,
    );
  }
}
