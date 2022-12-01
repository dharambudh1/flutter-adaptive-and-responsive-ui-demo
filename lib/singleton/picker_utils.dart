import "dart:developer";
import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:image_cropper/image_cropper.dart";
import "package:permission_handler/permission_handler.dart";
import "package:wechat_assets_picker/wechat_assets_picker.dart";
import "package:wechat_camera_picker/wechat_camera_picker.dart";

enum PickerType { camera, asset }

class PickerUtils {
  factory PickerUtils() {
    return _singleton;
  }

  PickerUtils._internal();

  static final PickerUtils _singleton = PickerUtils._internal();
  BuildContext context = NavigationSingleton().router.navigator!.context;

  Future<Map<Permission, PermissionStatus>> checkPermission({
    required PickerType type,
  }) async {
    final Map<Permission, PermissionStatus> temp =
        <Permission, PermissionStatus>{};
    PermissionStatus status = PermissionStatus.denied;
    final bool cameraIsGranted = await Permission.camera.isGranted;
    final bool storageIsGranted = await Permission.storage.isGranted;
    final bool photosIsGranted = await Permission.photos.isGranted;
    final bool photosIsLimited = await Permission.photos.isLimited;
    switch (type) {
      case PickerType.camera:
        if (!cameraIsGranted) {
          status = await Permission.camera.request();
          temp.addAll(
            <Permission, PermissionStatus>{Permission.camera: status},
          );
        }
        if (!storageIsGranted) {
          status = await Permission.storage.request();
          temp.addAll(
            <Permission, PermissionStatus>{Permission.storage: status},
          );
        }
        if (Platform.isIOS) {
          if (!photosIsGranted || !photosIsLimited) {
            status = await Permission.photos.request();
            temp.addAll(
              <Permission, PermissionStatus>{Permission.photos: status},
            );
          }
        }
        break;
      case PickerType.asset:
        if (!storageIsGranted) {
          status = await Permission.storage.request();
          temp.addAll(
            <Permission, PermissionStatus>{Permission.storage: status},
          );
        }
        if (Platform.isIOS) {
          if (!photosIsGranted || !photosIsLimited) {
            status = await Permission.photos.request();
            temp.addAll(
              <Permission, PermissionStatus>{Permission.photos: status},
            );
          }
        }
        break;
    }
    return Future<Map<Permission, PermissionStatus>>.value(temp);
  }

