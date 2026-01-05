// ignore_for_file: use_build_context_synchronously

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/src/features/climate/data/services/data_post.dart';
import 'package:controlapp/src/features/climate/data/services/history_post.dart';
import 'package:controlapp/data/historyModel.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/grafik_widget.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/su_tuketim_widget.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/veri_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TuketimDetail extends StatefulWidget {
  const TuketimDetail({super.key});

  @override
  State<TuketimDetail> createState() => _TuketimDetailState();
}

class _TuketimDetailState extends State<TuketimDetail> {
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
  // ignore: non_constant_identifier_names
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
                  AppLocalizations.of(context)!.tuketimVerileri,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.h,
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
                                            .tuketimVerileri,
                                        veriCardDataList: [
                                          VeriCardData(
                                            iconPath: "assets/icons/kW-3.png",

                                            header:
                                                AppLocalizations.of(context)!
                                                    .guc,
                                            percentage: "  12.0%  ",
                                            color: Colors.indigo,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOkW']}'),
                                            unit: "kW",
                                            title: AppLocalizations.of(context)!
                                                .guc,
                                            onPressed: () {
                                              grafikFunction(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .tuketim,
                                                'IOkW',
                                                "kW",
                                                grafiksicaklikColor,
                                              ); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath: "assets/icons/Akım.png",

                                            header:
                                                AppLocalizations.of(context)!
                                                    .akim,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOAkim']}'),
                                            unit: " A",
                                            title: AppLocalizations.of(context)!
                                                .akim,
                                            onPressed: () {
                                              grafikFunction(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .akim,
                                                'IOAkim',
                                                "A",
                                                grafiksicaklikColor,
                                              ); // Örnek bir işlev
                                            },

                                            // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath:
                                                "assets/icons/Gerilim.png",

                                            header:
                                                AppLocalizations.of(context)!
                                                    .gerilim,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelper.shortenValue(
                                                '${anaAnlikVeriMap['IOGerilim']}'),
                                            unit: "V",
                                            title: AppLocalizations.of(context)!
                                                .gerilim,
                                            onPressed: () {
                                              grafikFunction(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .gerilim,
                                                'IOGerilim',
                                                "V",
                                                grafiksicaklikColor,
                                              ); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          VeriCardData(
                                            iconPath: "assets/icons/pF.png",
                                            header: "pf",
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelperiki.shortenValue(
                                                '${anaAnlikVeriMap['IOpF']}'),
                                            unit: "",
                                            title: AppLocalizations.of(context)!
                                                .basincFarki,
                                            onPressed: () {
                                              grafikFunction(
                                                context,
                                                "pf",
                                                'IOpF',
                                                "",
                                                grafikbasicColor,
                                              ); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          // Diğer VeriCardData öğeleri buraya eklenebilir
                                        ],
                                      ),
                                      VeriCardList(
                                        showIconButton: true,
                                        title: AppLocalizations.of(context)!
                                            .suTuketimi,
                                        veriCardDataList: [
                                          VeriCardData(
                                            iconPath:
                                                "assets/icons/SuSayac.png",
                                            header:
                                                AppLocalizations.of(context)!
                                                    .tuketim,
                                            percentage: "  9.2%  ",
                                            color: Colors.red,
                                            value: StringHelperiki.shortenValue(
                                                '${anaAnlikVeriMap['IOHavuzSuSayac']}'),
                                            unit: "m3",
                                            title: AppLocalizations.of(context)!
                                                .suTuketimi,
                                            onPressed: () {
                                              tuketim(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .suTuketimi,
                                                'IOHavuzSuSayac',
                                                "m3",
                                                grafiknemColor,
                                              ); // Örnek bir işlev
                                            }, // Başlık eklendi
                                          ),
                                          // Diğer VeriCardData öğeleri buraya eklenebilir
                                        ],
                                      ),
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
      String unit, Color color) async {
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
                height: MediaQuery.of(context).size.height / 1.5,
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
                        grafikcolor: color,
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

  tuketim(BuildContext context, String title, String labelcode, String unit,
      Color color) async {
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
                height: MediaQuery.of(context).size.height / 1.5,
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
                      child: SuTuketimWidget(
                        historyDataList: historyDataList,
                        period: period,
                        selectedPeriod: selectedPeriod,
                        unit: unit,
                        grafikcolor: color,
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
