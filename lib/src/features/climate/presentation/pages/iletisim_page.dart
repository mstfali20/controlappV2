import 'dart:ui';

import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

// Diğer importlar buraya eklenebilir

class IletisimPage extends StatefulWidget {
  const IletisimPage({super.key});

  @override
  State<IletisimPage> createState() => _IletisimPageState();
}

class _IletisimPageState extends State<IletisimPage> {
  // Diğer değişkenler buraya eklenebilir
  // late FlutterGifController controllergif;
  // FlutterGifController controller = FlutterGifController(vsync: this);37.79387211742547, 29.09098266823148
  Future<void> _launchMapsUrl() async {
    const url = 'https://maps.app.goo.gl/U2ntnNDCbkSyZbte7';
    try {
      await launch(url);
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 30),
          FadeInAnimation(
            delay: 1,
            child: Row(
              children: [
                SizedBox(width: 30.h),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(25.h),
                    minimumSize: const Size(0, 0),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Iconsax.arrow_left),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FadeInAnimation(
                    delay: 1.2,
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('tel:02582681516'));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20.0.h, left: 20.0.h, top: 10.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                color: white.withOpacity(.9),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Container(
                                            // Siyah arkaplan, %30 opaklık
                                            decoration: BoxDecoration(
                                              color: lihtblue.withOpacity(
                                                  0.1), // Siyah arkaplan, %30 opaklık
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.h), // Kenar yuvarlama
                                            ),
                                            padding: EdgeInsets.all(8
                                                .h), // İçerik içindeki boşluklar
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    FontAwesomeIcons.headset,
                                                    color: black, // Icon rengi
                                                    size: 30.h, // Resmin boyutu
                                                  ),
                                                ), // Yıldız ikonu
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            FittedBox(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .cagriMerkezi,
                                                style: TextStyle(
                                                  fontSize: 30.h,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                " 0 (258) 268 15 16",
                                                style: TextStyle(
                                                  fontSize: 20.h,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeInAnimation(
                    delay: 1.5,
                    child: GestureDetector(
                      onTap: () {
                        _launchMapsUrl();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 20.0.h, left: 20.0.h, top: 10.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                color: white.withOpacity(.9),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Container(
                                            // Siyah arkaplan, %30 opaklık
                                            decoration: BoxDecoration(
                                              color: lihtblue.withOpacity(
                                                  0.1), // Siyah arkaplan, %30 opaklık
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.h), // Kenar yuvarlama
                                            ),
                                            padding: EdgeInsets.all(8
                                                .h), // İçerik içindeki boşluklar
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    FontAwesomeIcons.house,
                                                    color: black, // Icon rengi
                                                    size: 30.h, // Resmin boyutu
                                                  ),
                                                ), // Yıldız ikonu
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            FittedBox(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .adres,
                                                style: TextStyle(
                                                  fontSize: 30.h,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 230.h,
                                              child: Text(
                                                "Sümer Mahallesi 37. Sokak No:1 Merkezefendi/DENİZLİ",
                                                style: TextStyle(
                                                  fontSize: 20.h,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow
                                                    .clip, // Metnin taşması durumunda kısaltma işareti kullanın
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
