import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/broadcast/rated_music.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> feedItems = [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: feedItems,
            ),
          ),
          
          const RatedMusic(
            imageUrl: 'https://f4.bcbits.com/img/a2767682510_10.jpg',
            artist: 'People Like Us',
            musicname: 'Chicken Leggs',
            review: '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum scelerisque ligula in ligula semper, non suscipit orci viverra."',
            rating: 4,
          ),
        ],
      ),
    );
  }
}