// lib/screens/webview/webview_viewmode
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/screens/home/home_view.dart';
import 'package:stacked/stacked.dart';

class WebViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  Future<void> refreshData() async {
    if (_appProvider == null) return;

    try {
      await Future.wait([
        _appProvider!.fetchSurveys(),
        _appProvider!.fetchPoints(),
      ]);
      debugPrint('✅ Survey data refreshed');
    } catch (e) {
      debugPrint('❌ Failed to refresh data: $e');
    }
  }

  void navigateBack(BuildContext context) {
    // Refresh data before navigating back
    refreshData();
    // Navigate back to Surveys tab
    HomeView.of(context)?.resetTab(1);
  }
}
