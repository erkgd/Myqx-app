import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/broadcast/rated_music_element.dart';
import 'package:myqx_app/presentation/widgets/general/divisor.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista hardcodeada de instancias de RatedMusic
    List<Widget> feedItems = [
      RatedMusic(
        imageUrl: 'https://f4.bcbits.com/img/a2767682510_10.jpg',
        artist: 'People Like Us',
        musicname: 'Chicken Leggs',
        review:
            '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum scelerisque ligula in ligula semper, non suscipit orci viverra."',
        rating: 4,
        user: 'erkgd',
      ),
      RatedMusic(
        imageUrl: 'https://f4.bcbits.com/img/a2767682510_10.jpg',
        artist: 'People Like Us',
        musicname: 'Chicken Leggs',
        review:
            '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum scelerisque ligula in ligula semper, non suscipit orci viverra."',
        rating: 4,
        user: 'erkgd',
      ),
      RatedMusic(
        imageUrl: 'https://f4.bcbits.com/img/a2767682510_10.jpg',
        artist: 'People Like Us',
        musicname: 'Chicken Leggs',
        review:
            '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum scelerisque ligula in ligula semper, non suscipit orci viverra."',
        rating: 4,
        user: 'erkgd',
      ),
      
    ];

    List<Widget> feedWithDividers = [];
    for (int i = 0; i < feedItems.length; i++) {
      // Cada RatedMusic se pone con un margen de 10 en todo lado
      feedWithDividers.add(
        Container(
          margin: const EdgeInsets.all(2.0),
          child: feedItems[i],
        ),
      );
      // Si no es el último, añadimos un Divider con solo margen vertical
      if (i != feedItems.length - 1) {
        feedWithDividers.add(
          Divisor()
        );
      }
    }

    return Scaffold(
      appBar: UserHeader(showCircle: true),
      backgroundColor: Colors.transparent,
      // Eliminamos el Padding general para que el Divider llegue a los bordes
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: feedWithDividers,
        ),
      ),
    );
  }
}