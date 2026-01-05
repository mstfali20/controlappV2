import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/presentation/navigation/pages/navigation_page.dart';
import 'package:controlapp/src/features/presentation/navigation/view_model/app_navigator.dart';
import 'package:controlapp/src/features/presentation/under_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/auth/presentation/view/onboarding_view.dart';
import 'package:controlapp/src/features/auth/presentation/view/login_view.dart';
import 'package:controlapp/src/features/auth/presentation/view_model/splash_cubit.dart';
import 'package:controlapp/src/features/auth/presentation/view_model/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(
        getSessionUseCase: getIt(),
        loginUseCase: getIt(),
        saveSessionUseCase: getIt(),
        clearSessionUseCase: getIt(),
        logger: getIt(),
        remoteConfig: getIt(),
      )..initialize(deviceToken: fcmtokenstring),
      child: const _SplashViewContent(),
    );
  }
}

class _SplashViewContent extends StatelessWidget {
  const _SplashViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) => current.targetRoute != null,
      listener: (context, state) {
        final route = state.targetRoute;
        if (route == null) {
          return;
        }
        _handleNavigation(context, route, state.session);
        context.read<SplashCubit>().clearRoute();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.fromSize(
          size: MediaQuery.sizeOf(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/main.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                top: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.11,
                      child: Image.asset('assets/branding.png'),
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

  void _handleNavigation(
    BuildContext context,
    String route,
    dynamic session,
  ) {
    Widget target;
    switch (route) {
      case '/under':
        target = const Under();
        break;
      case '/onboarding':
        target = const OnboardingView();
        break;
      case '/login':
        target = const LoginView();
        break;
      case '/home':
      default:
        target = const NavigatiorPage();
        break;
    }

    AppNavigator.replaceWith(context, target);
  }
}
