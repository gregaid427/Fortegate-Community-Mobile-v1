// lib/appcore/api/survey_api.dart

import 'package:flutter/foundation.dart';
import 'api_service.dart';

class SurveyApi {
  final ApiService _api;

  SurveyApi(this._api);

  /// Get all surveys for a user
  Future<Map<String, dynamic>> getAllSurveys(String userId) async {
    debugPrint('📋 Fetching all surveys for user: $userId');
    return await _api.get('/respondents/getallsurveysynced/$userId');
  }

  /// Assign survey token to respondent
  Future<Map<String, dynamic>> assignSurveyToken({
    required String surveyId,
    required String respondentId,
    required String email,
    required String name,
  }) async {
    debugPrint('🎫 Assigning survey token - Survey: $surveyId, User: $respondentId');
    
    // Split name into firstname and lastname
    final nameParts = name.trim().split(' ');
    final firstname = nameParts.first;
    final lastname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return await _api.post(
      '/tokens/assign',
      data: {
        'respondentId': respondentId,
        'surveyId': surveyId,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
      },
    );
  }

  /// Get survey details
  Future<Map<String, dynamic>> getSurveyDetails(String surveyId) async {
    debugPrint('📄 Fetching survey details: $surveyId');
    return await _api.get('/surveys/$surveyId');
  }

  /// Submit survey response
  Future<Map<String, dynamic>> submitSurveyResponse({
    required String surveyId,
    required String respondentId,
    required Map<String, dynamic> responses,
  }) async {
    debugPrint('📤 Submitting survey response - Survey: $surveyId');
    return await _api.post(
      '/surveys/$surveyId/responses',
      data: {
        'respondentId': respondentId,
        'responses': responses,
      },
    );
  }
}