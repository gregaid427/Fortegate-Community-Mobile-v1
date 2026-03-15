// lib/screens/surveys/surveys_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

class SurveysViewModel extends BaseViewModel {
  Future<void> callAllsurveys(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    await appProvider.fetchSurveys();
    notifyListeners();
  }
}