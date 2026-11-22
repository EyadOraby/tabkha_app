import 'package:flash/flash.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';

class FlashWidgets {
  static void showNetworkErrorBar({
    required BuildContext context,
    FlashPosition position = FlashPosition.top,
    FlashBehavior behavior = FlashBehavior.fixed,
  }) {
    final size = MediaQuery.of(context).size;
    showFlash(
      context: context,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          // behavior: behavior,
          position: position,
          // boxShadows: kElevationToShadow[4],
          // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            controller: controller,
            indicatorColor: Colors.red,
            icon: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            content: Text(
              "You are not connected to any network",
              style: TextStyle(
                fontSize: size.width * 0.03,
              ),
            ),
            primaryAction: TextButton(
              onPressed: () {
                controller.dismiss();
              },
              child: const Text(
                "Dismiss",
              ),
            ),
          ),
        );
      },
    );
  }

  static void showWarningBar({
    required BuildContext context,
    required String message,
    FlashPosition position = FlashPosition.bottom,
    FlashBehavior behavior = FlashBehavior.floating,
  }) {
    final size = MediaQuery.of(context).size;
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          // margin: const EdgeInsets.only(bottom: 15),
          // constraints:
          //     BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          // borderRadius: BorderRadius.circular(6),
          controller: controller,
          // behavior: behavior,
          position: position,
          // backgroundColor: AppColors.warningOrange,
          // boxShadows: kElevationToShadow[4],
          // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            controller: controller,
            indicatorColor: AppColors.warningOrange,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            content: Text(
              message,
              style: TextStyle(
                color: AppColors.black,
                fontSize: size.width * 0.03,
              ),
            ),
          ),
        );
      },
    );
  }

  static void showSuccessBar({
    required BuildContext context,
    required String message,
    FlashPosition position = FlashPosition.top,
    FlashBehavior behavior = FlashBehavior.floating,
  }) {
    final size = MediaQuery.of(context).size;
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          // margin: const EdgeInsets.only(bottom: 15),
          // constraints:
          //     BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          // borderRadius: BorderRadius.circular(6),
          controller: controller,
          // behavior: behavior,
          position: position,
          // backgroundColor: AppColors.successGreen,
          // boxShadows: kElevationToShadow[4],
          // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            controller: controller,
            indicatorColor: AppColors.successGreen,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            content: Text(
              message,
              style: TextStyle(
                color: AppColors.black,
                fontSize: size.width * 0.03,
              ),
            ),
          ),
        );
      },
    );
  }

  static void showErrorBar({
    required BuildContext context,
    required String message,
    FlashPosition position = FlashPosition.bottom,
    FlashBehavior behavior = FlashBehavior.floating,
  }) {
    final size = MediaQuery.of(context).size;
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          // margin: const EdgeInsets.only(bottom: 15),
          // constraints:
          //     BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          // borderRadius: BorderRadius.circular(6),
          controller: controller,
          // behavior: behavior,
          position: position,
          // backgroundColor: AppColors.errorRed,
          // boxShadows: kElevationToShadow[4],
          // horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            controller: controller,
            indicatorColor: AppColors.errorRed,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            content: Text(
              message,
              style: TextStyle(
                color: AppColors.black,
                fontSize: size.width * 0.03,
              ),
            ),
          ),
        );
      },
    );
  }
}
