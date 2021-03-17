import 'dart:io';
import 'package:flutter/foundation.dart';
import '../APIs/TFC_IDeviceStorageAPI.dart';
import '../APIs/TFC_WebAPI.dart';
import 'TFC_IShareAPI.dart';
import 'TFC_MobileAPI.dart';

abstract class TFC_PlatformAPI {
  static TFC_PlatformAPI platformAPI;

  static Future<void> setupPlatformAPI() async {
    if (kIsWeb) {
      platformAPI = TFC_WebAPI();
    } else if (Platform.isIOS || Platform.isAndroid) {
      platformAPI = TFC_MobileAPI();
    }
    await platformAPI.setup();
  }

  TFC_IDeviceStorageAPI get deviceStorageAPI;
  TFC_IShareAPI get shareAPI;

  Future setup() async {
    await deviceStorageAPI.setup();
  }
}
