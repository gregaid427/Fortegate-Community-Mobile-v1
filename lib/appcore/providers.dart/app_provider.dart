// lib/appcore/providers/app_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../api/api_service.dart';
import '../helpers/helpers.dart';
import '../helpers/snackbar_helper.dart';

class AppProvider extends ChangeNotifier {
  // User data
  String? _userId;
  String? _name;
  String? _email;
  String? _phone;
  String? _fcmToken;
  String? _profileImage;
  String? _country;
  String? _language;
  int? _points = 0;
  String? _rank;
  int? _lsmStatus = 0;
  int? _onboardQstnStatus = 0;

  // Surveys
  List<dynamic> _allSurveys = [];
  List<dynamic> _newSurveys = [];
  List<dynamic> _ongoingSurveys = [];
  List<dynamic> _completedSurveys = [];

  // Meetings
  List<dynamic> _allMeetings = [];
  List<dynamic> _meetingParticipants = [];
  String? _meetingStatus;

  // Points
  List<dynamic> _pointsDetails = [];

  // Stats
  Object? _totalSurveys = '0';
  Object? _ongoingSurveysCount = '0';
  Object? _newSurveysCount = '0';

  // Getters
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get fcmToken => _fcmToken;
  String? get profileImage => _profileImage;
  String? get country => _country;
  String? get language => _language;
  int? get points => _points;
  String? get rank => _rank;
  int? get lsmStatus => _lsmStatus;
  int? get onboardQstnStatus => _onboardQstnStatus;

  List<dynamic> get allSurveys => _allSurveys;
  List<dynamic> get newSurveys => _newSurveys;
  List<dynamic> get ongoingSurveys => _ongoingSurveys;
  List<dynamic> get completedSurveys => _completedSurveys;

  List<dynamic> get allMeetings => _allMeetings;
  List<dynamic> get meetingParticipants => _meetingParticipants;
  String? get meetingStatus => _meetingStatus;

  List<dynamic> get pointsDetails => _pointsDetails;

  Object? get totalSurveys => _totalSurveys;
  Object? get ongoingSurveysCount => _ongoingSurveysCount;
  Object? get newSurveysCount => _newSurveysCount;

  /// Load user from local storage
  Future<void> loadUser() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user['id']?.toString();
      _name = user['name'];
      _email = user['email'];
      _phone = user['phone'];
      _fcmToken = user['fcm_token'];
      _points = user['points'] ?? 0;
      _rank = user['rank'] ?? 'Field Auditor';
      _lsmStatus = user['lsmstatus'] ?? 0;
      _onboardQstnStatus = user['onboardstaus'] ?? 0;
      
      _language = await StorageHelper.getLanguage() ?? 'English';
      _country = await StorageHelper.getCountry() ?? 'Ghana';
      _profileImage = user['profileImage'];

