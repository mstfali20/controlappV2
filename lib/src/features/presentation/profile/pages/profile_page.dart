import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/l10n/language_controller.dart';
import 'package:controlapp/src/features/auth/presentation/view/onboarding_view.dart';
import 'package:controlapp/src/features/presentation/profile/view_model/profile_cubit.dart';
import 'package:controlapp/src/features/presentation/profile/view_model/profile_state.dart';
import 'package:controlapp/src/features/presentation/shared/module_device_header.dart';
import 'package:controlapp/src/features/yardimci_tesisler/climate/presentation/pages/iletisim_page.dart';
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
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

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final Set<String> _expandedSections = {};

  void _toggleSection(String sectionId) {
    setState(() {
      if (!_expandedSections.remove(sectionId)) {
        _expandedSections.add(sectionId);
      }
    });
  }

  void _collapseSection(String sectionId) {
    if (!_expandedSections.contains(sectionId)) {
      return;
    }
    setState(() {
      _expandedSections.remove(sectionId);
    });
  }

  bool _isSectionExpanded(String sectionId) {
    return _expandedSections.contains(sectionId);
  }

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
                      if (_buildModuleSection(context) != null)
                        _buildModuleSection(context)!,
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
    if (legacy_data.sectionList.isNotEmpty) {
      return legacy_data.sectionList.map((section) {
        return _buildSectionTile(context, section);
      }).toList();
    }

    final iconMap = <String, IconData>{
      legacy_data.iklimlendirmeIzlem: Icons.air,
      legacy_data.enerjiIzlem: Icons.settings_input_component,
      legacy_data.boyahaneIzlem: Icons.brush,
    };

    return legacy_data.organizationList
        .where((organization) => iconMap.containsKey(organization.caption))
        .map(
          (organization) => ProfileModuleTile(
            icon: iconMap[organization.caption] ?? Icons.category,
            text: organization.caption,
            delay: 1.4,
            onTap: () {
              context
                  .read<ProfileCubit>()
                  .selectOrganization(organization);
            },
          ),
        )
        .toList();
  }

  Widget? _buildModuleSection(BuildContext context) {
    final tiles = _buildModuleTiles(context);
    if (tiles.isEmpty) {
      return null;
    }

    return FadeInAnimation(
      delay: 1.4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.widgets_rounded, size: 20.h, color: Colors.black),
                  SizedBox(width: 8.h),
                  Text(
                    AppLocalizations.of(context)!.modulSec,
                    style: TextStyle(
                      fontSize: 18.h,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...tiles,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTile(BuildContext context, SectionData section) {
    final isExpanded = _isSectionExpanded(section.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileModuleTile(
          icon: _sectionIcon(section.id),
          text: section.caption,
          delay: 1.4,
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more,
              color: Colors.grey.shade600,
            ),
          ),
          onTap: () => _toggleSection(section.id),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildSectionChildren(context, section),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
        ),
      ],
    );
  }

  Widget _buildSectionChildren(BuildContext context, SectionData section) {
    if (section.organizations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: section.organizations
          .map((organization) =>
              _buildOrganizationTile(context, section, organization))
          .toList(),
    );
  }

  Widget _buildOrganizationTile(
    BuildContext context,
    SectionData section,
    OrganizationData organization,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 28.h, right: 8.h, bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context
                .read<ProfileCubit>()
                .selectOrganization(organization, section: section);
            _collapseSection(section.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  _sectionIcon(section.id),
                  size: 18.h,
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: 10.h),
                Expanded(
                  child: Text(
                    organization.displayCaption,
                    style: TextStyle(
                      fontSize: 14.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18.h,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _sectionIcon(String sectionId) {
    switch (sectionId) {
      case 'energy':
        return Icons.settings_input_component;
      case 'renewable':
        return Icons.wb_sunny;
      case 'utilities':
        return Icons.build;
      case 'production':
        return Icons.precision_manufacturing;
      default:
        return Icons.category;
    }
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
