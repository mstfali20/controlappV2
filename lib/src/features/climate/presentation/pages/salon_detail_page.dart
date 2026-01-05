import 'dart:developer';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/climate/data/services/data_post.dart';
import 'package:controlapp/src/features/climate/data/services/history_post.dart';
import 'package:controlapp/data/historyModel.dart';

import 'package:controlapp/src/features/climate/presentation/widgets/grafik_widget.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/veri_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalonDetail extends StatefulWidget {
  const SalonDetail({super.key});

  @override
  State<SalonDetail> createState() => _SalonDetailState();
}

class _SalonDetailState extends State<SalonDetail> {
  late String? username;
  late String? password;
  late String? seriall;
  String? serialTitlee;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  // Future<void> _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      password = prefs.getString('password');
      seriall = prefs.getString('serial');
      serialTitlee = prefs.getString('serialTitle');
    });
  }

  void guncelleFunc(
      BuildContext context, String username, String password, seriall) async {
    final DataPost serviceData = DataPost();
    serialTitlee ??= serialTitle;
    seriall ??= serial;
    try {
      List<dynamic>? result =
          await serviceData.fetchDataApi(username, password, seriall);
      int errorCode = result![0];
      String errorDescription = result[1];

      if (errorCode == 0) {
        setState(() {});

        // Başarılı giriş
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: grey,
            content: Center(
                child: Text(
              AppLocalizations.of(context)!.guncellemeBasarili,
              style: const TextStyle(color: white),
            )),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Hatalı giriş
        print('Hata kodu: $errorDescription');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: grey,
            content: Text(
              'Güncelleme başarısız. Hata kodu: $errorDescription',
              style: const TextStyle(color: white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Hata oluştu
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: grey,
          content: Text(
            AppLocalizations.of(context)!.guncellemeBasarisiz,
            style: const TextStyle(color: white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List day = ['Gun', 'Hafta', 'Ay', 'Yil'];
  int index_color = 0;
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
                SizedBox(width: 30.h),
                Text(
                  AppLocalizations.of(context)!.salonVerileri,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: creamColor,
              backgroundColor: grey,
              onRefresh: () async {
                if (username != null && password != null) {
                  guncelleFunc(context, username!, password!, seriall);
                } else {
                  if (userDataConst["username"] != null &&
                      userDataConst["password"] != null) {
                    // userDataConst'tan kullanıcı adı ve şifre alındı
                    String? savedUsername = userDataConst["username"];
                    String? savedPassword = userDataConst["password"];
                    String? seriall = userDataConst["serial"];

                    guncelleFunc(
                        context, savedUsername!, savedPassword!, seriall);

                    // İşlem yapılabilir, örneğin:
                    print(
                        "Kullanıcı adı: $savedUsername, Şifre: $savedPassword");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: grey,
                        content: Text(
                          'Kullanıcı adı ve şifre yükleniyor, lütfen bekleyin.',
                          style: TextStyle(
                            color: creamColor,
                          ),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  // Kullanıcı adı ve şifre henüz yüklenmedi
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    SingleChildScrollView(
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.all(1.0.h),
                          child: FadeInAnimation(
                            delay: 2.5,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 20.h),
                              decoration: BoxDecoration(
                                color: creamColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      VeriCardList(
                                        showIconButton: true,
                                        title: AppLocalizations.of(context)!
                                            .salonVerileri,
                                        veriCardDataList: [
                                          VeriCardData(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .sicaklik,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOSalonSicaklikGosterge']}'),
                                            unit: "°C",
                                            title: AppLocalizations.of(context)!
                                                .sicaklik,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .sicaklik,
                                                  'IOSalonSicaklikGosterge',
                                                  "°C",
                                                  grafiksicaklikColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                            iconPath:
                                                "assets/icons/Sıcaklık.png",
                                          ),
                                          VeriCardData(
                                            iconPath: "assets/icons/Nem.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .nem,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOSalonNemGosterge']}'),
                                            unit: " %",
                                            title: AppLocalizations.of(context)!
                                                .nem,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .nem,
                                                  'IOSalonNemGosterge',
                                                  " %",
                                                  grafiknemColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),

                                          VeriCardData(
                                            iconPath: "assets/icons/Devir.png",

                                            header:
                                                AppLocalizations.of(context)!
                                                    .basincFarki,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOSalonBasincSensoru']}'),
                                            unit: "Pa",
                                            title: AppLocalizations.of(context)!
                                                .basincFarki,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  "Basınç",
                                                  'IOSalonBasincSensoru',
                                                  "Pa",
                                                  grafikbasicColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          // Diğer VeriCardData öğeleri buraya eklenebilir
                                        ],
                                      ),
                                      VeriCardList(
                                        title: AppLocalizations.of(context)!
                                            .disHavaVerileri,
                                        showIconButton: true,
                                        veriCardDataList: [
                                          VeriCardData(
                                            iconPath:
                                                "assets/icons/Sıcaklık.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .sicaklik,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IODisSicaklikGosterge']}'),
                                            unit: "°C",
                                            title: AppLocalizations.of(context)!
                                                .sicaklik,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .sicaklik,
                                                  'IODisSicaklikGosterge',
                                                  "°C",
                                                  grafiksicaklikColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath: "assets/icons/Nem.png",

                                            header:
                                                AppLocalizations.of(context)!
                                                    .nem,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IODisHavaNemGosterge']}'),
                                            unit: " %",
                                            title: AppLocalizations.of(context)!
                                                .nem,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .nem,
                                                  'IODisHavaNemGosterge',
                                                  "%",
                                                  grafiknemColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),

                                          // Diğer VeriCardData öğeleri buraya eklenebilir
                                        ],
                                      ),
                                      VeriCardList(
                                        title: AppLocalizations.of(context)!
                                            .havaKanali,
                                        veriCardDataList: [
                                          VeriCardData(
                                            iconPath:
                                                "assets/icons/HavaHızı-1.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .havaHizi,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOHavaHiziOlcumSensoru']}'),
                                            unit: "m/s",
                                            title: AppLocalizations.of(context)!
                                                .havaHizi,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .havaHizi,
                                                  'IOHavaHiziOlcumSensoru',
                                                  "m/s",
                                                  grafiknemColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath:
                                                "assets/icons/Sıcaklık.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .sicaklik,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOKanalSicaklikSensoru']}'),
                                            unit: "°C",
                                            title: AppLocalizations.of(context)!
                                                .kanalSicakligi,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .kanalSicakligi,
                                                  'IOKanalSicaklikSensoru',
                                                  "°C",
                                                  grafiksicaklikColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath: "assets/icons/Nem.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .nem,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOKanalNemSensoru']}'),
                                            unit: "%",
                                            title: AppLocalizations.of(context)!
                                                .nem,
                                            onPressed: () {
                                              grafikdenemeFunction(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .nem,
                                                  'IOKanalNemSensoru',
                                                  "%",
                                                  grafiknemColor); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          // Diğer VeriCardData öğeleri buraya eklenebilir
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.paddingOf(context).bottom + 100.h),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  grafikFunction(BuildContext context, String title, String labelcode,
      String unit, Color grafikcolor) async {
    final HistoryPost historyPost = HistoryPost();
    try {
      String selectedPeriod = "Gün";
      String period = '24';
      index_color = 0;
      List<HistoryData> historyDataList = []; // Boş bir listeye başlayalım

      showModalBottomSheet(
        backgroundColor: transparent,
        context: context,
        builder: (builder) {
          int state = 0;
          log("------------");
          log(serial.toString());
          log(seriall.toString());
          log("------------");
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              if (state == 0) {
                state++;
                historyPost
                    .fetchHistoryApi(
                  userDataConst["username"],
                  userDataConst["password"],
                  seriall != null ? seriall! : serial,
                  labelcode,
                  period,
                )
                    .then((dataList) {
                  setState(() {
                    historyDataList = dataList;
                  });
                });
              }

              return Container(
                padding: EdgeInsets.only(
                  left: 25.h,
                  right: 25.h,
                  top: 20.h,
                  bottom: 40.h,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.2,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.h),
                    topRight: Radius.circular(40.h),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 22.h,
                                      fontWeight: FontWeight.w900,
                                      color: black.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 30.h,
                            color: black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ...List.generate(
                                4,
                                (index) {
                                  String option;
                                  switch (index) {
                                    case 0:
                                      option = 'Gün';
                                      break;
                                    case 1:
                                      option = 'Hafta';
                                      break;
                                    case 2:
                                      option = 'Ay';
                                      break;
                                    case 3:
                                      option = 'Yıl';
                                      break;
                                    default:
                                      option = 'Gün';
                                      break;
                                  }
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        index_color = index;
                                        selectedPeriod = option;
                                      });
                                      // Yeni periyoda göre verileri yeniden al
                                      switch (selectedPeriod) {
                                        case 'Gün':
                                          period = '24';
                                          break;
                                        case 'Hafta':
                                          period = '168';
                                          break;
                                        case 'Ay':
                                          period = '720';
                                          break;
                                        case 'Yıl':
                                          period = '8760';
                                          break;
                                        default:
                                          period = '24';
                                      }
                                      historyPost
                                          .fetchHistoryApi(
                                        userDataConst["username"],
                                        userDataConst["password"],
                                        seriall != null ? seriall! : serial,
                                        labelcode,
                                        period,
                                      )
                                          .then((dataList) {
                                        setState(() {
                                          historyDataList = dataList;
                                        });
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: index_color == index
                                            ? lihtblue
                                            : Colors.white,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: index_color == index
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: GrafikWidget(
                        historyDataList: historyDataList,
                        period: period,
                        unit: unit,
                        grafikcolor: grafikcolor,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  grafikdenemeFunction(BuildContext context, String title, String labelcode,
      String unit, Color grafikcolor) async {
    final HistoryPost historyPost = HistoryPost();
    try {
      String selectedPeriod = "Gün";
      String period = '24';
      int indexColor = 0;
      List<HistoryData> historyDataList = [];

      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          int state = 0;
          log("------------");
          log(serial.toString());
          log(seriall.toString());
          log("------------");
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              if (state == 0) {
                state++;
                historyPost
                    .fetchHistoryApi(
                  userDataConst["username"],
                  userDataConst["password"],
                  seriall != null ? seriall! : serial,
                  labelcode,
                  period,
                )
                    .then((dataList) {
                  setState(() {
                    historyDataList = dataList;
                  });
                });
              }

              return Container(
                padding: EdgeInsets.only(
                  left: 25.h,
                  right: 25.h,
                  top: 20.h,
                  bottom: 40.h,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.2,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.h),
                    topRight: Radius.circular(40.h),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 22.h,
                                  fontWeight: FontWeight.w900,
                                  color: black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 30.h,
                            color: black,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          String option;
                          switch (index) {
                            case 0:
                              option = 'Gün';
                              break;
                            case 1:
                              option = 'Hafta';
                              break;
                            case 2:
                              option = 'Ay';
                              break;
                            case 3:
                              option = 'Yıl';
                              break;
                            default:
                              option = 'Gün';
                              break;
                          }
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                indexColor = index;
                                selectedPeriod = option;
                              });
                              switch (selectedPeriod) {
                                case 'Gün':
                                  period = '24';
                                  break;
                                case 'Hafta':
                                  period = '168';
                                  break;
                                case 'Ay':
                                  period = '720';
                                  break;
                                case 'Yıl':
                                  period = '8760';
                                  break;
                                default:
                                  period = '24';
                              }
                              historyPost
                                  .fetchHistoryApi(
                                userDataConst["username"],
                                userDataConst["password"],
                                seriall != null ? seriall! : serial,
                                labelcode,
                                period,
                              )
                                  .then((dataList) {
                                setState(() {
                                  historyDataList = dataList;
                                });
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: indexColor == index
                                    ? contolblue
                                    : Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: indexColor == index
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: GrafikWidget(
                        historyDataList: historyDataList,
                        period: period,
                        unit: unit,
                        grafikcolor: grafikcolor,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      log('Error: $e');
    }
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget({
    super.key,
    required this.value,
    required this.steps,
    this.isPrimary = false,
  });

  final double value;
  final String steps;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      height: value * 400,
      // width: 80,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryColor : AppColors.darkGreyColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            steps,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
