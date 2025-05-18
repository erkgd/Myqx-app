import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/user_graph_service.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

// Caché estático para almacenar los datos del grafo entre instancias de la pantalla
class _GraphCache {
  // Singleton para conservar datos entre instancias
  static final _GraphCache _singleton = _GraphCache._internal();
  factory _GraphCache() => _singleton;
  _GraphCache._internal();
  
  // Datos en caché del grafo
  static Map<String, dynamic>? cachedNetworkData;
}

class _GraphScreenState extends State<GraphScreen> {
  final UserGraphService _userGraphService = UserGraphService();
  // Instancia del controlador del grafo
  final Graph graph = Graph()..isTree = false;
  String? _currentUserId;
  // Almacena información de usuarios por ID
  Map<String, Map<String, dynamic>> _userData = {};
  // Almacena información de seguimiento: clave = ID del usuario seguido, valor = true si el usuario actual lo sigue
  Map<String, bool> _followingStatus = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _fetchAndBuildGraph();
  }
  
  // Cargar el ID del usuario actual
  Future<void> _loadCurrentUserId() async {
    try {
      final secureStorage = SecureStorage();
      _currentUserId = await secureStorage.getUserId();
      debugPrint('[DEBUG] Current user ID: $_currentUserId');
    } catch (e) {
      debugPrint('[DEBUG] Error loading current user ID: $e');
    }
  }

  Future<void> _fetchAndBuildGraph() async {
    // Verificar si el widget aún está montado antes de actualizar el estado
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Limpiamos el grafo existente para evitar duplicados
    graph.nodes.clear();
    graph.edges.clear();
    
    try {
      // Verificar si hay datos en caché primero
      if (_GraphCache.cachedNetworkData != null) {
        debugPrint('Usando datos del grafo desde caché');
        // Usar datos de caché
        final cachedData = _GraphCache.cachedNetworkData!;
        if (!mounted) return;
        _buildGraph(cachedData);
      } else {
        // Si no hay caché, hacer la petición de red
        debugPrint('Cargando datos del grafo desde API');
        final networkData = await _userGraphService.fetchFollowingNetwork();
        
        // Verificar nuevamente si el widget está montado después de la operación asíncrona
        if (!mounted) return;
        
        // Guardar datos en caché para uso futuro
        _GraphCache.cachedNetworkData = networkData;
        
        _buildGraph(networkData);
      }
    } catch (e) {
      // Verificar si el widget está montado antes de actualizar el estado
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Verificar si el widget está montado antes de actualizar el estado
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Construye el grafo a partir de los datos
  void _buildGraph(Map<String, dynamic> networkData) {
    // Mapa para almacenar nodos por ID para evitar duplicados
    final Map<dynamic, Node> nodes = {};
    // Mapa para almacenar datos completos de usuarios por ID
    final Map<String, Map<String, dynamic>> userData = {};
    // Mapa para almacenar el estado de seguimiento
    final Map<String, bool> followingStatus = {};
    
    // Añadir nodos al grafo
    if (networkData['following_network'] != null) {
      for (final connection in networkData['following_network']) {
        final followerId = connection['followerId'];
        final followedId = connection['followedId'];
        final isRecommended = connection['isRecommended'] ?? false;
        
        // Almacenar datos del seguidor si no existen
        if (!userData.containsKey(followerId)) {
          userData[followerId.toString()] = {
            'username': connection['followerUsername'] ?? '',
            'profileImage': connection['followerProfileImage'] ?? '',
            'spotifyId': connection['followerSpotifyId'] ?? '',
          };
        }
        
        // Almacenar datos del seguido si no existen
        if (!userData.containsKey(followedId)) {
          userData[followedId.toString()] = {
            'username': connection['followedUsername'] ?? '',
            'profileImage': connection['followedProfileImage'] ?? '',
            'spotifyId': connection['followedSpotifyId'] ?? '',
          };
        }
        
        // Si el seguidor es el usuario actual, registrar si sigue a este usuario
        if (followerId.toString() == _currentUserId && !isRecommended) {
          // Si isRecommended es false, significa que ya está siguiendo a este usuario
          followingStatus[followedId.toString()] = true;
          debugPrint('[DEBUG] El usuario actual ($followerId) sigue a: $followedId');
        }
        
        // Crear nodos si no existen
        if (!nodes.containsKey(followerId)) {
          nodes[followerId] = Node.Id(followerId);
          graph.addNode(nodes[followerId]!);
        }
        
        if (!nodes.containsKey(followedId)) {
          nodes[followedId] = Node.Id(followedId);
          graph.addNode(nodes[followedId]!);
        }
        
        // Añadir arista solo si no es una recomendación
        if (!isRecommended) {          
          graph.addEdge(
            nodes[followerId]!, 
            nodes[followedId]!,
            paint: Paint()
              ..color = CorporativeColors.mainColor
              ..strokeWidth = 10.0 // Líneas mucho más gruesas para mejor visibilidad
          );
        }
      }
    }
    
    // Guardar datos en el estado
    setState(() {
      _userData = userData;
      _followingStatus = followingStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const UserHeader(),
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: CorporativeColors.whiteColor,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              // Limpiar caché y recargar datos
              _GraphCache.cachedNetworkData = null;
              _fetchAndBuildGraph();
            },
            child: const Icon(
              Icons.refresh,
              color: CorporativeColors.whiteColor,
              size: 24,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),                      

                      const SizedBox(height: 10),                      
                      Expanded(
                        child: InteractiveViewer(
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(1000), // Aumentado considerablemente para evitar problemas con nodos en bordes
                          minScale: 0.05,
                          maxScale: 3.5, // Mayor rango de zoom para mejor visualización
                          
                          child: GraphView(
                            graph: graph,
                              algorithm: FruchtermanReingoldAlgorithm(
                              iterations: 2000 // Aumentado para mejor distribución de nodos en el espacio
                            ),
                            paint: Paint()
                              ..color = Colors.white
                              ..strokeWidth = 15.0
                              ..style = PaintingStyle.stroke,                            
                              builder: (Node node) {                              // Verificar si este nodo es el usuario actual
                              final nodeId = node.key?.value?.toString() ?? "";
                              // Comparar con el ID del usuario actual cargado desde SecureStorage
                              final isCurrentUser = _currentUserId != null && nodeId == _currentUserId;
                              
                              return nodeWidgetWithUserCircle(
                                nodeId,
                                isCurrentUser ? "You" : "User $nodeId", 
                                isCurrentUser, // Ahora identificamos si es el usuario actual
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
  // Widget para representar un nodo en el grafo mostrando solo la imagen del UserCircle
  Widget nodeWidgetWithUserCircle(String nodeId, String defaultName, bool isCurrentUser) {
    // Obtener datos del usuario desde _userData si existen
    final userData = _userData[nodeId] ?? {};
    final username = userData['username'] ?? defaultName;
    final imageUrl = userData['profileImage'] ?? '';
    
    // Retornamos solo la parte de imagen del UserCircle sin texto con tamaños aumentados
    return GestureDetector(
      onTap: () {
        // Si no es el usuario actual, navegar al perfil no afiliado
        if (!isCurrentUser && nodeId.isNotEmpty) {          // Determinar si el usuario actual sigue al usuario del perfil
          final bool isFollowing = _followingStatus[nodeId] ?? false;
          
          debugPrint('[DEBUG] Navegando al perfil no afiliado con ID: $nodeId (seguido: $isFollowing)');
          
          // Usar NavigationProvider para gestionar la navegación con información adicional
          final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.navigateToUserProfile(
            context, 
            nodeId,
            imageUrl: imageUrl,
            isFollowing: isFollowing,
          );
        } else if (isCurrentUser) {
          // Si es el usuario actual, no hacemos nada o mostramos un tooltip/snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your profile!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },      
      child: Container(
      width: isCurrentUser ? 90.0 : 70.0, // Nodos aún más grandes
      height: isCurrentUser ? 90.0 : 70.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 5.0, // Borde más grueso
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty 
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  backgroundColor: CorporativeColors.mainColor,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: CorporativeColors.mainColor,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
     ),
    );
  }
}
