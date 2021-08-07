import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';
import '../../UI/FoundationalElements/TFC_OnAfterChange.dart';
import '../TFC_AllItemsManager.dart';
import '../TFC_Change.dart';
import '../TFC_SyncDepth.dart';
import '../../Utilities/TFC_Event.dart';


// Models an attribute instance
abstract class TFC_Attribute implements TFC_OnAfterChange {
  // The attribute instance that this TFC_Attribute models
  @protected
  late final TFC_InstanceOfAttribute attributeInstance;


  // We'll expose the on-after-change event of the attribute instance.
  TFC_Event get onAfterChange {
    return attributeInstance.onAfterChange;
  }


  // This is mainly used for storing the attribute key while the attribute is being initialized
  final String attributeKey;


  // This is mainly used for storing the syncDepth while the attribute is being initialized
  final TFC_SyncDepth syncDepth;


  // Create a new control panel for an attribute instance
  TFC_Attribute({
    required this.attributeKey,
    required this.syncDepth,
  });



  /** This should only be called by TFC_Item */
  void connectToAttributeInstance({
    required TFC_SingleItemManager itemManager,
  }) {
    // Ensure that an instance of this attribute exists
    if (itemManager.getAttributeInstance(attributeKey: attributeKey) == null) {
      TFC_AllItemsManager.applyChangesIfRelevant(
        changes: [
          getAttributeInitChange(itemID: itemManager.itemID),
        ]
      );
    }

    // Connect thist attribute to its isnstance
    this.attributeInstance = itemManager.getAttributeInstance(attributeKey: attributeKey)!;
  }


  /** Gets the attribute init change object for this attribute. */
  TFC_ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  });


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
