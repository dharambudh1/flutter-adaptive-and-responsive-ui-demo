import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";

class LoaderUtils {
  factory LoaderUtils() {
    return _singleton;
  }

  LoaderUtils._internal();

  static final LoaderUtils _singleton = LoaderUtils._internal();

  BuildContext context = NavigationSingleton().router.navigator!.context;

  Future<void> startLoading() async {
    return Future<void>.value(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: CupertinoActivityIndicator(),
              )
            ],
          );
        },
      ),
    );
  }

  void stopLoading() {
    Navigator.of(context).pop();
  }
}
