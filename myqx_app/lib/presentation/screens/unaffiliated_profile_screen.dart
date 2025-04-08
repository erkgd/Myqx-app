import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_profile_service.dart';
import 'package:myqx_app/presentation/widgets/profile/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/profile/top_five_albums.dart';
import 'package:myqx_app/presentation/widgets/profile/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class UnaffiliatedProfileScreen extends StatefulWidget {
  const UnaffiliatedProfileScreen({super.key});

  @override
  State<UnaffiliatedProfileScreen> createState() => _UnaffiliatedProfileScreenState();
}

class _UnaffiliatedProfileScreenState extends State<UnaffiliatedProfileScreen> with WidgetsBindingObserver {
  bool _isFollowing = false;
  bool _isLoading = true;
  late final SpotifyProfileService _profileService;
  
  @override
  void initState() {
    super.initState();
    _profileService = SpotifyProfileService();
    _loadProfileData();
    // Registrar el observador del ciclo de vida
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Desregistrar el observador del ciclo de vida
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("[DEBUG] Profile: App resumed, recargando datos del perfil");
      // Recargar los datos del perfil cuando la app vuelve al primer plano
      _loadProfileData();
    }
  }
  
  Future<void> _loadProfileData() async {
    if (mounted) {  
      setState(() {
        _isLoading = true;
      });
    }
    try {
      debugPrint("[DEBUG] Profile: Cargando datos del perfil");
      await _profileService.initialize();
      debugPrint("[DEBUG] Profile: Datos del perfil cargados exitosamente");
    } catch (e) {
      debugPrint("[ERROR] Failed to load profile data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading ? _buildLoadingView() : _buildProfileContent(),
    );
  }
  
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: CorporativeColors.mainColor,
          ),
          SizedBox(height: 16),
          Text(
            "Loading profile...",
            style: TextStyle(
              color: CorporativeColors.whiteColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileContent() {
    final user = _profileService.currentUser;
    final starTrack = _profileService.starOfTheDay;
    final topAlbums = _profileService.topAlbums;
    
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Failed to load profile",
              style: TextStyle(
                color: CorporativeColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _profileService.errorMessage ?? "Unknown error",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfileData,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            
            // Profile circle with actual image if available
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CorporativeColors.mainColor,
                  width: 3,
                ),
                image: user.imageUrl != null ? DecorationImage(
                  image: NetworkImage(user.imageUrl!),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: user.imageUrl == null ? const Center(
                child: Icon(
                  Icons.person,
                  size: 90,
                  color: Colors.white70,
                ),
              ) : null,
            ),
            
            const SizedBox(height: 15),
            
            // Username and follow button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display actual username from Spotify
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: CorporativeColors.whiteColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Follow button
                SizedBox(
                  width: 90,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isFollowing = !_isFollowing;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing 
                          ? Colors.black 
                          : CorporativeColors.whiteColor,
                      foregroundColor: _isFollowing 
                          ? CorporativeColors.whiteColor 
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _isFollowing 
                              ? CorporativeColors.mainColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Open in Spotify button with actual profile URL
            OpenSpotifyButton(
              spotifyUrl: user.spotifyUrl,
              height: 30,
              text: 'Open in Spotify',
            ),
            
            const SizedBox(height: 15),
            
            // Star of the Day and Compatibility
            SizedBox(
              height: 255,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 7,
                      child: starTrack != null ? StarOfTheDay(
                        albumCoverUrl: starTrack.imageUrl ?? '',
                        artistName: starTrack.artistName,
                        songName: starTrack.name,
                        spotifyUrl: starTrack.spotifyUrl,
                      ) : const Center(
                        child: Text(
                          "No star track available",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 5,
                      child: UserCompatibility(
                        compatibilityPercentage: _profileService.calculateCompatibility(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Top 5 albums section with actual data
            topAlbums.isNotEmpty ? TopFiveAlbums(
              albums: topAlbums,
              title: 'Top Albums',
            ) : const Center(
              child: Text(
                "No album data available",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}