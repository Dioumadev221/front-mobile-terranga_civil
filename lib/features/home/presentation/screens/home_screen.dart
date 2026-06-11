import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/assets_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dossiers/presentation/providers/dossiers_provider.dart';

// ── Modèle service rapide ─────────────────────────────────────
class _QuickService {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickService({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// ── Modèle service bientôt ────────────────────────────────────
class _ComingSoon {
  final IconData icon;
  final String label;
  const _ComingSoon({required this.icon, required this.label});
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Tous les services disponibles ─────────────────────────────
  List<_QuickService> get _allServices => [
    _QuickService(
      icon: Icons.article_outlined,
      label: 'Naissance',
      color: const Color(0xFF3B82F6),
      onTap: () => context.push(AppRoutes.naissanceBeneficiary),
    ),
    _QuickService(
      icon: Icons.favorite_rounded,
      label: 'Mariage',
      color: const Color(0xFFEC4899),
      onTap: () => context.push(AppRoutes.mariageForm),
    ),
    _QuickService(
      icon: Icons.local_florist_outlined,
      label: 'Décès',
      color: const Color(0xFF6366F1),
      onTap: () => context.push(AppRoutes.decesForm),
    ),
    _QuickService(
      icon: Icons.folder_copy_outlined,
      label: 'Dossiers',
      color: const Color(0xFF1D9E75),
      onTap: () => context.go(AppRoutes.dossiers),
    ),
  ];

  // ── Tous les services bientôt ──────────────────────────────────
  static const _allComingSoon = [
    _ComingSoon(icon: Icons.gavel_rounded,     label: 'Casier judiciaire'),
    _ComingSoon(icon: Icons.public_rounded,    label: 'Nationalité'),
    _ComingSoon(icon: Icons.badge_outlined,    label: 'Demande NINEA'),
    _ComingSoon(icon: Icons.store_rounded,     label: 'Registre du Commerce'),
  ];

  List<_QuickService> get _filteredServices {
    if (_query.isEmpty) return _allServices;
    final q = _query.toLowerCase();
    return _allServices.where((s) => s.label.toLowerCase().contains(q)).toList();
  }

  List<_ComingSoon> get _filteredComingSoon {
    if (_query.isEmpty) return _allComingSoon;
    final q = _query.toLowerCase();
    return _allComingSoon.where((s) => s.label.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered      = _filteredServices;
    final filteredSoon  = _filteredComingSoon;
    final hasResults    = filtered.isNotEmpty || filteredSoon.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Top bar ──────────────────────────────────────
            SliverToBoxAdapter(child: _TopBar(
              onNotifications: () => _showNotifications(context),
            )),

            // ── Barre de recherche ───────────────────────────
            SliverToBoxAdapter(child: _SearchBarWidget(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
            )),

            // ── Résultat vide ────────────────────────────────
            if (!hasResults)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 56, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text('Aucun service trouvé',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),

            // ── Services disponibles ─────────────────────────
            if (filtered.isNotEmpty) ...[
              SliverToBoxAdapter(child: _SectionHeader(
                title: 'Services disponibles',
                actionLabel: 'Mes dossiers',
                onAction: () => context.go(AppRoutes.dossiers),
              )),
              SliverToBoxAdapter(child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) => _QuickServiceTile(service: filtered[i]),
                ),
              )),
            ],

            // ── Bientôt disponibles ──────────────────────────
            if (filteredSoon.isNotEmpty) ...[
              SliverToBoxAdapter(child: _SectionHeader(
                title: 'Bientôt disponibles',
              )),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ComingSoonCard(item: filteredSoon[i]),
                    childCount: filteredSoon.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NotificationSheet(ref: ref),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onNotifications;
  const _TopBar({required this.onNotifications});

  static const _navy = Color(0xFF0A1F5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo agrandi
          Image.asset(Assets.logoTeranga,
              width: 64, height: 64, fit: BoxFit.contain),
          const SizedBox(width: 12),
          // Titre seul (sans bonjour)
          const Expanded(
            child: Text('TERANGA CIVIL',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.2,
                )),
          ),
          // Cloche
          GestureDetector(
            onTap: onNotifications,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: _navy, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // Paramètres
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined,
                color: _navy, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar (fonctionnelle) ────────────────────────────────
class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBarWidget({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher un service...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF9CA3AF), size: 22),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF9CA3AF), size: 20),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0A1F5C), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                color: Color(0xFF0A1F5C),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: const TextStyle(
                    color: Color(0xFF1D9E75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  )),
            ),
        ],
      ),
    );
  }
}

