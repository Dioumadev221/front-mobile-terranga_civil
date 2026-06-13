import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notifications/notifications.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
      icon: Icons.apps_outlined,
      label: 'Autre',
      color: const Color(0xFF14B8A6),
      onTap: () => context.push(AppRoutes.otherServices),
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
    final unreadNotifs  = ref.watch(unreadNotificationsCountProvider);
    final user          = ref.watch(authProvider).user;
    final name          = (user?.nomComplet.trim().isNotEmpty ?? false)
        ? user!.nomComplet.trim()
        : 'Citoyen';
    final parts         = name.split(RegExp(r'\s+'));
    final initials      = (parts.length > 1
            ? '${parts.first[0]}${parts.last[0]}'
            : parts.first.substring(0, parts.first.length >= 2 ? 2 : 1))
        .toUpperCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── En-tête navy (avatar + salutation + recherche) ──
            SliverToBoxAdapter(child: _NavyHeader(
              name: name,
              initials: initials,
              onNotifications: () => _showNotifications(context),
              unreadCount: unreadNotifs,
              searchController: _searchCtrl,
              onSearchChanged: (v) => setState(() => _query = v.trim()),
            )),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

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
    ).then((_) async {
      // À la fermeture : marquer tout comme lu et rafraîchir le badge.
      await ref.read(notificationsDatasourceProvider).markAllRead();
      ref.invalidate(notificationsProvider);
    });
  }
}

// ── Top Bar ───────────────────────────────────────────────────
// ── En-tête navy : avatar + salutation + cloche/réglages + recherche ──
class _NavyHeader extends StatelessWidget {
  final String name;
  final String initials;
  final VoidCallback onNotifications;
  final int unreadCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  const _NavyHeader({
    required this.name,
    required this.initials,
    required this.onNotifications,
    required this.unreadCount,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 14, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bonjour,',
                        style: TextStyle(
                            color: Color(0xFF9FB0E8), fontSize: 12)),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _HeaderIcon(
                icon: Icons.notifications_outlined,
                onTap: onNotifications,
                badge: unreadCount,
              ),
              const SizedBox(width: 8),
              const _HeaderIcon(icon: Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: 'Rechercher un service...',
              hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF9CA3AF), size: 22),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (_, val, __) => val.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF9CA3AF), size: 20),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;
  const _HeaderIcon({required this.icon, this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFDBE3FF), size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Text(
                  badge > 9 ? '9+' : '$badge',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
              ),
            ),
        ],
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
/// Icône + couleur d'une notification, déduites de son titre.
({IconData icon, Color color}) _notifVisual(String title) {
  final t = title.toLowerCase();
  if (t.contains('disponible') || t.contains('prêt') || t.contains('pret')) {
    return (icon: Icons.check_circle_outline, color: AppColors.statusGreen);
  }
  if (t.contains('approuv') || t.contains('valid')) {
    return (icon: Icons.verified_outlined, color: AppColors.statusGreen);
  }
  if (t.contains('vérification') ||
      t.contains('verification') ||
      t.contains('traitement') ||
      t.contains('cours')) {
    return (icon: Icons.hourglass_top_outlined, color: AppColors.statusAmber);
  }
  if (t.contains('rejet') || t.contains('action requise')) {
    return (icon: Icons.cancel_outlined, color: AppColors.statusRed);
  }
  if (t.contains('attribué') || t.contains('attribue')) {
    return (icon: Icons.assignment_ind_outlined, color: AppColors.statusBlue);
  }
  return (icon: Icons.inbox_outlined, color: AppColors.statusBlue);
}

/// Temps relatif court ("à l'instant", "il y a 3 h", "il y a 2 j").
String _relativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inMinutes < 1) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _NotificationSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _NotificationSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final notifsAsync = ref.watch(notificationsProvider);
    final unread = notifsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

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
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$unread ${unread > 1 ? "nouveaux" : "nouveau"}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: notifsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => Center(
                child: Text('Impossible de charger les notifications.',
                    style: AppTextStyles.bodySmall),
              ),
              data: (list) {
                if (list.isEmpty) {
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
                        Text('Vous serez prévenu de l\'avancement de vos demandes',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 68),
                  itemBuilder: (_, i) {
                    final n = list[i];
                    final v = _notifVisual(n.title);
                    return ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: v.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(v.icon, color: v.color, size: 22),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(n.title,
                                style: AppTextStyles.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.body,
                              style: AppTextStyles.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          if (n.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(_relativeTime(n.createdAt),
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textHint)),
                          ],
                        ],
                      ),
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
