import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/l10n/language_controller.dart';
import 'package:controlapp/src/features/auth/presentation/view/onboarding_view.dart';
import 'package:controlapp/src/features/presentation/profile/view_model/profile_cubit.dart';
import 'package:controlapp/src/features/presentation/profile/view_model/profile_state.dart';
import 'package:controlapp/src/features/presentation/shared/module_device_header.dart';
import 'package:controlapp/src/features/climate/presentation/pages/iletisim_page.dart';
import 'package:controlapp/widget/profilbilgi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/profile_language_selector.dart';
import '../widgets/profile_module_tile.dart';
import '../widgets/profile_option_card.dart';
import '../widgets/profile_web_links.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              current.snackbarMessage != null &&
              current.snackbarMessage != previous.snackbarMessage,
          listener: (context, state) {
            final message = state.snackbarMessage;
            if (message != null && message.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: grey,
                    content: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              context.read<ProfileCubit>().clearSnackbar();
            }
          },
          builder: (context, state) {
            final summary = state.userSummary;
            final moduleTitle = state.selectedModule ?? '';
            final deviceTitle =
                state.selectedDeviceTitle ?? state.plcTitle ?? '';
            final imageUrl = summary.imageUrl;

            return Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // if (state.isLoading)
                      //   const LinearProgressIndicator(minHeight: 2),
                      FadeInAnimation(
                        delay: 1,
                        child: Row(
                          children: [
                            _buildDecorationImage(imageUrl),
                            SizedBox(width: 20.h),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.fullName.isNotEmpty
                                        ? summary.fullName
                                        : '',
                                    style: TextStyle(
                                      fontSize: 28.h,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  ModuleDeviceHeader(
                                    moduleTitle: moduleTitle,
                                    spacing: 2,
                                    moduleStyle: TextStyle(
                                      fontSize: 18.h,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                    deviceStyle: TextStyle(
                                      fontSize: 16.h,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(25),
                                minimumSize: const Size(0, 0),
                                foregroundColor: darkColor,
                              ),
                              onPressed: () => _showLogoutDialog(context),
                              child: const Icon(Iconsax.logout),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProfileOptionCard(
                        icon: Icons.person,
                        text: AppLocalizations.of(context)!.profilBilgisi,
                        delay: 1.2,
                        onTap: () => _showProfileInfo(context),
                      ),
                      ProfileOptionCard(
                        icon: Icons.info,
                        text: AppLocalizations.of(context)!.iletisimBilgisi,
                        delay: 1.3,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IletisimPage(),
                          ),
                        ),
                      ),
                      ..._buildModuleTiles(context),
                      ProfileLanguageSelector(
                        delay: 1.5,
                        languageProvider: languageProvider,
                      ),
                      const ProfileWebLinks(
                        delay: 1.6,
                        onTap: _launchExternalUrl,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildDecorationImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        height: 70.h,
        width: 70.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(120),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(120),
        image: const DecorationImage(
          image: AssetImage('assets/avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  List<Widget> _buildModuleTiles(BuildContext context) {
    final entries = [
      _ProfileModuleEntry(
          caption: legacy_data.iklimlendirmeIzlem, icon: Icons.air),
      _ProfileModuleEntry(
        caption: legacy_data.enerjiIzlem,
        icon: Icons.settings_input_component,
      ),
      _ProfileModuleEntry(
          caption: legacy_data.boyahaneIzlem, icon: Icons.brush),
    ];

    return entries
        .where((entry) => legacy_data.organizationList
            .any((organization) => organization.caption == entry.caption))
        .map(
          (entry) => ProfileModuleTile(
            icon: entry.icon,
            text: entry.caption,
            delay: 1.4,
            onTap: () {
              context.read<ProfileCubit>().selectOrganization(entry.caption);
            },
          ),
        )
        .toList();
  }

  static Future<void> _launchExternalUrl(String url) async {
    final uri = Uri(scheme: 'https', host: url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Failed to launch $url';
    }
  }

  static Future<void> _showProfileInfo(BuildContext context) async {
    final summary = context.read<ProfileCubit>().state.userSummary;

    await showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(dialogContext)!.profilBilgisi,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfilbilgiWidget(
                    icon: Icons.person,
                    title: AppLocalizations.of(dialogContext)!.girisIsmi,
                    value: summary.fullName.isNotEmpty ? summary.fullName : '',
                  ),
                  ProfilbilgiWidget(
                    icon: Icons.email,
                    title: AppLocalizations.of(dialogContext)!.ePosta,
                    value: legacy_data.userDataConst['email']?.toString() ?? '',
                  ),
                  ProfilbilgiWidget(
                    icon: Icons.business,
                    title: AppLocalizations.of(dialogContext)!.firmaAdi,
                    value: legacy_data.userDataConst['firm_name']?.toString() ??
                        '',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final navigator = Navigator.of(context);

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: white,
          shadowColor: transparent,
          surfaceTintColor: transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.h)),
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 28.sp,
                  color: Colors.red,
                ),
                Text(
                  AppLocalizations.of(context)!.cikisOnayi,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(dialogContext).pop();
                        await _clearSharedPreferences();
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.h),
                          border: Border.all(
                            width: 1.h,
                            color: grey,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.h,
                            vertical: 12.h,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.cikis,
                              style: TextStyle(
                                color: grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(dialogContext).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.h),
                          border: Border.all(
                            width: 1.h,
                            color: grey,
                          ),
                          color: grey,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.h,
                            vertical: 12.h,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.iptal,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class _ProfileModuleEntry {
  const _ProfileModuleEntry({required this.caption, required this.icon});

  final String caption;
  final IconData icon;
}
