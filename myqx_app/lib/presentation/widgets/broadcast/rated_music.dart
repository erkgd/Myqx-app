import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_link.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';

class RatedMusic extends StatelessWidget {
  final String imageUrl;
  final String artist;
  final String musicname;
  final String review;
  final double rating;

  const RatedMusic({
    super.key,
    required this.imageUrl,
    required this.artist,
    required this.musicname,
    required this.review,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      child:Row(
        children: [
          Column(
              children: [
                //-------------------------PORTADA
                Image.network(
                  imageUrl,
                  fit: BoxFit.fitHeight,
                  scale: 7,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            //-------------------------Artista
                            Text(
                              artist,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //-------------------------MUSICA
                            Text(
                              musicname,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.0,
                              ),
                              overflow: TextOverflow.ellipsis, // Trunca el texto si es demasiado largo
                            ),
                            
                          ],
                        ),
                        //-------------------------SPOTIFY
                        SpotifyLink(
                          songUrl: Uri.parse(
                            'https://open.spotify.com/intl-es/track/1VJALWHEqQhRIzxoHKZR0b?si=f089954986424567',
                          ),
                          size: 30,
                        ),
                        //-------------------------ADD PLAYLIST
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        
                      ]
                    ),
                   
                  ],
                ),
              ],
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  review,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.justify,
                ),
                
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: CorporativeColors.whiteColor,
                  ),
                  itemCount: 5,
                  itemSize: 12.0,
                  unratedColor: CorporativeColors.darkColor,
                  direction: Axis.horizontal,
                ),
              ],
          ),
        ],
      )
    );
  }
}