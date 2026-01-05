import 'dart:io';
import 'package:controlapp/const/Color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Under extends StatefulWidget {
  const Under({super.key});

  @override
  State<Under> createState() => _UnderState();
}

class _UnderState extends State<Under> with SingleTickerProviderStateMixin {
  bool sunucu = false;
  bool isLoading = true;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    checkVersionAndShowUpdate();
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Kapatılamasın
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.guncelememevcut,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.guncellemedevam,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: contolblue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  const googlePlayUrl =
                      'https://play.google.com/store/apps/details?id=com.yarbay.controlapp';
                  const appStoreUrl =
                      'https://apps.apple.com/tr/app/controlapp/id6511192984?l=tr';
                  if (Platform.isAndroid) {
                    await launchUrl(Uri.parse(googlePlayUrl),
                        mode: LaunchMode.externalApplication);
                  } else if (Platform.isIOS) {
                    await launchUrl(Uri.parse(appStoreUrl),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.guncelle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  // showUpdateBottomSheet fonksiyonunu kaldırıyoruz ve checkVersionAndShowUpdate içinde showUpdateDialog'u çağırıyoruz.
  Future<void> checkVersionAndShowUpdate() async {
    try {
      // Remote Config'den direkt versiyon al
      String remoteAppVersion = _remoteConfig.getString('app_version');
      // Mevcut uygulama versiyonunu al
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;
      setState(() {
        isLoading = false;
      });
      print('Remote App Version: $remoteAppVersion');
      print('Current App Version: $currentAppVersion');
      // Version kontrolü yap ve zorunlu güncelleme popup'ı göster
      showUpdateDialog(context);
    } catch (e) {
      print("Hata: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> lancurl(String gelurl) async {
  //   // ignore: deprecated_member_use

  //   try {
  //     final Uri uri = Uri(scheme: 'https', host: gelurl);
  //     if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
  //       print("URL successfully launched");
  //     } else {
  //       throw "Failed to launch URL";
  //     }
  //   } catch (e) {
  //     print("Error launching URL: $e");
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.fromSize(
        size: MediaQuery.sizeOf(context),
        child: Stack(
          children: [
            // Arka plan görseli
            Positioned.fill(
              child: Image.asset(
                'assets/main.jpg',
                fit: BoxFit.cover, // Görseli ekranın tamamına yay
              ),
            ),
            // Üstteki kararmayı sağlayan katman

            // Logo kısmı
            Visibility(
              visible: _remoteConfig.getBool('under_maintenance'),
              child: Positioned(
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                top: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    Text(
                      'Uygulamamız, geçici bir süreliğine bakım çalışmaları nedeniyle hizmet verememektedir. En kısa sürede tekrar erişime açılacaktır. Anlayışınız için teşekkür ederiz. Herhangi bir sorun yaşamanız durumunda lütfen yetkililere bildiriniz.',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 14.h,
                      ),
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            // Branding logosu
            Positioned(
              left: MediaQuery.of(context).size.width *
                  0.15, // Ekran genişliğinin %15'i kadar sola kaydır
              right: MediaQuery.of(context).size.width *
                  0.15, // Ekran genişliğinin %15'i kadar sağa kaydır
              top: MediaQuery.of(context).size.height *
                  0.85, // Ekran yüksekliğinin %85'i kadar yukarı kaydır
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
    );
  }
}
