import 'package:flutter/foundation.dart';

class RenewableGesViewModel extends ChangeNotifier {
  RenewableGesViewModel() {
    _currentPeriodType = periodTypes.first;
  }

  final List<String> periodTabs = const ['Bugün', 'Günlük', 'Aylık', 'Yıllık'];
  final List<String> periodTypes = const ['0', '1', '3', '4'];

  int _activeChartPeriodIndex = 0;
  String _currentPeriodType = '0';
  List<String> _locations = const [];
  String? _selectedLocation;

  int get activeChartPeriodIndex => _activeChartPeriodIndex;
  String get currentPeriodType => _currentPeriodType;
  List<String> get locations => _locations;
  String? get selectedLocation => _selectedLocation;

  void setLocations(List<String> newLocations) {
    final normalized = newLocations
        .map((tab) => tab.trim())
        .where((tab) => tab.isNotEmpty)
        .toList();
    if (listEquals(_locations, normalized)) {
      if (_locations.length <= 1 && _selectedLocation != null) {
        _selectedLocation = null;
        notifyListeners();
      }
      return;
    }
    _locations = List.unmodifiable(normalized);
    _selectedLocation = normalized.length > 1 ? normalized.first : null;
    notifyListeners();
  }

  void selectLocation(String location) {
    if (_selectedLocation == location) {
      return;
    }
    _selectedLocation = location;
    notifyListeners();
  }

  void selectPeriod(int index) {
    if (_activeChartPeriodIndex == index) {
      return;
    }
    _activeChartPeriodIndex = index;
    _currentPeriodType = periodTypes[index];
    notifyListeners();
  }
}
