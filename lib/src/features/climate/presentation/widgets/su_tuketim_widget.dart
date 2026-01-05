import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/data/historyModel.dart';

class SuTuketimWidget extends StatefulWidget {
  final List<HistoryData> historyDataList;
  final String period;
  final String unit;
  final String selectedPeriod;

  final Color grafikcolor;

  const SuTuketimWidget({
    super.key,
    required this.historyDataList,
    required this.period,
    required this.unit,
    required this.selectedPeriod,
    required this.grafikcolor,
  });

  @override
  State<SuTuketimWidget> createState() => _SuTuketimWidgetState();
}

class _SuTuketimWidgetState extends State<SuTuketimWidget> {
  late List<Color> gradientColors;

  @override
  void initState() {
    super.initState();
    gradientColors = [
      widget.grafikcolor,
      widget.grafikcolor.withOpacity(0.5),
    ];
  }

  double calculateTotalConsumption(List<HistoryData> historyDataList) {
    if (historyDataList.isEmpty) {
      return 0.0;
    }

    // İlk ve son değerleri al
    double firstValue = double.parse(historyDataList.first.avgValue);
    double lastValue = double.parse(historyDataList.last.avgValue);

    // Son değerden ilk değeri çıkar
    return lastValue - firstValue;
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    double totalConsumption = calculateTotalConsumption(widget.historyDataList);

    return widget.historyDataList.isEmpty
        ? _buildLoadingIndicator()
        : Padding(
            padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
            child: Column(
              children: <Widget>[
                Text(
                  "Bu ${widget.selectedPeriod} Toplam Tüketim",
                  style: TextStyle(
                    fontSize: 22.h,
                    fontWeight: FontWeight.bold,
                    color: widget.grafikcolor,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '${StringHelperiki.shortenValue('$totalConsumption')} ${widget.unit}',
                  style: TextStyle(
                    fontSize: 30.h,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),
                /* Lottie.asset('assets/lottie/water1.json',
                    width: 200.h, height: 150.h), */
              ],
            ),
          );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: widget.grafikcolor,
      ),
    );
  }
}
