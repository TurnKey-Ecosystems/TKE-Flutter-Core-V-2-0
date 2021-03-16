import '../APIs/TFC_MobileShareAPI.dart';
import '../APIs/TFC_MobileStorageAPI.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_MobileAPI extends TFC_PlatformAPI {
  TFC_MobileStorageAPI deviceStorageAPI = TFC_MobileStorageAPI();
  TFC_MobileShareAPI shareAPI = TFC_MobileShareAPI();
}