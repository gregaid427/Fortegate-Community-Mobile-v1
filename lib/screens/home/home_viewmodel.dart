// lib/screens/home/home_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/api/api_service.dart';
import 'package:fortegatecommunity/appcore/helpers/storage_helper.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  /// Fetch user points
  Future<void> getPoints() async {
    if (_appProvider == null) {
      debugPrint('⚠️ AppProvider not set in HomeViewModel');
      return;
    }

    await _appProvider!.fetchPoints();
    notifyListeners();
  }
  Future<void> PersistFCMTokenAtbackend() async {
    if (_appProvider == null) {
      debugPrint('⚠️ AppProvider not set in HomeViewModel');
      return;
    }
    String? fcmtoken = await StorageHelper.getFCMToken();
    final result = await ApiService.instance.respondent.updateFCMToken(
    userId: _appProvider!.userId, fcmToken: fcmtoken,
      );
  }
  /// Fetch user meetings
  Future<void> getMeetings() async {
    if (_appProvider == null) {
      debugPrint('⚠️ AppProvider not set in HomeViewModel');
      return;
    }

    await _appProvider!.fetchMeetings();
    notifyListeners();
  }

  /// Fetch user surveys
  Future<void> getSurveys() async {
    if (_appProvider == null) {
      debugPrint('⚠️ AppProvider not set in HomeViewModel');
      return;
    }

    await _appProvider!.fetchSurveys();
    notifyListeners();
  }
}