import 'package:controlapp/const/fade_zoom.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWebLinks extends StatelessWidget {
  const ProfileWebLinks({
    super.key,
    required this.onTap,
    this.delay = 1.0,
  });

  final void Function(String url) onTap;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeInAnimation(
        delay: delay,
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
                  const Icon(Icons.web),
                  SizedBox(width: 10.h),
                  Text(
                    AppLocalizations.of(context)!.webSayfalari,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _WebLinkTile(
                text: 'Controlapp',
                url: 'www.controlapp.com.tr',
                onTap: onTap,
              ),
              _WebLinkTile(
                text: 'Yarbay Otomasyon',
                url: 'www.yarbayotomasyon.com.tr',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebLinkTile extends StatelessWidget {
  const _WebLinkTile({
    required this.text,
    required this.url,
    required this.onTap,
  });

  final String text;
  final String url;
  final void Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(url),
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
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
