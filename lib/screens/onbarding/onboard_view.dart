// lib/screens/onboarding/onboard_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../authentication/signup/signup_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0;

  final List<Widget> _pages = [
    Image.asset(
      'assets/images/onboard1.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
    Image.asset(
      'assets/images/onboard2.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
    Image.asset(
      'assets/images/onboard3.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setAppStage();
    _controller = TabController(
      length: _pages.length,
      initialIndex: _index,
      vsync: this,
    );
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('Onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPreviousPressed() {
    setState(() {
      _index = (_index > 0) ? _index - 1 : 0;
      _controller.animateTo(_index);
    });
  }

  void _onNextPressed() {
    if (_index == _pages.length - 1) {
      // Last page - navigate to signup
      Navigator.pushReplacement(
        context,
        ScaleTransition1(const SignupView()),
      );
    } else {
      setState(() {
        _index++;
        _controller.animateTo(_index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              width: double.infinity,
              color: AppGreen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(32, 107, 107, 107),
                      minimumSize: Size(40.w, 40.h),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _onPreviousPressed,
                    child: const Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  // Page indicator
                  Padding(
                    padding: EdgeInsets.all(25.w),
                    child: TabPageSelector(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      selectedColor: Colors.white,
                      controller: _controller,
                    ),
                  ),

                  // Next/Get Started button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(32, 107, 107, 107),
                      minimumSize: Size(40.w, 40.h),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _onNextPressed,
                    child: const Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}