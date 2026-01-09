// import 'dart:math' as math;

// import 'package:controlapp/const/Color.dart';
// import 'package:controlapp/const/data.dart' as legacy_data;
// import 'package:controlapp/const/scale_button.dart';
// import 'package:controlapp/data/tree_node.dart';
// import 'package:controlapp/l10n/app_localizations.dart';
// import 'package:controlapp/src/core/di/injector.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/domain/entities/energy_consumption_record.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/domain/utils/energy_value_parser.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_consumption_cubit.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_consumption_state.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_cubit.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_history_cubit.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_history_state.dart';
// import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_state.dart';
// import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
// import 'package:controlapp/src/features/presentation/home/view_model/home_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// enum RenewablePeriod { today, daily, monthly, yearly }

// class RenewableEnergyWidget extends StatefulWidget {
//   const RenewableEnergyWidget({
//     super.key,
//     required this.moduleCaption,
//   });

//   final String moduleCaption;

//   @override
//   State<RenewableEnergyWidget> createState() => _RenewableEnergyWidgetState();
// }

// class _RenewableEnergyWidgetState extends State<RenewableEnergyWidget> {
//   bool _isLoading = true;
//   String? _errorMessage;
//   List<TreeNode> _devices = const [];
//   List<String> _locations = const [];
//   String? _selectedLocation;

//   @override
//   void initState() {
//     super.initState();
//     _loadDevices();
//   }

//   @override
//   void didUpdateWidget(covariant RenewableEnergyWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.moduleCaption != widget.moduleCaption) {
//       _loadDevices();
//     }
//   }

//   Future<void> _loadDevices() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final homeState = context.read<HomeCubit>().state;
//     final source = homeState.treeJson ?? legacy_data.treeJson;
//     if (source.trim().isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'tree_missing';
//       });
//       return;
//     }

//     final root = TreeNode.parseTree(source);
//     if (root == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'tree_parse_error';
//       });
//       return;
//     }

//     final organization = _resolveOrganization(root, homeState);
//     if (organization == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'organization_missing';
//       });
//       return;
//     }

//     final devices = organization
//         .walk()
//         .where((node) => node.classType.trim() == 'obm_device')
//         .toList()
//       ..sort((a, b) => a.caption.compareTo(b.caption));

//     if (devices.isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'device_missing';
//       });
//       return;
//     }

//     final locations = _buildLocations(devices);
//     setState(() {
//       _devices = List<TreeNode>.unmodifiable(devices);
//       _locations = List<String>.unmodifiable(locations);
//       _selectedLocation = locations.length > 1 ? locations.first : null;
//       _isLoading = false;
//       _errorMessage = null;
//     });
//   }

//   TreeNode? _resolveOrganization(TreeNode root, HomeState homeState) {
//     final organizationId =
//         homeState.session?.selectedOrganizationId ?? legacy_data.organizationid;
//     if (organizationId != null && organizationId.isNotEmpty) {
//       final byId = root.findById(organizationId);
//       if (byId != null && byId.id.isNotEmpty) {
//         return byId;
//       }
//     }

//     final normalizedModule = widget.moduleCaption.trim();
//     if (normalizedModule.isEmpty) {
//       return null;
//     }

//     final byCaption = root.walk().firstWhere(
//           (node) =>
//               node.classType.trim() == 'obm_organization' &&
//               node.caption.trim() == normalizedModule,
//           orElse: () => TreeNode.empty(),
//         );
//     return byCaption.id.isNotEmpty ? byCaption : null;
//   }

//   List<String> _buildLocations(List<TreeNode> devices) {
//     final seen = <String>{};
//     final locations = <String>[];
//     for (final device in devices) {
//       final location = _locationLabel(device.caption);
//       if (location.isEmpty) {
//         continue;
//       }
//       if (seen.add(location)) {
//         locations.add(location);
//       }
//     }
//     return locations;
//   }

//   String _locationLabel(String caption) {
//     var label = caption.trim();
//     if (label.isEmpty) {
//       return '';
//     }
//     label = label.replaceAll(RegExp(r'\bges\b', caseSensitive: false), '').trim();
//     label = label.replaceAll(RegExp(r'\btoplam\b', caseSensitive: false), '').trim();
//     return label.isNotEmpty ? label : caption.trim();
//   }

