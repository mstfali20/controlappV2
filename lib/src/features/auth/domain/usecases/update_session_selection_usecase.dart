import '../entities/auth_failure.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class UpdateSessionSelectionParams {
  const UpdateSessionSelectionParams({
    this.serial,
    this.serialTitle,
    this.plcTitle,
    this.selectedModule,
    this.selectedOrganizationId,
    this.treeXml,
    this.extras,
  });

  final String? serial;
  final String? serialTitle;
  final String? plcTitle;
  final String? selectedModule;
  final String? selectedOrganizationId;
  final String? treeXml;
  final Map<String, dynamic>? extras;
}

class UpdateSessionSelectionUseCase {
  const UpdateSessionSelectionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Session> call(UpdateSessionSelectionParams params) async {
    final current = await _repository.getSession();
    if (current == null) {
      throw const AuthFailure('session_not_found');
    }

    final mergedExtras = Map<String, dynamic>.from(current.extras);
    if (params.selectedModule != null) {
      mergedExtras['selected_module'] = params.selectedModule;
    }
    if (params.extras != null) {
      for (final entry in params.extras!.entries) {
        if (entry.value == null) {
          mergedExtras.remove(entry.key);
        } else {
          mergedExtras[entry.key] = entry.value;
        }
      }
    }
    mergedExtras.removeWhere((_, value) => value == null);

    final updatedSession = current.copyWith(
      serial: params.serial ?? current.serial,
      serialTitle: params.serialTitle ?? current.serialTitle,
      plcTitle: params.plcTitle ?? current.plcTitle,
      selectedOrganizationId:
          params.selectedOrganizationId ?? current.selectedOrganizationId,
      treeXml: params.treeXml ?? current.treeXml,
      extras: mergedExtras,
    );

    await _repository.saveSession(updatedSession);
    return updatedSession;
  }
}
