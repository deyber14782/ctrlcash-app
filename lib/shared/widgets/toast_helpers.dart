import 'package:flutter/material.dart';
import 'app_toast.dart';

void showSuccess(BuildContext context, String title, [String? subtitle]) {
  AppToast.show(context, title: title, subtitle: subtitle, type: ToastType.success);
}

void showError(BuildContext context, String title, [String? subtitle]) {
  AppToast.show(context, title: title, subtitle: subtitle, type: ToastType.error);
}

void showInfo(BuildContext context, String title, [String? subtitle]) {
  AppToast.show(context, title: title, subtitle: subtitle, type: ToastType.info);
}