// ── Quick Service Tile ────────────────────────────────────────
class _QuickServiceTile extends StatelessWidget {
  final _QuickService service;
  const _QuickServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: service.onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: service.color.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Icon(service.icon, color: service.color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              service.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coming Soon Card (grisée) ─────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  final _ComingSoon item;
  const _ComingSoonCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: const Color(0xFF94A3B8), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Bientôt',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lion Assistant Banner ─────────────────────────────────────
class _LionAssistantBanner extends StatelessWidget {
  const _LionAssistantBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Bouton micro agent IA ─────────────────────
              GestureDetector(
                onTap: () {/* lancer agent vocal */},
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1DB954),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // ── Texte ─────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge agent IA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1F5C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🤖  Agent IA — Teranga',
                        style: TextStyle(
                          color: Color(0xFF0A1F5C),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Faites vos demandes en parlant',
                      style: TextStyle(
                        color: Color(0xFF0A1F5C),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Dites simplement ce dont vous avez besoin — extrait de naissance, acte de mariage ou de décès — et notre agent IA collecte toutes les informations nécessaires pour vous.',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {/* navigation vers agent IA */},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1F5C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Parler à l\'agent  →',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notification Sheet ────────────────────────────────────────
class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _NotificationSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _NotificationSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final dossiers = ref.watch(dossiersListProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.35,
      builder: (ctx, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: AppTextStyles.headlineSmall),
                dossiers.when(
                  data: (list) => list.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${list.length}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: Colors.white)),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: dossiers.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => Center(
                child: Text('Impossible de charger les notifications.',
                    style: AppTextStyles.bodySmall),
              ),
              data: (list) {
                final items = list.map((d) {
                  final typeLabel =
                      AppFormatters.certTypeLabel(d.type).toLowerCase();
                  late String title;
                  late String subtitle;
                  late IconData icon;
                  late Color color;
                  switch (d.status) {
                    case 'pret':
                      title = 'Certificat prêt à télécharger';
                      subtitle = 'Votre $typeLabel (${d.id}) est disponible.';
                      icon = Icons.check_circle_outline;
                      color = AppColors.statusGreen;
                      break;
                    case 'valide':
                      title = 'Dossier validé';
                      subtitle = 'Votre $typeLabel (${d.id}) a été validé.';
                      icon = Icons.verified_outlined;
                      color = AppColors.statusGreen;
                      break;
                    case 'en_verification':
                      title = 'Dossier en vérification';
                      subtitle = 'Votre $typeLabel (${d.id}) est en cours.';
                      icon = Icons.hourglass_top_outlined;
                      color = AppColors.statusAmber;
                      break;
                    case 'rejete':
                      title = 'Dossier rejeté';
                      subtitle = 'Votre $typeLabel (${d.id}) a été rejeté.';
                      icon = Icons.cancel_outlined;
                      color = AppColors.statusRed;
                      break;
                    default:
                      title = 'Dossier reçu';
                      subtitle = 'Votre $typeLabel (${d.id}) a été soumis.';
                      icon = Icons.inbox_outlined;
                      color = AppColors.statusBlue;
                  }
                  return _NotifItem(
                      icon: icon, iconColor: color,
                      title: title, subtitle: subtitle);
                }).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_outlined,
                              size: 36, color: AppColors.textHint),
                        ),
                        const SizedBox(height: 16),
                        Text('Aucune notification',
                            style: AppTextStyles.labelMedium),
                        const SizedBox(height: 4),
                        Text('Vos dossiers s\'afficheront ici',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 68),
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: n.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(n.icon, color: n.iconColor, size: 22),
                      ),
                      title: Text(n.title, style: AppTextStyles.labelMedium),
                      subtitle: Text(n.subtitle,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
