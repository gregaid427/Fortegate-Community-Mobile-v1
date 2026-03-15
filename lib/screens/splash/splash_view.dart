// lib/screens/splash/splash_view.dart

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final appProvider = context.read<AppProvider>();
      
      // Load user from storage
      await appProvider.loadUser();

      // If user exists, fetch data
      if (appProvider.userId != null) {
        debugPrint("✅ User found: ${appProvider.userId}");
        await Future.wait([
          appProvider.fetchSurveys(),
          appProvider.fetchPoints(),
        ]);
      }

      // Navigate based on app stage
      final splashViewModel = SplashViewModel();
      if (mounted) {
        await splashViewModel.updateAppState(context);
      }
    } catch (e, s) {
      debugPrint("❌ Splash initialization failed: $e\n$s");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}