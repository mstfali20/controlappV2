import 'package:equatable/equatable.dart';

class EnergySnapshot extends Equatable {
  const EnergySnapshot({
    required this.deviceId,
    required this.values,
    this.errorCode = 0,
    this.errorDescription,
  });

  final String deviceId;
  final Map<String, String> values;
  final int errorCode;
  final String? errorDescription;

  bool get isSuccess => errorCode == 0;

  @override
  List<Object?> get props => [deviceId, values, errorCode, errorDescription];
}
