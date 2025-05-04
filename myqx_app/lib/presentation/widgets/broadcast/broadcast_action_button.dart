import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';

class BroadcastActionButton extends StatefulWidget {
  const BroadcastActionButton({Key? key}) : super(key: key);

  @override
  State<BroadcastActionButton> createState() => _BroadcastActionButtonState();
}

class _BroadcastActionButtonState extends State<BroadcastActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de búsqueda (índice 3)
        final navProvider = Provider.of<NavigationProvider>(context, listen: false);
        navProvider.setCurrentIndex(3);
      },
      child: Container(
        height: 40.0,
        width: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CorporativeColors.gradientColorTop,
          border: Border.all(
            color: CorporativeColors.mainColor,
            width: 2.0,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: CorporativeColors.mainColor,
          size: 35.0,
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildActionMenu(context),
      transitionAnimationController: _animationController,
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CorporativeColors.gradientColorTop, // Color oscuro para el fondo
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: CorporativeColors.mainColor,
            width: 1.5,
          ),
          left: BorderSide(
            color: CorporativeColors.mainColor,
            width: 1.5,
          ),
          right: BorderSide(
            color: CorporativeColors.mainColor,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrastre
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 25),
          
          // Opción 1: Rate Music
          _buildActionItem(
            icon: Icons.star,
            title: 'Rate Music',
            onTap: () {
              Navigator.of(context).pop();
              // Navegar a pantalla de calificación
              debugPrint('Navigate to Rate Music');
            },
          ),
          
          const SizedBox(height: 20),
          
          // Opción 2: Share Playlist
          _buildActionItem(
            icon: Icons.share,
            title: 'Share Playlist',
            onTap: () {
              Navigator.of(context).pop();
              // Compartir playlist
              debugPrint('Navigate to Share Playlists');
            },
          ),
          
          const SizedBox(height: 20),
          
          // Opción 3: Show your listening
          _buildActionItem(
            icon: Icons.headphones,
            title: 'Show your listening',
            onTap: () {
              Navigator.of(context).pop();
              // Mostrar lo que está escuchando
              debugPrint('Navigate to Show Your Listening');
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: CorporativeColors.mainColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CorporativeColors.mainColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}