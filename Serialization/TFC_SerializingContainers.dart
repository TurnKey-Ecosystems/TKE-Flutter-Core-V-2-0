//import 'dart:developer';
import 'package:flutter/foundation.dart';

abstract class TFC_SerializingContainer {
  final void Function() _onSet;

  TFC_SerializingContainer(this._onSet);

  dynamic _valueFromJson(dynamic value) {
    if (value is Map) {
      return TFC_SerializingMap.fromJson(_onSet, value as Map<String, dynamic>);
    } else if (value is List || value is Set) {
      return TFC_SerializingSet.fromJson(onSet: _onSet, json: value);
    } else {
      return value;
    }
  }

  dynamic _valueToJson(dynamic value) {
    if (value is TFC_SerializingMap) {
      return value.toJson();
    } else if (value is TFC_SerializingSet) {
      return value.toJson();
    } else {
      return value;
    }
  }
}

class TFC_SerializingMap extends TFC_SerializingContainer {
  late Map<String, dynamic> _map;
  int get length {
    return _map.length;
  }

  Iterable<String> get keys {
    return _map.keys;
  }

  Iterable<dynamic> get values {
    return _map.values;
  }

  Iterable<MapEntry<String, dynamic>> get entries {
    return _map.entries;
  }

  TFC_SerializingMap(void Function() onSet) : super(onSet) {
    _map = Map();
  }

  TFC_SerializingMap.fromJson(void Function() onSet, Map<String, dynamic> json)
      : super(onSet) {
    _map = Map();
    for (String key in json.keys) {
      _map[key] = _valueFromJson(json[key]);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> asJson = Map();
    for (String key in _map.keys) {
      asJson[key] = _valueToJson(_map[key]);
    }
    return asJson;
  }

  dynamic operator [](String key) {
    return _map[key];
  }

  void operator []=(String key, dynamic value) {
    _map[key] = _valueFromJson(value);
    _onSet();
  }

  bool containsKey(String key) {
    return _map.containsKey(key);
  }

  bool containsValue(dynamic value) {
    return _map.containsValue(value);
  }

  dynamic remove(String key) {
    dynamic wasValueInMap = _map.remove(key);
    _onSet();
    return wasValueInMap;
  }

  @override
  String toString() {
    return _map.toString();
  }
}

class TFC_SerializingSet extends TFC_SerializingContainer implements Iterable {
  late Set<dynamic> _set;
  late final void Function(dynamic, bool)? _onElementAdded;
  late final void Function(dynamic, bool)? _onElementRemoved;
  int get length {
    return _set.length;
  }

  Iterator<dynamic> get iterator {
    return _set.iterator;
  }

  TFC_SerializingSet(void Function() onSet,
      {void Function(dynamic, bool)? onElementAdded,
      void Function(dynamic, bool)? onElementRemoved})
      : _onElementAdded = onElementAdded,
        _onElementRemoved = onElementRemoved,
        super(onSet) {
    _set = Set();
  }

  TFC_SerializingSet.fromJson(
      {required void Function() onSet,
      required List<dynamic> json,
      void Function(dynamic, bool)? onElementAdded,
      void Function(dynamic, bool)? onElementRemoved})
      : _onElementAdded = onElementAdded,
        _onElementRemoved = onElementRemoved,
        super(onSet) {
    _set = Set();
    for (dynamic element in json) {
      _set.add(_valueFromJson(element));
    }
  }

  List<dynamic> toJson() {
    List<dynamic> asJson = [];
    for (dynamic element in _set) {
      asJson.add(_valueToJson(element));
    }
    return asJson;
  }

  bool contains(dynamic element) {
    return _set.contains(element);
  }

  void add(
    dynamic element, {
    bool shouldTriggerOnSet = true,
    bool shouldTriggerOnElementAdded = true,
    bool shouldLogChange = true,
  }) {
    _set.add(_valueFromJson(element));
    if (shouldTriggerOnSet) {
      _onSet();
    }
    if (shouldTriggerOnElementAdded) {
      triggerOnElementAdded(element, shouldLogChange);
    }
  }

