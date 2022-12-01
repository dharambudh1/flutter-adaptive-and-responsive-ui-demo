import "dart:async";

import "package:after_layout/after_layout.dart";
import "package:dynamic_height_grid_view/dynamic_height_grid_view.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_web_navigation/model/users_list_model.dart";
import "package:flutter_web_navigation/singleton/dio_singleton.dart";
import "package:flutter_web_navigation/singleton/image_singleton.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:flutter_web_navigation/utils/responsive_utils.dart";
import "package:flutter_web_navigation/utils/string_extension.dart";
import "package:responsive_framework/responsive_framework.dart";

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with AfterLayoutMixin<UserListScreen> {
  late final ScrollController _controller = ScrollController();
  int _page = 0;
  final int _limit = 30;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List<Data> _usersList = <Data>[];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    NavigationSingleton().router.addListener(routeListener);
    _controller.addListener(getUsersListLoadMore);
  }

  Future<void> routeListener() async {
    if (NavigationSingleton().router.location == NavigationSingleton.home) {
      await refresh();
    }
    return Future<void>.value();
  }

  Future<void> refresh() async {
    _page = 0;
    _hasNextPage = true;
    _isFirstLoadRunning = false;
    _isLoadMoreRunning = false;
    _usersList.clear();
    await _getUsersListFirstTime();
    return Future<void>.value();
  }

  @override
  void dispose() {
    NavigationSingleton().router.removeListener(routeListener);
    _controller.removeListener(getUsersListLoadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("List"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                NavigationSingleton().router.pushNamed(
                      NavigationSingleton.create,
                    );
              },
              borderRadius: const BorderRadius.all(
                Radius.circular(100),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isFirstLoadRunning
            ? const Padding(
                padding: EdgeInsets.all(18.0),
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
            : Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: refresh,
                        child: isMobilePhone(context)
                            ? ListView.builder(
                                controller: _controller,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount: _usersList.length,
                                itemBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  final Data data = _usersList[index];
                                  final String title = data.title?.caps() ?? "";
                                  final String firstName = data.firstName ?? "";
                                  final String lastName = data.lastName ?? "";
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    child: Dismissible(
                                      key: UniqueKey(),
                                      onDismissed: (
                                        DismissDirection direction,
                                      ) async {
                                        _usersList.remove(data);
                                        await deleteUserFromList(data.id ?? "");
                                        return Future<void>.value();
                                      },
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          onTap: () {
                                            NavigationSingleton()
                                                .router
                                                .pushNamed(
                                              NavigationSingleton.user,
                                              queryParams: <String, dynamic>{
                                                "id": data.id ?? "",
                                              },
                                            );
                                          },
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child:
                                                  ImageSingleton().imageWidget(
                                                data.picture ?? "",
                                              ),
                                            ),
                                          ),
                                          trailing: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text: data.id ?? "",
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.copy,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "$title. $firstName $lastName",
                                          ),
                                          subtitle: Text(
                                            "ID: ${data.id ?? ""}",
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : DynamicHeightGridView(
                                controller: _controller,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount: _usersList.length,
                                crossAxisCount:
                                    ResponsiveWrapper.of(context).isTablet ==
                                            true
                                        ? 2
                                        : 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                builder: (BuildContext ctx, int index) {
                                  final Data data = _usersList[index];
                                  final String title = data.title?.caps() ?? "";
                                  final String firstName = data.firstName ?? "";
                                  final String lastName = data.lastName ?? "";
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    child: Dismissible(
                                      key: UniqueKey(),
                                      onDismissed: (
                                        DismissDirection direction,
                                      ) async {
                                        _usersList.remove(data);
                                        await deleteUserFromList(data.id ?? "");
                                        return Future<void>.value();
                                      },
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: ListTile(
                                          onTap: () {
                                            NavigationSingleton()
                                                .router
                                                .pushNamed(
                                              NavigationSingleton.user,
                                              queryParams: <String, dynamic>{
                                                "id": data.id ?? "",
                                              },
                                            );
                                          },
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child:
                                                  ImageSingleton().imageWidget(
                                                data.picture ?? "",
                                              ),
                                            ),
                                          ),
                                          trailing: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text: data.id ?? "",
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.copy,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "$title. $firstName $lastName",
                                          ),
                                          subtitle: Text(
                                            "ID: ${data.id ?? ""}",
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    if (_isLoadMoreRunning == true)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: CupertinoActivityIndicator(),
                      ),
                    if (_hasNextPage == false)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text("You have fetched all of the content"),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _getUsersListFirstTime() async {
    _isFirstLoadRunning = true;
    setState(() {});
    final UsersListModel response = await DioSingleton().getUsersList(
      page: _page,
      limit: _limit,
    );
    _usersList = response.data ?? <Data>[];
    _isFirstLoadRunning = false;
    setState(() {});
    return Future<void>.value();
  }

  Future<void> getUsersListLoadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      _isLoadMoreRunning = true;
      setState(() {});
      _page += 1;
      final UsersListModel response = await DioSingleton().getUsersList(
        page: _page,
        limit: _limit,
      );
      final List<Data> fetchedPosts = response.data ?? <Data>[];
      if (fetchedPosts.isNotEmpty) {
        _usersList.addAll(fetchedPosts);
        setState(() {});
      } else {
        _hasNextPage = false;
        setState(() {});
      }
      _isLoadMoreRunning = false;
      setState(() {});
    }
    return Future<void>.value();
  }

  Future<void> deleteUserFromList(String id) async {
    await DioSingleton().deleteUser(
      id: id,
    );
    setState(() {});
    return Future<void>.value();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await _getUsersListFirstTime();
    return Future<void>.value();
  }
}
