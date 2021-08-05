import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';
import '../../UI/FoundationalElements/TFC_OnAfterChange.dart';
import '../TFC_SyncLevel.dart';
import 'TFC_InstanceOfAttribute.dart';
import '../../Utilities/TFC_Event.dart';


// Models an attribute instance
abstract class TFC_Attribute<AttributeInstanceType extends TFC_InstanceOfAttribute> implements TFC_OnAfterChange {
  // The attribute instance that this TFC_Attribute models
  @protected
  late final AttributeInstanceType attributeInstance;


  // We'll expose the on-after-change event of the attribute instance.
  TFC_Event get onAfterChange {
    return attributeInstance.onAfterChange;
  }


  // This is mainly used for storing the attribute key while the attribute is being initialized
  final String attributeKey;


  // This is mainly used for storing the syncLevel while the attribute is being initialized
  final TFC_SyncLevel syncLevel;


  // We'll let TFC_Attribute subtypes use their own way to get this.
  dynamic get valueOnCreateNew;


  // Create a new control panel for an attribute instance
  TFC_Attribute({
    required this.attributeKey,
    required this.syncLevel,
  });



  // This should only be called by TFC_Item
  void injectSetupDataFromItemInstance({
    required AttributeInstanceType attributeInstance,
  }) {
    this.attributeInstance = attributeInstance;
  }


  // An attribute has a unique attributeKey within its assocaited item.
  @override
  int get hashCode => hash2(attributeInstance.itemID.hashCode, attributeKey.hashCode);

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  bool operator ==(dynamic other) {
    return other is TFC_Attribute &&
        other.attributeInstance.itemID.hashCode == attributeInstance.itemID.hashCode &&
        other.attributeKey.hashCode == attributeKey.hashCode;
  }
}
