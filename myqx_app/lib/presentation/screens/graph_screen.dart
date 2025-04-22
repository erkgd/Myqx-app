import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/user_graph_service.dart';
import 'package:myqx_app/presentation/widgets/spotify/user_circle.dart';

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

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAndBuildGraph();
  }  Future<void> _fetchAndBuildGraph() async {
    // Verificar si el widget aún está montado antes de actualizar el estado
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });    try {
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
    
    // Añadir nodos al grafo
    if (networkData['following_network'] != null) {
      for (final connection in networkData['following_network']) {
        final followerId = connection['followerId'];
        final followedId = connection['followedId'];
        final isRecommended = connection['isRecommended'] ?? false;
        
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
              ..strokeWidth = 2
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Network Graph',
          style: TextStyle(
            color: CorporativeColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Your Music Network',
                          style: TextStyle(
                            color: CorporativeColors.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),                      Expanded(
                        child: InteractiveViewer(
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(100),
                          minScale: 0.1,
                          maxScale: 2.0,                          child: GraphView(
                            graph: graph,                      
                            algorithm: FruchtermanReingoldAlgorithm(
                              iterations: 1000 // Solo parámetro básico disponible
                            ),
                            paint: Paint()
                              ..color = Colors.white
                              ..strokeWidth = 2.0
                              ..style = PaintingStyle.stroke,
                            builder: (Node node) {
                              // Verificar si este nodo es el usuario actual (ejemplo con ID "31")
                              final nodeId = node.key?.value?.toString() ?? "";
                              // Consideramos que el nodo con ID 31 es el usuario actual (solo ejemplo)
                              final isCurrentUser = nodeId == "31";
                              
                              return nodeWidgetWithUserCircle(
                                isCurrentUser ? "You" : "User $nodeId", 
                                "", // URL de imagen (vacío por ahora)
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
  Widget nodeWidgetWithUserCircle(String username, String imageUrl, bool isCurrentUser) {
    // Retornamos solo la parte de imagen del UserCircle sin texto con tamaños aumentados
    return Container(
      width: isCurrentUser ? 70.0 : 55.0, // Tamaños más grandes para los nodos
      height: isCurrentUser ? 70.0 : 55.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 3.0, // Borde más grueso
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
    );
  }
}
