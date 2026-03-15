import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:fortegatecommunity/screens/authentication/login/login_viewmodel.dart';
import 'package:fortegatecommunity/screens/authentication/signup/signup_view.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:fortegatecommunity/core/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginupViewModel viewModel = LoginupViewModel();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Static background
          Positioned.fill(
            child: Image.asset('assets/images/com.png', fit: BoxFit.cover),
          ),
          // Positioned.fill(
          //   child: Container(color: Colors.black.withOpacity(0.5)),
          // ),

          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: AnimatedBuilder(
                  animation: viewModel,
                  builder: (_, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Welcome 👋",
                      //   style: TextStyle(
                      //     color: AppGreen,
                      //     fontSize: 32.sp,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // SizedBox(height: 10.h),
                      Text(
                        "Log In",
                        style: TextStyle(color: AppGreen, fontSize: 16.sp),
                      ),
                      SizedBox(height: 20.h),

                      // Full name field

                      // Email field
                      _buildTextField(
                        controller: viewModel.emailController,
                        label: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        errorText: viewModel.emailError,
                        // onChanged: (_) => setState(viewModel.validateAll),
                      ),
                      SizedBox(height: 15.h),
                      // Phone field
                      IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            color: AppGreen,
                            fontSize: 14.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF107a64),
                            ),
                          ),
                        ),
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: AppGreen,
                        ),
                        initialCountryCode: 'GH',
                        onCountryChanged: (country) {
                          viewModel.setCountryCode(country.dialCode);
                        },
                        onChanged: (phone) {
                          viewModel.setCountryCode(phone.countryCode);
                          viewModel.setPhoneNumber(phone.number);
                        },
                        cursorColor: AppGreen,
                        style: TextStyle(color: AppGreen, fontSize: 16.sp),
                      ),
                      if (viewModel.phoneError != null)
                        Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Text(
                            viewModel.phoneError!,
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      SizedBox(height: 2.h),
                      // Submit button
                      Row(
                        children: [
                          Text(
                            "No Account Yet ?",
                            style: TextStyle(color: AppGreen, fontSize: 12.sp),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                SizeTransition3(SignupView()),
                              );
                            },
                            child: Text(
                              "    Sign Up",
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
                            backgroundColor: const Color(0xFF107a64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () {
                            viewModel.signUp(context);
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(viewModel.isValid
                            //         ? "✅ Data logged to console"
                            //         : "⚠️ Please fix validation errors"),
                            //     backgroundColor: AppGreen,
                            //   ),
                            // );
                            setState(() {});
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // SizedBox(height: 25.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: AppGreen, fontSize: 16.sp),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppGreen),
            labelText: label,
            labelStyle: TextStyle(color: AppGreen, fontSize: 14.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Color(0xFF107a64)),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(left: 12.w, top: 4.h),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.redAccent, fontSize: 13.sp),
            ),
          ),
      ],
    );
  }
}
