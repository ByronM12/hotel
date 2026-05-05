import 'package:flutter/material.dart';

class FloatingNavigationBar extends StatefulWidget {
  const FloatingNavigationBar({
    super.key,
    required this.onAddPressed,
    required this.onFavoritesPressed,
    required this.onProfilePressed,
  });

  final VoidCallback onAddPressed;
  final VoidCallback onFavoritesPressed;
  final VoidCallback onProfilePressed;

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar> {
  int _activeIndex = -1; // -1 = none, 0 = add, 1 = favorites, 2 = profile

  void _selectIcon(int index) {
    setState(() {
      if (_activeIndex == index) {
        _activeIndex = -1;
      } else {
        _activeIndex = index;
        // Trigger the action
        if (index == 0) widget.onAddPressed();
        if (index == 1) widget.onFavoritesPressed();
        if (index == 2) widget.onProfilePressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.92),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(
              icon: Icons.add_rounded,
              index: 0,
              tooltip: 'Agregar',
              onTap: () => _selectIcon(0),
            ),
            _buildNavIcon(
              icon: Icons.favorite_border_rounded,
              index: 1,
              tooltip: 'Favoritos',
              onTap: () => _selectIcon(1),
            ),
            _buildNavIcon(
              icon: Icons.person_outline_rounded,
              index: 2,
              tooltip: 'Perfil',
              onTap: () => _selectIcon(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final bool isActive = _activeIndex == index;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isActive
                  ? const Color(0xFFD4AF37).withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 240),
                scale: isActive ? 1.2 : 1.0,
                child: Icon(
                  icon,
                  color: isActive
                      ? const Color(0xFFD4AF37)
                      : Colors.white.withOpacity(0.8),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
