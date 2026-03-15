import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LandingViewModel extends BaseViewModel {
  TextEditingController nameController = TextEditingController();
  bool obscure0 = true;

  void changeTempPasswordvisibility() {
    obscure0 = !obscure0;
    notifyListeners();
  }
}
