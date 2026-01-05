import 'dart:ui';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/presentation/notifications/domain/entities/alarm_notification.dart';
import 'package:controlapp/src/features/presentation/notifications/presentation/view_model/notification_cubit.dart';
import 'package:controlapp/src/features/presentation/notifications/presentation/view_model/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(
        fetchNotificationsUseCase: getIt(),
        getSessionUseCase: getIt(),
      )..load(),
      child: const _NotificationView(),
    );
  }
}

enum AlarmFilter { active, closed, all }

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  AlarmFilter _selectedFilter = AlarmFilter.active;

  void _onFilterChanged(AlarmFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
  }

  List<AlarmNotification> _applyFilter(List<AlarmNotification> alarms) {
    final sorted = [...alarms]..sort(
        (a, b) => b.creationDate.compareTo(a.creationDate),
      );

    switch (_selectedFilter) {
      case AlarmFilter.active:
        return sorted.where((alarm) => alarm.isActive).toList();
      case AlarmFilter.closed:
        return sorted.where((alarm) => alarm.isClosed).toList();
      case AlarmFilter.all:
        return sorted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final filteredAlarms = _applyFilter(state.alarms);
            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _Header(
                      isLoading: state.isLoading,
                      alarmCount: state.alarms.length,
                    ),
                    SizedBox(height: 14.h),
                    _OverviewRow(alarms: state.alarms),
                    SizedBox(height: 12.h),
                    _StatusFilterBar(
                      selectedFilter: _selectedFilter,
                      onChanged: _onFilterChanged,
                      alarms: state.alarms,
                    ),
                    SizedBox(height: 12.h),
                    FadeInAnimation(
                      delay: 1.5,
                      child: _Content(
                        state: state,
                        filteredAlarms: filteredAlarms,
                        selectedFilter: _selectedFilter,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isLoading, required this.alarmCount});

  final bool isLoading;
  final int alarmCount;

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: 1,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.bildirimler,
                  style: TextStyle(
                    fontSize: 30.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(18),
              minimumSize: const Size(0, 0),
              foregroundColor: darkColor,
            ),
            onPressed: () => context.read<NotificationCubit>().refresh(),
            child: isLoading
                ? SizedBox(
                    width: 18.h,
                    height: 18.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.refresh),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.alarms});

  final List<AlarmNotification> alarms;

  @override
  Widget build(BuildContext context) {
    final activeCount = alarms.where((alarm) => alarm.isActive).length;
    final closedCount = alarms.where((alarm) => alarm.isClosed).length;
    final totalCount = alarms.length;

    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: AppLocalizations.of(context)!.toplam,
            count: totalCount,
            icon: Iconsax.chart,
            accentColor: contolblue,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _OverviewCard(
            title: AppLocalizations.of(context)!.acik,
            count: activeCount,
            icon: Iconsax.activity,
            accentColor: Colors.redAccent,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _OverviewCard(
            title: AppLocalizations.of(context)!.kapali,
            count: closedCount,
            icon: Iconsax.archive,
            accentColor: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white : darkColor;
    final labelColor = isDark ? Colors.white70 : Colors.grey.shade800;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.95),
        border: Border.all(color: accentColor.withOpacity(0.18)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 16.h),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.h,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20.h,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selectedFilter,
    required this.onChanged,
    required this.alarms,
  });

  final AlarmFilter selectedFilter;
  final ValueChanged<AlarmFilter> onChanged;
  final List<AlarmNotification> alarms;

  int _countForFilter(AlarmFilter filter) {
    switch (filter) {
      case AlarmFilter.active:
        return alarms.where((alarm) => alarm.isActive).length;
      case AlarmFilter.closed:
        return alarms.where((alarm) => alarm.isClosed).length;
      case AlarmFilter.all:
        return alarms.length;
    }
  }

  String _labelForFilter(AppLocalizations l10n, AlarmFilter filter) {
    switch (filter) {
      case AlarmFilter.active:
        return l10n.acik;
      case AlarmFilter.closed:
        return l10n.kapali;
      case AlarmFilter.all:
        return l10n.tumu;
    }
  }

  IconData _iconForFilter(AlarmFilter filter) {
    switch (filter) {
      case AlarmFilter.active:
        return Iconsax.notification;
      case AlarmFilter.closed:
        return Iconsax.archive;
      case AlarmFilter.all:
        return Iconsax.menu_1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const filters = [
      AlarmFilter.active,
      AlarmFilter.closed,
      AlarmFilter.all,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBackground =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                showCheckmark: false,
                selected: selectedFilter == filter,
                onSelected: (_) => onChanged(filter),
                side: BorderSide(
                  color: selectedFilter == filter
                      ? contolblue
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                backgroundColor: chipBackground,
                selectedColor: contolblue.withOpacity(isDark ? 0.25 : 0.15),
                label: Text(
                  '${_labelForFilter(l10n, filter)} (${_countForFilter(filter)})',
                ),
                avatar: Icon(
                  _iconForFilter(filter),
                  size: 14,
                  color: selectedFilter == filter
                      ? contolblue
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
                labelStyle: TextStyle(
                  fontSize: 12.h,
                  fontWeight: FontWeight.w600,
                  color: selectedFilter == filter
                      ? contolblue
                      : (isDark ? Colors.white70 : Colors.grey.shade700),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.filteredAlarms,
    required this.selectedFilter,
  });

  final NotificationState state;
  final List<AlarmNotification> filteredAlarms;
  final AlarmFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.alarms.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isFailure && state.alarms.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Column(
          children: [
            Text(
              state.errorMessage ??
                  'Veriler alınırken bir sorun oluştu. Lütfen tekrar deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.h,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.read<NotificationCubit>().refresh(),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    if (state.alarms.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.henuzBildirimYok),
      );
    }

    if (filteredAlarms.isEmpty) {
      return _EmptyFilterState(filter: selectedFilter);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: ListView.separated(
        key: ValueKey('${selectedFilter.name}-${filteredAlarms.length}'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredAlarms.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, index) => _AlarmCard(alarm: filteredAlarms[index]),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.filter});

  final AlarmFilter filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 48.h),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.12),
              ),
              child: Icon(_icon, color: _accentColor, size: 28.h),
            ),
            SizedBox(height: 16.h),
            Text(
              _title,
              style: TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.w600,
                color: darkColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Farklı bir filtre seçerek diğer alarmları görüntüleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.h,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    switch (filter) {
      case AlarmFilter.active:
        return 'Aktif alarm yok';
      case AlarmFilter.closed:
        return 'Kapalı alarm yok';
      case AlarmFilter.all:
        return 'Alarm bulunamadı';
    }
  }

  IconData get _icon {
    switch (filter) {
      case AlarmFilter.active:
        return Iconsax.notification;
      case AlarmFilter.closed:
        return Iconsax.archive;
      case AlarmFilter.all:
        return Iconsax.filter;
    }
  }

  Color get _accentColor {
    switch (filter) {
      case AlarmFilter.active:
        return Colors.redAccent;
      case AlarmFilter.closed:
        return Colors.green;
      case AlarmFilter.all:
        return contolblue;
    }
  }
}

