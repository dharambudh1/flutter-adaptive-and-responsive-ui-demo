import "dart:async";
import "dart:developer";

import "package:after_layout/after_layout.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_web_navigation/model/users_info_model.dart";
import "package:flutter_web_navigation/singleton/color_utils.dart";
import "package:flutter_web_navigation/singleton/dio_singleton.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:flutter_web_navigation/utils/responsive_utils.dart";
import "package:flutter_web_navigation/utils/string_extension.dart";
import "package:responsive_framework/responsive_framework.dart";

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({
    required this.queryParams,
    super.key,
  });

  final Map<String, dynamic>? queryParams;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with AfterLayoutMixin<UserInfoScreen> {
  Future<UsersInfoModel>? _future;
  UsersInfoModel _usersInfoModel = UsersInfoModel();
  bool _shouldShowEditButton = false;
  String id = "";

  @override
  void initState() {
    super.initState();
    NavigationSingleton().router.addListener(routeListener);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> routeListener() async {
    final String user = NavigationSingleton.user;
    if (NavigationSingleton().router.location == "$user?id=$id") {
      await checkRedirectOrInitCall();
    }
    return Future<void>.value();
  }

  Future<void> checkRedirectOrInitCall() async {
    id = widget.queryParams?["id"] ?? "";
    id.isEmpty ? redirect() : await initCall();
    return Future<void>.value();
  }

  void redirect() {
    _future = Future<UsersInfoModel>.value(UsersInfoModel());
    if (NavigationSingleton().router.location != NavigationSingleton.home) {
      NavigationSingleton().router.pushNamed(NavigationSingleton.home);
    }
    return;
  }

  Future<UsersInfoModel> initCall() async {
    final UsersInfoModel response = await DioSingleton().viewUser(
      id: id,
    );
    _future = Future<UsersInfoModel>.value(response);
    _usersInfoModel = response;
    _shouldShowEditButton = true;
    setState(() {});
    return Future<UsersInfoModel>.value(response);
  }

  @override
  void dispose() {
    NavigationSingleton().router.removeListener(routeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Information",
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              100,
            ),
            onTap: () {
              if (NavigationSingleton().router.canPop()) {
                NavigationSingleton().router.pop();
              } else {
                NavigationSingleton().router.pushNamed(
                      NavigationSingleton.home,
                    );
              }
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible: _shouldShowEditButton,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  NavigationSingleton().router.pushNamed(
                        NavigationSingleton.update,
                        queryParams: <String, dynamic>{
                          "id": _usersInfoModel.id ?? "",
                        },
                        extra: _usersInfoModel,
                      );
                },
                borderRadius: const BorderRadius.all(
                  Radius.circular(100),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.edit,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<UsersInfoModel>(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<UsersInfoModel> snapshot,
          ) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.active:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                  );
                } else {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: isMobilePhone(context)
                          ? isMobile(snapshot)
                          : ResponsiveWrapper.of(context).isTablet
                              ? isTablet(snapshot)
                              : ResponsiveWrapper.of(context).isDesktop
                                  ? isDesktop(snapshot)
                                  : const SizedBox(),
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Widget profilePictureWidget(AsyncSnapshot<UsersInfoModel> snapshot) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
        border: Border.all(
          color: ColorUtils().borderColor(),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
          child: Image.network(
            snapshot.data?.picture ?? "",
            fit: BoxFit.fill,
            loadingBuilder: loadingBuilder,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return const Icon(
                Icons.error,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget isMobile(AsyncSnapshot<UsersInfoModel> snapshot) {
    return Column(
      children: <Widget>[
        profilePictureWidget(snapshot),
        const SizedBox(
          height: 20,
        ),
        basicInfoCard(snapshot),
        const SizedBox(
          height: 20,
        ),
        personalInfoCard(snapshot),
        const SizedBox(
          height: 20,
        ),
        contactInfoCard(snapshot),
        const SizedBox(
          height: 20,
        ),
        locationInfoCard(snapshot),
        const SizedBox(
          height: 20,
        ),
        registerUpdatedCard(snapshot),
      ],
    );
  }

  Widget isTablet(AsyncSnapshot<UsersInfoModel> snapshot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        profilePictureWidget(snapshot),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              basicInfoCard(snapshot),
              const SizedBox(
                height: 20,
              ),
              personalInfoCard(snapshot),
              const SizedBox(
                height: 20,
              ),
              contactInfoCard(snapshot),
              const SizedBox(
                height: 20,
              ),
              locationInfoCard(snapshot),
              const SizedBox(
                height: 20,
              ),
              registerUpdatedCard(snapshot),
            ],
          ),
        ),
      ],
    );
  }

  Widget isDesktop(AsyncSnapshot<UsersInfoModel> snapshot) {
    return Column(
      children: <Widget>[
        profilePictureWidget(snapshot),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: basicInfoCard(snapshot),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: personalInfoCard(snapshot),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: locationInfoCard(snapshot),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  contactInfoCard(snapshot),
                  const SizedBox(
                    height: 17,
                  ),
                  registerUpdatedCard(snapshot),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget basicInfoCard(AsyncSnapshot<UsersInfoModel> snapshot) {
    final String title = snapshot.data?.title?.caps() ?? "";
    final String firstName = snapshot.data?.firstName ?? "";
    final String lastName = snapshot.data?.lastName ?? "";
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "ID: ${snapshot.data?.id ?? ""}",
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(
                      100,
                    ),
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: snapshot.data?.id ?? "",
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "$title. $firstName $lastName",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget personalInfoCard(AsyncSnapshot<UsersInfoModel> snapshot) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Gender: ${snapshot.data?.gender?.caps() ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "DOB: ${snapshot.data?.dateOfBirth ?? ""}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget contactInfoCard(AsyncSnapshot<UsersInfoModel> snapshot) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Email address: ${snapshot.data?.email ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Phone: ${snapshot.data?.phone ?? ""}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget registerUpdatedCard(AsyncSnapshot<UsersInfoModel> snapshot) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Register date: ${snapshot.data?.registerDate ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Updated date: ${snapshot.data?.updatedDate ?? ""}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationInfoCard(AsyncSnapshot<UsersInfoModel> snapshot) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Street: ${snapshot.data?.location?.street ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "City: ${snapshot.data?.location?.city ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "State: ${snapshot.data?.location?.state ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Country: ${snapshot.data?.location?.country ?? ""}",
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Timezone: ${snapshot.data?.location?.timezone ?? ""}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    return (progress == null)
        ? child
        : Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    log("checkRedirectOrInitCall");
    await checkRedirectOrInitCall();
    return Future<void>.value();
  }
}