//   List<TreeNode> get _filteredDevices {
//     final selected = _selectedLocation;
//     if (selected == null || selected.isEmpty) {
//       return _devices;
//     }
//     return _devices
//         .where(
//           (device) => _locationLabel(device.caption) == selected,
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);
//     final homeState = context.watch<HomeCubit>().state;
//     final firmName = homeState.userSummary.firmName;
//     final username = homeState.username ??
//         (legacy_data.users.isNotEmpty
//             ? legacy_data.users
//             : legacy_data.userDataConst['username']?.toString() ?? '');
//     final password = homeState.password ??
//         (legacy_data.pass.isNotEmpty
//             ? legacy_data.pass
//             : legacy_data.userDataConst['password']?.toString() ?? '');

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator(color: contolblue));
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           l10n?.altVeriBulunamadi ?? 'Veri bulunamadi',
//           style: TextStyle(fontSize: 14.sp, color: Colors.black54),
//         ),
//       );
//     }

//     final devices = _filteredDevices;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (firmName.isNotEmpty)
//           Padding(
//             padding: EdgeInsets.only(bottom: 12.h),
//             child: Text(
//               firmName,
//               style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         if (_locations.length > 1)
//           SizedBox(
//             height: 42.h,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: _locations.length,
//               separatorBuilder: (_, __) => SizedBox(width: 10.w),
//               itemBuilder: (context, index) {
//                 final location = _locations[index];
//                 final isSelected = location == _selectedLocation;
//                 return ScaleButton(
//                   onTap: () {
//                     setState(() {
//                       _selectedLocation = location;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
//                     decoration: BoxDecoration(
//                       color: isSelected ? contolblue : Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: contolblue),
//                     ),
//                     child: Center(
//                       child: Text(
//                         location,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : contolblue,
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         SizedBox(height: 16.h),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: devices.length,
//           separatorBuilder: (_, __) => SizedBox(height: 20.h),
//           itemBuilder: (context, index) {
//             final device = devices[index];
//             return RenewablePlantCard(
//               device: device,
//               username: username,
//               password: password,
//             );
//           },
//         ),
//         SizedBox(height: MediaQuery.paddingOf(context).bottom + 100.h),
//       ],
//     );
//   }
// }

// class RenewablePlantCard extends StatefulWidget {
//   const RenewablePlantCard({
//     super.key,
//     required this.device,
//     required this.username,
//     required this.password,
//   });

//   final TreeNode device;
//   final String username;
//   final String password;

//   @override
//   State<RenewablePlantCard> createState() => _RenewablePlantCardState();
// }

// class _RenewablePlantCardState extends State<RenewablePlantCard> {
//   static const _consumptionType = '1';
//   static const _totalCheckPt = '0';
//   static const _term = '1';
//   static const _historyType = '0';
//   static const _historyTotalCheckPt = '1';

//   RenewablePeriod _selectedPeriod = RenewablePeriod.today;
//   late final EnergyCubit _snapshotCubit;
//   late final EnergyConsumptionCubit _consumptionCubit;
//   late final EnergyHistoryCubit _historyCubit;

//   @override
//   void initState() {
//     super.initState();
//     _snapshotCubit = EnergyCubit(
//       fetchUseCase: getIt(),
//       getCachedUseCase: getIt(),
//     );
//     _consumptionCubit = EnergyConsumptionCubit(fetchUseCase: getIt());
//     _historyCubit = EnergyHistoryCubit(fetchUseCase: getIt());
//     _loadSnapshot();
//     _loadConsumption();
//     _loadHistory();
//   }

//   @override
//   void dispose() {
//     _snapshotCubit.close();
//     _consumptionCubit.close();
//     _historyCubit.close();
//     super.dispose();
//   }

//   void _loadSnapshot() {
//     _snapshotCubit.load(
//       username: widget.username,
//       password: widget.password,
//       deviceId: widget.device.id,
//     );
//   }

//   void _loadConsumption() {
//     _consumptionCubit.load(
//       username: widget.username,
//       password: widget.password,
//       deviceId: widget.device.id,
//       periodType: _periodType(_selectedPeriod),
//       type: _consumptionType,
//       totalCheckPt: _totalCheckPt,
//       term: _term,
//     );
//   }

//   void _loadHistory() {
//     final range = _dateRangeFor(_selectedPeriod);
//     _historyCubit.load(
//       username: widget.username,
//       password: widget.password,
//       deviceId: widget.device.id,
//       periodType: _periodType(_selectedPeriod),
//       type: _historyType,
//       totalCheckPt: _historyTotalCheckPt,
//       term: _term,
//       startDate: _formatDate(range.start),
//       endDate: _formatDate(range.end),
//     );
//   }

