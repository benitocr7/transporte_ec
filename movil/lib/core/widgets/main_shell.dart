import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabs = [
    _TabItem(label: 'Inicio', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, path: '/home'),
    _TabItem(label: 'Cargas', icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping_rounded, path: '/loads'),
    _TabItem(label: 'Publicar', icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, path: '/publish'),
    _TabItem(label: 'Mensajes', icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, path: '/messages'),
    _TabItem(label: 'Perfil', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, path: '/profile'),
  ];

  int get _currentIndex {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildNavigationBar(context),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) {
            HapticFeedback.lightImpact();
            context.go(_tabs[i].path);
          },
          destinations: _tabs.asMap().entries.map((e) {
            final tab = e.value;
            final isSelected = e.key == _currentIndex;
            return NavigationDestination(
              icon: Icon(isSelected ? tab.activeIcon : tab.icon),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}
