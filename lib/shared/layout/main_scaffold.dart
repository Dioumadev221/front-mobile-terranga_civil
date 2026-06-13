import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const _tabs = [
    _NavTab(
        label: 'Accueil',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        route: '/home'),
    _NavTab(
        label: 'Dossiers',
        icon: Icons.folder_copy_outlined,
        activeIcon: Icons.folder_copy,
        route: '/dossiers'),
    _NavTab(
        label: 'Profil',
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        route: '/profile'),
  ];

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    context.go(_tabs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      // ── Barre de navigation avec micro central (assistant) ──
      bottomNavigationBar: _TerangaBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => _onTabTapped(context, i),
        onMic: () => context.push(AppRoutes.agentChat),
        onAide: () {}, // purement visuel pour l'instant
      ),
    );
  }
}

class _TerangaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback onMic;
  final VoidCallback onAide;
  const _TerangaBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onMic,
    required this.onAide,
  });

  static const _aideTab = _NavTab(
    label: 'Aide',
    icon: Icons.support_agent_outlined,
    activeIcon: Icons.support_agent,
    route: '',
  );

  @override
  Widget build(BuildContext context) {
    final tabs = MainScaffold._tabs;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              // Groupe gauche : Accueil + Dossiers
              Expanded(
                flex: 2,
                child: Row(children: [
                  Expanded(
                    child: _NavItem(
                      tab: tabs[0],
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      tab: tabs[1],
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ),
                ]),
              ),
              // Micro central — assistant vocal Ndiogoye
              _MicButton(onTap: onMic),
              // Groupe droit : Aide + Profil
              Expanded(
                flex: 2,
                child: Row(children: [
                  Expanded(
                    child: _NavItem(
                      tab: _aideTab,
                      isActive: false,
                      onTap: onAide,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      tab: tabs[2],
                      isActive: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 2),
            Text(
              'Ndiogoye',
              style: AppTextStyles.navLabel.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem(
      {required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? tab.activeIcon : tab.icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: AppTextStyles.navLabel.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
