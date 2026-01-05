import 'package:controlapp/const/Color.dart';
import 'package:controlapp/data/historyModel.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class GrafikWidget extends StatefulWidget {
  final List<HistoryData> historyDataList;
  final String period;
  final String unit;
  final Color grafikcolor;

  const GrafikWidget({
    super.key,
    required this.historyDataList,
    required this.period,
    required this.unit,
    required this.grafikcolor,
  });
  @override
  State<GrafikWidget> createState() => _GrafikWidgetState();
}

class _GrafikWidgetState extends State<GrafikWidget> {
  late List<Color> gradientColors; // Başlangıçta boş olarak tanımlıyoruz

  @override
  void initState() {
    super.initState();
    // Başlatıcı içinde atama yaparak widget özelliğine erişebiliriz
    gradientColors = [
      widget.grafikcolor,
      widget.grafikcolor.withOpacity(0.5),
    ];
  }

  List<FlSpot> _convertToFlSpots(List<HistoryData> historyDataList) {
    List<FlSpot> spots = [];
    for (int i = 0; i < historyDataList.length; i++) {
      double avgValue = double.parse(historyDataList[i].avgValue);
      spots.add(FlSpot(i.toDouble(), avgValue));
    }
    return spots;
  }

  double getMaxValue(List<HistoryData> historyDataList) {
    double max = double.negativeInfinity;
    for (final data in historyDataList) {
      final avgValue = double.parse(data.avgValue);
      if (avgValue > max) {
        max = avgValue;
      }
    }
    return max;
  }

  double getMinValue(List<HistoryData> historyDataList) {
    double min = double.infinity;
    for (final data in historyDataList) {
      final avgValue = double.parse(data.avgValue);
      if (avgValue < min) {
        min = avgValue;
      }
    }
    return min;
  }

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    final double maxValue = getMaxValue(widget.historyDataList);
    final double minValue = getMinValue(widget.historyDataList);
    double avrg = (maxValue + minValue) / 2;

    double maxAvrg = (avrg + maxValue) / 2;
    double minAvrg = (avrg + minValue) / 2;

    // Ortalama değere göre orta değerleri hesapla

    return widget.historyDataList.isEmpty
        ? _buildLoadingIndicator()
        : // Özelleştirilmiş bir yükleme göstergesi oluşturun

        // showAvg ? avgData() : mainData(),

        Padding(
            padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${maxValue.toStringAsFixed(2)} ${widget.unit}",
                        style: style),
                    Text("${maxAvrg.toStringAsFixed(2)} ${widget.unit}",
                        style: style),
                    Text("${avrg.toStringAsFixed(2)} ${widget.unit}",
                        style: style),
                    Text("${minAvrg.toStringAsFixed(2)} ${widget.unit}",
                        style: style),
                    Text("${minValue.toStringAsFixed(2)} ${widget.unit}",
                        style: style),
                  ],
                ),
                SizedBox(width: 20.h),
                Flexible(
                  child: LineChart(
                    // showAvg ? avgData() : mainData(),
                    mainData(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  void _showDate(String dateTime) {
    // Burada tarih göstermek için yapılacak işlemleri gerçekleştirin
    print('Tıklanan tarih: $dateTime');
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: widget.grafikcolor,
      ), // veya başka bir yükleme göstergesi widget'i
    );
  }

  // Widget leftTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     fontWeight: FontWeight.bold,
  //     fontSize: 15,
  //   );

  //   // Eğer veri kümesi boşsa veya geçerli bir değer yoksa hata mesajını döndür
  //   if (widget.historyDataList.isEmpty || !value.isFinite) {
  //     return Text('Hata: Veri yok', style: style, textAlign: TextAlign.left);
  //   }

  //   // Veri kümesinden farklı olan ve sıralı olarak eksen değerlerini oluşturun
  //   List<double> distinctValues = [];
  //   for (final data in widget.historyDataList) {
  //     final avgValue = double.parse(data.avgValue);
  //     if (!distinctValues.contains(avgValue)) {
  //       distinctValues.add(avgValue);
  //     }
  //   }
  //   distinctValues.sort();

  //   // Eğer eksen değerleri sıralı değilse sıralayın
  //   if (distinctValues.length > 1) {
  //     double diff = distinctValues[1] - distinctValues[0];
  //     if (diff == 0) {
  //       distinctValues.removeAt(0);
  //     }
  //   }

  //   // Eksenlerin sayısını belirlemek için bir değişken kullanın
  //   int numberOfAxisValues = 4; // Varsayılan olarak 4 ekseni kullanalım
  //   if (distinctValues.length < numberOfAxisValues) {
  //     numberOfAxisValues = distinctValues.length;
  //   }

  //   // Eksenler arasındaki farkları hesaplayın
  //   double minValue = distinctValues.first;
  //   double maxValue = distinctValues.last;
  //   double interval = (maxValue - minValue) / (numberOfAxisValues - 1);

  //   // Eksen değerlerini oluşturun
  //   List<double> axisValues = [];
  //   for (int i = 0; i < numberOfAxisValues; i++) {
  //     axisValues.add(minValue + i * interval);
  //   }
  //   log(axisValues.toString() + ' asd');

  //   // value değerine en yakın eksen değerini bulun
  //   double closestValue = axisValues
  //       .reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);

  //   // Belirli bir aralıkta bir metin oluştur
  //   String text = '${closestValue.toStringAsFixed(2)} ${widget.unit}';

  //   return Text(text, style: style, textAlign: TextAlign.left);
  // }

  LineChartData mainData() {
    // final double maxValue = getMaxValue(widget.historyDataList);
    // final double minValue = getMinValue(widget.historyDataList);

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final historyData = widget.historyDataList[flSpot.x.toInt()];
              final avgdata =
                  StringHelperiki.shortenValue(historyData.avgValue);
              return LineTooltipItem(
                '${historyData.dateTime}:00\n$avgdata ${widget.unit}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 1,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(),
/*         leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,

            interval: diff <= 1
                ? diff
                : diff / 2.5 <= 2
                    ? diff / 2
                    : diff / 2.5 <= 2
                        ? diff / 2.5
                        : diff,
            getTitlesWidget: leftTitleWidgets,
            // (value, meta) => Text(value.toString()),
            /* leftTitleWidgets */
            reservedSize: 80.h,
          ),
        ), */
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.historyDataList.length.toDouble() - 1,

      // maxY: maxValue <= 100 ? maxValue : 2000,

      lineBarsData: [
        LineChartBarData(
          preventCurveOverShooting: true,
          spots: _convertToFlSpots(widget.historyDataList),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
