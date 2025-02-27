import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:myqx_app/services/spotify_service.dart'; // Asume que tienes un servicio para Spotify

class AddToPlaylist extends StatefulWidget {
  final String songId;
  final double size;
  final Function()? onLikeChanged;
  
  const AddToPlaylist({
    Key? key,
    required this.songId,
    this.size = 30.0,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  State<AddToPlaylist> createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  bool _isLiked = false; // Mantenido para el estado visual
  // final SpotifyService _spotifyService = SpotifyService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _checkIfSongIsLiked();
  }

  /*
  Future<void> _checkIfSongIsLiked() async {
    try {
      final bool isLiked = await _spotifyService.isSongLiked(widget.songId);
      setState(() {
        _isLiked = isLiked;
      });
    } catch (e) {
      debugPrint('Error checking if song is liked: $e');
    }
  }
  */

  // Versión simplificada que solo cambia el estado visual sin llamar a la API
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (widget.onLikeChanged != null) {
      widget.onLikeChanged!();
    }
    
    /*
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isLiked) {
        await _spotifyService.unlikeSong(widget.songId);
      } else {
        await _spotifyService.likeSong(widget.songId);
      }
      
      setState(() {
        _isLiked = !_isLiked;
      });
      
      if (widget.onLikeChanged != null) {
        widget.onLikeChanged!();
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar canción en Spotify: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: _isLoading 
          ? const Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              ),
            )
          : Center(
              child: SvgPicture.asset(
                _isLiked 
                  ? 'assets/images/spotify-icon-liked.svg'
                  : 'assets/images/spotify-like-icon.svg',
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                color: Colors.black,
              ),
            ),
      ),
    );
  }
}