      debugPrint('✅ User loaded from storage: $_userId');
      notifyListeners();
    }
  }

  /// Set user and save to storage (with optional JWT token)
  Future<void> setUser(Map<String, dynamic> userData, {String? token}) async {
    await StorageHelper.setUser(userData);
    
    if (token != null) {
      await ApiService.instance.setAccessToken(token);
    }

    await loadUser();
  }

  /// Update specific user field
  Future<void> updateUserField(String key, dynamic value) async {
    await StorageHelper.updateUserField(key, value);
    await loadUser();
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    _language = language;
    await StorageHelper.setLanguage(language);
    notifyListeners();
  }

  /// Set country
  Future<void> setCountry(String country) async {
    _country = country;
    await StorageHelper.setCountry(country);
    notifyListeners();
  }

  /// Set profile image
  Future<void> setProfileImage(String imageUrl) async {
    _profileImage = imageUrl;
    await updateUserField('profileImage', imageUrl);
    notifyListeners();
  }

  /// Update profile
  Future<void> updateProfile({
    required BuildContext context,
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_userId == null) return;

    await EasyLoading.show(status: 'Updating Profile...');

    final result = await ApiService.instance.respondent.updateProfile(
      userId: _userId!,
      name: name,
      email: email,
      phone: phone,
    );

    EasyLoading.dismiss();

    if (result['error'] == true) {
      if (context.mounted) {
        SnackbarHelper.showError(context, result['msg'] ?? 'Update failed');
      }
    } else {
      _name = name;
      _email = email;
      _phone = phone;
      await updateUserField('name', name);
      await updateUserField('email', email);
      await updateUserField('phone', phone);
      notifyListeners();

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Profile updated successfully');
      }
    }
  }

  /// Fetch user surveys
  Future<void> fetchSurveys() async {
    if (_userId == null) return;

    final result = await ApiService.instance.survey.getAllSurveys(_userId!);

    if (result['data'] == null) {
      _allSurveys = [];
    } else {
      _allSurveys = (result['data'] as List)
          .where((survey) => survey['active'] != 'N')
          .toList();

      _newSurveys = _allSurveys
          .where((s) =>
              s['completed'] == 'N' &&
              s['responses_count'] == 0 &&
              s['active'] == 'Y')
          .toList();

      _completedSurveys = _allSurveys
          .where((s) => s['responses_count'] != 0)
          .toList();

      _ongoingSurveys = _allSurveys
          .where((s) =>
              s['completed'] == 'N' &&
              s['active'] != 'N' &&
              s['responses_count'] > 0)
          .toList();

      debugPrint('✅ Surveys loaded: ${_allSurveys.length}');
    }

    notifyListeners();
  }

  /// Fetch user points
  Future<void> fetchPoints() async {
    if (_userId == null) return;

    final result = await ApiService.instance.points.getUserPoints(_userId!);

    if (result['success'] == 0 || result['error'] == true) {
      debugPrint('❌ Error fetching points: ${result['msg']}');
    } else {
      _points = result['data']['currentPoints'];
      await updateUserField('points', _points);
      debugPrint('💰 Points updated: $_points');
      notifyListeners();
    }
  }

  /// Fetch user meetings
  Future<void> fetchMeetings() async {
    if (_userId == null) return;

    await EasyLoading.show(status: 'Loading Meetings...');

    final result = await ApiService.instance.meeting.getParticipantMeetings([_userId!]);

    EasyLoading.dismiss();

    if (result['error'] == true) {
      debugPrint('❌ Error fetching meetings: ${result['msg']}');
    } else {
      _allMeetings = result['data'] ?? [];
      debugPrint('✅ Meetings loaded: ${_allMeetings.length}');
      notifyListeners();
    }
  }

  /// Create point request
  Future<void> createPointRequest({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    await EasyLoading.show(status: 'Submitting Request...');

    final result = await ApiService.instance.points.createPointRequest(data);

    EasyLoading.dismiss();

    if (result['error'] == true) {
      if (context.mounted) {
        SnackbarHelper.showError(context, result['msg'] ?? 'Request failed');
      }
    } else {
      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Request submitted successfully');
      }
    }
  }

  /// Create meeting
  Future<void> createMeeting({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    await EasyLoading.show(status: 'Scheduling Meeting...');

    final result = await ApiService.instance.meeting.createMeeting(data);

    EasyLoading.dismiss();

    if (result['error'] == true) {
      if (context.mounted) {
        SnackbarHelper.showError(context, result['msg'] ?? 'Failed to schedule meeting');
      }
    } else {
      _allMeetings = result['data'] ?? [];
      notifyListeners();

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Meeting scheduled successfully');
      }
    }
  }

  /// Delete meeting
  Future<void> deleteMeeting({
    required BuildContext context,
    required String meetingId,
  }) async {
    if (_userId == null) return;

    await EasyLoading.show(status: 'Deleting Meeting...');

    final result = await ApiService.instance.meeting.deleteMeeting(
      participantId: _userId!,
      meetingId: meetingId,
    );

    EasyLoading.dismiss();

    if (result['error'] == true) {
      if (context.mounted) {
        SnackbarHelper.showError(context, result['msg'] ?? 'Failed to delete meeting');
      }
    } else {
      _allMeetings = result['data'] ?? [];
      notifyListeners();

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Meeting deleted successfully');
      }
    }
  }

  /// Fetch meeting participants
  Future<void> fetchMeetingParticipants(String meetingId) async {
    await EasyLoading.show(status: 'Fetching Participants...');

    final result = await ApiService.instance.meeting.getAllParticipants(meetingId);

    EasyLoading.dismiss();

    if (result['error'] == true) {
      debugPrint('❌ Error fetching participants: ${result['msg']}');
    } else {
      _meetingParticipants = result['data'] ?? [];
      notifyListeners();
    }
  }

  /// Notify participants
  Future<void> notifyParticipants({
    required BuildContext context,
    required List<String> participantIds,
  }) async {
    await EasyLoading.show(status: 'Notifying Participants...');

    final result = await ApiService.instance.meeting.notifyParticipants(
      participantIds: participantIds,
    );

    EasyLoading.dismiss();

    if (result['error'] == true) {
      if (context.mounted) {
        SnackbarHelper.showError(context, result['msg'] ?? 'Notification failed');
      }
    } else {
      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Participants notified successfully');
      }
    }
  }

  /// Update meeting status
  Future<bool> updateMeetingStatus({
    required String meetingId,
    required String status,
  }) async {
    await EasyLoading.show(status: 'Updating Status...');

    final result = await ApiService.instance.meeting.updateMeetingStatus(
      meetingId: meetingId,
      status: status,
    );

    EasyLoading.dismiss();

    if (result['success'] == 1) {
      _meetingStatus = status;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logout
  Future<void> logout() async {
    await StorageHelper.clearUser();
    await ApiService.instance.clearAccessToken();
    
    _userId = null;
    _name = null;
    _email = null;
    _phone = null;
    _fcmToken = null;
    _points = 0;
    _allSurveys = [];
    _allMeetings = [];
    
    notifyListeners();
    debugPrint('🔓 User logged out');
  }
}