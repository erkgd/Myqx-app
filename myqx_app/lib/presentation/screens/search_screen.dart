import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_search_service.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/widgets/album_representation/album_header.dart';
import 'package:myqx_app/presentation/widgets/general/gradient_background.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SpotifySearchService _searchService;
  bool _showResults = false;
  String _searchQuery = '';
  bool _filterAlbums = true;
  bool _filterTracks = true;
  bool _isSearchPressed = false;
  
  
  @override
  void initState() {
    super.initState();
    _searchService = SpotifySearchService();
    _searchService.addListener(_onSearchResultsChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchService.removeListener(_onSearchResultsChanged);
    super.dispose();
  }
  
  void _onSearchResultsChanged() {
    if (mounted) {
      setState(() {}); // Refresh UI when search results change
    }
  }
  
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _showResults = true;
      _searchQuery = query;
    });
    
    // Determinar el tipo de búsqueda basado en los filtros activos
    String type = '';
    if (_filterTracks) type += 'track,';
    if (_filterAlbums) type += 'album,';
    if (type.isEmpty) type = 'track,album'; // Default if nothing selected
    else type = type.substring(0, type.length - 1); // Remove trailing comma
    
    _searchService.search(query, type: type);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const UserHeader(),
      body: GradientBackground(
        child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for tracks or albums...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: CorporativeColors.blackColor,
                    prefixIcon: const Icon(Icons.search, color: CorporativeColors.mainColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: CorporativeColors.mainColor),
                            onPressed: () {
                              _searchController.clear();
                              _searchService.clearResults();
                              setState(() {
                                _showResults = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: CorporativeColors.mainColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: CorporativeColors.mainColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: CorporativeColors.mainColor, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _performSearch(),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              
              // Search filters/tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _filterAlbums = !_filterAlbums),
                      child: _buildFilterChip('Albums', _filterAlbums),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _filterTracks = !_filterTracks),
                      child: _buildFilterChip('Tracks', _filterTracks),
                    ),
                    const Spacer(),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isSearchPressed = true),
                        onTapUp: (_) {
                          setState(() => _isSearchPressed = false);
                          _performSearch();
                        },
                        onTapCancel: () => setState(() => _isSearchPressed = false),
                        child: _buildSearchButton(),
                      ),
                  ],
                ),
              ),
              
              // Results or initial state
              if (_searchService.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CorporativeColors.mainColor,
                    ),
                  ),
                )
              else if (_searchService.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Text(
                      'Error: ${_searchService.errorMessage}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else if (_showResults)
                _buildSearchResults()
              else
                _buildInitialState(),
            ],
          ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? CorporativeColors.blackColor : CorporativeColors.mainColor,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildSearchButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(
        horizontal: 16, 
        vertical: 6
      ),
      decoration: BoxDecoration(
        color: CorporativeColors.blackColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: _isSearchPressed ? 2.5 : 1.5,
        ),
      ),
      child: const Text(
        'Search',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSearchResults() {
    final albums = _searchService.albums;
    final tracks = _searchService.tracks;
    
    if (albums.isEmpty && tracks.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found for "$_searchQuery"',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        children: [
          // Albums section
          if (albums.isNotEmpty && _filterAlbums) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 10),
              child: Text(
                'Albums',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // CAMBIO AQUÍ: Envolver en GestureDetector para navegación por Provider
            ...albums.map((album) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector( // Añadido GestureDetector
                onTap: () {
                  // Usar NavigationProvider para navegar al álbum
                  final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                  navProvider.navigateToAlbumById(context, album.id);
                },
                child: AlbumHeader(
                  albumId: album.id,
                  albumTitle: album.name,
                  artist: album.artistName,
                  imageUrl: album.coverUrl,
                  releaseYear: _extractYear(album.spotifyUrl),
                  rating: 0.0,
                  spotifyUrl: album.spotifyUrl,
                  onRatingChanged: (rating) {
                    // Handle rating change
                  },
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],
          
          // Tracks section
          if (tracks.isNotEmpty && _filterTracks) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 10),
              child: Text(
                'Tracks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...tracks.map((track) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector( // Añadido para navegación
                onTap: () {
                  if (track.albumId != null && track.albumId!.isNotEmpty) {
                    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                    navProvider.navigateToAlbumById(context, track.albumId!);
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: track.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            track.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note, color: Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note, color: Colors.white),
                        ),
                  title: Text(
                    track.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    track.artistName,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.more_vert, color: Colors.white),
                  tileColor: CorporativeColors.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
  
  // Método mejorado para extraer año
  String _extractYear(String? releaseDate) {
    // Intentar extraer de una fecha real si está disponible
    if (releaseDate != null && releaseDate.length >= 4) {
      final year = releaseDate.substring(0, 4);
      if (int.tryParse(year) != null) {
        return year;
      }
    }
    
    // Fallback a año aleatorio (para demo)
    return '${2018 + DateTime.now().millisecondsSinceEpoch % 6}';
  }
  
  Widget _buildInitialState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for your favorite music',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find albums and tracks on Spotify',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}