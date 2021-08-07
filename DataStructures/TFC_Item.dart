import 'TFC_Change.dart';
import 'TFC_SyncDepth.dart';
import 'package:tuple/tuple.dart';
import 'TFC_AllItemsManager.dart';
import '../Utilities/TFC_Event.dart';
import 'package:flutter/foundation.dart';
import 'Attributes/TFC_Attribute.dart';


// Acts a a control pannel for an item instance
@immutable
abstract class TFC_Item {
  // We can't require subtypes to provide an itemType, so this is the best we can do.
  String get itemType;


  // The instnace of this item
  late final TFC_SingleItemManager _itemManager;


  // Expose the itemID for getting
  late final String itemID;


  // Expose the onDelete event for listeners
  TFC_Event get onDelete {
    return _itemManager.onDelete;
  }
  

  // Item subtypes should override this
  @protected
  List<TFC_Attribute> getAllAttributes();


  /**Creates a new item */
  TFC_Item.createNew() {
    // Create a list to collect changes in
    List<TFC_Change> changes = [];

    // Create the item creation change
    this.itemID = TFC_AllItemsManager.requestNewItemID(itemType: itemType);
    changes.add(
      TFC_ChangeItemCreation(
        changeApplicationDepth: TFC_SyncDepth.CLOUD,
        itemType: itemType,
        itemID: itemID,
      ),
    );

    // Create an attribute init change for each attribute
    for (TFC_Attribute attribute in getAllAttributes()) {
      changes.add(
        attribute.getAttributeInitChange(itemID: itemID),
      );
    }

    // Create the new item isntance
    TFC_AllItemsManager.applyChangesIfRelevant(changes: changes);
    
    // Record the new item instance
    _itemManager = TFC_AllItemsManager.getItemInstance(itemID)!;

    // Wire up the attributes
    _connectAttributesToAttributeInstances();
  }

  /** Creates a new item control pannel for the item with the given itemID. */
  TFC_Item.fromItemID(String itemID) {
    this.itemID = itemID;
    _itemManager = TFC_AllItemsManager.getItemInstance(itemID)!;
    _connectAttributesToAttributeInstances();
  }


  /** Sets up all the attributes in this item */
  void _connectAttributesToAttributeInstances() {
    for (TFC_Attribute attribute in getAllAttributes()) {
      attribute.connectToAttributeInstance(
        itemManager: _itemManager,
      );
    }
  }


  /** Permanently delete this item */
  @mustCallSuper
  void delete() {
    TFC_AllItemsManager.applyChangesIfRelevant(
      changes: [
        TFC_ChangeItemDeletion(
          itemType: itemType,
          itemID: itemID,
          changeApplicationDepth: TFC_SyncDepth.CLOUD,
        )
      ],
    );
  }


  // Items are identified by their itemID
  @override
  int get hashCode => itemID.hashCode;

  // Items are identified by their itemID
  @override
  bool operator ==(dynamic other) {
    return other is TFC_Item && other.itemID == itemID;
  }
}
