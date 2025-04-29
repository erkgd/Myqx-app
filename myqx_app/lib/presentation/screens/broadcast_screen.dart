import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/broadcast_service.dart';
import 'package:myqx_app/data/models/feed_item.dart';
import 'package:myqx_app/presentation/widgets/broadcast/rated_music_element.dart';
import 'package:myqx_app/presentation/widgets/general/divisor.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:provider/provider.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<FeedItem> _feedItems = [];
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    // No llamamos a _loadFeed() aquí para evitar el error de provider
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Este método se llama después de que el widget esté completamente construido
    // y es seguro acceder a los providers
    if (!_initialLoadDone) {
      _loadFeed();
      _initialLoadDone = true;
    }
  }  // Método para cargar el feed desde el BFF
  Future<void> _loadFeed({String userId = '3'}) async {
    // Accedemos al provider después de que el widget esté completamente construido
    final broadcastService = Provider.of<BroadcastService>(context, listen: false);
    
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
      
      // Obtener el feed del servicio sin utilizar directamente los callbacks de estado
      // del servicio para evitar conflictos con el ciclo de construcción
      final feed = await broadcastService.getFeed(userId: userId);
      if (mounted) {
        setState(() {
          _feedItems = feed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el feed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Obtener el servicio sin escuchar cambios (usaremos nuestro propio estado local)
    // Esto evita posibles problemas con el ciclo de construcción
    Provider.of<BroadcastService>(context, listen: false);
    
    // Crear widgets para elementos del feed o mostrar mensajes de carga/error
    List<Widget> feedWidgets = [];
    
    if (_isLoading) {
      // Mostrar indicador de carga
      return Scaffold(
        appBar: const UserHeader(showCircle: true),
        backgroundColor: Colors.transparent,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null) {
      // Mostrar mensaje de error
      return Scaffold(
        appBar: const UserHeader(showCircle: true),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFeed,
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }
    
    // Si no hay elementos en el feed
    if (_feedItems.isEmpty) {
      return Scaffold(
        appBar: const UserHeader(showCircle: true),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.feed,
                size: 60,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay actividad en el feed',
                style: TextStyle(color: Colors.white),
              ),              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadFeed(userId: '3'),
                child: const Text('Actualizar'),
              )
            ],
          ),
        ),
      );
    }
    
    // Convertir elementos de feed a widgets RatedMusic
    for (final item in _feedItems) {
      // Debug para ver si la review está presente
      if (item.review != null && item.review!.isNotEmpty) {
        debugPrint('[BROADCAST] Item con review: "${item.review}" - Para: ${item.title}');
      } else {
        debugPrint('[BROADCAST] Item sin review para: ${item.title}');
      }
      
      // Log para depuración completa de los datos
      debugPrint('[BROADCAST] Item: Tipo=${item.contentType}, Título=${item.title}, Artista=${item.artist}');
      debugPrint('[BROADCAST] URLs - Contenido: "${item.imageUrl}", Usuario: "${item.userImageUrl}"');
      
      feedWidgets.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), 
          child: RatedMusic(
            imageUrl: item.imageUrl,
            artist: item.artist,
            musicname: item.title,
            review: item.review,
            rating: item.rating.toInt(),
            user: item.username,
            userImageUrl: item.userImageUrl, // URL de la imagen de perfil del usuario
            contentType: item.contentType,   // Tipo de contenido: 'album' o 'track'
          ),
        ),
      );
      
      // Si no es el último, añadir divisor
      if (item != _feedItems.last) {
        feedWidgets.add(Divisor());
      }
    }
    
    // Mostrar feed con pull-to-refresh para actualización
    return Scaffold(
      appBar: const UserHeader(showCircle: true),
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: feedWidgets,
          ),
        ),
      ),
    );
  }
}