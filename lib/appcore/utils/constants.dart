// lib/appcore/util/constants.dart

import 'package:flutter/material.dart';

// Colors
const AppGreen = Color(0xFF107a64);
const kBackgroundColour = Color(0xFFF2F3F8);
const kPrimaryColor = Color(0xFF324BCD);
const kPrimaryColor2 = Color(0xFF324BCD);
const kSecondaryColor = Color.fromARGB(57, 201, 221, 226);
const kWarningColor = Color(0xFFFFFFFF);
const kErrorColor = Color(0xFFF03738);
const kTextColor = Color(0xFF757575);
const kDefaultPadding = 20.0;
const kPrimaryLightColor = Color(0xFFFFECDF);

// Gradients
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);

// Text Styles
const headline1 = TextStyle(
  fontSize: 96.0,
  fontWeight: FontWeight.w300,
);

const headline5 = TextStyle(
  fontSize: 60.0,
  fontWeight: FontWeight.w300,
);

const kTitleStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'CM Sans Serif',
  fontSize: 26.0,
  height: 1.5,
);

const kSubtitleStyle = TextStyle(
  color: Colors.black,
  fontSize: 16.0,
  height: 1.2,
);

const kSubtitleStyle1 = TextStyle(
  color: Colors.black54,
  fontSize: 16.0,
  height: 1.2,
);

const kHomeCardStyle1 = TextStyle(
  color: Colors.white,
  fontSize: 19.0,
);

const kHomeCardStyle2 = TextStyle(
  color: Colors.white,
  fontSize: 15.0,
  fontWeight: FontWeight.bold,
);

const kHistoryStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.grey,
);

const kHistoryStyle1 = TextStyle(
  fontSize: 17,
  color: Colors.black54,
);

const kHistoryStyle2 = TextStyle(
  fontSize: 17,
  color: Colors.deepOrange,
);

// Durations
const kAnimationDuration = Duration(milliseconds: 200);
const defaultDuration = Duration(milliseconds: 250);

// Validation Messages
const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter valid email";
const String kPassNullError = "Please enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNameNullError = "Please enter your name";
const String kPhoneNumberNullError = "Please enter your phone number";
const String kAddressNullError = "Please enter your address";

// Regex
final RegExp emailValidatorRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

// Size Configuration
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Get proportionate screen height
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  return (inputHeight / 812.0) * screenHeight;
}

// Get proportionate screen width
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  return (inputWidth / 375.0) * screenWidth;
}

// App Stages
enum AppStage {
  auth,
  onboarding,
  home,
}

extension AppStageExtension on AppStage {
  String get value {
    switch (this) {
      case AppStage.auth:
        return 'AUTH';
      case AppStage.onboarding:
        return 'ONBOARDING';
      case AppStage.home:
        return 'HOME';
    }
  }

  static AppStage fromString(String value) {
    switch (value) {
      case 'AUTH':
        return AppStage.auth;
      case 'ONBOARDING':
        return AppStage.onboarding;
      case 'HOME':
        return AppStage.home;
      default:
        return AppStage.auth;
    }
  }
}

// Survey Status
enum SurveyStatus {
  newSurvey,
  ongoing,
  completed,
}

extension SurveyStatusExtension on SurveyStatus {
  String get displayName {
    switch (this) {
      case SurveyStatus.newSurvey:
        return 'New';
      case SurveyStatus.ongoing:
        return 'Ongoing';
      case SurveyStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case SurveyStatus.newSurvey:
        return Colors.blue;
      case SurveyStatus.ongoing:
        return Colors.orange;
      case SurveyStatus.completed:
        return Colors.green;
    }
  }
}

// Meeting Status
enum MeetingStatus {
  pending,
  active,
  completed,
  cancelled,
}

extension MeetingStatusExtension on MeetingStatus {
  String get value {
    switch (this) {
      case MeetingStatus.pending:
        return 'pending';
      case MeetingStatus.active:
        return 'active';
      case MeetingStatus.completed:
        return 'completed';
      case MeetingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case MeetingStatus.pending:
        return 'Pending';
      case MeetingStatus.active:
        return 'Active';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case MeetingStatus.pending:
        return Colors.orange;
      case MeetingStatus.active:
        return Colors.blue;
      case MeetingStatus.completed:
        return Colors.green;
      case MeetingStatus.cancelled:
        return Colors.red;
    }
  }

  static MeetingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return MeetingStatus.pending;
      case 'active':
        return MeetingStatus.active;
      case 'completed':
        return MeetingStatus.completed;
      case 'cancelled':
        return MeetingStatus.cancelled;
      default:
        return MeetingStatus.pending;
    }
  }
}

// Point Request Status
enum PointRequestStatus {
  pending,
  approved,
  rejected,
}

extension PointRequestStatusExtension on PointRequestStatus {
  String get value {
    switch (this) {
      case PointRequestStatus.pending:
        return 'pending';
      case PointRequestStatus.approved:
        return 'approved';
      case PointRequestStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case PointRequestStatus.pending:
        return 'Pending';
      case PointRequestStatus.approved:
        return 'Approved';
      case PointRequestStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case PointRequestStatus.pending:
        return Colors.orange;
      case PointRequestStatus.approved:
        return Colors.green;
      case PointRequestStatus.rejected:
        return Colors.red;
    }
  }

  static PointRequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PointRequestStatus.pending;
      case 'approved':
        return PointRequestStatus.approved;
      case 'rejected':
        return PointRequestStatus.rejected;
      default:
        return PointRequestStatus.pending;
    }
  }
}