// lib/screens/onboardquestions/onboardingquestions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/appcore/utils/pagetransitions.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import 'onboardingquestions_viewmodel.dart';
import 'LSMQuestion_view.dart';

class OnboardingQuestionsView extends StatefulWidget {
  const OnboardingQuestionsView({super.key});

  @override
  State<OnboardingQuestionsView> createState() =>
      _OnboardingQuestionsViewState();
}

class _OnboardingQuestionsViewState extends State<OnboardingQuestionsView> {
  bool _agePromptShown = false;

  @override
  void initState() {
    super.initState();
    _setAppStage();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showAgePrompt(context),
    );
  }

  Future<void> _setAppStage() async {
    await StorageHelper.setAppStage('onboardquestion');
  }

  Future<void> _showAgePrompt(BuildContext context) async {
    if (_agePromptShown) return;
    _agePromptShown = true;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Age Confirmation",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15.h),
                  Text(
                    "Age Verification",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppGreen,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Are you under 15 years old?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          minimumSize: Size(100.w, 40.h),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("No"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          minimumSize: Size(100.w, 40.h),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );

    if (result == true && mounted) {
      // User is under 15 - proceed to LSM questions
      Navigator.pushReplacement(
        context,
        SizeTransition3(const LSMQuestionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OnboardingQuestionsViewModel>.reactive(
      viewModelBuilder: () => OnboardingQuestionsViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.loadQuestions();
      },
      builder: (context, model, child) {
        if (model.isBusy) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "📝 Onboarding Questions",
              style: TextStyle(color: AppGreen, fontSize: 16.sp),
            ),
          ),
          body: SafeArea(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: model.questions.length,
              itemBuilder: (context, index) {
                final q = model.questions[index];
                return _buildQuestionCard(context, model, q, index + 1);
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
            child: SizedBox(
              width: double.infinity,
              height: 42.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                onPressed: model.isBusy ? null : () => model.submitAnswers(context),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    OnboardingQuestionsViewModel model,
    Question q,
    int index,
  ) {
    final answer =
        model.answers[q.identifier.isNotEmpty ? q.identifier : q.id.toString()];
    final showCond = model.shouldShowConditional(q);

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 16, 122, 101),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    q.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            _buildInputWidget(q, model, answer),
            if (showCond) ...[
              SizedBox(height: 10.h),
              TextField(
                onChanged: (val) => model.setConditional(q.id, val),
                decoration: InputDecoration(
                  hintText: "Please specify...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputWidget(
    Question q,
    OnboardingQuestionsViewModel model,
    dynamic answer,
  ) {
    switch (q.type) {
      case 'radio':
        return Column(
          children: q.options.map((opt) {
            return RadioListTile<String>(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              title: Text(opt),
              value: opt,
              groupValue: answer,
              onChanged: (val) => model.setValueInstant(q.id, val),
            );
          }).toList(),
        );

      case 'checkbox':
        return Column(
          children: q.options.map((opt) {
            final selected = (answer ?? []).contains(opt);
            return CheckboxListTile(
              title: Text(opt, style: const TextStyle(fontSize: 13)),
              value: selected,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: -4,
                horizontal: 4,
              ),
              visualDensity: VisualDensity.compact,
              onChanged: (val) => model.toggleCheckbox(q.id, opt, val ?? false),
            );
          }).toList(),
        );

      case 'dropdown':
        return DropdownButtonFormField<String>(
          isExpanded: true,
          value: answer,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: q.options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) => model.setValueInstant(q.id, val),
        );

      case 'country':
        if (model.countries.isNotEmpty) {
          return DropdownButtonFormField<String>(
            isExpanded: true,
            value: answer,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            hint: const Text('Select your country'),
            items: model.countries
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => model.setValueInstant(q.id, val),
          );
        } else {
          return TextFormField(
            initialValue: answer ?? '',
            decoration: InputDecoration(
              hintText: 'Enter your country',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            onChanged: (val) => model.setValueInstant(q.id, val),
          );
        }

      case 'number':
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (val) => model.setValueInstant(q.id, val),
          decoration: InputDecoration(
            hintText: "Enter a number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

      case 'textarea':
        return TextField(
          maxLines: 3,
          onChanged: (val) => model.setValueInstant(q.id, val),
          decoration: InputDecoration(
            hintText: "Type your response...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

      default:
        return TextField(
          onChanged: (val) => model.setValueInstant(q.id, val),
          decoration: InputDecoration(
            hintText: "Your answer...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
    }
  }
}