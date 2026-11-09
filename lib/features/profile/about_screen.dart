import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:master_ji/l10n/app_localizations.dart';
import 'package:master_ji/theme/app_colors.dart';
import 'package:master_ji/theme/app_text.dart';
import 'package:master_ji/theme/app_theme.dart';
import 'package:master_ji/widgets/app_card.dart';

/// About & Privacy screen displaying app branding, dynamic version info, and privacy details.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.aboutAndPrivacy),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.sp24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.sp16),

              // ── App Icon ──────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.sp16),

              // ── App Name ──────────────────────────────────────────────────
              Text(
                l10n.appName,
                style: AppTextStyles.headlineLarge(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.sp8),

              // ── Version Info ──────────────────────────────────────────────
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final versionText = snapshot.hasData
                      ? '${l10n.version} ${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                      : '${l10n.version} 1.0.0+1';
                  return Text(
                    versionText,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.sp24),

              // ── Divider ───────────────────────────────────────────────────
              const Divider(),

              const SizedBox(height: AppTheme.sp24),

              // ── Privacy Card ──────────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppTheme.sp8),
                        Text(
                          l10n.aboutAndPrivacy,
                          style: AppTextStyles.titleMedium(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.sp12),
                    Text(
                      l10n.privacyPlaceholder,
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sp16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openPrivacyPolicy(context),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('View Full Privacy Policy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusButton),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.sp32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    const url = 'https://masterji.app/privacy';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open web browser.')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy URL.')),
        );
      }
    }
  }
}
