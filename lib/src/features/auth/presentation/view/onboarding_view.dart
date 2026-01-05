import 'package:controlapp/const/Color.dart';
import 'package:controlapp/widget/carousel_page.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Positioned.fill(
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 600.h,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        CarouselPage(
                          imageUrl: "assets/ControlAppSiyah.png",
                          sliderTitle: "ControlApp",
                          sliderText1: AppLocalizations.of(context)!.onboard1,
                        ),
                        CarouselPage(
                          imageUrl: "assets/ControlAppSiyah.png",
                          sliderTitle: "ControlApp",
                          sliderText1: AppLocalizations.of(context)!.onboard2,
                        ),
                        CarouselPage(
                          imageUrl: "assets/ControlAppSiyah.png",
                          sliderTitle: "ControlApp",
                          sliderText1: AppLocalizations.of(context)!.onboard3,
                        ),
                        CarouselPage(
                          imageUrl: "assets/ControlAppSiyah.png",
                          sliderTitle: "ControlApp",
                          sliderText1: AppLocalizations.of(context)!.onboard4,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 1.h),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 4,
                        effect: ExpandingDotsEffect(
                          activeDotColor: blue,
                          dotColor: blue,
                          dotHeight: 15.h,
                          dotWidth: 15.h,
                          spacing: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () => _onNextPressed(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentPage == 3 ? black : blue,
                            borderRadius: BorderRadius.circular(100.h),
                          ),
                          height: 55.h,
                          width: 55.h,
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                            size: 46.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 1.h),
                    ],
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNextPressed(BuildContext context) {
    if (_currentPage == 3) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
      return;
    }

    _pageController.animateToPage(
      (_currentPage + 1).clamp(0, 3),
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }
}