  void addAll(
    List<dynamic> elements, {
    bool shouldTriggerOnSet = true,
    bool shouldTriggerOnElementAdded = true,
    bool shouldLogChange = true,
  }) {
    List<dynamic> serializedElemnts = [];
    for (dynamic element in elements) {
      serializedElemnts.add(_valueFromJson(element));
    }
    _set.addAll(serializedElemnts);
    if (shouldTriggerOnSet) {
      _onSet();
    }
    if (shouldTriggerOnElementAdded) {
      for (dynamic element in elements) {
        triggerOnElementAdded(element, shouldLogChange);
      }
    }
  }

  bool remove(
    dynamic element, {
    bool shouldTriggerOnSet = true,
    bool shouldTriggerOnElementRemoved = true,
    bool shouldLogChange = true,
  }) {
    bool wasElementInSet = _set.remove(_valueFromJson(element));
    if (shouldTriggerOnSet) {
      _onSet();
    }
    if (shouldTriggerOnElementRemoved) {
      triggerOnElementRemoved(element, shouldLogChange);
    }
    return wasElementInSet;
  }

  void triggerOnElementAdded(dynamic element, bool shouldLogChange) {
    if (_onElementAdded != null) {
      _onElementAdded!(element, shouldLogChange);
    }
  }

  void triggerOnElementRemoved(dynamic element, bool shouldLogChange) {
    if (_onElementRemoved != null) {
      _onElementRemoved!(element, shouldLogChange);
    }
  }

  @override
  String toString() {
    return _set.toString();
  }

  // Iterable Implementation
  bool any(bool Function(dynamic) test) {
    return _set.any(test);
  }

  Set<R> cast<R>() {
    return _set.cast<R>();
  }

  dynamic elementAt(int index) {
    return _set.elementAt(index);
  }

  bool every(bool Function(dynamic) test) {
    return _set.every(test);
  }

  Iterable<T> expand<T>(Iterable<T> Function(dynamic) f) {
    return _set.expand(f);
  }

  dynamic firstWhere(bool Function(dynamic) test, {dynamic Function()? orElse}) {
    return _set.firstWhere(test, orElse: orElse);
  }

  T fold<T>(T initialValue, T Function(T, dynamic) combine) {
    return _set.fold(initialValue, combine);
  }

  Iterable<dynamic> followedBy(Iterable<dynamic> other) {
    return _set.followedBy(other);
  }

  void forEach(void Function(dynamic) f) {
    _set.forEach(f);
  }

  String join([String seperator = ""]) {
    return _set.join(seperator);
  }

  dynamic lastWhere(bool Function(dynamic) test, {dynamic Function()? orElse}) {
    return _set.lastWhere(test, orElse: orElse);
  }

  Iterable<T> map<T>(T Function(dynamic) f) {
    return _set.map(f);
  }

  dynamic reduce(dynamic Function(dynamic, dynamic) f) {
    return _set.reduce(f);
  }

  dynamic singleWhere(bool Function(dynamic) test,
      {dynamic Function()? orElse}) {
    return _set.singleWhere(test, orElse: orElse);
  }

  Iterable<dynamic> skip(int count) {
    return _set.skip(count);
  }

  Iterable<dynamic> skipWhile(bool Function(dynamic) test) {
    return _set.skipWhile(test);
  }

  Iterable<dynamic> take(int count) {
    return _set.take(count);
  }

  Iterable<dynamic> takeWhile(bool Function(dynamic) test) {
    return _set.takeWhile(test);
  }

  List<dynamic> toList({bool growable = true}) {
    return _set.toList(growable: growable);
  }

  Set<dynamic> toSet() {
    return _set.toSet();
  }

  Iterable<dynamic> where(bool Function(dynamic) test) {
    return _set.where(test);
  }

  Iterable<T> whereType<T>() {
    return _set.whereType<T>();
  }

  dynamic get first {
    return _set.first;
  }

  bool get isEmpty {
    return _set.isEmpty;
  }

  bool get isNotEmpty {
    return _set.isNotEmpty;
  }

