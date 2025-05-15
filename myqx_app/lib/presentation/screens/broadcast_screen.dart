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
  
  // Variables para la paginación y el scroll infinito
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // No llamamos a _loadFeed() aquí para evitar el error de provider
    
    // Configurar el listener para el scroll infinito
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    // Limpiar el controller cuando se destruya el widget
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  // Método que escucha los eventos de scroll para cargar más elementos
  void _scrollListener() {
    // Comprobar si el controlador está adjunto y tiene una posición
    if (!_scrollController.hasClients) return;
    
    // Calcular cuánto falta para llegar al final
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Usamos un valor fijo en píxeles en lugar de un porcentaje
    // Esto es más confiable, especialmente en listas pequeñas
    final distanceToBottom = maxScroll - currentScroll;
    const loadMoreThreshold = 200.0; // Cargar más cuando falten 200px para el final
    
    // Debug para ayudar a diagnosticar problemas de scroll
    debugPrint('[SCROLL] Current: $currentScroll, Max: $maxScroll, Distance to bottom: $distanceToBottom');
    
    // Si estamos a menos de loadMoreThreshold píxeles del final y no estamos ya cargando
    if (distanceToBottom < loadMoreThreshold && !_isLoadingMore && _hasMoreItems) {
      debugPrint('[SCROLL] Detectado cerca del final del scroll, cargando más elementos');
      // Cargar la siguiente página
      _loadMoreItems();
    }
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
  }
    // Método para cargar el feed desde el BFF (carga inicial)
  Future<void> _loadFeed({bool forceRefresh = false}) async {
    // Accedemos al provider después de que el widget esté completamente construido
    final broadcastService = Provider.of<BroadcastService>(context, listen: false);
    
    // No establecer _isLoading = true cuando se usa con RefreshIndicator (pull-to-refresh)
    // porque el RefreshIndicator ya muestra su propio indicador de carga
    if (!forceRefresh && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    // Reset de la paginación cuando hacemos una carga completa
    _currentPage = 0;
    _hasMoreItems = true;
    _feedItems = []; // Limpiar la lista actual al recargar desde cero
    
    try {
      // Si se solicita forzar la recarga, usar refreshFeed para limpiar la caché y hacer una nueva petición
      List<FeedItem> feed;
      if (forceRefresh) {
        debugPrint('[BROADCAST] Forzando recarga completa del feed y limpiando caché');
        await broadcastService.refreshFeed();
        feed = broadcastService.feedItems;
        debugPrint('[BROADCAST] Feed recargado con ${feed.length} elementos');
      } else {
        // Comportamiento normal, usar datos en caché si están disponibles
        feed = await broadcastService.getFeed(limit: _itemsPerPage, offset: 0);
      }
      
      // Verificar si hay más elementos disponibles
      _hasMoreItems = feed.isNotEmpty && feed.length >= _itemsPerPage;
      
      if (mounted) {
        setState(() {
          _feedItems = feed;
          _isLoading = false;
          // Mostrar mensaje si el feed está vacío pero podría cargar más
          if (feed.isEmpty) {
            debugPrint('[BROADCAST] El feed inicial está vacío');
          } else {
            debugPrint('[BROADCAST] Cargados ${feed.length} elementos iniciales');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el feed: ${e.toString()}';
          _isLoading = false;
        });
      }
      debugPrint('[BROADCAST][ERROR] Error al recargar el feed: $e');
    }
  }
    // Método para cargar más elementos al hacer scroll
  Future<void> _loadMoreItems() async {
    // Verificar si ya estamos cargando o no hay más elementos
    if (_isLoadingMore || !_hasMoreItems) {
      debugPrint('[BROADCAST] Ignorando petición de carga: isLoadingMore=$_isLoadingMore, hasMoreItems=$_hasMoreItems');
      return;
    }
    
    // Indicar que estamos cargando más elementos
    setState(() {
      _isLoadingMore = true;
    });
    
    // Pequeña pausa para mejorar la UX y asegurar que el indicador de carga se muestre
    await Future.delayed(const Duration(milliseconds: 500));
    
    debugPrint('[BROADCAST] Cargando más elementos (página ${_currentPage + 1})');
    
    try {
      final broadcastService = Provider.of<BroadcastService>(context, listen: false);
      
      // Incrementar la página actual
      _currentPage++;
      
      // Calcular el offset para la siguiente página
      final offset = _currentPage * _itemsPerPage;
      debugPrint('[BROADCAST] Solicitando elementos con offset: $offset, limit: $_itemsPerPage');
      
      // Cargar los siguientes elementos
      final nextItems = await broadcastService.getFeed(
        limit: _itemsPerPage, 
        offset: offset,
        forceRefresh: true // Forzar carga desde servidor para elementos antiguos
      );
      
      // Verificar si hay más elementos disponibles para próximas cargas
      _hasMoreItems = nextItems.isNotEmpty && nextItems.length >= _itemsPerPage;
      
      if (mounted) {
        setState(() {
          // Añadir los nuevos elementos a la lista existente si hay alguno
          if (nextItems.isNotEmpty) {
            _feedItems.addAll(nextItems);
            debugPrint('[BROADCAST] Añadidos ${nextItems.length} elementos. Total ahora: ${_feedItems.length}');
          } else {
            debugPrint('[BROADCAST] No se encontraron más elementos');
            _hasMoreItems = false; // No hay más elementos disponibles
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      debugPrint('[BROADCAST][ERROR] Error al cargar más elementos: $e');
      // Mostrar un mensaje temporal de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar más elementos: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
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
      // Mostrar indicador de carga/
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
              ),              
              const SizedBox(height: 24),              
              ElevatedButton(
                onPressed: () => _loadFeed(forceRefresh: true),
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
            contentId: item.contentId,       // ID del contenido en Spotify
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
        onRefresh: () => _loadFeed(forceRefresh: true),
        // El color y el fondo del indicador para hacerlo más visible
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        // La distancia mínima para activar el refresh
        displacement: 40.0,        
        child: SingleChildScrollView(
          // Añadimos el controlador para detectar cuando se llega al final
          controller: _scrollController,
          // Esto garantiza que se pueda hacer scroll aunque el contenido sea pequeño
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            // Este constraint asegura que incluso con poco contenido el scroll funcione
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         kToolbarHeight - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: feedWidgets.isEmpty 
                  ? [
                      // Si no hay elementos, mostrar un mensaje explicativo
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          "Desliza hacia abajo para cargar el feed",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ] 
                  : [
                      // Mostrar todos los elementos del feed
                      ...feedWidgets,
                      // Añadir indicador de carga al final si estamos cargando más o si hay más elementos
                      if (_isLoadingMore)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      else if (_hasMoreItems)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Desliza para cargar más",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}