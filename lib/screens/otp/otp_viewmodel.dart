// lib/screens/otp/otp_viewmodel.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/api/api_service.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../home/home_view.dart';
import '../onboardquestions/LSMQuestion_view.dart';
import '../onboardquestions/onboardingquestions_view.dart';
import 'otp_view.dart';

class OtpViewmodel extends BaseViewModel {
  String _phoneNumber = "";

  String get getphoneNumber => _phoneNumber;

  void setphoneNumber(String value) {
    if (value.isNotEmpty) {
      _phoneNumber = value;
    } else {
      throw Exception("Invalid phone number");
    }
  }

  Future<void> getOtp(
    BuildContext context, {
    required String countryCode,
    required String phone,
    String? token,
  }) async {
    await EasyLoading.show(
      status: 'Authenticating...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final result = await ApiService.instance.respondent.sendOTP(
        fcmToken: token, phoneNumber: countryCode + phone, rawnumber: phone,
      );

      await EasyLoading.dismiss();

      if (result["error"] == true) {
        if (context.mounted) {
          SnackbarHelper.showError(context, result["msg"]);
        }
        return;
      }

      if (result["success"] == 1) {
        debugPrint("✅ OTP sent successfully");

        //Store user data
        await StorageHelper.saveUser(result['data']);
        await StorageHelper.write('otp', result['otp'].toString());
        await StorageHelper.write('userId', result['data']['id'].toString());
        await StorageHelper.write('userName', result['data']['name']);

        if (context.mounted) {
          final appProvider = context.read<AppProvider>();
          await appProvider.fetchSurveys();
          await appProvider.loadUser();

          Navigator.push(context, SizeTransition3(OtpView()));
        }
      } else if (result["success"] == 0) {
        if (context.mounted) {
          SnackbarHelper.showError(context, 'registered_yet'.tr());
        }
      }
    } catch (e) {
      await EasyLoading.dismiss();
      debugPrint("❌ Error sending OTP: $e");
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to send OTP');
      }
    }
  }

  void navigate(int? lsm, int? onboard, BuildContext context) {
    debugPrint("Navigation - LSM: $lsm, Onboard: $onboard");

    if (onboard == 0) {
      Navigator.pushReplacement(
        context,
        SizeTransition3(const OnboardingQuestionsView()),
      );
    } else if (lsm == 0) {
      Navigator.pushReplacement(
        context,
        SizeTransition3(const LSMQuestionPage()),
      );
    } else if (lsm != 0 && onboard != 0) {
      Navigator.pushReplacement(
        context,
        SizeTransition3(const HomeView(pageId: 0)),
      );
    }
  }

  Future<void> resendotp(
    BuildContext context,
    String? token,
    String? id,
  ) async {
    try {
      final result = await ApiService.instance.respondent.resendOTP(
        fcmToken: token, userId: id!, type: 1,
      );

      await EasyLoading.dismiss();

      if (await result["error"] == true) {
        if (context.mounted) {
          SnackbarHelper.showError(context, result["msg"]);
        }
        return;
      }
                print(result);
                print('result.            is            this ');

      if (await result["success"] == 1) {
        debugPrint("✅ OTP resent successfully");


        // Store updated data
       // await StorageHelper.saveUser(result["respondentId"]);
        await StorageHelper.write('otp', result['otp'].toString());
        // await StorageHelper.write(
        //   'userId',
        //   result["data"]['id'].toString(),
        // );

        if (context.mounted) {
          final appProvider = context.read<AppProvider>();
          await appProvider.fetchSurveys();

          Navigator.push(context, SizeTransition3(OtpView()));
        }
      } else if (await result["success"] == 0) {
        if (context.mounted) {
          SnackbarHelper.showError(
            context,
            'Phone Number Not Registered Yet!'.tr(),
          );
        }
      }
    } catch (e) {
      await EasyLoading.dismiss();
      debugPrint("❌ Error resending OTP: $e");
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to resend OTP');
      }
    }
  }
}