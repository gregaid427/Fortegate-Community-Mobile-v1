// lib/appcore/config/app_config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  //static String get apiUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:5500';
    static  String? devApiUrl = 'http://10.0.2.2:5500';
  static  String? prodApiUrl = dotenv.env['BASE_URL'];
  
  static String? get apiUrl => true ? devApiUrl : prodApiUrl;

  
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? 'X7k2Pz9Qm3L8sR1T4v6W0yZaBcDeFgHj';

  // App Information
  static const String appName = 'Fortegate Community';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@fortegate.com';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Token Expiration
  static const Duration tokenExpiryDuration = Duration(days: 7);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Default Values
  static const String defaultCountry = 'Ghana';
  static const String defaultLanguage = 'English';
  static const String defaultRank = 'Field Auditor';

  // Meeting Status
  static const String meetingStatusPending = 'pending';
  static const String meetingStatusActive = 'active';
  static const String meetingStatusCompleted = 'completed';
  static const String meetingStatusCancelled = 'cancelled';

  // Survey Status
  static const String surveyStatusNew = 'new';
  static const String surveyStatusOngoing = 'ongoing';
  static const String surveyStatusCompleted = 'completed';

  // Point Request Status
  static const String pointRequestPending = 'pending';
  static const String pointRequestApproved = 'approved';
  static const String pointRequestRejected = 'rejected';

  // Notification Channels
  static const String notificationChannelId = 'default_channel';
  static const String notificationChannelName = 'Default';
  static const String notificationChannelDescription = 'Default notification channel';

  // Routes
  static const String routeHome = '/home';
  static const String routeSurvey = '/survey';
  static const String routeMeeting = '/meeting';
  static const String routePoints = '/points';
  static const String routeSettings = '/settings';
  static const String routeSurveyDetails = '/survey-details';
  static const String routeMeetingDetails = '/meeting-details';

  // App Stages
  static const String stageAuth = 'AUTH';
  static const String stageOnboarding = 'ONBOARDING';
  static const String stageHome = 'HOME';

  // Error Messages
  static const String errorNoInternet = 'No internet connection. Please check and try again.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorServerError = 'Server error occurred. Please try again later.';
  static const String errorUnexpected = 'Unexpected error occurred. Please try again.';
  static const String errorSessionExpired = 'Session expired. Please login again.';

  // Success Messages
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successMeetingCreated = 'Meeting scheduled successfully';
  static const String successMeetingDeleted = 'Meeting deleted successfully';
  static const String successPointRequestCreated = 'Request submitted successfully';
  static const String successParticipantsNotified = 'Participants notified successfully';

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;
  static const int minPhoneLength = 10;

  // Development
 // static bool get isDevelopment => apiUrl.contains('localhost') || apiUrl.contains('127.0.0.1');
  //static bool get isProduction => !isDevelopment;
}