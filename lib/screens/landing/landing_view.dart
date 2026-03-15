// lib/screens/landing/landing_view.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

import 'landing_viewmodel.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LandingViewModel>.reactive(
      viewModelBuilder: () => LandingViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        appProvider.fetchPoints();
        appProvider.fetchSurveys();
      },
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return Scaffold(
              body: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/landingbg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    // User Header
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 23,
                              backgroundColor: AppGreen,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CircleAvatar(
                                  radius: 50.r,
                                  backgroundImage: appProvider.profileImage != null
                                      ? FileImage(File(appProvider.profileImage!))
                                      : const AssetImage("assets/images/usericon.png")
                                          as ImageProvider,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'welcome'.tr(),
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  appProvider.name ?? 'User',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Cards
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              LandingContainer(
                                text1: 'surveys'.tr(),
                                text2: 'ongoing'.tr(),
                                val: appProvider.allSurveys.length.toString(),
                              ),
                              LandingContainer(
                                text2: 'surveys'.tr(),
                                text1: 'new'.tr(),
                                val: appProvider.newSurveys.length.toString(),
                              ),
                              LandingContainer(
                                text1: 'points'.tr(),
                                text2: 'earned'.tr(),
                                val: appProvider.points?.toString() ?? '0',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Recent Surveys
                    Expanded(
                      flex: 4,
                      child: RecentSurveysCard(
                        surveys: appProvider.allSurveys,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LandingContainer extends StatelessWidget {
  final String? text1;
  final String? text2;
  final String? val;

  const LandingContainer({
    super.key,
    this.text1,
    this.text2,
    this.val,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(113, 158, 158, 158),
            spreadRadius: 1,
            offset: Offset(2, 2),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text1 ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppGreen,
                ),
              ),
              Text(
                text2 ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppGreen,
                ),
              ),
              Text(
                val ?? '0',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentSurveysCard extends StatelessWidget {
  final List<dynamic> surveys;

  const RecentSurveysCard({Key? key, required this.surveys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 247, 241, 241),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'recent_surveys'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                child: surveys.isEmpty
                    ? Center(
                        child: Text(
                          'no_surveys_available'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: surveys.length,
                        itemBuilder: (context, index) {
                          final survey = surveys[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              (survey["name"] != null &&
                                                      survey["name"].length > 30)
                                                  ? survey["name"].substring(0, 30) + "..."
                                                  : survey["name"] ?? "",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: AppGreen,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Color.fromARGB(68, 158, 158, 158),
                                height: 1,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}