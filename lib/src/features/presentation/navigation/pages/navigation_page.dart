import 'package:controlapp/const/Color.dart';
import 'package:controlapp/src/features/presentation/home/pages/home_page.dart';
import 'package:controlapp/src/features/presentation/notifications/presentation/pages/notification_page.dart';
import 'package:controlapp/src/features/presentation/profile/pages/profile_page.dart';
import 'package:controlapp/src/features/presentation/profile/view_model/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:controlapp/src/features/climate/domain/usecases/fetch_climate_snapshot_usecase.dart';
import 'package:controlapp/src/features/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:controlapp/src/features/auth/domain/usecases/update_session_selection_usecase.dart';

class NavigatiorPage extends StatefulWidget {
  const NavigatiorPage({super.key});

  @override
  State<NavigatiorPage> createState() => _NavigatiorPageState();
}

class _NavigatiorPageState extends State<NavigatiorPage> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  late final List<Widget> pages;
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit(
      fetchClimateSnapshotUseCase: getIt<FetchClimateSnapshotUseCase>(),
      fetchEnergySnapshotUseCase: getIt<FetchEnergySnapshotUseCase>(),
      getSessionUseCase: getIt<GetSessionUseCase>(),
      updateSessionSelectionUseCase: getIt<UpdateSessionSelectionUseCase>(),
    )..initialize();

    pages = [
      BlocProvider.value(
        value: _homeCubit,
        child: HomePage(),
      ),
      const NotificationPage(),
      BlocProvider.value(
        value: _homeCubit,
        child: BlocProvider(
          create: (_) => ProfileCubit(homeCubit: _homeCubit),
          child: const ProfilPage(),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[_page],
          Align(
            alignment: Alignment.bottomCenter,
            child: CurvedNavigationBar(
              buttonBackgroundColor: lithtgrey, // Seçilen ikonun çember rengi

              animationCurve: Curves.easeInOut, // Daha yumuşak geçişler
              backgroundColor: Colors.transparent, // Arka planı şeffaf yap
              key: _bottomNavigationKey,
              items: <Widget>[
                Icon(Icons.home, size: 25.h, color: Colors.black),
                // Icon(FontAwesomeIcons.filter, size: 25.h, color: Colors.black),
                Icon(Icons.notification_important,
                    size: 30.h, color: Colors.black),
                Icon(Icons.person_2, size: 30.h, color: Colors.black),
              ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
