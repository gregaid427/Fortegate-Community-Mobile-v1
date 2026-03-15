// lib/screens/otp/otp_phone_input.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/service/fcm_service.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../authentication/signup/signup_view.dart';
import 'otp_viewmodel.dart';

class PhoneInputView extends StatefulWidget {
  const PhoneInputView({Key? key}) : super(key: key);

  @override
  State<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<PhoneInputView> {
  String? _countryCode;
  String? _completeNumber;

  @override
  void initState() {
    super.initState();
    _setAppStage();
    _initFCMForGuest();
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('Otpinput');
  }

  Future<void> _initFCMForGuest() async {
    try {
      await FCMService.instance.initWithoutUser();
      debugPrint('FCM initialized (guest mode)');
    } catch (e) {
      debugPrint('FCM init failed (guest): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OtpViewmodel>.reactive(
      viewModelBuilder: () => OtpViewmodel(),
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/com.png',
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "get_started".tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                          color: AppGreen,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: "phone_number".tr(),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        initialCountryCode: 'GH',
                        onCountryChanged: (country) {
                          setState(() {
                            _countryCode = country.dialCode;
                          });
                          
                          final appProvider = context.read<AppProvider>();
                          appProvider.setCountry(country.name);
                        },
                        onChanged: (phone) {
                          setState(() {
                            _countryCode = phone.countryCode;
                            _completeNumber = phone.number;
                          });
                          model.setphoneNumber(phone.number);
                        },
                      ),
                      SizedBox(height: 1.h),
                      LanguageSelector(
                        onChanged: (locale) {
                          debugPrint("Selected locale: $locale");
                        },
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            "no_account_yet".tr(),
                            style: TextStyle(
                              color: AppGreen,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 10.sp),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                SizeTransition3(const SignupView()),
                              );
                            },
                            child: Text(
                              "signup".tr(),
                              style: TextStyle(
                                color: AppGreen,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          onPressed: () async {
                            if (_completeNumber == null ||
                                _completeNumber!.trim().isEmpty) {
                              SnackbarHelper.showError(
                                context,
                                'phone_not_epmty'.tr(),
                              );
                              return;
                            }

                            final token =
                                await StorageHelper.getFCMToken();
                            
                            model.getOtp(
                              context,
                              countryCode: _countryCode ?? '',
                              phone: _completeNumber ?? '',
                              token: token,
                            );
                          },
                          child: Text(context.tr('proceed')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSelector extends StatefulWidget {
  final Function(String) onChanged;
  const LanguageSelector({super.key, required this.onChanged});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _selected = "English";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale.languageCode;
    _selected = currentLocale == "fr" ? "French" : "English";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('language'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: _selected,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          items: [
            DropdownMenuItem(value: "English", child: Text("english".tr())),
            DropdownMenuItem(value: "French", child: Text("french".tr())),
          ],
          onChanged: (value) async {
            if (value != null) {
              setState(() => _selected = value);
              widget.onChanged(value);

              // Apply locale
              if (value == "French") {
                context.setLocale(const Locale('fr'));
              } else {
                context.setLocale(const Locale('en'));
              }

              // Store in provider and storage
              final appProvider = context.read<AppProvider>();
              await appProvider.setLanguage(value);
              await StorageHelper.write('language', value);
              
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}