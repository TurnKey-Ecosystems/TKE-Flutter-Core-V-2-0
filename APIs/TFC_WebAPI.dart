import '../APIs/TFC_WebShareAPI.dart';
import '../APIs/TFC_WebStorageAPI.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_WebAPI extends TFC_PlatformAPI {
  TFC_WebStorageAPI deviceStorageAPI = TFC_WebStorageAPI();
  TFC_WebShareAPI shareAPI = TFC_WebShareAPI();
}
