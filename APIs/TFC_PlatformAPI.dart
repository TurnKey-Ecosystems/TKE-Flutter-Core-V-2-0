import '../APIs/TFC_IDeviceStorageAPI.dart';
import 'TFC_IShareAPI.dart';
import 'TFC_MobileAPI.dart' if (dart.library.html) 'TFC_WebAPI.dart';

abstract class TFC_PlatformAPI {
  static TFC_PlatformAPI platformAPI;

  static Future<void> setupPlatformAPI() async {
    platformAPI = TFC_APIForThisPlatform();
    await platformAPI.setup();
  }

  TFC_IDeviceStorageAPI get deviceStorageAPI;
  TFC_IShareAPI get shareAPI;

  Future setup() async {
    await deviceStorageAPI.setup();
  }

  // Web Exclusive stubs
  void setWebBackgroundColor(String hexColor) async {}

  void hideHTMLSplashScreen() async {}

  TFC_BrowserAndOSTestResults testBrowserAndOS() {
    return null;
  }

  void copyTextToClipBoard(String textToCopy) {}

  void showInstallPrompt() {}

  bool getIsInstalled() {
    return true;
  }

  String getCurrentURL() {
    return null;
  }

  String getPasscodeFromURL() {
    return "";
  }
}

enum TFC_OperatingSystem { ANDROID, IOS, UNKNOWN }
enum TFC_Browser { CHROME, SAFARI, UNKNOWN }

class TFC_BrowserAndOSTestResults {
  TFC_OperatingSystem os;
  TFC_Browser browser;
  bool isCorrectBrowserForOS;
}
