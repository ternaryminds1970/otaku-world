import 'package:flutter/material.dart';

import '../constants/dimensions_constants.dart';

class UIUtils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  static double getWidgetWidth({
    required double targetWidgetWidth,
    required double screenWidth,
  }) {
    double widthScaleFactor =
        targetWidgetWidth / DimensionsConstants.designedScreenWidth;

    return screenWidth * widthScaleFactor;
  }

  static double getWidgetHeight({
    required double targetWidgetHeight,
    required double screenHeight,
  }) {
    double heightScaleFactor =
        targetWidgetHeight / DimensionsConstants.designedScreenHeight;

    return screenHeight * heightScaleFactor;
  }
}
