import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/bottom_navbar.dart';
import 'package:myqx_app/presentation/widgets/gradient_background.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';

class AppScaffold extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;

  const AppScaffold({
    super.key,
    required this.pages,
    this.initialIndex = 0,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.pages[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onIndexChanged,
        ),
      ),
    );
  }
}