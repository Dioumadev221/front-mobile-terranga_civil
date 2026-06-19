import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

/// Barre de navigation flottante (pill) : 5 items avec le bouton IA « Ndiogoye »
/// pile au centre.
///
/// [currentIndex] suit _shellIndex : 0 = Accueil, 1 = Dossiers, 3 = Documents,
/// 4 = Profil (2 = bouton IA central, action, jamais "actif").
class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            height: 78,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Barre pill ──
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: Container(
                    height: 62,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavItem(
                          label: 'Accueil',
                          icon: Icons.home_rounded,
                          imageAsset: 'assets/images/menu/accueil.png',
                          isActive: currentIndex == 0,
                          onTap: () => context.go(AppRoutes.home),
                        ),
                        _NavItem(
                          label: 'Dossiers',
                          icon: Icons.folder_rounded,
                          imageAsset: 'assets/images/menu/dossiers.png',
                          isActive: currentIndex == 1,
                          onTap: () => context.go(AppRoutes.dossiers),
                        ),
                        const SizedBox(width: 56),
                        _NavItem(
                          label: 'Documents',
                          icon: Icons.article_rounded,
                          imageAsset: 'assets/images/menu/documents.png',
                          isActive: currentIndex == 3,
                          onTap: () => context.go(AppRoutes.documents),
                        ),
                        _NavItem(
                          label: 'Profil',
                          icon: Icons.person_rounded,
                          imageAsset: 'assets/images/menu/profil.png',
                          isActive: currentIndex == 4,
                          onTap: () => context.go(AppRoutes.profile),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Bouton Ndiogoye central surélevé ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _NdiogoyeButton(
                      onTap: () => context.push(AppRoutes.agentChat),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String? imageAsset;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.primary : const Color(0xFF1E293B);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE9F1FB)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: imageAsset != null
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      child: Image.asset(imageAsset!,
                          width: 21, height: 21, fit: BoxFit.contain),
                    )
                  : Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NdiogoyeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NdiogoyeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C6FB8), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.background, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
