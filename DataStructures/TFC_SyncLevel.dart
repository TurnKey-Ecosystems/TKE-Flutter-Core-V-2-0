enum TFC_SyncLevel { CLOUD, DEVICE, SESSION }

extension TFC_SyncLevelExtension on TFC_SyncLevel {
  String get attributesMapKey {
    switch(this) {
      case TFC_SyncLevel.CLOUD:
        return "cloudAttributes";
      case TFC_SyncLevel.DEVICE:
        return "deviceAttributes";
      case TFC_SyncLevel.SESSION:
        return "sessionAttributes";
    }
  }
}