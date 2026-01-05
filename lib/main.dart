import 'package:controlapp/const/Color.dart';
import 'package:controlapp/src/core/notifications/firebase_api.dart';
import 'package:controlapp/firebase_options.dart';
import 'package:controlapp/l10n/language_controller.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/auth/presentation/view/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:controlapp/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:controlapp/l10n/app_localizations.dart";
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await FirebaseApi().initNotifications();
  } catch (e) {
    print("Error initializing notifications: $e");
  }

  await configureDependencies();

  final prefs = await SharedPreferences.getInstance();
  // Telefonun varsayılan dilini al
  Locale deviceLocale = WidgetsBinding.instance.window.locale;
  // Daha önce kaydedilmiş bir dil varsa onu al, yoksa cihazın dilini kullan
  String savedLocale = prefs.getString('locale') ?? deviceLocale.languageCode;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(savedLocale: savedLocale),
        ),
        // Diğer provider'ları buraya ekleyebilirsiniz.
      ],
      child: const ControllerWidgat(),
    ),
  );
}

class ControllerWidgat extends StatefulWidget {
  const ControllerWidgat({super.key});

  @override
  State<ControllerWidgat> createState() => _ControllerWidgatState();
}

class _ControllerWidgatState extends State<ControllerWidgat> {
  @override
  void initState() {
    super.initState();
    _initializeFirebaseInBackground();
  }

  void _initializeFirebaseInBackground() async {
    FlutterNativeSplash
        .remove(); // Uygulama hazır olduğunda splash ekranını kaldır
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(languageProvider.locale),
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              theme: ThemeData(
                scaffoldBackgroundColor: bgColor,
                useMaterial3: true,
                fontFamily: GoogleFonts.nunito().fontFamily,
              ),
              home: SplashView(),
            );
          },
        );
      },
    );
  }
}
