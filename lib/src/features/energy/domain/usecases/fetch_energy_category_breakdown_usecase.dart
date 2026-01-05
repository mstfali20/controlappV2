import '../entities/energy_category_breakdown.dart';
import '../repositories/energy_repository.dart';

class FetchEnergyCategoryBreakdownParams {
  const FetchEnergyCategoryBreakdownParams({
    required this.username,
    required this.password,
    required this.organizationId,
    required this.periodType,
    required this.term,
  });

  final String username;
  final String password;
  final String organizationId;
  final String periodType;
  final String term;
}

class FetchEnergyCategoryBreakdownUseCase {
  FetchEnergyCategoryBreakdownUseCase(this._repository);

  final EnergyRepository _repository;

  Future<EnergyCategoryBreakdown> call(
    FetchEnergyCategoryBreakdownParams params,
  ) {
    return _repository.fetchCategoryBreakdown(
      username: params.username,
      password: params.password,
      organizationId: params.organizationId,
      periodType: params.periodType,
      term: params.term,
    );
  }
}
