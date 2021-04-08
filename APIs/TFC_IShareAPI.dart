//import '../APIs/TFC_IDeviceStorageAPI.dart';

abstract class TFC_IShareAPI {
  void shareFile(String title, String body, List<String> fileNames);
}
