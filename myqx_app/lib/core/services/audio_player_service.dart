import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isPlaying = false;
  
  // Singleton pattern
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  
  factory AudioPlayerService() => _instance;
  
  AudioPlayerService._internal() {
    _initAudioSession();
    
    // Añadir oyentes para los cambios de estado
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      
      if (processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentlyPlayingId = null;
        notifyListeners();
      } else {
        _isPlaying = isPlaying;
        notifyListeners();
      }
    });
  }
  
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('[ERROR] Could not configure audio session: $e');
    }
  }
  
  // Getters para el estado
  String? get currentlyPlayingId => _currentlyPlayingId;
  bool get isPlaying => _isPlaying;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  /// Reproduce la previsualización de una pista
  Future<void> playPreview(String? url, String trackId) async {
    if (url == null || url.isEmpty) {
      debugPrint('[WARNING] No preview URL available for track $trackId');
      return;
    }
    
    try {
      if (_currentlyPlayingId == trackId && _isPlaying) {
        // Si es la misma pista y está reproduciendo, pausar
        await _audioPlayer.pause();
      } else if (_currentlyPlayingId == trackId && !_isPlaying) {
        // Si es la misma pista pero está pausada, reproducir
        await _audioPlayer.play();
      } else {
        // Si es una pista diferente o nada está sonando, configurar y reproducir
        if (_isPlaying) {
          await _audioPlayer.stop();
        }
        
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        _currentlyPlayingId = trackId;
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to play preview: $e');
    }
    
    notifyListeners();
  }
  
  /// Pausa la reproducción actual
  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }
  
  /// Detiene la reproducción actual
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentlyPlayingId = null;
  }
    /// Libera recursos
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
