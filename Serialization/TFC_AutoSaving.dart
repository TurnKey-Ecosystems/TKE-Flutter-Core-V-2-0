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



/** An auto-saving Map */
class TFC_AutoSavingMap<ValueType> extends TFC_AutoSaving {
  /** The map of entries */
  final Map<String, ValueType> _map = Map();

  /** Returns a copy of the map */
  Map<String, ValueType> get allEntries {
    return Map.from(_map);
  }

  /** Sts the given entry to the given value */
  void set(String key, ValueType value) {
    _map[key] = value;
    _saveMap();
  }

  /** Adds all the given entries to the set */
  void addAll(Map<String, ValueType> entries) {
    _map.addAll(entries);
    _saveMap();
  }

  /** Removes the given entry from the set */
  void remove(String key) {
    _map.remove(key);
    _saveMap();
  }

  /** Removes all the given entries from the set */
  void removeAll(Set<String> keys) {
    for (String key in keys) {
      _map.remove(key);
    }
    _saveMap();
  }

  /** Convert the given value into a json value. */
  dynamic Function(ValueType) valueToJson;

  /** Saves the map to its file */
  void _saveMap() {
    // Turn each entry into a json value
    Map<String, dynamic> json = {};
    for (String key in _map.keys) {
      json[key] = valueToJson(_map[key]!);
    }

    // Save the map to the file
    save(jsonEncode(json));
  }


  /** Load an value from the given json value. */
  ValueType Function(dynamic) valueFromJson;

  /** Initializes an auto-saving Map */
  TFC_AutoSavingMap({
    required String fileNameWithoutExtension,
    required this.valueToJson,
    required this.valueFromJson,
  }) : super(fileNameWithoutExtension) {
    // Attempt to load the map from a file
    if (TFC_DiskController.fileExists(fileName)) {
      // Read in the json
      dynamic json = jsonDecode(TFC_DiskController.readFileAsString(fileName)!);

      // Extract each entry
      for (dynamic key in json.keys) {
        _map[key] = valueFromJson(json[key]);
      }
    }
  }
}



/** An auto-saving Set */
class TFC_AutoSavingSet<ContentType> extends TFC_AutoSaving {
  /** The set of elements */
  final Set<ContentType> _set = Set();

  /** Returns a copy of the set */
  Set<ContentType> get allElements {
    return Set.from(_set);
  }

  /** Adds the given element to the set */
  void add(ContentType element) {
    _set.add(element);
    _saveSet();
  }

  /** Adds all the given element to the set */
  void addAll(List<ContentType> elements) {
    _set.addAll(elements);
    _saveSet();
  }

  /** Removes the given element from the set */
  void remove(ContentType element) {
    _set.remove(element);
    _saveSet();
  }

  /** Removes all the given elements from the set */
  void removeAll(List<ContentType> elements) {
    _set.removeAll(elements);
    _saveSet();
  }

  /** Convert the given element into a json value. */
  dynamic Function(ContentType) elementToJson;

  /** Saves the set to its file */
  void _saveSet() {
    // Turn each elment into a json value
    List<dynamic> json = [];
    for (ContentType element in _set) {
      json.add(
        elementToJson(element),
      );
    }

    // Save the set to the file
    save(jsonEncode(json));
  }


  /** Load an element from the given json value. */
  ContentType Function(dynamic) elementFromJson;

  /** Initializes an auto-saving Set */
  TFC_AutoSavingSet({
    required String fileNameWithoutExtension,
    required this.elementToJson,
    required this.elementFromJson,
  }) : super(fileNameWithoutExtension) {
    // Attempt to load the set from a file
    if (TFC_DiskController.fileExists(fileName)) {
      // Read in the json
      dynamic json = jsonDecode(TFC_DiskController.readFileAsString(fileName)!);

      // Extract each element
      for (dynamic elementAsJson in json) {
        _set.add(elementFromJson(elementAsJson));
      }
    }
  }
}
