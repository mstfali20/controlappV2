import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/iklim_menu_widget.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/energy_menu_widget.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_state.dart';
import 'package:controlapp/src/features/presentation/role/pages/climate_role_page.dart';
import 'package:controlapp/src/features/presentation/role/pages/energy_role_page.dart';
import 'package:controlapp/src/features/presentation/role/pages/webdeneme.dart';
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
        final moduleTitle =
            state.selectedModule ?? HomeCubit.energyModuleCaption;
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
                  _buildHeader(context, state, module, imageUrl, name),
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
                                Visibility(
                                  visible:
                                      module == HomeCubit.climateModuleCaption,
                                  child: const IklimWidget(),
                                  // child: const KazanWidget(),
                                  // child: const WebKazanWidget(),
                                ),
                                Visibility(
                                  visible:
                                      module == HomeCubit.energyModuleCaption,
                                  child: const EnerjiWidget(),
                                ),
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
  ) {
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
                    visible: module == HomeCubit.energyModuleCaption,
                    child: EnerjiMenuWidget(
                      organisation: module,
                      loadAndParseTree: context.read<HomeCubit>().loadTreeNodes,
                    ),
                  ),
                  Visibility(
                    visible: module == HomeCubit.climateModuleCaption,
                    child: IklimMenuWidget(
                      organisation: module,
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
