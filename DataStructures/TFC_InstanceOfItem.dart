import 'TFC_InstanceOfAttribute.dart';
import 'TFC_InstanceOfAttributeSet.dart';
import 'TFC_InstanceOfAttributeProperty.dart';

enum TFC_SyncLevel { CLOUD, DEVICE, SESSION }

extension TFC_SyncLevelExtension on TFC_SyncLevel {
  static Set<TFC_SyncLevel> get locallySavedSyncLevels {
    return Set.from([ TFC_SyncLevel.CLOUD, TFC_SyncLevel.DEVICE ]);
  }
  String get syncLevelAttributesKey {
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

class TFC_InstanceOfItem {
  // Attributes by SyncLevel
  Map<String, TFC_InstanceOfAttribute> _cloudSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> _deviceSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> _sessionSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> getAttributesAtSyncLevel(TFC_SyncLevel syncLevel) {
    switch(syncLevel) {
      case TFC_SyncLevel.CLOUD:
        return _cloudSyncedAttributes;
      case TFC_SyncLevel.DEVICE:
        return _deviceSyncedAttributes;
      case TFC_SyncLevel.SESSION:
        return _sessionSyncedAttributes;
    }
  }

  // Serialization API
  Map<String, Map<String, dynamic>> toJson() {
    Map<String, Map<String, dynamic>> json = Map();
    for (TFC_SyncLevel syncLevel in TFC_SyncLevelExtension.locallySavedSyncLevels) {
      Map<String, dynamic> attributesAsJson = Map();
      Map<String, TFC_InstanceOfAttribute> attributes = getAttributesAtSyncLevel(syncLevel);
      for (String attributeKey in attributes.keys) {
        attributesAsJson[attributeKey] = attributes[attributeKey]!.toJson();
      }
      json[syncLevel.syncLevelAttributesKey] = attributesAsJson;
    }
    return json;
  }
  TFC_InstanceOfItem.fromJson(dynamic json) {
    for (TFC_SyncLevel syncLevel in TFC_SyncLevelExtension.locallySavedSyncLevels) {
      Map<String, dynamic> attributes = json[syncLevel.syncLevelAttributesKey];
      for (String attributeKey in attributes.keys) {
        dynamic attributeValue = attributes[attributeKey];
        if (attributeValue is List) {
          _cloudSyncedAttributes[attributeKey] = TFC_InstanceOfAttributeSet.fromJson(attributeValue);
        } else {
          _cloudSyncedAttributes[attributeKey] = TFC_InstanceOfAttributeProperty.fromJson(attributeValue);
        }
      }
    }
  }
}