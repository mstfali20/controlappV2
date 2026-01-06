import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:controlapp/src/features/yardimci_tesisler/climate/presentation/widgets/iklim_menu_widget.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/widgets/energy_menu_widget.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_state.dart';
import 'package:controlapp/src/features/presentation/role/pages/climate_role_page.dart';
import 'package:controlapp/src/features/presentation/role/pages/energy_role_page.dart';
import 'package:controlapp/src/features/presentation/role/pages/renewable_role_page.dart';
import 'package:controlapp/src/features/presentation/role/pages/webdeneme.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        final hasNewError = current.errorMessage != null &&
            current.errorMessage != previous.errorMessage;
        final fallbackActivated =
            current.isFallbackToEnergy && !previous.isFallbackToEnergy;
        return hasNewError || fallbackActivated;
      },
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          _showSnackBar(context, message);
        } else if (state.isFallbackToEnergy) {
          _showSnackBar(
            context,
            'İklim verileri alınamadı, enerji verileri gösteriliyor.',
          );
        }
      },
      builder: (context, state) {
        if (state.status == HomeStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        final module = state.selectedModule ?? HomeCubit.energyModuleCaption;
        final organizationCaption = _resolveSelectedOrganizationCaption(state);
        final isClimateModule =
            organizationCaption == HomeCubit.climateModuleCaption ||
                module == HomeCubit.climateModuleCaption;
        final section = _resolveSection(
          module,
          organizationCaption: organizationCaption,
        );
        final isRenewableModule = section?.id == 'renewable';
        final moduleTitle = _resolveModuleTitle(module, section);
        final deviceTitle =
            state.selectedDeviceTitle ?? state.plcTitle ?? 'Cihaz seçilmedi';
        final name = state.userSummary.fullName.isNotEmpty
            ? state.userSummary.fullName
            : AppLocalizations.of(context)?.hosgeldiniz ?? 'Hoş geldiniz';
        final imageUrl = state.userSummary.imageUrl;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    state,
                    module,
                    imageUrl,
                    name,
                    organizationCaption,
                    isClimateModule,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.h),
                    child: FadeInAnimation(
                      delay: 1,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              moduleTitle,
                              style: TextStyle(
                                fontSize: 20.h,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: creamColor,
                      backgroundColor: grey,
                      onRefresh: () => context
                          .read<HomeCubit>()
                          .refreshCurrentDevice(forceRefresh: true),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                if (isClimateModule) const IklimWidget(),
                                if (!isClimateModule && isRenewableModule)
                                  RenewableEnergyWidget(
                                    moduleCaption: module,
                                  ),
                                if (!isClimateModule && !isRenewableModule)
                                  const EnerjiWidget(),
                              ],
                            ),
                          ),
                          if (state.isLoading)
                            const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HomeState state,
    String module,
    String? imageUrl,
    String name,
    String? organizationCaption,
    bool isClimateModule,
  ) {
    final menuOrganization = organizationCaption ?? module;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeInAnimation(
        delay: 1,
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: Image.asset(
                      'assets/ControlAppSiyah.png',
                      height: 40.h,
                    ),
                  ),
                  Visibility(
                    visible: !isClimateModule,
                    child: EnerjiMenuWidget(
                      organisation: menuOrganization,
                      loadAndParseTree: context.read<HomeCubit>().loadTreeNodes,
                    ),
                  ),
                  Visibility(
                    visible: isClimateModule,
                    child: IklimMenuWidget(
                      organisation: menuOrganization,
                      loadAndParseTree: context.read<HomeCubit>().loadTreeNodes,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildAvatar(imageUrl),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 25.h,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _resolveSelectedOrganizationCaption(HomeState state) {
    final organizationId =
        state.session?.selectedOrganizationId ?? legacy_data.organizationid;
    if (organizationId == null || organizationId.isEmpty) {
      return null;
    }
    final source = state.treeJson ?? legacy_data.treeJson;
    if (source.isEmpty) {
      return null;
    }
    final root = TreeNode.parseTree(source);
    if (root == null) {
      return null;
    }
    final node = root.findById(organizationId);
    if (node == null) {
      return null;
    }
    final caption = node.caption.trim();
    return caption.isNotEmpty ? caption : null;
  }

  SectionData? _resolveSection(
    String moduleCaption, {
    String? organizationCaption,
  }) {
    final normalized = moduleCaption.trim();
    for (final section in legacy_data.sectionList) {
      if (section.caption.trim() == normalized) {
        return section;
      }
      for (final organization in section.organizations) {
        if (organization.caption.trim() == normalized ||
            (organizationCaption != null &&
                organization.caption.trim() == organizationCaption.trim())) {
          return section;
        }
      }
    }
    return null;
  }

  String _resolveModuleTitle(
    String moduleCaption,
    SectionData? section,
  ) {
    if (section == null) {
      return moduleCaption;
    }
    return section.caption;
  }

  Widget _buildAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        height: 70.h,
        width: 70.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
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
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(120),
        image: const DecorationImage(
          image: AssetImage('assets/avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
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
  }
}
