import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String imageUrl="0";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
            },
          ),
        ],
      ),
    );
  }
}

