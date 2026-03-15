// lib/screens/onboardquestions/LSMQuestionViewModel.dart

import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/api/api_service.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../home/home_view.dart';

class LSMQuestionViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  List<Map<String, dynamic>> sections = [];
  Map<String, bool> answers = {};
  Map<String, String?> radioAnswers = {};
  Map<String, int> _radioScores = {};
  int totalScore = 0;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  int asInt(dynamic value) => (value is num) ? value.toInt() : 0;

  String getClass(int totalScore) {
    if (totalScore >= 60) {
      return "AB";
    } else if (totalScore >= 46 && totalScore <= 59) {
      return "C1";
    } else if (totalScore >= 25 && totalScore <= 45) {
      return "C2";
    } else {
      return "DE";
    }
  }

  Future<void> init() async {
    setBusy(true);
    await EasyLoading.show(
      status: 'Please wait...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final jsonStr = await rootBundle.loadString(
        'assets/onboardingquestions/lsm_questions',
      );
      sections = List<Map<String, dynamic>>.from(json.decode(jsonStr));
    } catch (e) {
      debugPrint("❌ Error loading questions: $e");
      sections = [];
    }

    await EasyLoading.dismiss();
    setBusy(false);
  }

  Future<void> submitScore(BuildContext context) async {
    if (_appProvider == null) {
      SnackbarHelper.showError(context, 'Session expired');
      return;
    }

    await EasyLoading.show(
      status: 'Submitting...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final result = await ApiService.instance.respondent.submitLSMScore(
          
       userId: _appProvider!.userId, score: getClass(totalScore),
      );

      await EasyLoading.dismiss();

      if (result["error"] == true) {
        if (context.mounted) {
          SnackbarHelper.showError(context, result["msg"]);
        }
        return;
      }

      if (result["success"] == 1) {
        debugPrint("✅ Successfully submitted LSM score: ${getClass(totalScore)}");

        // Refresh surveys
        await _appProvider!.fetchSurveys();

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            ScaleTransition1(const HomeView(pageId: 0)),
          );
        }
      }
    } catch (e) {
      await EasyLoading.dismiss();
      debugPrint("❌ Error submitting score: $e");
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to submit score');
      }
    }
  }

  void toggleAnswer(String key, dynamic score, bool? value) {
    int s = asInt(score);
    if (value == true) {
      answers[key] = true;
      totalScore += s;
    } else {
      answers[key] = false;
      totalScore -= s;
    }
    notifyListeners();
  }

  void toggleRadioAnswer(String section, String key, dynamic score) {
    int s = asInt(score);

    // Remove old score for that section if any
    if (_radioScores.containsKey(section)) {
      totalScore -= _radioScores[section]!;
    }

    // Add new score
    totalScore += s;
    radioAnswers[section] = key;
    _radioScores[section] = s;

    notifyListeners();
  }

  String get totalScoreText => "$totalScore";
}