// lib/screens/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/service/fcm_service.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../FocusGroup/ScheduleMeeting.dart';
import '../landing/landing_view.dart';
import '../points/points_view.dart';
import '../settings/settings_view.dart';
import '../surveys/surveys_view.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  final int pageId;

  const HomeView({super.key, required this.pageId});

  static _HomeViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_HomeViewState>();
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int pageIndex = 0;
  final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  // Navigator Keys
  final landingNavKey = GlobalKey<NavigatorState>();
  final surveysNavKey = GlobalKey<NavigatorState>();
  final meetingsNavKey = GlobalKey<NavigatorState>();
  final pointsNavKey = GlobalKey<NavigatorState>();
  final settingsNavKey = GlobalKey<NavigatorState>();

  bool _fcmInitialized = false;

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
    pageIndex = widget.pageId;
    currentTab.value = widget.pageId;
    
    debugPrint('🏠 Home initialized with pageId: ${widget.pageId}');
    
    _setAppStage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_fcmInitialized) return;
    _fcmInitialized = true;

    _initFCM();
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('HOME');
  }

  /// Initialize FCM for logged-in user
  Future<void> _initFCM() async {
    try {
      final appProvider = context.read<AppProvider>();
      final userId = appProvider.userId;
      final apiToken = appProvider.fcmToken;

      if (userId == null) {
        debugPrint('⚠️ No userId found, skipping FCM init');
        return;
      }

      // Fetch points on home load
      await appProvider.fetchPoints();

      // Initialize FCM with user
      await FCMService.instance.init();

      debugPrint('✅ FCM initialized for user: $userId');
    } catch (e, s) {
      debugPrint('❌ Error initializing FCM: $e');
      debugPrint('$s');
    }
  }

  void resetTab(int pageId) {
    GlobalKey<NavigatorState>? navKey;

    switch (pageId) {
      case 0:
        navKey = landingNavKey;
        break;
      case 1:
        navKey = surveysNavKey;
        break;
      case 2:
        navKey = meetingsNavKey;
        break;
      case 3:
        navKey = pointsNavKey;
        break;
      case 4:
        navKey = settingsNavKey;
        break;
      default:
        return;
    }

    navKey.currentState?.popUntil((route) => route.isFirst);

    currentTab.value = pageId;
    setState(() => pageIndex = pageId);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.getPoints();
        model.PersistFCMTokenAtbackend();
      },
      builder: (context, model, child) => Scaffold(
        body: IndexedStack(
          index: pageIndex,
          children: [
            _buildLandingNavigator(),
            _buildSurveysNavigator(),
            _buildMeetingsNavigator(),
            _buildPointsNavigator(),
            _buildSettingsNavigator(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ============================================================
  // NAVIGATORS
  // ============================================================

  Widget _buildLandingNavigator() {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (_, active, __) {
        if (active != 0) return const SizedBox.shrink();

        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            return Navigator(
              key: landingNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const LandingView()),
            );
          },
        );
      },
    );
  }

  Widget _buildSurveysNavigator() {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (_, active, __) {
        if (active != 1) return const SizedBox.shrink();

        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            return Navigator(
              key: surveysNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const SurveysView()),
            );
          },
        );
      },
    );
  }

  Widget _buildMeetingsNavigator() {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (_, active, __) {
        if (active != 2) return const SizedBox.shrink();

        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            return Navigator(
              key: meetingsNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const ScheduledMeetingsPage()),
            );
          },
        );
      },
    );
  }

  Widget _buildPointsNavigator() {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (_, active, __) {
        if (active != 3) return const SizedBox.shrink();

        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            return Navigator(
              key: pointsNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const PointsView()),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsNavigator() {
    return ValueListenableBuilder<int>(
      valueListenable: currentTab,
      builder: (_, active, __) {
        if (active != 4) return const SizedBox.shrink();

        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            return Navigator(
              key: settingsNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const SettingsView()),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BOTTOM NAV BAR
  // ============================================================
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color.fromARGB(125, 192, 191, 191),
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBarItem(Icons.home_filled, 0),
            _buildBarItem(Icons.pie_chart, 1),
            _buildBarItem(Icons.video_camera_front, 2),
            _buildBarItem(Icons.stars_rounded, 3),
            _buildBarItem(Icons.person_2_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBarItem(IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        color: pageIndex == index
            ? const Color.fromARGB(255, 255, 255, 255)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        onPressed: () {
          switch (index) {
            case 0:
              landingNavKey.currentState?.popUntil((r) => r.isFirst);
              break;
            case 1:
              surveysNavKey.currentState?.popUntil((r) => r.isFirst);
              break;
            case 2:
              meetingsNavKey.currentState?.popUntil((r) => r.isFirst);
              break;
            case 3:
              pointsNavKey.currentState?.popUntil((r) => r.isFirst);
              break;
            case 4:
              settingsNavKey.currentState?.popUntil((r) => r.isFirst);
              break;
          }

          currentTab.value = index;
          setState(() => pageIndex = index);
        },
        icon: Icon(icon, color: AppGreen, size: 29),
      ),
    );
  }
}