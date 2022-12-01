import "dart:async";
import "dart:developer";
import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_web_navigation/model/upload_cdn_model.dart";
import "package:flutter_web_navigation/model/users_delete_model.dart";
import "package:flutter_web_navigation/model/users_info_model.dart";
import "package:flutter_web_navigation/model/users_list_model.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:image_picker/image_picker.dart";
import "package:mime/mime.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";

class DioSingleton {
  factory DioSingleton() {
    return _singleton;
  }

  DioSingleton._internal() {
    dio.interceptors.add(
      PrettyDioLogger(requestHeader: true),
    );
  }

  static final DioSingleton _singleton = DioSingleton._internal();

  Dio dio = Dio();
  final String baseURL = "https://dummyapi.io/data/v1/";
  BuildContext context = NavigationSingleton().router.navigator!.context;

  /*Get List
  Get list of users sorted by registration date.
  - Pagination query params available.
  - Created query params available.

  GET
  /user
  Response: List(User Preview)*/

  Future<UsersListModel> getUsersList({
    required int page,
    required int limit,
  }) async {
    log("current page: $page - current limit: $limit");
    UsersListModel usersListModel = UsersListModel();
    try {
      final Response<dynamic> response = await dio
          .get(
            "${baseURL}user?page=$page&limit=$limit",
            options: commonHeaders(),
          )
          .onError(errorHandle);
      if (response.statusCode == 200) {
        usersListModel = UsersListModel.fromJson(response.data);
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UsersListModel>.value(usersListModel);
  }

  /*--------------------------------------------------------------------------*/

  /*Get User by id
  Get user full data by user id

  GET
  /user/:id
  Response: User*/

  Future<UsersInfoModel> viewUser({
    required String id,
  }) async {
    UsersInfoModel usersInfoModel = UsersInfoModel();
    try {
      final Response<dynamic> response = await dio
          .get(
            "${baseURL}user/$id",
            options: commonHeaders(),
          )
          .onError(errorHandle);
      if (response.statusCode == 200) {
        usersInfoModel = UsersInfoModel.fromJson(response.data);
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UsersInfoModel>.value(usersInfoModel);
  }

  /*--------------------------------------------------------------------------*/

  /*Create User
  Create new user, return created user data.
  Body: User Create (firstName, lastName, email are required)

  POST
  /user/create
  Response: User*/

  Future<UsersInfoModel> createNewUser({
    required UsersInfoModel usersInfoProvidedModel,
  }) async {
    UsersInfoModel usersInfoResponseModel = UsersInfoModel();
    try {
      final Response<dynamic> response = await dio
          .post(
            "${baseURL}user/create",
            options: commonHeaders(),
            data: usersInfoProvidedModel.toJson(),
          )
          .onError(errorHandle);
      if (response.statusCode == 200) {
        usersInfoResponseModel = UsersInfoModel.fromJson(response.data);
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UsersInfoModel>.value(usersInfoResponseModel);
  }

  /*--------------------------------------------------------------------------*/

  /*Delete User
  Delete user by id, return id of deleted user

  DELETE
  /user/:id
  Response: string*/

  Future<UsersDeleteModel> deleteUser({
    required String id,
  }) async {
    UsersDeleteModel usersDeleteModel = UsersDeleteModel();
    try {
      final Response<dynamic> response = await dio
          .delete(
            "${baseURL}user/$id",
            options: commonHeaders(),
          )
          .onError(errorHandle);
      if (response.statusCode == 200) {
        usersDeleteModel = UsersDeleteModel.fromJson(response.data);
        showSnackBar(
          message: "User deleted successfully",
        );
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UsersDeleteModel>.value(usersDeleteModel);
  }

  /*--------------------------------------------------------------------------*/

  /*POST https://api.upload.io/v2/accounts/{accountId}/uploads/binary

  curl --data-binary @sample-image.jpg \
  -H "Content-Type: image/jpeg" \
  -H "Authorization: Bearer YOUR_PUBLIC_API_KEY" \
  -X POST "https://api.upload.io/v2/accounts/{accountId}/uploads/binary"*/

  Future<UploadCDNModel> uploadImage({
    required File file,
    required XFile webPickedFile,
  }) async {
    UploadCDNModel uploadCDNModel = UploadCDNModel();
    try {
      final Uint8List image = kIsWeb
          ? await webPickedFile.readAsBytes()
          : await File(file.path).readAsBytes();

      log("mimeType: ${webPickedFile.mimeType ?? "Unknown mimeType"}");

      final Response<dynamic> response = await dio.post(
        "https://api.upload.io/v2/accounts/FW25avn/uploads/binary",
        options: Options(
          headers: <String, dynamic>{
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Authorization": "Bearer public_FW25avn8ayNvn1axXfATmG6TJMvx",
            "Content-Type": kIsWeb
                ? webPickedFile.mimeType ?? ""
                : lookupMimeType(file.path),
            "Content-Length": image.length,
          },
        ),
        onSendProgress: (int sent, int total) {
          log("progress: ${(sent / total * 100).toStringAsFixed(0)}% ($sent/$total)");
        },
        data: kIsWeb ? webPickedFile.openRead() : file.openRead(),
      ).onError(errorHandle);
      if (response.statusCode == 200) {
        uploadCDNModel = UploadCDNModel.fromJson(response.data);
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UploadCDNModel>.value(uploadCDNModel);
  }

  /*--------------------------------------------------------------------------*/

  /*Update User
  Update user by id, return updated User data
  Body: User data, only fields that should be updated.
  (email is forbidden to update)

  PUT
  /user/:id
  Response: User*/

  Future<UsersInfoModel> updateExistingUser({
    required UsersInfoModel usersInfoProvidedModel,
  }) async {
    UsersInfoModel usersInfoResponseModel = UsersInfoModel();
    try {
      final Response<dynamic> response = await dio
          .put(
            "${baseURL}user/${usersInfoProvidedModel.id}",
            options: commonHeaders(),
            data: usersInfoProvidedModel.toJson(),
          )
          .onError(errorHandle);
      if (response.statusCode == 200) {
        usersInfoResponseModel = UsersInfoModel.fromJson(response.data);
      } else {
        log("response.statusCode : ${response.statusCode}");
      }
    } on Exception catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future<UsersInfoModel>.value(usersInfoResponseModel);
  }

  /*--------------------------------------------------------------------------*/

  Options commonHeaders() {
    return Options(
      headers: <String, dynamic>{
        "app-id": "633d45b08eba32af5e7b4ba1",
        "Content-Type": "application/json",
      },
    );
  }

  /*--------------------------------------------------------------------------*/

  Future<Response<DioError>> errorHandle(
    DioError error,
    StackTrace stackTrace,
  ) {
    showSnackBar(message: error.response.toString());
    return Future<Response<DioError>>.error(error, stackTrace);
  }

  /*--------------------------------------------------------------------------*/

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required String message,
  }) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(
        seconds: 8,
      ),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /*--------------------------------------------------------------------------*/
}
