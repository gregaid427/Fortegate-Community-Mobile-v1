// lib/screens/points/points_viewmodel.dart

import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:stacked/stacked.dart';

class PointsViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  Future<void> getPoints() async {
    if (_appProvider == null) return;
    await _appProvider!.fetchPoints();
    notifyListeners();
  }
}