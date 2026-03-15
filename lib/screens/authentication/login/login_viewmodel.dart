// lib/screens/authentication/login/login_viewmodel.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../../appcore/api/api_service.dart';
import '../../../appcore/helpers/storage_helper.dart';
import '../../../appcore/helpers/snackbar_helper.dart';
import '../../otp/otp_view.dart';

class LoginupViewModel extends BaseViewModel {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  String _countryCode = '';
  String _phoneNumber = '';

  String? fullNameError;
  String? phoneError;
  String? emailError;

  void setPhoneNumber(String number) {
    _phoneNumber = number;
    _validatePhone();
    notifyListeners();
  }

  void setCountryCode(String code) {
    _countryCode = code;
    notifyListeners();
  }

  bool _validateFullName() {
    if (fullNameController.text.trim().isEmpty) {
      fullNameError = "Full name is required";
      return false;
    }
    fullNameError = null;
    return true;
  }

  bool _validatePhone() {
    if (_phoneNumber.trim().isEmpty) {
      phoneError = "Phone number is required";
      return false;
    }
    phoneError = null;
    return true;
  }

  bool _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError = "Email is required";
      return false;
    }
    final emailRegex = RegExp(r"^[\w\.\-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      emailError = "Invalid email format";
      return false;
    }
    emailError = null;
    return true;
  }

  bool validateAll() {
    bool valid = _validatePhone() & _validateEmail();
    notifyListeners();
    return valid;
  }

  Map<String, String> get signupData => {
        "name": fullNameController.text.trim(),
        "country_code": _countryCode,
        "phone": _phoneNumber,
        "email": emailController.text.trim(),
      };

  bool get isValid => phoneError == null && emailError == null;

  Future<void> signUp(BuildContext context) async {
    if (!validateAll()) {
      debugPrint("⚠️ Validation failed.");
      return;
    }

    await EasyLoading.show(
      status: 'Authenticating...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final result = await ApiService.instance.respondent.signup(
        phone: _countryCode + _phoneNumber,
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
      );

      await EasyLoading.dismiss();

      if (result["error"] == true) {
        if (context.mounted) {
          SnackbarHelper.showError(context, result["msg"]);
        }
        return;
      }

      if (result['success'] == 2) {
        if (context.mounted) {
          SnackbarHelper.showError(context, "taken".tr());
        }
        return;
      }

      if (result['success'] == 1) {
        debugPrint("✅ Login successful: $signupData");

        // Store user data
        await StorageHelper.saveUser(result['data'][0]);
        await StorageHelper.write('otp', result['otp'].toString());
        await StorageHelper.write(
          'userId',
          result['data'][0]['id'].toString(),
        );
        await StorageHelper.write(
          'userName',
          result['data'][0]['name'],
        );

        if (context.mounted) {
          final appProvider = context.read<AppProvider>();
          await appProvider.fetchSurveys();
          await appProvider.loadUser();

          Navigator.pushReplacement(
            context,
            SizeTransition3(const OtpView()),
          );
        }
      }
    } catch (e) {
      await EasyLoading.dismiss();
      debugPrint("❌ Login error: $e");
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Login failed');
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}