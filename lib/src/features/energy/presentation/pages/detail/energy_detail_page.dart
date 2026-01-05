import 'package:controlapp/src/features/energy/presentation/widgets/veri_card_enerjy.dart';
import 'package:controlapp/l10n/app_localizations.dart';

import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/scale_button.dart';
import 'package:controlapp/src/features/energy/domain/utils/device_type_helper.dart';
import 'package:controlapp/data/xmlModel.dart';
import 'energy_former_widget.dart';
import 'energy_momentary_widget.dart';
import 'energy_period_widget.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnerjiDetail extends StatefulWidget {
  const EnerjiDetail({
    super.key,
    required this.data,
    required this.title,
  });

  final XmlModel data;
  final String title;

  @override
  State<EnerjiDetail> createState() => _EnerjiDetailState();
}

class _EnerjiDetailState extends State<EnerjiDetail> {
  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  String getDevicetypeUnit(int deviceType) {
    // Elektrik ölçüm cihazları
    if ([1, 2, 3, 11, 41].contains(deviceType)) {
      return AppLocalizations.of(context)!.guc;
    }
    // Doğalgaz/Buhar ölçüm cihazları
    else if ([12, 22, 42].contains(deviceType)) {
      return "";
    }
    // Su ölçüm cihazları/Basınçlı hava debimetresi
    else if ([13, 21, 43].contains(deviceType)) {
      return AppLocalizations.of(context)!.endeks;
    }
    // Bilinmeyen cihaz tipi
    else {
      return "Unknown";
    }
  }

