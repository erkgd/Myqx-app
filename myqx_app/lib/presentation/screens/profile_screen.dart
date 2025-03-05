import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/profile/settings_button.dart';
import 'package:myqx_app/presentation/widgets/profile/logout_button.dart';
import 'package:myqx_app/presentation/widgets/profile/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/profile/top_five_albums.dart';
import 'package:myqx_app/presentation/widgets/profile/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estado para controlar si el usuario está siguiendo o no
  bool _isFollowing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Quita el botón de retroceso
        leading: const SettingsButton(),
        actions: const [
          LogoutButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              
              // Círculo de perfil
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CorporativeColors.mainColor,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 90,
                    color: Colors.white70,
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Fila con nombre de usuario y botón de seguir
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nombre de usuario
                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: CorporativeColors.whiteColor,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Botón de follow/unfollow con tamaño fijo
                  SizedBox(
                    width: 90, // Ancho fijo
                    height: 30, // Misma altura que el botón de Spotify
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
                        padding: EdgeInsets.zero, // Sin padding interno adicional
                        minimumSize: Size.zero, // Permite tamaños menores
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce el área de toque
                      ),
                      child: Text(
                        _isFollowing ? 'Unfollow' : 'Follow',
                        style: const TextStyle(
                          fontSize: 12, // Tamaño de texto consistente
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Botón de Open Spotify
              OpenSpotifyButton(
                spotifyUrl: 'https://open.spotify.com/user/username',
                height: 30,
                text: 'Open in Spotify',
              ),
              
              const SizedBox(height: 15),


              // Este fragmento reemplaza la sección de las dos tarjetas en ProfileScreen
              SizedBox(
                height: 255, // Altura fija en píxeles
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 7,
                        child: StarOfTheDay(
                          albumCoverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                          artistName: 'Aphex Twin',
                          songName: 'Xtal',
                          spotifyUrl: 'https://open.spotify.com/track/3qTLa1q1WwYpBXYIxnU2NC',
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 5,
                        child: UserCompatibility(compatibilityPercentage: 40),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TopFiveAlbums(
              albums: [
                SpotifyAlbum(
                  id: '1',
                  name: 'Selected Ambient Works 85-92',
                  coverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                  artistName: 'Aphex Twin',
                  spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
                ),
                SpotifyAlbum(
                  id: '1',
                  name: 'Selected Ambient Works 85-92',
                  coverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                  artistName: 'Aphex Twin',
                  spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
                ),
                SpotifyAlbum(
                  id: '1',
                  name: 'Selected Ambient Works 85-92',
                  coverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                  artistName: 'Aphex Twin',
                  spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
                ),
                SpotifyAlbum(
                  id: '1',
                  name: 'Selected Ambient Works 85-92',
                  coverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                  artistName: 'Aphex Twin',
                  spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
                ),
                SpotifyAlbum(
                  id: '1',
                  name: 'Selected Ambient Works 85-92',
                  coverUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
                  artistName: 'Aphex Twin',
                  spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
                ),
              ],
              title: 'Top Albums',
            ),
            ],
          ),
        ),
      ),
    );
  }
}