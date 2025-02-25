import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            artist,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            musicname,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            unratedColor: Colors.grey,
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 8.0),
          Text(
            review,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}