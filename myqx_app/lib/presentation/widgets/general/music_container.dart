import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class MusicContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const MusicContainer({Key? key, required this.child, this.borderColor = CorporativeColors.whiteColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.black,
         border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }
}