import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/bottom_navbar.dart';
import 'package:myqx_app/presentation/widgets/gradient_background.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;

  /// Callback opcional para notificar un cambio en el índice.
  final Function(int index)? onIndexChanged;

  const AppScaffold({
    super.key,
    required this.body,
    this.onIndexChanged,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 1;

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (widget.onIndexChanged != null) {
      widget.onIndexChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.body,
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleBottomNavTap,
        ),
      ),
    );
  }
}