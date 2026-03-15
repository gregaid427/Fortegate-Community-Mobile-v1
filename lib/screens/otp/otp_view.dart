// lib/screens/otp/otp_view.dart

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/service/fcm_service.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../authentication/signup/signup_view.dart';
import 'otp_viewmodel.dart';

class OtpView extends StatefulWidget {
  const OtpView({Key? key}) : super(key: key);

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final TextEditingController otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _setAppStage();
    _startTimer();
    _initFCM();
    _loadUserData();
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('Otpcode');
  }

  Future<void> _initFCM() async {
    try {
      await FCMService.instance.initWithoutUser();
      debugPrint('FCM initialized (guest mode)');
    } catch (e) {
      debugPrint('FCM init failed (guest): $e');
    }
  }

  Future<void> _loadUserData() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.loadUser();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OtpViewmodel>.reactive(
      viewModelBuilder: () => OtpViewmodel(),
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/otp.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: AppGreen,
                                size: 40.sp,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  ScaleTransition2(const SignupView()),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/fgcm1.png',
                              width: 220.w,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "enter_code".tr(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppGreen,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Pinput(
                                length: 5,
                                controller: otpController,
                                showCursor: true,
                                onCompleted: (pin) async {
                                  final storedOtp =
                                      await StorageHelper.read('otp');
                                      print(storedOtp);
                                  
                                  if (storedOtp == pin) {
                                    final lsm = appProvider!.lsmStatus;
                                    final onboard =
                                        appProvider.onboardQstnStatus;
                                    model.navigate(lsm, onboard, context);
                                  } else {
                                    if (context.mounted) {
                                      SnackbarHelper.showError(
                                        context,
                                        'wrong_pin'.tr(),
                                      );
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),
                              _secondsLeft > 0
                                  ? Text(
                                      "resendcode".tr() +
                                          " $_secondsLeft " +
                                          "seconds".tr(),
                                      style: TextStyle(fontSize: 14.sp),
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          "didnt_receive".tr(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppGreen,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final token =
                                                await StorageHelper.getFCMToken();
                                            model.resendotp(
                                              context,
                                              token,
                                              appProvider.userId,
                                            );
                                            _startTimer();
                                          },
                                          child: Text(
                                            "resend".tr(),
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}