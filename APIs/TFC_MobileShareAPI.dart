import 'dart:developer';
import 'package:flutter_share/flutter_share.dart';
import '../APIs/TFC_IDeviceStorageAPI.dart';
import '../APIs/TFC_IShareAPI.dart';
import '../APIs/TFC_MobileStorageAPI.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_MobileShareAPI extends TFC_IShareAPI {
  void shareFile(String title, String body, List<String> fileNames) {
    TFC_MobileStorageAPI storageAPI = TFC_PlatformAPI.platformAPI.deviceStorageAPI as TFC_MobileStorageAPI;
    List<String> filePaths = [];
    for (String fileName in fileNames) {
      String filePath = storageAPI.getAbsoluteFilePath(fileName, FileLocation.EXPORT);
      filePaths.add(filePath);
    }

    // TODO: Allow multiple files to be shared.
    FlutterShare.shareFile(
      title: title,
      chooserTitle: title,
      text: body,
      filePath: filePaths[0],
    ).catchError((e) {
      log(e.toString());
    });
  }
}