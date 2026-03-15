// lib/screens/preview/preview_viewmodel.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/api/api_service.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../../appcore/helpers/validator_helper.dart';
import '../webview/webview_view.dart';

class PreviewViewModel extends BaseViewModel {
  AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  Future<void> checkToken(
    dynamic surveyId,
    dynamic token,
    BuildContext context,
  ) async {
    if (_appProvider == null) {
      SnackbarHelper.showError(context, 'Session expired. Please log in again.');
      return;
    }

    final name = _appProvider!.name;
    final userId = _appProvider!.userId;
    final email = _appProvider!.email;

    // If token already exists, navigate directly
    if (token != null) {
      _navigateToSurvey(context, surveyId, token);
      return;
    }

    // Validate email before requesting token
    // if (!ValidatorHelper.validateEmail(email ?? '')) {
    //   if (context.mounted) {
    //     SnackbarHelper.showError(context, 'invalid_email'.tr());
    //   }
    //   return;
    // }

    // Request new token from backend
    await _requestSurveyToken(context, surveyId, userId, email, name);
  }

  Future<void> _requestSurveyToken(
    BuildContext context,
    dynamic surveyId,
    String? userId,
    String? email,
    String? name,
  ) async {
    try {
      setBusy(true);

      final result = await ApiService.instance.survey.assignSurveyToken(
        surveyId: surveyId.toString(),
        respondentId: userId ?? '',
        email: email ?? '',
        name: name ?? '',
      );

      setBusy(false);

      if (result['success'] == true && result['token'] != null) {
        if (context.mounted) {
          _navigateToSurvey(context, surveyId, result['token']);
        }
      } else {
        if (context.mounted) {
          SnackbarHelper.showError(context, 'system_glitch'.tr());
        }
      }
    } catch (e) {
      setBusy(false);
      debugPrint('❌ Error requesting survey token: $e');
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to get survey token');
      }
    }
  }

  void _navigateToSurvey(BuildContext context, dynamic surveyId, dynamic token) {
    Navigator.push(
      context,
      ScaleTransition2(
        WebView(surveyid: surveyId, token: token),
      ),
    );
  }
}