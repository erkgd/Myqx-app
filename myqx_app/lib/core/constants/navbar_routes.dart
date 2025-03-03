import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/broadcast_screen.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_widgets.dart';
import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/screens/album_screen.dart';

class NavbarRoutes{
  static final List<Widget> pages = [
    const ProfileScreen(),
    const BroadcastScreen(),
    AlbumScreen(
      albumTitle: 'Selected Ambient Works 85-92',
      artist: 'Aphex Twin',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png',
      releaseYear: '1992',
      rating: 4.8,
      trackList: [
        'Xtal',
        'Tha',
        'Pulsewidth',
        'Ageispolis',
        'I',
        'Green Calx',
        'Heliosphan',
        'We Are The Music Makers',
        'Schottkey 7th Path',
        'Ptolemy',
        'Hedphelym',
        'Delphium',
        'Actium',
      ],
      spotifyUrl: 'https://open.spotify.com/album/7aNclGRxTysfh6z0d8671k',
    )
  ];

}