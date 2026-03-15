// lib/screens/settings/settings_viewmodel.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/storage_helper.dart';
import '../../appcore/helpers/snackbar_helper.dart';

class SettingsViewModel extends BaseViewModel {



   AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }
  String _id = "";
  String _name = "";
  String _rank = "";
  String _phone = "";
  String _email = "";
  String _language = "English";
  String _country = "";

  String get id => _id;
  String get name => _name;
  String get rank => _rank;
  String get phone => _phone;
  String get email => _email;
  String get language => _language;
  String get country => _country;

  set id(String value) {
    _id = value;
    notifyListeners();
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  set rank(String value) {
    _rank = value;
    notifyListeners();
  }

  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set language(String value) {
    _language = value;
    notifyListeners();
  }

  set country(String value) {
    _country = value;
    notifyListeners();
  }

  void loadUserData(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    _name = appProvider.name ?? '';
    _phone = appProvider.phone ?? '';
    _email = appProvider.email ?? '';
    _language = appProvider.language ?? 'English';
    _country = appProvider.country ?? 'Ghana';
    notifyListeners();
  }

  Future<void> setProfileImage(File? file, BuildContext context) async {
    if (file != null) {
      await StorageHelper.updateUserField('profileImage', file.path);
      
      final appProvider = context.read<AppProvider>();
      await appProvider.setProfileImage(file.path);

      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'profile_updated'.tr(),
        );
      }
    }
  }

  Future<void> callUpdateProfile(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    
    await appProvider.updateProfile(
      context: context,
      name: _name,
      email: _email,
      phone: _phone,
    );
  }
}