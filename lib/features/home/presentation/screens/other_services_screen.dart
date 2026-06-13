import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Écran listant les services « Autre » (au-delà de naissance/mariage/décès).
/// Extensible : on ajoute simplement de nouvelles entrées dans [_services].
class OtherServicesScreen extends StatelessWidget {
  const OtherServicesScreen({super.key});

  static const _services = [
    (
      Icons.home_work_outlined,
      Color(0xFF14B8A6),
      'Certificat de résidence',
      'Validité 3 mois',
      AppRoutes.residenceForm,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Autres services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final (icon, color, title, subtitle, route) = _services[i];
            return GestureDetector(
              onTap: () => context.push(route),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.labelMedium),
                          const SizedBox(height: 2),
                          Text(subtitle, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textHint),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
