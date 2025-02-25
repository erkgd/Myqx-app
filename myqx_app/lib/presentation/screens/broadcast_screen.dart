import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/app_scaffold.dart';
import 'package:myqx_app/presentation/widgets/rated_music.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> feedItems = [
      ListTile(
        leading: Icon(Icons.article),
        title: Text('Article 1'),
        subtitle: Text('Description of article 1'),
      ),
      ListTile(
        leading: Icon(Icons.article),
        title: Text('Article 2'),
        subtitle: Text('Description of article 2'),
      ),
      // Agrega más elementos aquí
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Broadcast Feed'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: feedItems,
            ),
          ),
          const SizedBox(height: 8.0),
          const RatedMusic(
            imageUrl: 'https://example.com/image.jpg',
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