import '../TFC_AllItemsManager.dart';
import '../TFC_Change.dart';
import '../TFC_Item.dart';
import '../TFC_SyncDepth.dart';
import 'TFC_Attribute.dart';


// Provides a control pannel for an instance of an item attribute
class TFC_AttributeItemSet<ItemClassType extends TFC_Item> extends TFC_Attribute {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Allow devs to access the items in this set
  Set<ItemClassType> get allItems {
    Set<ItemClassType> allItems = {};
    for (String itemID in attributeInstance.getAllValuesAsSet<String>()) {
      allItems.add(
        getItemFromItemID(itemID),
      );
    }
    return allItems;
  }


  // Changes to the attribute made through this class are considered local changes
  void add(ItemClassType newItem) {
    TFC_AllItemsManager.applyChangesIfRelevant(
      changes: [
        TFC_ChangeAttributeAddValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: newItem.itemID,
        ),
      ],
    );
  }

  // Changes to the attribute made through this class are considered local changes
  void remove(ItemClassType itemToRemove) {
    TFC_AllItemsManager.applyChangesIfRelevant(
      changes: [
        TFC_ChangeAttributeRemoveValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: itemToRemove.itemID,
        ),
      ],
    );
  }


  // Whether or not to delete all children when the parent object is deleted
  final bool shouldDeleteContentsWhenItemIsDeleted;

  // Keeps track of the onDelete listenners by item
  static Map<String, Map<String, void Function()>> _deleteContentsOnItemDeleteListeners = {};

  // This will setup a listener to delete all contents when the parent item is deleted
  void _listenToOnDeleteAndDeleteContents() {
    // Ensure a slot exists for this item
    if (!_deleteContentsOnItemDeleteListeners.containsKey(attributeInstance.itemID)) {
      _deleteContentsOnItemDeleteListeners[attributeInstance.itemID] = {};
    }

    // Add a listenner if there is none for this attribute
    Map<String, void Function()> onDeleteItemEntry =
      _deleteContentsOnItemDeleteListeners[attributeInstance.itemID]!;
    if (!onDeleteItemEntry.containsKey(attributeKey)) {
      onDeleteItemEntry[attributeKey] = () {
        // Delete all of this sets contents
        for (ItemClassType item in allItems) {
          item.delete();
        }

        // The item will be deleted, so their is no sense is listening any more
        onDeleteItemEntry.remove(attributeKey);
      };
    }
  }


  // Creates a new attribute item set
  TFC_AttributeItemSet({
    required String attributeKey,
    required TFC_SyncDepth syncDepth,
    required this.getItemFromItemID,
    required this.shouldDeleteContentsWhenItemIsDeleted,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
  );


  /** Gets the attribute init change object for this attribute. */
  @override
  TFC_ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  }) {
    return TFC_ChangeAttributeInit.set(
      changeApplicationDepth: syncDepth,
      itemID: itemID,
      attributeKey: attributeKey,
    );
  }
  

  /** After the attributes are setup, then we want to listen for the item being deleted */
  @override
  void connectToAttributeInstance({
    required TFC_SingleItemManager itemManager,
  }) {
    super.connectToAttributeInstance(itemManager: itemManager);

    // If this is a defining relationship, then delete the contents of this Set when the item is deleted
    if (shouldDeleteContentsWhenItemIsDeleted) {
      _listenToOnDeleteAndDeleteContents();
    }
  }
}