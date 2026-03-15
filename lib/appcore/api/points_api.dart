// lib/appcore/api/points_api.dart

import 'package:flutter/foundation.dart';
import 'api_service.dart';

class PointsApi {
  final ApiService _api;

  PointsApi(this._api);

  /// Get user points
  Future<Map<String, dynamic>> getUserPoints(String respondentId) async {
    debugPrint('💰 Fetching points for user: $respondentId');
    
    return await _api.post(
      '/respondents/syncupdatepoint',
      data: {
        'respondentId': respondentId,
      },
    );
  }

  /// Create point request
  Future<Map<String, dynamic>> createPointRequest(Map<String, dynamic> data) async {
    debugPrint('💳 Creating point request');
    
    return await _api.post('/point/create', data: data);
  }

  /// Get point request history
  Future<Map<String, dynamic>> getPointHistory(String respondentId) async {
    debugPrint('📜 Fetching point history for user: $respondentId');
    
    return await _api.get('/point/history/$respondentId');
  }

  /// Get point summary
  Future<Map<String, dynamic>> getPointSummary(String respondentId) async {
    debugPrint('📊 Fetching point summary for user: $respondentId');
    
    return await _api.get('/point/summary/$respondentId');
  }
}