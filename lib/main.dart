// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fortegatecommunity/appcore/api/api_service.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/service/fcm_service.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/screens/home/home_view.dart';
import 'package:fortegatecommunity/screens/splash/splash_view.dart';
import 'package:provider/provider.dart';
import 'appcore/config/appconfig.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📬 Background message: ${message.messageId}');
}

// Navigator key for global navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize FCM in background (non-blocking)
    FCMService.instance.init().then((_) {
      debugPrint('✅ FCM initialized successfully');
    }).catchError((e) {
      debugPrint('⚠️ FCM initialization failed: $e');
      // App continues without FCM
    });
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // App continues without Firebase
  }

  // Initialize API Service (load token)
  await ApiService.instance.init();

  // Lock orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure EasyLoading
  configLoading();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = AppGreen
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(319, 672),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppGreen),
              useMaterial3: true,
            ),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashView(),
              AppConfig.routeHome: (_) => const HomeView(pageId: 0),
              AppConfig.routeSurvey: (_) => const HomeView(pageId: 1),
              AppConfig.routeMeeting: (_) => const HomeView(pageId: 2),
              AppConfig.routePoints: (_) => const HomeView(pageId: 3),
              AppConfig.routeSettings: (_) => const HomeView(pageId: 4),
            },
            builder: EasyLoading.init(),
          ),
        );
      },
    );
  }
}