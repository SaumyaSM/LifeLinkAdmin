import 'package:flutter/material.dart';
import 'package:m_toast/m_toast.dart';

class ToastService {
  static void displaySuccessMotionToast({
    required BuildContext context,
    required String description,
  }) {
    ShowMToast(context).successToast(
      message: description,
      alignment: Alignment.bottomCenter,
      duration: 2000,
    );
  }

  static void displayErrorMotionToast({
    required BuildContext context,
    required String description,
  }) {
    ShowMToast(context).errorToast(
      message: description,
      alignment: Alignment.bottomCenter,
      duration: 2000,
    );
  }
}
