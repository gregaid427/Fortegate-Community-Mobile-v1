// lib/screens/onboardquestions/LSMQuestion_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import 'LSMQuestionViewModel.dart';

class LSMQuestionPage extends StatefulWidget {
  const LSMQuestionPage({Key? key}) : super(key: key);

  @override
  State<LSMQuestionPage> createState() => _LSMQuestionPageState();
}

class _LSMQuestionPageState extends State<LSMQuestionPage> {
  @override
  void initState() {
    super.initState();
    _setAppStage();
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('lsmquestion');
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LSMQuestionViewModel>.reactive(
      viewModelBuilder: () => LSMQuestionViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.init();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "📝 Onboarding Questions 2",
                style: TextStyle(
                  color: AppGreen,
                  fontSize: 15.sp,
                ),
              ),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppGreen,
                ),
                alignment: Alignment.center,
                child: Text(
                  model.totalScoreText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Text(
                        "Please select all options that apply to you.",
                        style: TextStyle(color: AppGreen, fontSize: 12.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...model.sections.map((section) {
                      final type = section['type'];
                      return Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['section'],
                                style: TextStyle(
                                  color: AppGreen,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Divider(color: AppGreen.withOpacity(0.2)),
                              ...List.generate(
                                (section['questions'] as List).length,
                                (qIndex) {
                                  final q = section['questions'][qIndex];
                                  final key =
                                      "${section['section']}_${q['text']}";

                                  if (type == 'checkbox') {
                                    return CheckboxListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        q['text'],
                                        style: TextStyle(fontSize: 12.5.sp),
                                      ),
                                      activeColor: AppGreen,
                                      value: model.answers[key] ?? false,
                                      onChanged: (val) => model.toggleAnswer(
                                        key,
                                        q['score'],
                                        val,
                                      ),
                                    );
                                  } else {
                                    final groupValue =
                                        model.radioAnswers[section['section']];
                                    return RadioListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: AppGreen,
                                      title: Text(
                                        q['text'],
                                        style: TextStyle(fontSize: 12.5.sp),
                                      ),
                                      value: key,
                                      groupValue: groupValue,
                                      onChanged: (_) => model.toggleRadioAnswer(
                                        section['section'],
                                        key,
                                        q['score'],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 15.h),
                    SizedBox(
                      width: double.infinity,
                      height: 38.h,
                      child: ElevatedButton(
                        onPressed: model.isBusy
                            ? null
                            : () => model.submitScore(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
      ),
    );
  }
}