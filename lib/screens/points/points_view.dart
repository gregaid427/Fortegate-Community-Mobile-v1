// lib/screens/points/points_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../home/home_view.dart';
import 'points_viewmodel.dart';

class PointsView extends StatefulWidget {
  const PointsView({super.key});

  @override
  State<PointsView> createState() => _PointsViewState();
}

class _PointsViewState extends State<PointsView> {
  void _showRedeemBottomSheet(
    BuildContext context,
    int points,
    String? userId,
    String? name,
  ) {
    String selectedOption = 'Mobile Money';
    String _countryCode = '+233';
    String _countryName = "Ghana";
    String _completeNumber = '';

    TextEditingController phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isSubmitEnabled = phoneController.text.isNotEmpty;

            Widget buildOption(String option, IconData icon) {
              bool isSelected = selectedOption == option;
              return InkWell(
                onTap: () => setState(() => selectedOption = option),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppGreen : Colors.grey.shade400,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? AppGreen : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? AppGreen : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          CupertinoIcons.check_mark,
                          color: AppGreen,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "Select Option to Redeem Points",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    const SizedBox(height: 8),
                    buildOption("Mobile Money", Icons.account_balance_wallet),
                    buildOption("Mobile Airtime", Icons.phone_android),
                    buildOption("Mobile Data", Icons.wifi),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Input number to receive",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IntlPhoneField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 12.sp),
                        labelText: "Phone Number",
                        filled: true,
                        fillColor: const Color.fromARGB(188, 238, 238, 238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      initialCountryCode: 'GH',
                      onCountryChanged: (country) {
                        setState(() {
                          _countryCode = country.dialCode;
                          _countryName = country.name;
                        });
                      },
                      onChanged: (phone) {
                        setState(() {
                          _countryCode = phone.countryCode;
                          _completeNumber = phone.number;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppGreen, width: 2),
                            ),
                            child: const Text("Close"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitEnabled
                                ? () async {
                                    final appProvider = context.read<AppProvider>();
                                    
                                    final data = {
                                      "choice": selectedOption,
                                      "country": _countryName,
                                      "countryCode": _countryCode,
                                      "phonetoreceive":
                                          "$_countryCode$_completeNumber",
                                      "phone": _completeNumber,
                                      "respondentid": userId,
                                      "name": name,
                                      "point": points,
                                      "status": "Pending",
                                    };

                                    await appProvider.createPointRequest(
                                      context: context,
                                      data: data,
                                    );

                                    Navigator.of(context).pop();

                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => HomeView.of(context)?.resetTab(3),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Submit"),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PointsViewModel>.reactive(
      viewModelBuilder: () => PointsViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.getPoints();
      },
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return Scaffold(
              body: Container(
                padding: EdgeInsets.all(15.sp),
                child: Column(
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
                                'points'.tr(),
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
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          if ((appProvider.points ?? 0) > 0) {
                            _showRedeemBottomSheet(
                              context,
                              appProvider.points ?? 0,
                              appProvider.userId,
                              appProvider.name,
                            );
                          } else {
                            SnackbarHelper.showError(
                              context,
                              "Points Not Enough to Redeem!",
                            );
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1,
                                    horizontal: 15,
                                  ),
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppGreen,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.sp),
                                      topLeft: Radius.circular(10.sp),
                                    ),
                                  ),
                                  width: double.infinity,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.stars_rounded,
                                        color: Colors.white,
                                        size: 35.sp,
                                      ),
                                      SizedBox(width: 5.sp),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'point_earned'.tr(),
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            (appProvider.points ?? 0).toString(),
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 192, 191, 191),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10.sp),
                                      bottomLeft: Radius.circular(10.sp),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(flex: 1, child: SizedBox()),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'redeem_point'.tr(),
                                              style: const TextStyle(
                                                color: AppGreen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(
                                              CupertinoIcons.chevron_forward,
                                              color: AppGreen,
                                            ),
                                          ],
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
                    ),
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 247, 241, 241),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 15.sp,
                              horizontal: 10.sp,
                            ),
                            child: RecentSurveysCard(
                              surveys: appProvider.allSurveys,
                            ),
                          ),
                        ),
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

class RecentSurveysCard extends StatelessWidget {
  final List<dynamic> surveys;

  const RecentSurveysCard({Key? key, required this.surveys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  itemCount: surveys.length.clamp(0, 7),
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
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
                                            ? survey["name"].substring(0, 30) +
                                                "..."
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
    );
  }
}