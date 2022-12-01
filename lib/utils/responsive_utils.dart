import "dart:developer";

import "package:flutter/cupertino.dart";
import "package:responsive_framework/responsive_framework.dart";

bool isMobilePhone(BuildContext context) {
  final double shortestSide = MediaQuery.of(context).size.shortestSide;
  final bool useMobileLayout = shortestSide < 600;
  bool value = false;
  try {
    if (ResponsiveWrapper.of(context).isPhone == true ||
        ResponsiveWrapper.of(context).isMobile == true ||
        /*Platform.isIOS || Platform.isAndroid*/
        useMobileLayout == true) {
      value = true;
    } else {
      value = false;
    }
  } on Exception catch (e) {
    log("catch e : ${e.toString()}");
    value = false;
  }
  return value;
}
