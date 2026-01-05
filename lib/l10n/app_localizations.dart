import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @dil.
  ///
  /// In en, this message translates to:
  /// **'en_US'**
  String get dil;

  /// No description provided for @giris.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get giris;

  /// No description provided for @hosgeldiniz.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Please enter your information.'**
  String get hosgeldiniz;

  /// No description provided for @kullaniciAdi.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get kullaniciAdi;

  /// No description provided for @sifre.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sifre;

  /// No description provided for @bilgileriKaydet.
  ///
  /// In en, this message translates to:
  /// **'Save Information'**
  String get bilgileriKaydet;

  /// No description provided for @sosyalMedya.
  ///
  /// In en, this message translates to:
  /// **'Our Social Media and Sales Accounts'**
  String get sosyalMedya;

  /// No description provided for @demoIste.
  ///
  /// In en, this message translates to:
  /// **'Request Demo'**
  String get demoIste;

  /// No description provided for @modulSec.
  ///
  /// In en, this message translates to:
  /// **'Select Module'**
  String get modulSec;

  /// No description provided for @girisBasarisiz.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Error Message'**
  String get girisBasarisiz;

  /// No description provided for @girisHata.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get girisHata;

  /// No description provided for @sunucuHata.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get sunucuHata;

  /// No description provided for @tekrarDene.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tekrarDene;

  /// No description provided for @veriHata.
  ///
  /// In en, this message translates to:
  /// **'Error while retrieving real-time data:'**
  String get veriHata;

  /// No description provided for @altVeriBulunamadi.
  ///
  /// In en, this message translates to:
  /// **'Subdata not found'**
  String get altVeriBulunamadi;

  /// No description provided for @enerjiIzlemeBulunamadi.
  ///
  /// In en, this message translates to:
  /// **'Energy Monitoring System not found'**
  String get enerjiIzlemeBulunamadi;

  /// No description provided for @beklenmedikHata.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get beklenmedikHata;

  /// No description provided for @guncellemeBasarili.
  ///
  /// In en, this message translates to:
  /// **'Update Successful.'**
  String get guncellemeBasarili;

  /// No description provided for @guncellemeBasarisiz.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Error code'**
  String get guncellemeBasarisiz;

  /// No description provided for @enerjiIzlemeSistemi.
  ///
  /// In en, this message translates to:
  /// **'Energy Monitoring System'**
  String get enerjiIzlemeSistemi;

  /// No description provided for @dugumBulunamadi.
  ///
  /// In en, this message translates to:
  /// **'Nodes under the \'Energy Monitoring System\' could not be found.'**
  String get dugumBulunamadi;

  /// No description provided for @modulYok.
  ///
  /// In en, this message translates to:
  /// **'No Module to Select'**
  String get modulYok;

  /// No description provided for @tamam.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get tamam;

  /// No description provided for @bekleyin.
  ///
  /// In en, this message translates to:
  /// **'Username and password are loading, please wait.'**
  String get bekleyin;

  /// No description provided for @veriAlmaHata.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while retrieving data.'**
  String get veriAlmaHata;

  /// No description provided for @bildirimler.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get bildirimler;

  /// No description provided for @henuzBildirimYok.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get henuzBildirimYok;

  /// No description provided for @salon.
  ///
  /// In en, this message translates to:
  /// **'Hall'**
  String get salon;

  /// No description provided for @havuz.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get havuz;

  /// No description provided for @damper.
  ///
  /// In en, this message translates to:
  /// **'Damper'**
  String get damper;

  /// No description provided for @tuketim.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get tuketim;

  /// No description provided for @filtreFarkBasinc.
  ///
  /// In en, this message translates to:
  /// **'Filter Differential Pressure'**
  String get filtreFarkBasinc;

  /// No description provided for @webSayfalari.
  ///
  /// In en, this message translates to:
  /// **'Web Pages'**
  String get webSayfalari;

  /// No description provided for @dilAyar.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get dilAyar;

  /// No description provided for @profilBilgisi.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profilBilgisi;

  /// No description provided for @iletisimBilgisi.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get iletisimBilgisi;

  /// No description provided for @sunucuHatasiBekleyin.
  ///
  /// In en, this message translates to:
  /// **'Server error, please wait'**
  String get sunucuHatasiBekleyin;

  /// No description provided for @icOrtam.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get icOrtam;

  /// No description provided for @nem.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get nem;

  /// No description provided for @disOrtam.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get disOrtam;

  /// No description provided for @sicaklik.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get sicaklik;

  /// No description provided for @tuketimVerileri.
  ///
  /// In en, this message translates to:
  /// **'Consumption Data'**
  String get tuketimVerileri;

  /// No description provided for @guc.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get guc;

  /// No description provided for @akim.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get akim;

  /// No description provided for @salonVerileri.
  ///
  /// In en, this message translates to:
  /// **'Hall Data'**
  String get salonVerileri;

  /// No description provided for @kategori.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get kategori;

  /// No description provided for @oncekiPeriyot.
  ///
  /// In en, this message translates to:
  /// **'Previous Period'**
  String get oncekiPeriyot;

  /// No description provided for @donemIci.
  ///
  /// In en, this message translates to:
  /// **'In Period'**
  String get donemIci;

  /// No description provided for @anlik.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get anlik;

  /// No description provided for @gesUretim.
  ///
  /// In en, this message translates to:
  /// **'Solar Power Generation'**
  String get gesUretim;

  /// No description provided for @uretim.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get uretim;

  /// No description provided for @dun.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dun;

  /// No description provided for @gecenHafta.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get gecenHafta;

  /// No description provided for @gecenAy.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get gecenAy;

  /// No description provided for @gecenYil.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get gecenYil;

  /// No description provided for @elektrikTuketim.
  ///
  /// In en, this message translates to:
  /// **'Electricity Consumption'**
  String get elektrikTuketim;

  /// No description provided for @su.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get su;

  /// No description provided for @dogalGaz.
  ///
  /// In en, this message translates to:
  /// **'Natural Gas'**
  String get dogalGaz;

  /// No description provided for @buhar.
  ///
  /// In en, this message translates to:
  /// **'Steam'**
  String get buhar;

  /// No description provided for @bugun.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get bugun;

  /// No description provided for @buHafta.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get buHafta;

  /// No description provided for @buAy.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get buAy;

  /// No description provided for @buYil.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get buYil;

  /// No description provided for @fark.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get fark;

  /// No description provided for @endeks.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get endeks;

  /// No description provided for @isletmeSecildi.
  ///
  /// In en, this message translates to:
  /// **'Business Selected.'**
  String get isletmeSecildi;

  /// No description provided for @isletmeSecimiBasarisiz.
  ///
  /// In en, this message translates to:
  /// **'Business selection failed. Error code:'**
  String get isletmeSecimiBasarisiz;

  /// No description provided for @isletmeSecimiHatasi.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during business selection.'**
  String get isletmeSecimiHatasi;

  /// No description provided for @cikisOnayi.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get cikisOnayi;

  /// No description provided for @cikis.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get cikis;

  /// No description provided for @iptal.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get iptal;

  /// No description provided for @girisIsmi.
  ///
  /// In en, this message translates to:
  /// **'Login Name'**
  String get girisIsmi;

  /// No description provided for @ePosta.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get ePosta;

  /// No description provided for @firmaAdi.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get firmaAdi;

  /// No description provided for @tumAlanlariDoldurun.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get tumAlanlariDoldurun;

  /// No description provided for @ornek.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get ornek;

  /// No description provided for @adSoyad.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get adSoyad;

  /// No description provided for @rol.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get rol;

  /// No description provided for @firmaCalismaAlani.
  ///
  /// In en, this message translates to:
  /// **'Company Field'**
  String get firmaCalismaAlani;

  /// No description provided for @telefon.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get telefon;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @kayitAlindi.
  ///
  /// In en, this message translates to:
  /// **'Your registration has been received.'**
  String get kayitAlindi;

  /// No description provided for @kayitIletildi.
  ///
  /// In en, this message translates to:
  /// **'Your registration has been submitted.'**
  String get kayitIletildi;

  /// No description provided for @hataTekrarDeneyin.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get hataTekrarDeneyin;

  /// No description provided for @gun.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get gun;

  /// No description provided for @hafta.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get hafta;

  /// No description provided for @ay.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get ay;

  /// No description provided for @yil.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yil;

  /// No description provided for @gerilim.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get gerilim;

  /// No description provided for @basincFarki.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get basincFarki;

  /// No description provided for @suTuketimi.
  ///
  /// In en, this message translates to:
  /// **'Water Consumption'**
  String get suTuketimi;

  /// No description provided for @filtreKirliligi.
  ///
  /// In en, this message translates to:
  /// **'Filter Status'**
  String get filtreKirliligi;

  /// No description provided for @filtreBakimZamani.
  ///
  /// In en, this message translates to:
  /// **'Filter Maintenance Time'**
  String get filtreBakimZamani;

  /// No description provided for @damperVerileri.
  ///
  /// In en, this message translates to:
  /// **'Damper Data'**
  String get damperVerileri;

  /// No description provided for @tazeHava.
  ///
  /// In en, this message translates to:
  /// **'Fresh Air'**
  String get tazeHava;

  /// No description provided for @egzoz.
  ///
  /// In en, this message translates to:
  /// **'Exhaust'**
  String get egzoz;

  /// No description provided for @devir.
  ///
  /// In en, this message translates to:
  /// **'Revolutions'**
  String get devir;

  /// No description provided for @pompaVerileri.
  ///
  /// In en, this message translates to:
  /// **'Pump Data'**
  String get pompaVerileri;

  /// No description provided for @seperator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get seperator;

  /// No description provided for @doluluk.
  ///
  /// In en, this message translates to:
  /// **'Fill Level'**
  String get doluluk;

  /// No description provided for @suSicakligi.
  ///
  /// In en, this message translates to:
  /// **'Water Temp'**
  String get suSicakligi;

  /// No description provided for @havuzVerileri.
  ///
  /// In en, this message translates to:
  /// **'Pool Data'**
  String get havuzVerileri;

  /// No description provided for @cagriMerkezi.
  ///
  /// In en, this message translates to:
  /// **'Call Center'**
  String get cagriMerkezi;

  /// No description provided for @adres.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adres;

  /// No description provided for @disHavaVerileri.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Air Data'**
  String get disHavaVerileri;

  /// No description provided for @havaKanali.
  ///
  /// In en, this message translates to:
  /// **'Air Duct'**
  String get havaKanali;

  /// No description provided for @havaHizi.
  ///
  /// In en, this message translates to:
  /// **'Air Speed'**
  String get havaHizi;

  /// No description provided for @kanalSicakligi.
  ///
  /// In en, this message translates to:
  /// **'Duct Temperature'**
  String get kanalSicakligi;

  /// No description provided for @kanalNemi.
  ///
  /// In en, this message translates to:
  /// **'Duct Humidity'**
  String get kanalNemi;

  /// No description provided for @fan.
  ///
  /// In en, this message translates to:
  /// **'Fans'**
  String get fan;

  /// No description provided for @basinc.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get basinc;

  /// No description provided for @asprator.
  ///
  /// In en, this message translates to:
  /// **'Aspirators'**
  String get asprator;

  /// No description provided for @turkce.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkce;

  /// No description provided for @ingilzice.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get ingilzice;

  /// No description provided for @onboard1.
  ///
  /// In en, this message translates to:
  /// **'Monitor your machines from anywhere in the factory with our app and reduce costs.'**
  String get onboard1;

  /// No description provided for @onboard2.
  ///
  /// In en, this message translates to:
  /// **'Track energy usage, optimize efficiency, and gain a competitive edge with our mobile app.'**
  String get onboard2;

  /// No description provided for @onboard3.
  ///
  /// In en, this message translates to:
  /// **'Gain mobile control of your factory; manage your production processes more efficiently with our app.'**
  String get onboard3;

  /// No description provided for @onboard4.
  ///
  /// In en, this message translates to:
  /// **'Quickly address industrial malfunctions with instant notifications to boost performance and cut costs.'**
  String get onboard4;

  /// No description provided for @guncelememevcut.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get guncelememevcut;

  /// No description provided for @guncelle.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get guncelle;

  /// No description provided for @guncellemedevam.
  ///
  /// In en, this message translates to:
  /// **'We have released an update to ensure you are using the latest version of our app. For better service and an improved experience, please update your application.'**
  String get guncellemedevam;

  /// No description provided for @kategorigrafigi.
  ///
  /// In en, this message translates to:
  /// **'Category Chart Could Not Be Generated.'**
  String get kategorigrafigi;

  /// No description provided for @ocak.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get ocak;

  /// No description provided for @subat.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get subat;

  /// No description provided for @mart.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get mart;

  /// No description provided for @nisan.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get nisan;

  /// No description provided for @mayis.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayis;

  /// No description provided for @haziran.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get haziran;

  /// No description provided for @temmuz.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get temmuz;

  /// No description provided for @agustos.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get agustos;

  /// No description provided for @eylul.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get eylul;

  /// No description provided for @ekim.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get ekim;

  /// No description provided for @kasim.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get kasim;

  /// No description provided for @aralik.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get aralik;

  /// No description provided for @gunluk.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get gunluk;

  /// No description provided for @aylik.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get aylik;

  /// No description provided for @yillik.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yillik;

  /// No description provided for @gesUretimFarki.
  ///
  /// In en, this message translates to:
  /// **'Solar Production Difference'**
  String get gesUretimFarki;

  /// No description provided for @fabrikatoplamtuketim.
  ///
  /// In en, this message translates to:
  /// **'Factory Total Consumption'**
  String get fabrikatoplamtuketim;

  /// No description provided for @filitreindex.
  ///
  /// In en, this message translates to:
  /// **'İndex Filtering'**
  String get filitreindex;

  /// No description provided for @ozet.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get ozet;

  /// No description provided for @elektrik.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get elektrik;

  /// No description provided for @ges.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get ges;

  /// No description provided for @karbon.
  ///
  /// In en, this message translates to:
  /// **'Carbon'**
  String get karbon;

  /// No description provided for @karbonEmisyonu.
  ///
  /// In en, this message translates to:
  /// **'Carbon Emissions'**
  String get karbonEmisyonu;

  /// No description provided for @karbonEmisyonFarki.
  ///
  /// In en, this message translates to:
  /// **'Carbon Emissions Difference'**
  String get karbonEmisyonFarki;

  /// No description provided for @karbonAzaltimi.
  ///
  /// In en, this message translates to:
  /// **'Carbon Reduction'**
  String get karbonAzaltimi;

  /// No description provided for @agacSayisi.
  ///
  /// In en, this message translates to:
  /// **'Number of Trees:'**
  String get agacSayisi;

  /// No description provided for @acik.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get acik;

  /// No description provided for @kapali.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get kapali;

  /// No description provided for @toplam.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get toplam;

  /// No description provided for @tumu.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tumu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
