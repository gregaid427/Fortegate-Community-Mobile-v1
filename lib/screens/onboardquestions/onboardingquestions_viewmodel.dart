// lib/screens/onboardquestions/onboardingquestions_viewmodel.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/api/api_service.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../home/home_view.dart';
import 'LSMQuestion_view.dart';

class Question {
  final int id;
  final String identifier;
  final String text;
  final String type;
  final List<String> options;
  final bool conditional;
  final String rule;

  Question({
    required this.id,
    required this.identifier,
    required this.text,
    required this.type,
    required this.options,
    required this.conditional,
    required this.rule,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        identifier: json['identifier'] ?? '',
        text: json['text'],
        type: json['type'],
        options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
        conditional: json['conditional'] ?? false,
        rule: json['rule'] ?? '',
      );
}

class OnboardingQuestionsViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  List<Question> questions = [];
  Map<String, dynamic> answers = {};
  Map<String, String> conditionalInputs = {};

  // Country data
  List<String> countries = [];
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  static const _cacheKey = 'cached_countries';

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  Future<void> loadQuestions() async {
    setBusy(true);
    await EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final raw = await rootBundle.loadString(
        'assets/onboardingquestions/onboarding_questions',
      );
      final List<dynamic> parsed = json.decode(raw);
      questions = parsed.map((q) => Question.fromJson(q)).toList();

      await _loadCountries();
    } catch (e) {
      debugPrint("❌ Error loading questions or countries: $e");
    }

    await EasyLoading.dismiss();
    setBusy(false);
  }

  Future<void> _loadCountries() async {
    if (countries.isNotEmpty) return;

    final cached = await _storage.read(key: _cacheKey);
    if (cached != null) {
      countries = List<String>.from(jsonDecode(cached));
      return;
    }

    try {
      final response = await _dio.get(
        'https://restcountries.com/v3.1/all?fields=name',
      );
      final data = response.data as List<dynamic>;

      countries = data
          .map((c) => c['name']?['common']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      await _storage.write(key: _cacheKey, value: jsonEncode(countries));
      debugPrint("✅ Fetched ${countries.length} countries");
    } catch (e) {
      debugPrint("⚠️ Failed to fetch countries: $e");
    }
  }

  void setValueInstant(int questionId, dynamic value) {
    final q = questions.firstWhere((x) => x.id == questionId);
    final key = q.identifier.isNotEmpty ? q.identifier : questionId.toString();
    answers[key] = value;
    notifyListeners();
  }

  void toggleCheckbox(int questionId, String option, bool selected) {
    final q = questions.firstWhere((x) => x.id == questionId);
    final key = q.identifier.isNotEmpty ? q.identifier : questionId.toString();
    final current = List<String>.from(answers[key] ?? []);

    if (selected) {
      if (!current.contains(option)) current.add(option);
    } else {
      current.remove(option);
    }

    answers[key] = current;
    notifyListeners();
  }

  void setConditional(int questionId, String text) {
    final q = questions.firstWhere((x) => x.id == questionId);
    final key = q.identifier.isNotEmpty
        ? "${q.identifier}_cond"
        : "${questionId}_cond";
    conditionalInputs[key] = text;
    notifyListeners();
  }

  bool shouldShowConditional(Question q) {
    if (!q.conditional) return false;
    final ans = answers[q.identifier];
    if (ans == null) return false;
    if (ans is String) return ans == q.rule;
    if (ans is List) return ans.contains(q.rule);
    return false;
  }

  Future<void> submitAnswers(BuildContext context) async {
    if (_appProvider == null) {
      SnackbarHelper.showError(context, 'Session expired');
      return;
    }

    await EasyLoading.show(
      status: 'Submitting...',
      maskType: EasyLoadingMaskType.black,
    );

    final finalAnswers = Map<String, dynamic>.from(answers);
    conditionalInputs.forEach((k, v) => finalAnswers[k] = v);

    debugPrint("📝 Final Answers Submitted:");
    debugPrint(const JsonEncoder.withIndent('  ').convert(finalAnswers));

    try {
      final result = await ApiService.instance.respondent.submitOnboardingAnswers(
        answers: finalAnswers,
    userId: _appProvider!.userId,
      );

      await EasyLoading.dismiss();

      if (result["error"] == true) {
        if (context.mounted) {
          SnackbarHelper.showError(context, result["msg"]);
        }
        return;
      }

      if (result["success"] == 1) {
        debugPrint("✅ Onboarding answers submitted successfully");

        // Check if LSM questions are needed
        final lsmStatus = _appProvider!.lsmStatus;

        if (context.mounted) {
          if (lsmStatus == 0) {
            Navigator.pushReplacement(
              context,
              SizeTransition3(const LSMQuestionPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              SizeTransition3(const HomeView(pageId: 0)),
            );
          }
        }
      }
    } catch (e) {
      await EasyLoading.dismiss();
      debugPrint("❌ Error submitting answers: $e");
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to submit answers');
      }
    }
  }
}