//   void _changePeriod(RenewablePeriod period) {
//     if (_selectedPeriod == period) {
//       return;
//     }
//     setState(() => _selectedPeriod = period);
//     _loadConsumption();
//     _loadHistory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);
//     final periodLabel = _periodLabel(l10n, _selectedPeriod);

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: _snapshotCubit),
//         BlocProvider.value(value: _consumptionCubit),
//         BlocProvider.value(value: _historyCubit),
//       ],
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.green.shade500,
//           borderRadius: BorderRadius.circular(20.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderRow(),
//             SizedBox(height: 10.h),
//             _buildPowerRow(),
//             SizedBox(height: 8.h),
//             _buildProductionRow(periodLabel, l10n),
//             SizedBox(height: 12.h),
//             _buildMetricsRow(),
//             SizedBox(height: 12.h),
//             _buildPeriodTabs(l10n),
//             SizedBox(height: 8.h),
//             _buildChart(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             widget.device.caption.trim(),
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         BlocBuilder<EnergyCubit, EnergyState>(
//           builder: (context, state) {
//             final tempLabel = _temperatureLabel(state.snapshot?.values);
//             if (tempLabel == null) {
//               return const SizedBox.shrink();
//             }
//             return Row(
//               children: [
//                 const Icon(
//                   Icons.wb_sunny_outlined,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//                 SizedBox(width: 4.w),
//                 Text(
//                   tempLabel,
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPowerRow() {
//     return BlocBuilder<EnergyCubit, EnergyState>(
//       builder: (context, state) {
//         final powerLabel =
//             _formatPower(state.snapshot?.values['InsActPowerTotal']);
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               powerLabel,
//               style: TextStyle(
//                 fontSize: 28.sp,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               'kW',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white70,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildProductionRow(String periodLabel, AppLocalizations? l10n) {
//     return BlocBuilder<EnergyConsumptionCubit, EnergyConsumptionState>(
//       builder: (context, state) {
//         final rawValue = state.data?.consumptionValue;
//         final productionLabel = _formatEnergy(rawValue);
//         final labelText = l10n == null
//             ? '$periodLabel PV Uretimi'
//             : '$periodLabel PV ${l10n.uretim}';

//         return Row(
//           children: [
//             Text(
//               '$labelText: ',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             if (state.loading && state.data == null)
//               SizedBox(
//                 height: 12.h,
//                 width: 12.h,
//                 child: const CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             else
//               Text(
//                 productionLabel,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildMetricsRow() {
//     return BlocBuilder<EnergyCubit, EnergyState>(
//       builder: (context, state) {
//         final values = state.snapshot?.values ?? const <String, String>{};
//         final metrics = [
//           _MetricItem(
//             icon: Icons.flash_on_outlined,
//             value: _formatMetric(values['InsCurTotal'], 'A'),
//           ),
//           _MetricItem(
//             icon: Icons.bolt_outlined,
//             value: _formatMetric(values['InsActPowerTotal'], 'kW'),
//           ),
//           _MetricItem(
//             icon: Icons.battery_charging_full,
//             value: _formatMetric(values['IndActive1ImpTotal'], 'kWh'),
//           ),
//           _MetricItem(
//             icon: Icons.speed_outlined,
//             value: _formatMetric(values['IndReactiveInd1ImpTotal'], 'kVArh'),
//           ),
//           _MetricItem(
//             icon: Icons.upload_outlined,
//             value: _formatMetric(values['IndActive1ExpTotal'], 'kWh'),
//           ),
//         ];

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: metrics.map((metric) => Expanded(child: metric)).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildPeriodTabs(AppLocalizations? l10n) {
//     final labels = <RenewablePeriod, String>{
//       RenewablePeriod.today: l10n?.bugun ?? 'Bugun',
//       RenewablePeriod.daily: l10n?.gunluk ?? 'Gunluk',
//       RenewablePeriod.monthly: l10n?.aylik ?? 'Aylik',
//       RenewablePeriod.yearly: l10n?.yillik ?? 'Yillik',
//     };

//     return Row(
//       children: RenewablePeriod.values.map((period) {
//         final isSelected = period == _selectedPeriod;
//         return Padding(
//           padding: EdgeInsets.only(right: 6.w),
//           child: ScaleButton(
//             onTap: () => _changePeriod(period),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: isSelected ? contolblue : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 labels[period] ?? '',
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : contolblue,
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildChart() {
//     return BlocBuilder<EnergyHistoryCubit, EnergyHistoryState>(
//       builder: (context, state) {
//         if (state.loading && state.history == null) {
//           return SizedBox(
//             height: 90.h,
//             child: const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         }

//         final records =
//             state.history?.records ?? const <EnergyConsumptionRecord>[];
//         if (records.isEmpty) {
//           return SizedBox(
//             height: 90.h,
//             child: Center(
//               child: Text(
//                 '--',
//                 style: TextStyle(color: Colors.white70, fontSize: 12.sp),
//               ),
//             ),
//           );
//         }

//         final values = _chartValues(records);
//         return SizedBox(
//           height: 90.h,
//           child: _MiniBarChart(values: values),
//         );
//       },
//     );
//   }

//   List<double> _chartValues(List<EnergyConsumptionRecord> records) {
//     final values = records.map((record) => record.value).toList();
//     if (values.length <= 8) {
//       return values;
//     }
//     return values.sublist(values.length - 8);
//   }

//   String _periodLabel(AppLocalizations? l10n, RenewablePeriod period) {
//     switch (period) {
//       case RenewablePeriod.today:
//         return l10n?.bugun ?? 'Bugun';
//       case RenewablePeriod.daily:
//         return l10n?.gunluk ?? 'Gunluk';
//       case RenewablePeriod.monthly:
//         return l10n?.aylik ?? 'Aylik';
//       case RenewablePeriod.yearly:
//         return l10n?.yillik ?? 'Yillik';
//     }
//   }

//   String _periodType(RenewablePeriod period) {
//     switch (period) {
//       case RenewablePeriod.today:
//         return '0';
//       case RenewablePeriod.daily:
//         return '1';
//       case RenewablePeriod.monthly:
//         return '3';
//       case RenewablePeriod.yearly:
//         return '4';
//     }
//   }

//   _DateRange _dateRangeFor(RenewablePeriod period) {
//     final now = DateTime.now();
//     switch (period) {
//       case RenewablePeriod.today:
//         final start = DateTime(now.year, now.month, now.day);
//         final end = start.add(const Duration(days: 1));
//         return _DateRange(start, end);
//       case RenewablePeriod.daily:
//         final start = DateTime(now.year, now.month, 1);
//         final end = DateTime(now.year, now.month + 1, 0);
//         return _DateRange(start, end);
//       case RenewablePeriod.monthly:
//         final start = DateTime(now.year, 1, 1);
//         final end = DateTime(now.year, now.month + 1, 0);
//         return _DateRange(start, end);
//       case RenewablePeriod.yearly:
//         final start = DateTime(now.year, 1, 1);
//         final end = DateTime(now.year, 12, 31);
//         return _DateRange(start, end);
//     }
//   }

//   String _formatEnergy(String? rawValue) {
//     if (rawValue == null || rawValue.isEmpty) {
//       return '--';
//     }
//     final parsed = EnergyValueParser.parse(rawValue);
//     final numberFormat = NumberFormat('#,##0.##', 'tr_TR');
//     if (parsed >= 1000) {
//       return '${numberFormat.format(parsed / 1000)} MWh';
//     }
//     return '${numberFormat.format(parsed)} kWh';
//   }

//   String _formatPower(String? rawValue) {
//     if (rawValue == null || rawValue.trim().isEmpty) {
//       return '--';
//     }
//     final parsed = EnergyValueParser.parse(rawValue);
//     final numberFormat = NumberFormat('#,##0.0', 'tr_TR');
//     return numberFormat.format(parsed);
//   }

//   String _formatMetric(String? rawValue, String unit) {
//     if (rawValue == null || rawValue.isEmpty) {
//       return '--';
//     }
//     final parsed = EnergyValueParser.parse(rawValue);
//     if (parsed == 0 && rawValue.trim() != '0') {
//       return '--';
//     }
//     final numberFormat = NumberFormat('#,##0.#', 'tr_TR');
//     return '${numberFormat.format(parsed)} $unit';
//   }

//   String? _temperatureLabel(Map<String, String>? values) {
//     if (values == null) {
//       return null;
//     }
//     for (final key in const [
//       'Temperature',
//       'Temp',
//       'InsTemp',
//       'InsTmp',
//     ]) {
//       final value = values[key];
//       if (value != null && value.trim().isNotEmpty) {
//         final numberFormat = NumberFormat('#,##0.#', 'tr_TR');
//         final parsed = EnergyValueParser.parse(value);
//         return '${numberFormat.format(parsed)} C';
//       }
//     }
//     return null;
//   }

//   String _formatDate(DateTime date) =>
//       DateFormat('yyyy-MM-dd').format(date.toLocal());
// }

// class _MetricItem extends StatelessWidget {
//   const _MetricItem({
//     required this.icon,
//     required this.value,
//   });

//   final IconData icon;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white, size: 16),
//         SizedBox(height: 4.h),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 10.sp,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

// class _MiniBarChart extends StatelessWidget {
//   const _MiniBarChart({required this.values});

//   final List<double> values;

//   @override
//   Widget build(BuildContext context) {
//     if (values.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final maxValue = values.reduce(math.max);
//     final safeMax = maxValue <= 0 ? 1 : maxValue;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: values.map((value) {
//         final heightFactor = (value / safeMax).clamp(0.05, 1.0);
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 2.w),
//             child: FractionallySizedBox(
//               heightFactor: heightFactor,
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class _DateRange {
//   _DateRange(this.start, this.end);

//   final DateTime start;
//   final DateTime end;
// }
