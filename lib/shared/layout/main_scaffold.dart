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
      // ── Body avec FAB flottant intégré ──────────────────
      body: Stack(
        children: [
          child,
          // Bandeau assistante — en bas au-dessus de la barre de nav
          // Affiché uniquement sur l'onglet Accueil (index 0)
          if (currentIndex == 0)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.agentChat),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar — zoom sur le visage
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        height: 59,
                        child: OverflowBox(
                          maxWidth: 130,
                          maxHeight: 140,
                          alignment: const Alignment(0, -0.65),
                          child: Image.asset(
                            'assets/images/assistante.png',
                            width: 130,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Texte d'invitation
                    Expanded(
                      child: Text(
                        'Besoin d\'aide ? Faites votre demande directement avec notre assistante !',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.secondary, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // ── Barre de navigation 3 items égaux ───────────────
      bottomNavigationBar: _TerangaBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => _onTabTapped(context, i),
      ),
    );
  }
}

class _TerangaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _TerangaBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          height: 60,
          child: Row(
            children: List.generate(MainScaffold._tabs.length, (i) {
              return Expanded(
                child: _NavItem(
                  tab: MainScaffold._tabs[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
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
