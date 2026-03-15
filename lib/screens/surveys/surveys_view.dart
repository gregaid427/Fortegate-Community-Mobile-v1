// lib/screens/surveys/surveys_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../preview/preview_view.dart';
import 'surveys_viewmodel.dart';

class SurveysView extends StatefulWidget {
  const SurveysView({super.key});

  @override
  State<SurveysView> createState() => _SurveysViewState();
}

class _SurveysViewState extends State<SurveysView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SurveysViewModel>.reactive(
      viewModelBuilder: () => SurveysViewModel(),
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Center(
                            child: Text(
                              'surveys'.tr(),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppGreen,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.sp),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: 'ongoing'.tr()),
                            Tab(text: 'new'.tr()),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              CompletedSurveys(
                                apiData: appProvider!.allSurveys,
                              ),
                              PendingSurveys(
                                apiData: appProvider.newSurveys,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PendingSurveys extends StatelessWidget {
  const PendingSurveys({super.key, required this.apiData});
  final List<dynamic> apiData;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SurveysViewModel>.reactive(
      viewModelBuilder: () => SurveysViewModel(),
      builder: (context, model, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
        child: RefreshIndicator(
          onRefresh: () => model.callAllsurveys(context),
          child: apiData.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          "no_new_surveys".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 5.sp),
                  itemCount: apiData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final survey = apiData[index];
                    return _SurveyCard(
                      survey: survey,
                      color: const Color.fromARGB(255, 230, 126, 115),
                      showChevron: true,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class CompletedSurveys extends StatelessWidget {
  const CompletedSurveys({super.key, required this.apiData});
  final List<dynamic> apiData;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SurveysViewModel>.reactive(
      viewModelBuilder: () => SurveysViewModel(),
      builder: (context, model, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
        child: RefreshIndicator(
          onRefresh: () => model.callAllsurveys(context),
          child: apiData.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          "no_new_surveys".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 5.sp),
                  itemCount: apiData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final survey = apiData[index];
                    return _SurveyCard(
                      survey: survey,
                      color: const Color.fromARGB(255, 31, 77, 0),
                      showChevron: false,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;
  final Color color;
  final bool showChevron;

  const _SurveyCard({
    required this.survey,
    required this.color,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SlideTransition2(PreviewView(surveyinfo: survey)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        padding: const EdgeInsets.all(10),
        height: 55.sp,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.white, size: 30.sp),
                const SizedBox(width: 8),
                Container(
                  color: Colors.white,
                  width: 1,
                  height: double.infinity,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      survey['startdate'] ?? 'Date: n/a',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showChevron)
              const Icon(
                CupertinoIcons.chevron_forward,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}