  dynamic get last {
    return _set.last;
  }

  dynamic get single {
    return _set.single;
  }
}

/*class TFC_SerializingList extends TFC_SerializingContainer implements Iterable {
  List<dynamic> _list;
  int get length {
    return _list.length;
  }
  Iterator<dynamic> get iterator {
    return _list.iterator;
  }

  TFC_SerializingList(void Function() onSet) : super(onSet) {
    _list = List();
  }

  TFC_SerializingList.fromJson(void Function() onSet, List<dynamic> json) : super(onSet) {
    _list = List();
    for(dynamic element in json) {
      _list.add(_valueFromJson(element));
    }
  }

  List<dynamic> toJson() {
    List<dynamic> asJson = List();
    for(dynamic element in _list) {
      asJson.add(_valueToJson(element));
    }
    return asJson;
  }

  dynamic operator [](int index) {
    return _list[index];
  }

  void operator []=(int index, dynamic value) {
    _list[index] = _valueFromJson(value);
      _onSet();
  }

  bool contains(dynamic element) {
    return _list.contains(element);
  }

  void add(dynamic value) {
    _list.add(_valueFromJson(value));
    _onSet();
  }

  void remove(dynamic value) {
    _list.remove(value);
    _onSet();
  }

  void removeAt(int index) {
    _list.removeAt(index);
    _onSet();
  }

  @override
  String toString() {
    return _list.toString();
  }
  
  // Iterable Implementation
  bool any(bool Function(dynamic) test) {
    return _list.any(test);
  }
  List<R> cast<R>() {
    return _list.cast<R>();
  }
  dynamic elementAt(int index) {
    return _list.elementAt(index);
  }
  bool every(bool Function(dynamic) test) {
    return _list.every(test);
  }
  Iterable<T> expand<T>(Iterable<T> Function(dynamic) f) {
    return _list.expand(f);
  }
  dynamic firstWhere(bool Function(dynamic) test, {dynamic Function() orElse}) {
    return _list.firstWhere(test, orElse: orElse);
  }
  T fold<T>(T initialValue, T Function(T, dynamic) combine) {
    return _list.fold(initialValue, combine);
  }
  Iterable<dynamic> followedBy(Iterable<dynamic> other) {
    return _list.followedBy(other);
  }
  void forEach(void Function(dynamic) f) {
    _list.forEach(f);
  }
  String join([String seperator = ""]) {
    return _list.join(seperator);
  }
  dynamic lastWhere(bool Function(dynamic) test, {dynamic Function() orElse}) {
    return _list.lastWhere(test, orElse: orElse);
  }
  Iterable<T> map<T>(T Function(dynamic) f) {
    return _list.map(f);
  }
  dynamic reduce(dynamic Function(dynamic, dynamic) f) {
    return _list.reduce(f);
  }
  dynamic singleWhere(bool Function(dynamic) test, {dynamic Function() orElse}) {
    return _list.singleWhere(test, orElse: orElse);
  }
  Iterable<dynamic> skip(int count) {
    return _list.skip(count);
  }
  Iterable<dynamic> skipWhile(bool Function(dynamic) test) {
    return _list.skipWhile(test);
  }
  Iterable<dynamic> take(int count) {
    return _list.take(count);
  }
  Iterable<dynamic> takeWhile(bool Function(dynamic) test) {
    return _list.takeWhile(test);
  }
  List<dynamic> toList({bool growable = true}) {
    return _list.toList(growable: growable);
  }
  Set<dynamic> toSet() {
    return _list.toSet();
  }
  Iterable<dynamic> where(bool Function(dynamic) test) {
    return _list.where(test);
  }
  Iterable<T> whereType<T>() {
    return _list.whereType<T>();
  }
  dynamic get first {
    return _list.first;
  }
  bool get isEmpty {
    return _list.isEmpty;
  }
  bool get isNotEmpty {
    return _list.isNotEmpty;
  }
  dynamic get last {
    return _list.last;
  }
  dynamic get single {
    return _list.single;
  }
}*/
