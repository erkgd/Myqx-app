import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/spotify/user_circle.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'dart:math' as math;

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> with TickerProviderStateMixin {
  // Caché para evitar múltiples solicitudes a imágenes de perfil que fallan
  final Set<String> _failedImageUrls = {};
  
  // Datos de ejemplo del endpoint
  final Map<String, dynamic> networkData = {
    "user_id": "1",
    "following_network": [
      {
        "followerId": 1,
        "followerUsername": "SynthLover",
        "followerSpotifyId": "spotify_user_1",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85c8a98d93bc1fcde3a9986e2a",
        "followerCreatedAt": "2025-04-07T08:14:04.294000000+00:00",
        "followedId": 2,
        "followedUsername": "RetroFan",
        "followedSpotifyId": "spotify_user_2",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85ec11c8d2676278294fb96b21",
        "followedCreatedAt": "2025-04-07T08:14:04.443000000+00:00",
        "isRecommended": false
      },
      {
        "followerId": 1,
        "followerUsername": "SynthLover",
        "followerSpotifyId": "spotify_user_1",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85c8a98d93bc1fcde3a9986e2a",
        "followerCreatedAt": "2025-04-07T08:14:04.294000000+00:00",
        "followedId": "31anflvbhjbrb4insk223drl4ecu",
        "followedUsername": "ElectroBeats",
        "followedSpotifyId": "31anflvbhjbrb4insk223drl4ecu",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85258fa22dda85658db09d03b0",
        "followedCreatedAt": "2025-04-07T11:07:30.880000000+00:00",
        "isRecommended": true
      },
      {
        "followerId": 1,
        "followerUsername": "SynthLover",
        "followerSpotifyId": "spotify_user_1",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85c8a98d93bc1fcde3a9986e2a",
        "followerCreatedAt": "2025-04-07T08:14:04.294000000+00:00",
        "followedId": 3,
        "followedUsername": "JazzMaster",
        "followedSpotifyId": "spotify_user_3",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85a64387716e901bc9a5253f2b",
        "followedCreatedAt": "2025-04-08T10:24:15.443000000+00:00",
        "isRecommended": false
      },
      {
        "followerId": 2,
        "followerUsername": "RetroFan",
        "followerSpotifyId": "spotify_user_2",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85ec11c8d2676278294fb96b21",
        "followerCreatedAt": "2025-04-07T08:14:04.443000000+00:00",
        "followedId": 3,
        "followedUsername": "JazzMaster",
        "followedSpotifyId": "spotify_user_3",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85a64387716e901bc9a5253f2b",
        "followedCreatedAt": "2025-04-08T10:24:15.443000000+00:00",
        "isRecommended": false
      },
      {
        "followerId": 3,
        "followerUsername": "JazzMaster",
        "followerSpotifyId": "spotify_user_3",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85a64387716e901bc9a5253f2b",
        "followerCreatedAt": "2025-04-08T10:24:15.443000000+00:00",
        "followedId": 4,
        "followedUsername": "ClassicalVibes",
        "followedSpotifyId": "spotify_user_4",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee854e1b2f32faffb0b7f543e9a7",
        "followedCreatedAt": "2025-04-10T14:35:22.123000000+00:00",
        "isRecommended": false
      },
      {
        "followerId": 1,
        "followerUsername": "SynthLover",
        "followerSpotifyId": "spotify_user_1",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85c8a98d93bc1fcde3a9986e2a",
        "followerCreatedAt": "2025-04-07T08:14:04.294000000+00:00",
        "followedId": 5,
        "followedUsername": "RockLegend",
        "followedSpotifyId": "spotify_user_5",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee857b5b93df8c67b6b318359a69",
        "followedCreatedAt": "2025-04-12T09:17:33.876000000+00:00",
        "isRecommended": true
      },
      {
        "followerId": 5,
        "followerUsername": "RockLegend",
        "followerSpotifyId": "spotify_user_5",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee857b5b93df8c67b6b318359a69",
        "followerCreatedAt": "2025-04-12T09:17:33.876000000+00:00",
        "followedId": 2,
        "followedUsername": "RetroFan",
        "followedSpotifyId": "spotify_user_2",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85ec11c8d2676278294fb96b21",
        "followedCreatedAt": "2025-04-07T08:14:04.443000000+00:00",
        "isRecommended": false
      },
      {
        "followerId": 6,
        "followerUsername": "FolkSoul",
        "followerSpotifyId": "spotify_user_6",
        "followerProfileImage": "https://i.scdn.co/image/ab6775700000ee85a5a0c2e75d9edd8a00767d09",
        "followerCreatedAt": "2025-04-14T16:42:18.543000000+00:00",
        "followedId": 1,
        "followedUsername": "SynthLover",
        "followedSpotifyId": "spotify_user_1",
        "followedProfileImage": "https://i.scdn.co/image/ab6775700000ee85c8a98d93bc1fcde3a9986e2a",
        "followedCreatedAt": "2025-04-07T08:14:04.294000000+00:00",
        "isRecommended": false
      }
    ],
    "count": 8,
    "timestamp": "2025-04-20T10:38:02.630468"
  };

  // Instancia del controlador del grafo
  final Graph graph = Graph()..isTree = false;
  
  // Nodo central (usuario principal)
  Node? centralNode;
  
  // Controlador de animación para transiciones suaves
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  
  // Algoritmo para layout
  late final Algorithm algorithm;
  
  // Centro del grafo (para posicionamiento inicial)
  final Offset _screenCenter = const Offset(0, 0);
  
  // Control de estado para inicialización suave
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Configurar animación para transición suave
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    // Configurar algoritmo con más iteraciones
    algorithm = FruchtermanReingoldAlgorithm(
      iterations: 2000,
    );
    
    // Construir grafo con un pequeño retraso para asegurar que la UI está lista
    Future.delayed(const Duration(milliseconds: 100), _initializeGraph);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Inicialización suave del grafo
  Future<void> _initializeGraph() async {
    // Construir estructura base
    _buildGraph();
    
    setState(() {
      _isInitialized = true; // Esto activará la animación
    });
    
    // Iniciar animación para que los nodos aparezcan suavemente
    _animationController.forward();
  }

  // Construye el grafo a partir de los datos
  void _buildGraph() {
    // Limpiar el grafo existente
    graph.nodes.clear();
    graph.edges.clear();
    
    // Mapa para almacenar nodos por ID para evitar duplicados
    final Map<dynamic, Node> nodes = {};
    
    // Crear primero el nodo principal (usuario ID 1)
    final mainUserId = 1;
    centralNode = Node.Id(mainUserId);
    centralNode!.position = _screenCenter; // Posicionar en el centro
    graph.addNode(centralNode!);
    nodes[mainUserId] = centralNode!;
    
    // Añadir nodos al grafo
    if (networkData['following_network'] != null) {
      for (final connection in networkData['following_network']) {
        // Verificar que la conexión tiene los datos necesarios
        if (!connection.containsKey('followerId') || !connection.containsKey('followedId')) {
          continue; // Ignorar conexiones incompletas
        }
        
        final followerId = connection['followerId'];
        final followedId = connection['followedId'];
        final isRecommended = connection['isRecommended'] ?? false;
        
        // Crear nodos si no existen (excepto el nodo central que ya está creado)
        if (followedId != mainUserId && !nodes.containsKey(followedId)) {
          nodes[followedId] = Node.Id(followedId);
          
          // Posicionar inicialmente cerca del centro con ligera variación aleatoria
          // para evitar superposiciones exactas (esto ayuda al algoritmo a separarlos)
          final randomOffset = _getSmallRandomOffset();
          nodes[followedId]!.position = Offset(
            _screenCenter.dx + randomOffset.dx,
            _screenCenter.dy + randomOffset.dy
          );
          
          graph.addNode(nodes[followedId]!);
        }
        
        if (!nodes.containsKey(followerId)) {
          nodes[followerId] = Node.Id(followerId);
          
          // Posicionar similar a los demás nodos
          final randomOffset = _getSmallRandomOffset();
          nodes[followerId]!.position = Offset(
            _screenCenter.dx + randomOffset.dx,
            _screenCenter.dy + randomOffset.dy
          );
          
          graph.addNode(nodes[followerId]!);
        }
        
        // Añadir arista solo si no es una recomendación
        if (!isRecommended && followedId != mainUserId) {
          // Conectar desde el nodo central hacia el nodo seguido
          graph.addEdge(
            nodes[followerId]!, 
            nodes[followedId]!,
            paint: Paint()
              ..color = CorporativeColors.mainColor
              ..strokeWidth = 5 // Líneas más gruesas
          );
        }
      }
    }
  }
  
  // Genera un pequeño desplazamiento aleatorio para evitar superposición de nodos
  Offset _getSmallRandomOffset() {
    final random = math.Random();
    // Valor pequeño para mantener los nodos cerca del centro
    return Offset(
      (random.nextDouble() - 0.5) * 10.0,
      (random.nextDouble() - 0.5) * 10.0,
    );
  }
  
  // Estado para controlar la carga del grafo
  bool _isLoading = false;
  
  // Función para recargar el grafo
  void _reloadGraph() {
    setState(() {
      _isLoading = true;
    });
    
    // Reiniciar la animación para la nueva carga
    _animationController.reset();
    
    // Reconstruir el grafo con un pequeño retraso
    Future.delayed(const Duration(milliseconds: 500), () {
      _buildGraph();
      
      // Iniciar animación nuevamente
      _animationController.forward();
      
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se construye el grafo
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildUserHeader(),
        body: const Center(
          child: CircularProgressIndicator(
            color: CorporativeColors.mainColor,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildUserHeader(),
      floatingActionButton: FloatingActionButton(
        onPressed: _reloadGraph,
        backgroundColor: CorporativeColors.mainColor,
        child: const Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                // Animación para el contenedor del grafo
                child: AnimatedOpacity(
                  opacity: _isInitialized ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.5 + (_animation.value * 0.5), // Escala gradual desde 0.5 hasta 1.0
                        child: child,
                      );
                    },
                    child: InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.1,
                      maxScale: 2.0,                
                      child: GraphView(
                        graph: graph,                      
                        algorithm: algorithm,
                        paint: Paint()..color = Colors.white,
                        builder: (Node node) {
                          // Determinar si es un nodo recomendado
                          bool isRecommended = false;
                          bool isCentralNode = node.key!.value == centralNode?.key?.value;
                          // Variables para mantener la información del nodo
                          String imageUrl = '';
                          
                          // Buscar en las conexiones para determinar si este nodo es recomendado
                          if (isCentralNode) {
                            // Si es el nodo central (usuario actual), buscar su imagen de perfil
                            for (final connection in networkData['following_network']) {
                              if (connection['followerId'] == node.key!.value) {
                                imageUrl = connection['followerProfileImage'] ?? '';
                                break;
                              }
                            }
                          } else {
                            // Si es otro nodo, buscar si es un usuario seguido y si es recomendado
                            for (final connection in networkData['following_network']) {
                              if (connection['followedId'].toString() == node.key!.value.toString()) {
                                isRecommended = connection['isRecommended'] ?? false;
                                imageUrl = connection['followedProfileImage'] ?? '';
                                break;
                              }
                            }
                          }
                          
                          // El tamaño depende de si es el nodo principal, un nodo recomendado o un nodo normal
                          double nodeSize = isCentralNode ? 70.0 : (isRecommended ? 45.0 : 40.0);
                          
                          // Obtener el nombre de usuario para usar la inicial si no hay imagen
                          String username = '';
                          if (isCentralNode) {
                            for (final connection in networkData['following_network']) {
                              if (connection['followerId'] == node.key!.value) {
                                username = connection['followerUsername'] ?? '';
                                break;
                              }
                            }
                          } else {
                            for (final connection in networkData['following_network']) {
                              if (connection['followedId'].toString() == node.key!.value.toString()) {
                                username = connection['followedUsername'] ?? '';
                                break;
                              }
                            }
                          }
                          
                          // Validar la URL de la imagen para evitar solicitudes innecesarias
                          String finalImageUrl = '';
                          // Solo usar URLs válidas de Spotify que no hayan fallado anteriormente
                          if (imageUrl.isNotEmpty && 
                              imageUrl.startsWith('https://i.scdn.co/') && 
                              !_failedImageUrls.contains(imageUrl)) {
                            finalImageUrl = imageUrl;
                          }
                          
                          return UserCircle(
                            username: username, // Usar el nombre de usuario para mostrar la inicial
                            imageUrl: finalImageUrl,
                            imageSize: nodeSize,
                            fontSize: 0, // Sin texto pero se usará el username para la inicial
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Usar el widget UserHeader compartido, como en AlbumScreen
  PreferredSizeWidget _buildUserHeader() {
    return const UserHeader();
  }
}