  Future<List<File>> checkPermissionAndPick({
    required int maxFileSize,
    required bool shouldFollowMaxSizeInCamera,
    required bool shouldFollowMaxSizeInAssets,
    required PickerType type,
    required List<File> filePaths,
    required int maxLength,
    required Function(List<File>) discardedFiles,
    required Function(Map<Permission, PermissionStatus>) permDeniedList,
  }) async {
    List<File> tempList = <File>[];
    final ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
    final Map<Permission, PermissionStatus> status =
        await checkPermission(type: type);
    final bool isGranted = status.containsValue(PermissionStatus.granted);
    final bool isLimited = status.containsValue(PermissionStatus.limited);
    final bool hasAccess = isGranted || isLimited;
    if (hasAccess || status.isEmpty) {
      if (filePaths.length < maxLength) {
        switch (type) {
          case PickerType.camera:
            tempList = await pickFromCamera(
              discardedFiles: discardedFiles,
              maxFileSize: maxFileSize,
              shouldFollowMaxSizeInCamera: shouldFollowMaxSizeInCamera,
            );
            break;
          case PickerType.asset:
            tempList = await pickFromAssets(
              filePaths: filePaths,
              maxLength: maxLength,
              discardedFiles: discardedFiles,
              maxFileSize: maxFileSize,
              shouldFollowMaxSizeInAssets: shouldFollowMaxSizeInAssets,
            );
            break;
        }
      } else {
        messengerState.showSnackBar(
          const SnackBar(
            content: Text(
              "You've reached the maximum assets upload limit",
            ),
          ),
        );
      }
    } else {
      permDeniedList(status);
      messengerState.showSnackBar(
        SnackBar(
          content: Text(
            status.toString(),
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    return Future<List<File>>.value(tempList);
  }

  Future<List<File>> pickFromCamera({
    required Function(List<File>) discardedFiles,
    required int maxFileSize,
    required bool shouldFollowMaxSizeInCamera,
  }) async {
    final AssetEntity imageFile = await fetchImagesFromCamera();
    final List<List<AssetEntity>> separationList = separationFunction(
      isList: false,
      assetEntity: imageFile,
      listOfAssetEntity: <AssetEntity>[],
    );
    final List<AssetEntity> imagesList = separationList[0];
    final List<AssetEntity> videosList = separationList[1];
    final List<CroppedFile> croppedPaths = await assetImgToCroppedFiles(
      assetFiles: imagesList,
    );
    final List<File> tempFilePaths = await croppedFilesToFiles(
      croppedPaths: croppedPaths,
    );
    final List<File> temp = await assetVideosToFiles(assetFiles: videosList);
    tempFilePaths.addAll(temp);
    final List<File> finalList = shouldFollowDiscard(
      tempFilePaths,
      (List<File> list) {
        discardedFiles(list);
      },
      maxFileSize,
      shouldFollow: shouldFollowMaxSizeInCamera,
    );
    return Future<List<File>>.value(finalList);
  }

  Future<List<File>> pickFromAssets({
    required List<File> filePaths,
    required int maxLength,
    required Function(List<File>) discardedFiles,
    required int maxFileSize,
    required bool shouldFollowMaxSizeInAssets,
  }) async {
    final List<AssetEntity> assetFiles = await fetchImagesAssets(
      filePaths: filePaths,
      maxLength: maxLength,
    );
    final List<List<AssetEntity>> separationList = separationFunction(
      isList: true,
      assetEntity: const AssetEntity(
        id: "0",
        typeInt: 0,
        width: 0,
        height: 0,
      ),
      listOfAssetEntity: assetFiles,
    );
    final List<AssetEntity> imagesList = separationList[0];
    final List<AssetEntity> videosList = separationList[1];
    final List<CroppedFile> croppedPaths = await assetImgToCroppedFiles(
      assetFiles: imagesList,
    );
    final List<File> tempFilePaths = await croppedFilesToFiles(
      croppedPaths: croppedPaths,
    );
    final List<File> temp = await assetVideosToFiles(assetFiles: videosList);
    tempFilePaths.addAll(temp);
    final List<File> finalList = shouldFollowDiscard(
      tempFilePaths,
      (List<File> list) {
        discardedFiles(list);
      },
      maxFileSize,
      shouldFollow: shouldFollowMaxSizeInAssets,
    );
    return Future<List<File>>.value(finalList);
  }

  List<List<AssetEntity>> separationFunction({
    required bool isList,
    required AssetEntity assetEntity,
    required List<AssetEntity> listOfAssetEntity,
  }) {
    final List<AssetEntity> imagesList = <AssetEntity>[];
    final List<AssetEntity> videosList = <AssetEntity>[];
    if (isList == false) {
      if (assetEntity.type == AssetType.image) {
        imagesList.add(assetEntity);
      } else if (assetEntity.type == AssetType.video) {
        videosList.add(assetEntity);
      } else {
        log("Error in item is AssetEntity");
      }
    } else if (isList == true) {
      for (final AssetEntity element in listOfAssetEntity) {
        if (element.type == AssetType.image) {
          imagesList.add(element);
        } else if (element.type == AssetType.video) {
          videosList.add(element);
        } else {
          log("Error in item is List<AssetEntity>");
        }
      }
    } else {
      log("Error in separationFunction item");
    }
    return <List<AssetEntity>>[imagesList, videosList];
  }

  Future<AssetEntity> fetchImagesFromCamera() async {
    AssetEntity tempAssetEntity = const AssetEntity(
      id: "0",
      typeInt: 0,
      width: 0,
      height: 0,
    );
    try {
      tempAssetEntity = await CameraPicker.pickFromCamera(
            context,
            locale: Localizations.localeOf(context),
            pickerConfig: CameraPickerConfig(
              textDelegate: const EnglishCameraPickerTextDelegate(),
              imageFormatGroup: ImageFormatGroup.jpeg,
              shouldDeletePreviewFile: true,
              onError: (Object object, StackTrace? stackTrace) {
                log("onError object : ${object.toString()}");
                log("onError stackTrace : ${stackTrace.toString()}");
              },
            ),
          ) ??
          const AssetEntity(
            id: "0",
            typeInt: 0,
            width: 0,
            height: 0,
          );
    } on Exception catch (e) {
      log("Unable to fetch image from camera : ${e.toString()}");
    }
    return Future<AssetEntity>.value(tempAssetEntity);
  }

  Future<List<AssetEntity>> fetchImagesAssets({
    required List<File> filePaths,
    required int maxLength,
  }) async {
    List<AssetEntity> tempAssetEntity = <AssetEntity>[];
    try {
      tempAssetEntity = await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              maxAssets: maxLength - filePaths.length,
              textDelegate: const EnglishAssetPickerTextDelegate(),
              requestType: RequestType.image,
              limitedPermissionOverlayPredicate: (PermissionState state) {
                log("limitedPermissionOverlayPredicate : $state");
                return false;
              },
              loadingIndicatorBuilder:
                  (BuildContext context, bool isAssetsEmpty) {
                return isAssetsEmpty
                    ? const Text(
                        "Assets are unavailable, try adding assets.",
                      )
                    : Platform.isIOS
                        ? const CupertinoActivityIndicator()
                        : Platform.isAndroid
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Assets are loading...",
                              );
              },
            ),
          ) ??
          <AssetEntity>[];
    } on Exception catch (e) {
      log("Unable to fetch image from asset : ${e.toString()}");
    }
    return Future<List<AssetEntity>>.value(tempAssetEntity);
  }

  Future<List<CroppedFile>> assetImgToCroppedFiles({
    required List<AssetEntity> assetFiles,
  }) async {
    final List<CroppedFile> tempCroppedList = <CroppedFile>[];
    await Future.forEach(
      assetFiles,
      (AssetEntity item) async {
        final File normalFile = await item.file ?? File("");
        final CroppedFile croppedFile = await cropImage(file: normalFile);
        tempCroppedList.add(croppedFile);
      },
    );
    return Future<List<CroppedFile>>.value(tempCroppedList);
  }

  Future<CroppedFile> cropImage({
    required File file,
  }) async {
    final CroppedFile tempCroppedFile = await ImageCropper.platform.cropImage(
          sourcePath: file.path,
          cropStyle: CropStyle.circle,
          compressFormat: ImageCompressFormat.png,
          compressQuality: 100,
          uiSettings: <PlatformUiSettings>[
            WebUiSettings(
              context: NavigationSingleton().router.navigator!.context,
              boundary: CroppieBoundary(
                height: (MediaQuery.of(
                          NavigationSingleton().router.navigator!.context,
                        ).size.height *
                        0.60)
                    .toInt(),
                width: (MediaQuery.of(
                          NavigationSingleton().router.navigator!.context,
                        ).size.width *
                        0.60)
                    .toInt(),
              ),
            ),
          ],
        ) ??
        CroppedFile("");
    return Future<CroppedFile>.value(tempCroppedFile);
  }

  Future<List<File>> croppedFilesToFiles({
    required List<CroppedFile> croppedPaths,
  }) async {
    final List<File> tempFileList = <File>[];
    for (final CroppedFile element in croppedPaths) {
      tempFileList.add(File(element.path));
    }
    return Future<List<File>>.value(tempFileList);
  }

  Future<List<File>> assetVideosToFiles({
    required List<AssetEntity> assetFiles,
  }) async {
    final List<File> temp = <File>[];
    await Future.forEach(
      assetFiles,
      (AssetEntity item) async {
        final File normalFile = await item.file ?? File("");
        temp.add(normalFile);
      },
    );
    return Future<List<File>>.value(temp);
  }

  List<List<File>> discardFunction(
    List<File> tempFilePaths,
    int maxFileSize,
  ) {
    final List<File> keepFilesList = <File>[];
    final List<File> discardedFilesList = <File>[];
    for (final File element in tempFilePaths) {
      element.lengthSync() < maxFileSize
          ? keepFilesList.add(element)
          : discardedFilesList.add(element);
    }
    return <List<File>>[keepFilesList, discardedFilesList];
  }

  List<File> shouldFollowDiscard(
    List<File> tempFilePaths,
    Function(List<File>) discardedFiles,
    int maxFileSize, {
    required bool shouldFollow,
  }) {
    tempFilePaths.removeWhere((File element) => element.path == "");
    if (shouldFollow) {
      List<File> keepFilesList = <File>[];
      List<File> discardedFilesList = <File>[];
      final List<List<File>> keepAndDiscardList = discardFunction(
        tempFilePaths,
        maxFileSize,
      );
      keepFilesList = keepAndDiscardList[0];
      discardedFilesList = keepAndDiscardList[1];
      discardedFiles(discardedFilesList);
      return keepFilesList;
    } else {
      return tempFilePaths;
    }
  }

  Future<XFile> webImageCrop(File file) async {
    final CroppedFile croppedFile = await cropImage(file: file);
    final XFile xFile = XFile(
      XFile(croppedFile.path).path,
      name: XFile(croppedFile.path).name,
      bytes: await XFile(croppedFile.path).readAsBytes(),
      length: await XFile(croppedFile.path).length(),
      mimeType: XFile(croppedFile.path).mimeType ?? "image/png",
      lastModified: await XFile(croppedFile.path).lastModified(),
    );
    return Future<XFile>.value(xFile);
  }
}
