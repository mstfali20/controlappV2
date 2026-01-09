import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KazanPage extends StatelessWidget {
  const KazanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      _KazanMetric(
        icon: Icons.speed_rounded,
        label: 'Basinc',
        value: '4.2',
        unit: 'bar',
      ),
      _KazanMetric(
        icon: Icons.whatshot,
        label: 'Sicaklik',
        value: '92',
        unit: 'C',
      ),
      _KazanMetric(
        icon: Icons.bolt,
        label: 'Anlik Guc',
        value: '128',
        unit: 'kW',
      ),
      _KazanMetric(
        icon: Icons.water_drop_outlined,
        label: 'Su Seviyesi',
        value: '68',
        unit: '%',
      ),
    ];

    final summary = const [
      _KazanMetric(
        icon: Icons.local_fire_department_outlined,
        label: 'Yakıt',
        value: '1.2',
        unit: 'm3/h',
      ),
      _KazanMetric(
        icon: Icons.thermostat_outlined,
        label: 'Bacagaz',
        value: '184',
        unit: 'C',
      ),
      _KazanMetric(
        icon: Icons.bubble_chart_outlined,
        label: 'Buhar Debi',
        value: '2.8',
        unit: 't/h',
      ),
      _KazanMetric(
        icon: Icons.air_outlined,
        label: 'O2',
        value: '3.1',
        unit: '%',
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KazanHeaderCard(
                title: 'Kazan Izleme',
                subtitle: 'Anlik Durum',
                value: '88%',
                valueLabel: 'Verim',
              ),
              SizedBox(height: 18.h),
              _SectionHeader(
                title: 'Anlik Veriler',
                action: 'Bugun',
              ),
              SizedBox(height: 12.h),
              _MetricGrid(metrics: metrics),
              SizedBox(height: 18.h),
              _SectionHeader(
                title: 'Proses Ozeti',
                action: 'Son 24s',
              ),
              SizedBox(height: 12.h),
              _MetricGrid(metrics: summary),
              SizedBox(height: 18.h),
              _KazanStatusCard(
                title: 'Alarm Durumu',
                message: 'Aktif alarm yok',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KazanHeaderCard extends StatelessWidget {
  const _KazanHeaderCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueLabel,
  });

  final String title;
  final String subtitle;
  final String value;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF7A23A),
            Color(0xFFF06D2B),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 54.h,
            width: 54.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.h,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.h,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.h,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 12.h,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
  });

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.h,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            action,
            style: TextStyle(
              fontSize: 11.h,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_KazanMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 110.h,
        crossAxisSpacing: 12.h,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _MetricCard(metric: metric);
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _KazanMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.h,
            width: 32.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, size: 18.h, color: Colors.grey.shade800),
          ),
          SizedBox(height: 10.h),
          Text(
            metric.label,
            style: TextStyle(
              fontSize: 12.h,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                metric.value,
                style: TextStyle(
                  fontSize: 18.h,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              SizedBox(width: 4.h),
              Text(
                metric.unit,
                style: TextStyle(
                  fontSize: 12.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KazanStatusCard extends StatelessWidget {
  const _KazanStatusCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 36.h,
            width: 36.h,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade600,
            ),
          ),
          SizedBox(width: 12.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.h,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.h,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KazanMetric {
  const _KazanMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
}
