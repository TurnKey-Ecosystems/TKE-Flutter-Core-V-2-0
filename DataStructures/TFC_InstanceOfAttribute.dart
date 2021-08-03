import '../Utilities/TFC_Event.dart';

abstract class TFC_InstanceOfAttribute<SerializedType> {
  // On after change Event
  final TFC_Event onAfterChange = TFC_Event();

  // Serialization API
  dynamic toJson();
  TFC_InstanceOfAttribute.fromJson(dynamic json);
}