import "package:flutter/material.dart";
import "package:flutter_web_navigation/screen/users_create_screen.dart";
import "package:flutter_web_navigation/screen/users_info_screen.dart";
import "package:flutter_web_navigation/screen/users_list_screen.dart";
import "package:go_router/go_router.dart";

class NavigationSingleton {
  factory NavigationSingleton() {
    return _singleton;
  }

  NavigationSingleton._internal();

  static final NavigationSingleton _singleton = NavigationSingleton._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static String home = "/";
  static String user = "/user";
  static String create = "/create";
  static String update = "/update";

  GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: <GoRoute>[
      GoRoute(
        path: home,
        name: home,
        builder: (BuildContext context, GoRouterState state) {
          return const UserListScreen();
        },
      ),
      GoRoute(
        name: user,
        path: user,
        builder: (BuildContext context, GoRouterState state) {
          return UserInfoScreen(
            queryParams: state.queryParams,
          );
        },
      ),
      GoRoute(
        name: create,
        path: create,
        builder: (BuildContext context, GoRouterState state) {
          return UserCreateScreen(
            queryParams: state.queryParams,
            extra: state.extra,
          );
        },
      ),
      GoRoute(
        name: update,
        path: update,
        builder: (BuildContext context, GoRouterState state) {
          return UserCreateScreen(
            queryParams: state.queryParams,
            extra: state.extra,
          );
        },
      ),
    ],
  );
}
