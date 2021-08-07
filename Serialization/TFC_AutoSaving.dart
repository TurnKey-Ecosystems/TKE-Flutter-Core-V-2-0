import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../AppManagment/TFC_DiskController.dart';
import 'TFC_SerializingContainers.dart';

abstract class TFC_AutoSaving {
  static const String _FILE_EXTENSION = ".aso";
  final String _fileNameWithoutExtension;
  String get fileName {
    return _fileNameWithoutExtension + _FILE_EXTENSION;
  }

  TFC_AutoSaving(this._fileNameWithoutExtension);

  @protected
  void save(String encodedJson) {
    TFC_DiskController.writeFileAsString(fileName, encodedJson);
  }
}

class TFC_AutoSavingProperty<PropertyType> extends TFC_AutoSaving {
  late PropertyType _value;
  PropertyType get value {
    return _value;
  }

  set value(PropertyType newValue) {
    _value = newValue;
    _saveValue();
  }

  TFC_AutoSavingProperty({
    required PropertyType initialValue,
    required String fileNameWithoutExtension,
  }) : super(fileNameWithoutExtension) {
    _attemptLoadValue(initialValue);
  }

  void _saveValue() {
    save(jsonEncode(_value));
  }

  void _attemptLoadValue(PropertyType initialValue) {
    String? encodedJson = TFC_DiskController.readFileAsString(fileName);

    if (encodedJson != null) {
      _value = json.decode(encodedJson);
    } else {
      _value = initialValue;
    }
  }
}

class TFC_AutoSavingMap extends TFC_AutoSaving {
  late TFC_SerializingMap _map;
  TFC_SerializingMap get map {
    return _map;
  }

  TFC_AutoSavingMap(String fileNameWithoutExtension)
      : super(fileNameWithoutExtension) {
    _attemptLoadMap();
  }

  void _saveMap() {
    save(jsonEncode(_map));
  }

  void _attemptLoadMap() {
    String? encodedJson = TFC_DiskController.readFileAsString(fileName);

    if (encodedJson != null) {
      _map = TFC_SerializingMap.fromJson(_saveMap, json.decode(encodedJson));
    } else {
      _map = TFC_SerializingMap(_saveMap);
    }
  }

  void setFromJson(Map<String, dynamic> newMap) {
    _map = TFC_SerializingMap.fromJson(_saveMap, newMap);
    _saveMap();
  }

  Map<String, dynamic> getAsJson() {
    return _map.toJson();
  }
}

class TFC_AutoSavingSet extends TFC_AutoSaving {
  late TFC_SerializingSet _set;
  TFC_SerializingSet get serializingSet {
    return _set;
  }

  TFC_AutoSavingSet(String fileNameWithoutExtension)
      : super(fileNameWithoutExtension) {
    _attemptLoadList();
  }

  void _saveList() {
    save(jsonEncode(_set));
  }

  void _attemptLoadList() {
    String? encodedJson = TFC_DiskController.readFileAsString(fileName);

    if (encodedJson != null) {
      _set = TFC_SerializingSet.fromJson(
          onSet: _saveList, json: json.decode(encodedJson));
    } else {
      _set = TFC_SerializingSet(_saveList);
    }
  }

  void setFromJson(List newSet) {
    _set = TFC_SerializingSet.fromJson(onSet: _saveList, json: newSet);
    _saveList();
  }

  List<dynamic> getAsJson() {
    return _set.toJson();
  }
}
