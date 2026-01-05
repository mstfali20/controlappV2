import 'package:equatable/equatable.dart';

import '../../domain/entities/energy_consumption.dart';

class EnergyCarbonState extends Equatable {
  const EnergyCarbonState({
    this.loading = false,
    this.error,
    this.consumption,
    this.production,
    this.gasConsumption,
    this.consumptionValue,
    this.productionValue,
    this.gasValue,
    this.difference,
    this.carbonEmissionTon,
    this.treeCount,
    this.gasEmissionTon,
  });

  final bool loading;
  final String? error;
  final EnergyConsumption? consumption;
  final EnergyConsumption? production;
  final EnergyConsumption? gasConsumption;
  final double? consumptionValue;
  final double? productionValue;
  final double? gasValue;
  final double? difference;
  final double? carbonEmissionTon;
  final double? treeCount;
  final double? gasEmissionTon;

  EnergyCarbonState copyWith({
    bool? loading,
    String? error,
    EnergyConsumption? consumption,
    EnergyConsumption? production,
    EnergyConsumption? gasConsumption,
    double? consumptionValue,
    double? productionValue,
    double? gasValue,
    double? difference,
    double? carbonEmissionTon,
    double? treeCount,
    double? gasEmissionTon,
    bool clearError = false,
    bool clearProduction = false,
    bool clearGas = false,
  }) {
    return EnergyCarbonState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      consumption: consumption ?? this.consumption,
      production: clearProduction ? null : (production ?? this.production),
      gasConsumption: clearGas ? null : (gasConsumption ?? this.gasConsumption),
      consumptionValue: consumptionValue ?? this.consumptionValue,
      productionValue: productionValue ?? this.productionValue,
      gasValue: clearGas ? null : (gasValue ?? this.gasValue),
      difference: difference ?? this.difference,
      carbonEmissionTon: carbonEmissionTon ?? this.carbonEmissionTon,
      treeCount: treeCount ?? this.treeCount,
      gasEmissionTon: clearGas ? null : (gasEmissionTon ?? this.gasEmissionTon),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        consumption,
        production,
        gasConsumption,
        consumptionValue,
        productionValue,
        gasValue,
        difference,
        carbonEmissionTon,
        treeCount,
        gasEmissionTon,
      ];
}
