import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpotifyLink extends StatelessWidget {
  final Uri songUrl;
  final double size;

  const SpotifyLink({Key? key, required this.songUrl, required this.size}) : super(key: key);

  Future<void> _launchURL() async {
    if (await canLaunchUrl(songUrl)) {
      await launchUrl(
        songUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $songUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: SizedBox(
        width: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SvgPicture.asset(
            'assets/images/spotifyLogo.svg',
            color: CorporativeColors.spotifyColor,
          ),
        ),
      ),
    );
  }
}