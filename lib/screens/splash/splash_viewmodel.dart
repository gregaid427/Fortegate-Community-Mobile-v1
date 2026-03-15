// lib/screens/splash/splash_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:fortegatecommunity/screens/onbarding/onboard_view.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../otp/otp_phone_input.dart';
import '../otp/otp_view.dart';
import '../onboardquestions/onboardingquestions_view.dart';
import '../onboardquestions/LSMQuestion_view.dart';
import '../home/home_view.dart';

class SplashViewModel extends BaseViewModel {
  Future<void> updateAppState(BuildContext context) async {
    final stageValue = await StorageHelper.getAppStage();
    final appProvider = context.read<AppProvider>();

    debugPrint("📱 App stage: $stageValue");

    Widget nextPage;

    switch (stageValue) {
      case 'lsmquestion':
        nextPage = const LSMQuestionPage();
        break;
      case 'onboardquestion':
        nextPage = const OnboardingQuestionsView();
        break;
      case 'Otpinput':
        nextPage = const PhoneInputView();
        break;
      case 'Otpcode':
        nextPage = OtpView();
        break;
      case 'HOME':
        nextPage = const HomeView(pageId: 0);
        break;
      default:
        nextPage = const OnboardingView();
    }

    if (context.mounted) {
      Navigator.pushReplacement(context, SizeTransition1(nextPage));
    }
  }
}