  late String? username;
  late String? password;
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      password = prefs.getString('password');
    });
  }

  Widget _buildSelectedWidget(String deviceId, String kw, String akim,
      String deviceType, String subuhar) {
    switch (selectedCategoryIndex) {
      case 0:
        return EnerjiFormeriWidget(
          deviceId: deviceId, // Dışarıdan alınan deviceId
        );
      case 1:
        return EnerjiPeriodWidget(
          deviceId: deviceId,
        );
      case 2:
        return EnerjiMomentaryWidget(
          deviceId: deviceId,
          kw: kw,
          akim: akim,
          deviceType: deviceType,
          subuhar: subuhar,
        ); // Category 2'ye özel widget

      default:
        return const Text('Kategori Seçimi Yapılmadı');
    }
  }

  int selectedCategoryIndex = 0; // Başlangıçta seçili kategori 0. indexte

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      AppLocalizations.of(context)!.oncekiPeriyot,
      AppLocalizations.of(context)!.donemIci,
      AppLocalizations.of(context)!.anlik,
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 1.h),
          child: Column(
            children: [
              // SizedBox(height: MediaQuery.paddingOf(context).top + 30),
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
                        // log(widget.data.deviceType.toString());
                        // log(widget.title.toString());
                      },
                      child: const Icon(Iconsax.arrow_left),
                    ),
                    SizedBox(width: 30.h),
                    Expanded(
                      // Bu satır, Text widget'ına genişleyebileceği bir alan sağlar.
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap:
                            true, // Metnin alt satıra inmesine izin verir.
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: FadeInAnimation(
                  delay: 1.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Önce category == '0' olan öğeleri filtreleyip liste oluşturuyoruz
                      if (widget.data.children.length > 1)
                        ...widget.data.children
                            .where((dataItem) => dataItem.category == '0')
                            .map((dataItem) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            dataItem.caption,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: ListView.separated(
                                      itemCount: categories.length,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, index) {
                                        bool isSelected =
                                            selectedCategoryIndex == index;
                                        return ScaleButton(
                                          onTap: () {
                                            setState(() {
                                              selectedCategoryIndex =
                                                  index; // Seçilen kategoriyi güncelle
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? contolblue
                                                  : Colors.white,
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: DefaultTextStyle(
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : darkColor,
                                                  fontSize: 18,
                                                ),
                                                child: Text(
                                                  categories[index],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0.h),
                                    child: FadeInAnimation(
                                      delay: 1.6,
                                      child: _buildSelectedWidget(
                                          dataItem.id,
                                          dataItem.kwa,
                                          dataItem.akim,
                                          dataItem.deviceType,
                                          dataItem.subuhar),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      // Eğer sadece 1 öğe varsa, tüm öğeleri listeletiyoruz
                      else
                        ...widget.data.children.map((dataItem) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            dataItem.caption,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: ListView.separated(
                                      itemCount: categories.length,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, index) {
                                        bool isSelected =
                                            selectedCategoryIndex == index;
                                        return ScaleButton(
                                          onTap: () {
                                            setState(() {
                                              selectedCategoryIndex =
                                                  index; // Seçilen kategoriyi güncelle
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? contolblue
                                                  : Colors.white,
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: DefaultTextStyle(
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : darkColor,
                                                  fontSize: 18,
                                                ),
                                                child: Text(
                                                  categories[index],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0.h),
                                    child: FadeInAnimation(
                                      delay: 1.6,
                                      child: _buildSelectedWidget(
                                          dataItem.id,
                                          dataItem.kwa,
                                          dataItem.akim,
                                          dataItem.deviceType,
                                          dataItem.subuhar),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      if (widget.data.children.length > 1)
                        ...widget.data.children
                            .where((dataItem) => dataItem.category != '0')
                            .map((dataItem) {
                          return InkWell(
                            onTap: () {
                              // Burada mevcut XmlModel verisini üst bir organizasyon düğümüne yerleştiriyoruz
                              XmlModel organization = XmlModel(
                                id: widget.title, // Organizasyonun ID'si
                                caption:
                                    dataItem.caption, // Organizasyon başlığı
                                title: '', // Organizasyon için başlık
                                deviceType:
                                    dataItem.deviceType, // Organizasyon türü
                                category: '', // Kategori
                                kwa: '', // Diğer bilgileri boş bırakabilirsiniz
                                akim: '',
                                classType:
                                    'obm_organization', // Organizasyon tipi
                                subuhar: '',
                                children: [
                                  dataItem
                                ], // Cihazı (dataItem) organizasyonun çocukları olarak ekliyoruz
                              );

                              // Organizasyon verisini EnerjiDetail sayfasına taşıyoruz
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnerjiDetail(
                                    data: organization, // Organizasyon verisi
                                    title: organization
                                        .caption, // Organizasyonun başlığı
                                  ),
                                ),
                              );
                            },
                            child: VeriCardEnerjyList(
                              showIconButton: true,
                              title: dataItem.caption.toString(),
                              veriCardDataList: [
                                VeriCardEnerjy(
                                  iconPath: Stringdeger.getDeviceImageUnit(
                                    int.tryParse(dataItem.deviceType) ??
                                        1, // String'i int'e dönüştür, başarısız olursa 0 kullan
                                  ),

                                  header: getDevicetypeUnit(
                                    int.tryParse(dataItem.deviceType) ??
                                        1, // String'i int'e dönüştür, başarısız olursa 0 kullan
                                  ),
                                  percentage: "  12.0%  ",
                                  color: Colors.indigo,
                                  value: dataItem.kwa.isNotEmpty
                                      ? StringHelper.shortenValue(dataItem.kwa)
                                      : StringHelper.shortenValue(
                                          dataItem.subuhar),
                                  // unit: DeviceTypeWidget(deviceType: dataItem.deviceType.toString()).toString(),  // "kw" gösterir (Elektrik ölçüm cihazı)
                                  unit: Stringdeger.getDeviceTypeUnit(
                                    int.tryParse(dataItem.deviceType) ??
                                        0, // String'i int'e dönüştür, başarısız olursa 0 kullan
                                  ),
                                  title: AppLocalizations.of(context)!.guc,
                                  // Başlık eklendi
                                ),
                                if (dataItem.akim.isNotEmpty)
                                  VeriCardEnerjy(
                                    iconPath: "assets/icons/Akım.png",
                                    header: AppLocalizations.of(context)!.akim,
                                    percentage: "  9.2%  ",
                                    color: Colors.red,
                                    value: StringHelper.shortenValue(
                                        dataItem.akim),
                                    unit: " A",
                                    title: AppLocalizations.of(context)!.akim,
                                  ),
                              ],
                            ),
                          );
                        }),

                      // Eğer liste boş değilse alt kısma boşluk ekleyelim
                      if (widget.data.children.length > 1)
                        SizedBox(
                            height: MediaQuery.paddingOf(context).bottom + 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
