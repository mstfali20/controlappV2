import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/scale_button.dart';
import 'package:controlapp/src/features/climate/presentation/pages/damper_detail_page.dart';
import 'package:controlapp/src/features/climate/presentation/pages/fanlar_details_page.dart';
import 'package:controlapp/src/features/climate/presentation/pages/filtre_details_page.dart';
import 'package:controlapp/src/features/climate/presentation/pages/havuz_detail_page.dart';
import 'package:controlapp/src/features/climate/presentation/pages/salon_detail_page.dart';
import 'package:controlapp/src/features/climate/presentation/pages/tuketim_detail_page.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/custom_tile.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/bottom_card.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';

class IklimWidget extends StatefulWidget {
  const IklimWidget({
    super.key,
  });

  @override
  State<IklimWidget> createState() => _IklimWidgetState();
}

class _IklimWidgetState extends State<IklimWidget> {
  List<Widget> pages = [
    const SalonDetail(),
    const HavuzDetail(),
    const DamperDetail(),
    const TuketimDetail(),
    const FiltreDetail(),
    const FanlarDetail(),
  ];
  String selectedCategory = 'All';
  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;
    final deviceTitle =
        homeState.selectedDeviceTitle ?? homeState.plcTitle ?? plcTitle;
    List<String> categories = [
      AppLocalizations.of(context)!.salon,
      AppLocalizations.of(context)!.havuz,
      AppLocalizations.of(context)!.damper,
      AppLocalizations.of(context)!.tuketim,
      AppLocalizations.of(context)!.filtreKirliligi,
      AppLocalizations.of(context)!.fan
    ];
    return Column(
      children: [
        FadeInAnimation(
          delay: 1.5,
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: ListView.separated(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return ScaleButton(
                  onTap: () {
                    // Burada belirli bir kategoriye tıklandığında ilgili sayfayı açabilirsiniz
                    // Örneğin Navigator ile ilgili sayfayı açabilirsiniz
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            pages[index], // Kategoriye göre ilgili sayfayı açın
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: isSelected ? darkColor : Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkColor,
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
        ),
        SizedBox(height: 15.h),
        FadeInAnimation(
          delay: 2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              deviceTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        FadeInAnimation(
          delay: 2,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.salonVerileri,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.h),
                  decoration: BoxDecoration(
                    color: creamColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.icOrtam,
                                style: TextStyle(
                                  fontSize: 25.h,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            CustomTile(
                              iconPath: "assets/icons/Sıcaklık-Yedek.png",
                              dotColor: Colors.red,
                              title: StringHelper.shortenValue(
                                  '${anaAnlikVeriMap['IOSalonSicaklikGosterge']}'),
                              subtitle: AppLocalizations.of(context)!.sicaklik,
                              unit: "°C",
                            ),
                            SizedBox(height: 20.h),
                            CustomTile(
                              iconPath: "assets/icons/Nem-Yedek.png",
                              dotColor: Colors.blueAccent,
                              title: StringHelper.shortenValue(
                                  '${anaAnlikVeriMap['IOSalonNemGosterge']}'),
                              subtitle: AppLocalizations.of(context)!.nem,
                              unit: "%",
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppLocalizations.of(context)!.disOrtam,
                                style: TextStyle(
                                  fontSize: 25.h,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            CustomTile(
                              iconPath: "assets/icons/Sıcaklık-Yedek.png",
                              dotColor: Colors.red,
                              title: StringHelper.shortenValue(
                                  '${anaAnlikVeriMap['IODisSicaklikGosterge']}'),
                              subtitle: AppLocalizations.of(context)!.sicaklik,
                              unit: "°C",
                            ),
                            SizedBox(height: 20.h),
                            CustomTile(
                              iconPath: "assets/icons/Nem-Yedek.png",
                              dotColor: Colors.blueAccent,
                              title: StringHelper.shortenValue(
                                  '${anaAnlikVeriMap['IODisHavaNemGosterge']}'),
                              subtitle: AppLocalizations.of(context)!.nem,
                              unit: "%",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        FadeInAnimation(
          delay: 2.5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.h),
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.tuketimVerileri,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    BottomCard(
                      iconPath: "assets/icons/kW-3.png",
                      header: AppLocalizations.of(context)!.guc,
                      percentage: "  12.0%  ",
                      value: StringHelper.shortenValue(
                          '${anaAnlikVeriMap['IOkW']}'),
                      unit: "kW",
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    BottomCard(
                      iconPath: "assets/icons/Akım.png",
                      header: AppLocalizations.of(context)!.akim,
                      percentage: "  9.2%  ",
                      value: StringHelper.shortenValue(
                          '${anaAnlikVeriMap['IOAkim']}'),
                      unit: "A",
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }
}
