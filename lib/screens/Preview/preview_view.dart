// lib/screens/preview/preview_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../home/home_view.dart';
import 'preview_viewmodel.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({super.key, required this.surveyinfo});
  final dynamic surveyinfo;

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PreviewViewModel>.reactive(
      viewModelBuilder: () => PreviewViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
      },
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            padding: EdgeInsets.all(15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppGreen,
                      ),
                      onPressed: () {
                        HomeView.of(context)?.resetTab(1);
                      },
                    ),
                    Text(
                      'take_survey'.tr(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Survey info
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 247, 241, 241),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
  Icons.assignment,
  "title".tr(),
  widget.surveyinfo['name']?.toString() ?? "n/a",
),

Divider(),

_buildInfoRow(
  Icons.calendar_today,
  "date_created".tr(),
  widget.surveyinfo['startdate'] ?? "n/a",
),

Divider(),

_buildInfoRow(
  Icons.stars,
  "points_per_response".tr(),
  widget.surveyinfo['points']?.toString() ?? "n/a",
),

Divider(),

_buildInfoRow(
  Icons.vpn_key,
  "survey_token".tr(),
  widget.surveyinfo['token'] ?? "n/a",
),
                      ],
                    ),
                  ),
                ),

                // Proceed button
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
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
                        onPressed: model.isBusy
                            ? null
                            : () {
                                model.checkToken(
                                  widget.surveyinfo['survey_id'],
                                  widget.surveyinfo['token'],
                                  context,
                                );
                              },
                        child: model.isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text("proceed".tr()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Icon
        Icon(
          icon,
          size: 20,
          color: AppGreen,
        ),

        SizedBox(width: 8.w),

        /// Vertical divider
        Container(
          height: 36.h,
          width: 1,
          color: const Color.fromARGB(120, 158, 158, 158),
        ),

        SizedBox(width: 10.w),

        /// Text section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: AppGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}