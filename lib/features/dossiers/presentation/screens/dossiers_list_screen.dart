import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/dossier_model.dart';
import '../providers/dossiers_provider.dart';
import '../providers/downloaded_docs_provider.dart';

class DossiersListScreen extends ConsumerStatefulWidget {
  const DossiersListScreen({super.key});

  @override
  ConsumerState<DossiersListScreen> createState() => _DossiersListScreenState();
}

class _DossiersListScreenState extends ConsumerState<DossiersListScreen> {
  String _selectedFilter = 'Tous';
  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = ['Tous', 'En cours', 'Validés', 'Incomplets'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isDone(String s) => s == 'pret' || s == 'valide';
  bool _isIncomplete(String s) => s == 'rejete';

  @override
  Widget build(BuildContext context) {
    final dossiersAsync = ref.watch(dossiersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dossiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0B285D))),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              const Text('Impossible de charger', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(dossiersListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (dossiers) {
          final total = dossiers.length;
          final termines = dossiers.where((d) => _isDone(d.status)).length;
          final enCours = dossiers.where((d) => !_isDone(d.status) && !_isIncomplete(d.status)).length;

          final filtered = dossiers.where((d) {
            switch (_selectedFilter) {
              case 'En cours':   return !_isDone(d.status) && !_isIncomplete(d.status);
              case 'Validés':    return _isDone(d.status);
              case 'Incomplets': return _isIncomplete(d.status);
              default:           return true;
            }
          }).toList();

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HERO (navy + halos, cohérent avec l'accueil) ──────
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0B2E66),
                            Color(0xFF0B285D),
                            Color(0xFF0A1F4D)
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.8, -0.9),
                                    radius: 1.0,
                                    colors: [
                                      const Color(0xFF3B7AC4)
                                          .withValues(alpha: 0.50),
                                      const Color(0xFF3B7AC4)
                                          .withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.6],
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.95, 1.0),
                                    radius: 1.0,
                                    colors: [
                                      const Color(0xFFC9883E)
                                          .withValues(alpha: 0.30),
                                      const Color(0xFFC9883E)
                                          .withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.55],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 56, 20, 42),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Mes dossiers',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Suivez l'avancement de vos demandes",
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.78),
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _hdrBtn(Icons.event_rounded,
                                      onTap: () => context
                                          .push(AppRoutes.appointments)),
                                  const SizedBox(width: 10),
                                  _hdrBtn(Icons.notifications_none,
                                      onTap: () => context
                                          .push(AppRoutes.notifications)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Stats (cartes blanches qui chevauchent le hero) ──
                    Transform.translate(
                      offset: const Offset(0, -34),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                                child: _statCard(
                                    'Total', total, const Color(0xFF0F172A))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _statCard('En cours', enCours,
                                    const Color(0xFFC0840F))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _statCard('Prêts', termines,
                                    const Color(0xFF1E7A48))),
                          ],
                        ),
                      ),
                    ),

                    // ── FILTRES ───────────────────────────────────────────
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final sel = _selectedFilter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF0B285D)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: sel
                                    ? null
                                    : Border.all(color: const Color(0xFFE6EAF0)),
                              ),
                              child: Text(f,
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins')),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── LISTE ─────────────────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Aucun dossier trouvé', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DossierCard(dossier: filtered[i]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _hdrBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _statCard(String label, int count, Color numColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEFF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  color: numColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  height: 1)),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte dossier
// ─────────────────────────────────────────────────────────────────────────────
class _DossierCard extends ConsumerWidget {
  final DossierModel dossier;
  const _DossierCard({required this.dossier});

  bool get _isDone => dossier.status == 'pret' || dossier.status == 'valide';
  bool get _isIncomplete => dossier.status == 'rejete';

  /// Télécharge le certificat PDF du dossier (web/natif via downloadCertificate).
  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('Téléchargement en cours…'),
      duration: Duration(seconds: 1),
    ));
    try {
      final path =
          await ref.read(downloadCertificateProvider(dossier.id).future);
      // Règle métier : un document prêt ne se télécharge qu'une seule fois.
      await ref.read(downloadedDocsProvider.notifier).markDownloaded(dossier.id);
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('Certificat téléchargé : $path'),
          backgroundColor: const Color(0xFF10B981),
        ));
    } catch (_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
          content: Text('Échec du téléchargement.'),
          backgroundColor: Color(0xFFEF4444),
        ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = _typeStyle(dossier.type);
    final s = _statusStyle();
    final downloaded = ref.watch(downloadedDocsProvider).contains(dossier.id);
    final ref8 = dossier.id.length > 8
        ? dossier.id.substring(0, 8).toUpperCase()
        : dossier.id.toUpperCase();

    return GestureDetector(
      onTap: () => context.push(AppRoutes.dossierDetailPath(dossier.id)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEFF4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: t.$2, borderRadius: BorderRadius.circular(13)),
                  child: Icon(t.$1, color: t.$3, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.certTypeLabel(dossier.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'N° $ref8 · ${AppFormatters.dateShort(dossier.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: s.$3, borderRadius: BorderRadius.circular(100)),
                  child: Text(s.$1,
                      style: TextStyle(
                          color: s.$2,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: dossier.progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFEEF1F6),
                valueColor: AlwaysStoppedAnimation<Color>(s.$2),
              ),
            ),
            const SizedBox(height: 12),
            if (_isDone)
              Row(
                children: [
                  Expanded(
                    child: downloaded
                        ? _btn('Déjà téléchargé', Icons.check_circle,
                            const Color(0xFFEEF1F6), const Color(0xFF64748B),
                            filled: true)
                        : GestureDetector(
                            onTap: () => _download(context, ref),
                            child: _btn('Télécharger', Icons.download_rounded,
                                const Color(0xFF0B285D), Colors.white,
                                filled: true),
                          ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.dossierDetailPath(dossier.id)),
                    child: _btn('Détail', null, Colors.white,
                        const Color(0xFF475569),
                        filled: false),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isIncomplete ? 'Action requise' : s.$1,
                    style: TextStyle(
                        color: _isIncomplete
                            ? const Color(0xFFA32D2D)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'),
                  ),
                  const Row(
                    children: [
                      Text('Détail',
                          style: TextStyle(
                              color: Color(0xFF0B285D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins')),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 15, color: Color(0xFF0B285D)),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// (icône, fond, couleur) selon le type de démarche.
  (IconData, Color, Color) _typeStyle(String type) {
    switch (type) {
      case 'naissance':
        return (Icons.child_friendly_rounded, Color(0xFFE6F0FB), Color(0xFF0B285D));
      case 'mariage':
        return (Icons.favorite_rounded, Color(0xFFFBE9EF), Color(0xFFB23A60));
      case 'deces':
        return (Icons.local_florist_rounded, Color(0xFFF1F5F9), Color(0xFF475569));
      case 'residence':
        return (Icons.home_rounded, Color(0xFFE7F3EC), Color(0xFF1E7A48));
      case 'regularisation':
      case 'autorisation_construire':
      case 'mutation_parcelle':
        return (Icons.map_rounded, Color(0xFFF3EAFB), Color(0xFF7A3DAE));
      default:
        return (Icons.description_rounded, Color(0xFFE6F0FB), Color(0xFF0B285D));
    }
  }

  /// (libellé, couleur texte, fond pastille) selon le statut.
  (String, Color, Color) _statusStyle() {
    if (_isDone) {
      return ('Prêt', const Color(0xFF1E7A48), const Color(0xFFE7F3EC));
    }
    if (_isIncomplete) {
      return ('À corriger', const Color(0xFFA32D2D), const Color(0xFFFCEBEB));
    }
    String label;
    switch (dossier.status) {
      case 'soumis':
        label = 'Soumis';
        break;
      case 'en_verification':
        label = 'En vérification';
        break;
      default:
        label = 'En cours';
    }
    return (label, const Color(0xFF9A6308), const Color(0xFFFBF0DC));
  }

  Widget _btn(String label, IconData? icon, Color bg, Color fg,
      {required bool filled}) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      padding: filled ? null : const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: filled ? bg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
