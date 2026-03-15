// lib/appcore/api/meeting_api.dart

import 'package:flutter/foundation.dart';
import 'package:fortegatecommunity/appcore/api/api_service.dart';

class MeetingApi {
  final ApiService _api;

  MeetingApi(this._api);

  /// Create new meeting
  Future<Map<String, dynamic>> createMeeting(Map<String, dynamic> data) async {
    debugPrint('📅 Creating new meeting');
    
    return await _api.post('/meeting/create', data: data);
  }

  /// Get meetings for participant
  Future<Map<String, dynamic>> getParticipantMeetings(List<String> participantIds) async {
    debugPrint('📋 Fetching meetings for participants: $participantIds');
    
    return await _api.post(
      '/meeting/participants/getParticipantMeetings',
      data: {
        'participantIds': participantIds,
      },
    );
  }

  /// Get all participants for a meeting
  Future<Map<String, dynamic>> getAllParticipants(String meetingId) async {
    debugPrint('👥 Fetching participants for meeting: $meetingId');
    
    return await _api.get('/meeting/getallparticipant/$meetingId');
  }

  /// Notify participants
  Future<Map<String, dynamic>> notifyParticipants({
    required List<String> participantIds,
    String title = 'Fortegate Community Meeting',
    String body = 'You are being notified about a scheduled meeting',
    String group = 'community',
  }) async {
    debugPrint('🔔 Notifying participants: $participantIds');
    
    return await _api.post(
      '/meeting/participants/notifynow',
      data: {
        'title': title,
        'participantIds': participantIds,
        'body': body,
        'group': group,
      },
    );
  }

  /// Update meeting status
  Future<Map<String, dynamic>> updateMeetingStatus({
    required String meetingId,
    required String status,
  }) async {
    debugPrint('🔄 Updating meeting status: $meetingId -> $status');
    
    return await _api.post(
      '/meeting/updatemeetingstatus',
      data: {
        'mid': meetingId,
        'status': status,
      },
    );
  }

  /// Delete meeting
  Future<Map<String, dynamic>> deleteMeeting({
    required String participantId,
    required String meetingId,
  }) async {
    debugPrint('🗑️ Deleting meeting: $meetingId');
    
    return await _api.get('/meeting/deletemeeting/$participantId/$meetingId');
  }

  /// Get meeting details
  Future<Map<String, dynamic>> getMeetingDetails(String meetingId) async {
    debugPrint('📄 Fetching meeting details: $meetingId');
    
    return await _api.get('/meeting/$meetingId');
  }
}