// lib/screens/settings/settings_view.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import '../otp/otp_phone_input.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(SettingsViewModel model) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await model.setProfileImage(File(picked.path), context);
    }
  }

  void _showEditSheet(
    BuildContext context,
    SettingsViewModel model,
    String field,
  ) {
    late TextEditingController controller;

    switch (field) {
      case "name":
        controller = TextEditingController(text: model.name);
        break;
      case "phone":
        controller = TextEditingController(text: model.phone);
        break;
      case "email":
        controller = TextEditingController(text: model.email);
        break;
      case "language":
        controller = TextEditingController(text: model.language);
        break;
      default:
        controller = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
      ),
      builder: (context) {
        Widget inputField;

        if (field == "language") {
          inputField = DropdownButtonFormField<String>(
            value: model.language,
            items: [
              DropdownMenuItem(value: "English", child: Text("english".tr())),
              DropdownMenuItem(value: "French", child: Text("french".tr())),
            ],
            onChanged: (val) {
              if (val != null) {
                final appProvider = context.read<AppProvider>();
                appProvider.setLanguage(val);
                controller.text = val;
                
                // Update locale
                if (val == "French") {
                  context.setLocale(const Locale('fr'));
                } else {
                  context.setLocale(const Locale('en'));
                }
                
                setState(() {});
              }
            },
            decoration: InputDecoration(labelText: "language".tr()),
          );
        } else if (field == "phone") {
          inputField = IntlPhoneField(
            initialValue: model.phone,
            onChanged: (phone) => controller.text = phone.completeNumber,
          );
        } else {
          inputField = TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field[0].toUpperCase() + field.substring(1),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "update".tr() + " " + field.tr(),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
              ),
              SizedBox(height: 15.h),
              inputField,
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  switch (field) {
                    case "name":
                      model.name = controller.text;
                      break;
                    case "phone":
                      model.phone = controller.text;
                      break;
                    case "email":
                      model.email = controller.text;
                      break;
                    case "language":
                      model.language = controller.text;
                      break;
                  }
                  setState(() {});
                  
                  if (field != 'language') {
                    model.callUpdateProfile(context);
                  }
                  
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                ),
                child: Text(
                  "done".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String field,
    required SettingsViewModel model,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
      margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppGreen, size: 20.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ),
          if (field != 'country')
            SizedBox(
              height: 37.h,
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.grey, size: 18.sp),
                onPressed: () => _showEditSheet(context, model, field),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('suretologout'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final appProvider = context.read<AppProvider>();
      await appProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PhoneInputView()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
      viewModelBuilder: () => SettingsViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.loadUserData(context);
      },
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'profileinfo'.tr(),
                    style: const TextStyle(color: AppGreen),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 4,
                  actions: [
                    TextButton(
                      onPressed: () => _logout(context),
                      child: Text('logout'.tr()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppGreen),
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    SizedBox(height: 15.h),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundImage: appProvider.profileImage != null
                              ? FileImage(File(appProvider.profileImage!))
                              : const AssetImage("assets/images/usericon.png")
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 5.h,
                          right: 5.w,
                          child: InkWell(
                            onTap: () => _pickImage(model),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildProfileItem(
                            icon: Icons.person,
                            value: appProvider.name ?? '',
                            field: "name",
                            model: model,
                            context: context,
                          ),
                          _buildProfileItem(
                            icon: Icons.phone,
                            value: appProvider.phone ?? '',
                            field: "phone",
                            model: model,
                            context: context,
                          ),
                          _buildProfileItem(
                            icon: Icons.email,
                            value: appProvider.email ?? '',
                            field: "email",
                            model: model,
                            context: context,
                          ),
                          _buildProfileItem(
                            icon: Icons.language,
                            value: appProvider.language ?? 'English',
                            field: "language",
                            model: model,
                            context: context,
                          ),
                          _buildProfileItem(
                            icon: Icons.flag,
                            value: appProvider.country ?? 'Ghana',
                            field: "country",
                            model: model,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
            );
          },
        );
      },
    );
  }
}