import 'package:controlapp/const/Color.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/utils/currency_formatter.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_consumption_cubit.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_consumption_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnergyTotalCard extends StatelessWidget {
  const EnergyTotalCard({
    super.key,
    required this.title,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.username,
    required this.password,
    required this.periodType,
    required this.deviceId,
    required this.type,
    required this.totalCheckPt,
    required this.term,
  });

  final String title;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final String username;
  final String password;
  final String periodType;
  final String deviceId;
  final String type;
  final String totalCheckPt;
  final String term;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnergyConsumptionCubit(fetchUseCase: getIt())
        ..load(
          username: username,
          password: password,
          deviceId: deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
        ),
      child: _EnergyTotalCardView(
        title: title,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
      ),
    );
  }
}

class _EnergyTotalCardView extends StatelessWidget {
  const _EnergyTotalCardView({
    required this.title,
    required this.gradientStartColor,
    required this.gradientEndColor,
  });

  final String title;
  final Color gradientStartColor;
  final Color gradientEndColor;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnergyConsumptionCubit, EnergyConsumptionState>(
      listener: (context, state) {
        if (state.error != null && !state.loading) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.shade400,
                content: Text(state.error!),
              ),
            );
        }
      },
      builder: (context, state) {
        final data = state.data;
        final amount = data?.consumptionAmount ?? '#';
        final formattedAmount = CurrencyFormatter.formatLabel(amount);

        return Container(
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [gradientStartColor, gradientEndColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 20.h),
          child: state.loading && data == null
              ? const Center(
                  child: CircularProgressIndicator(color: contolblue))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      data?.consumptionValue ?? '#',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      formattedAmount,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
