import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/l10n/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class ProfileLanguageSelector extends StatelessWidget {
  const ProfileLanguageSelector({
    super.key,
    required this.languageProvider,
    this.delay = 1.0,
  });

  final LanguageProvider languageProvider;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            languageProvider.toggleLanguageOptionsVisibility();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.language),
                    SizedBox(width: 10.h),
                    Text(
                      AppLocalizations.of(context)!.dilAyar,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10.h),
                    Image.asset(
                      languageProvider.locale == 'tr'
                          ? 'assets/flags/turkish.png'
                          : 'assets/flags/english.png',
                      height: 30.h,
                    ),
                  ],
                ),
                SizedBox(width: 8.h),
                Visibility(
                  visible: languageProvider.isLanguageOptionsVisible,
                  child: Column(
                    children: [
                      _OptionItem(
                        flagPath: 'assets/flags/turkish.png',
                        label: AppLocalizations.of(context)!.turkce,
                        selected: languageProvider.locale == 'tr',
                        onTap: () async {
                          await languageProvider.setLanguage('tr');
                          languageProvider.toggleLanguageOptionsVisibility();
                        },
                      ),
                      _OptionItem(
                        flagPath: 'assets/flags/english.png',
                        label: AppLocalizations.of(context)!.ingilzice,
                        selected: languageProvider.locale == 'en',
                        onTap: () async {
                          await languageProvider.setLanguage('en');
                          languageProvider.toggleLanguageOptionsVisibility();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({
    required this.flagPath,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final String flagPath;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(flagPath, height: 32),
              SizedBox(width: 10.h),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20.h,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
