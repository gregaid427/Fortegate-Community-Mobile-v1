// import 'package:cosmo/size_config.dart';
import 'package:flutter/material.dart';

const AppGreen = Color(0xFF107a64);
const kBackgroundColour = Color(0xFFF2F3F8);
const kPrimaryColor = Color(0xFF324BCD);
const kPrimaryColor2 = Color(0xFF324BCD);
const kSecondaryColor = Color.fromARGB(57, 201, 221, 226);
const kWarninngColor = Color(0xFFFFFFFF);
const kErrorColor = Color(0xFFF03738);
const kDefaultPadding = 20.0;
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kTextColor = Color(0xFF757575);
const headline1 = TextStyle(fontSize: 96.0, fontWeight: FontWeight.w300);
const headline5 = TextStyle(fontSize: 60.0, fontWeight: FontWeight.w300);
// Other text styles...
const kAnimationDuration = Duration(milliseconds: 200);

// final headingStyle = TextStyle(
//   fontSize: getProportionateScreenWidth(28),
//   fontWeight: FontWeight.bold,
//   color: Colors.black,
//   height: 1.5,
// );

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
//  fontFamily: 'CM Sans Serif',
  fontSize: 19.0,
);

const kHomeCardStyle2 = TextStyle(
    color: Colors.white,
    // fontFamily: 'CM Sans Serif',
    fontSize: 15.0,
    fontWeight: FontWeight.bold);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

// final otpInputDecoration = InputDecoration(
//   contentPadding:
//   EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
//   border: outlineInputBorder(),
//   focusedBorder: outlineInputBorder(),
//   enabledBorder: outlineInputBorder(),
// );

// OutlineInputBorder outlineInputBorder() {
//   return OutlineInputBorder(
//     borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
//     borderSide: BorderSide(color: kTextColor),
//   );
// }

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

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}

const kHistoryStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey);

const kHistoryStyle1 = TextStyle(fontSize: 17, color: Colors.black54);
const kHistoryStyle2 = TextStyle(fontSize: 17, color: Colors.deepOrange);
