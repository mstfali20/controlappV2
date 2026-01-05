import 'package:equatable/equatable.dart';

class EnergyCategoryBreakdown extends Equatable {
  const EnergyCategoryBreakdown({
    required this.categories,
    this.errorCode = 0,
    this.errorDescription,
  });

  final Map<String, double> categories;
  final int errorCode;
  final String? errorDescription;

  bool get isSuccess => errorCode == 0;

  @override
  List<Object?> get props => [categories, errorCode, errorDescription];
}