class _AlarmCard extends StatelessWidget {
  const _AlarmCard({required this.alarm});

  final AlarmNotification alarm;

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(alarm.confidenceLevel);
    final statusColor = _statusColor(alarm.status);
    final metaItems = <Widget>[];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? Colors.white.withOpacity(0.08) : white.withOpacity(.92);

    if (alarm.labelCode.isNotEmpty) {
      metaItems.add(_buildInfoPill(Iconsax.tag, alarm.labelCode));
    }
    if (alarm.creationDateText.isNotEmpty) {
      metaItems.add(_buildInfoPill(Iconsax.clock, alarm.creationDateText));
    }
    if (alarm.alarmDuration.isNotEmpty) {
      metaItems.add(_buildInfoPill(Iconsax.timer, alarm.alarmDuration));
    }
    if (alarm.operator.isNotEmpty) {
      metaItems.add(_buildInfoPill(Iconsax.user, alarm.operator));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withOpacity(isDark ? 0.7 : 0.85),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: severityColor.withOpacity(0.8),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: lihtblue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(10.h),
                    child: Icon(
                      FontAwesomeIcons.bell,
                      color: contolblue,
                      size: 18.h,
                    ),
                  ),
                  SizedBox(width: 12.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alarm.deviceDescription,
                          style: TextStyle(
                            fontSize: 16.h,
                            fontWeight: FontWeight.w700,
                            color: darkColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          alarm.deviceOrganization,
                          style: TextStyle(
                            fontSize: 12.h,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildChip(alarm.confidenceLabel, severityColor),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                alarm.description,
                style: TextStyle(
                  fontSize: 14.h,
                  fontWeight: FontWeight.w600,
                  color: darkColor,
                ),
              ),
              if (alarm.alarmValue.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'Değer: ${alarm.alarmValue}',
                  style: TextStyle(
                    fontSize: 12.h,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              if (metaItems.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: metaItems,
                ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChip(
                    alarm.statusLabel,
                    statusColor,
                    icon: _statusIcon(alarm.status),
                  ),
                  Text(
                    alarm.endDateText,
                    style: TextStyle(
                      fontSize: 11.h,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildChip(String label, Color color, {IconData? icon}) {
  if (label.isEmpty) return const SizedBox.shrink();

  return Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(50),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 12.h,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoPill(IconData icon, String label) {
  if (label.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: grey.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: contolblue),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.h,
            color: darkColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Color _severityColor(int level) {
  switch (level) {
    case 1:
      return Colors.orange;
    case 2:
      return Colors.red;
    case 3:
      return Colors.deepPurple;
    default:
      return contolblue;
  }
}

Color _statusColor(int status) {
  switch (status) {
    case 0:
      return Colors.redAccent;
    case 1:
      return Colors.blueGrey;
    case 2:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

IconData _statusIcon(int status) {
  switch (status) {
    case 0:
      return Iconsax.warning_2;
    case 1:
      return Iconsax.tick_square;
    case 2:
      return Iconsax.tick_circle;
    default:
      return Iconsax.information;
  }
}
