import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';


class ReviewInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onCancel;

  const ReviewInput({
    Key? key, 
    required this.controller,
    required this.maxLength,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      borderColor: CorporativeColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Write your review (optional, max. $maxLength characters)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: CorporativeColors.mainColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: CorporativeColors.mainColor,
                    width: 2.0,
                  ),
                ),
                hintText: 'Share your thoughts about this album (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                counterStyle: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: const Text('Cancel All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}