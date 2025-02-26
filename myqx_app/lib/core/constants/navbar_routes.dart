import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/broadcast_screen.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_widgets.dart';
import 'package:flutter/material.dart';

class NavbarRoutes{
  static final List<Widget> pages = [
    const ProfileScreen(),
    const BroadcastScreen(),
    const SpotifyUserProfile(displayName: 'Juan', email: 'john@doe.ad')
  ];
}