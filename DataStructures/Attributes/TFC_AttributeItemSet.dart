import '../TFC_Item.dart';
import '../TFC_AllItemsManager.dart';
import '../TFC_SyncLevel.dart';
import 'TFC_Attribute.dart';
import 'TFC_InstanceOfAttribute.dart';


// Provides a control pannel for an instance of an item attribute
class TFC_AttributeItemSet<ItemClassType extends TFC_Item> extends TFC_Attribute<TFC_InstanceOfAttributeSet<dynamic>> {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Allow devs to access the items in this set
  Set<ItemClassType> get allItems {
    Set<ItemClassType> allItems = {};
    for (String itemID in attributeInstance.allValues) {
      allItems.add(
        getItemFromItemID(itemID),
      );
    }
    return allItems;
  }


  // Changes to the attribute made through this class are considered local changes
  void add(ItemClassType newItem) {
    attributeInstance.addValue(
      addedValue: newItem.itemID,
      changeSource: TFC_ChangeSource.DEVICE,
    );
  }

  // Changes to the attribute made through this class are considered local changes
  void remove(ItemClassType itemToRemove) {
    attributeInstance.removeValue(
      removedValue: itemToRemove.itemID,
      changeSource: TFC_ChangeSource.DEVICE,
    );
  }


  // By default Item sets should start empty
  final List<String> valueOnCreateNew = [];


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
    required TFC_SyncLevel syncLevel,
    required this.getItemFromItemID,
    required this.shouldDeleteContentsWhenItemIsDeleted,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
  );
  

  // After the attributes are setup, then we want to listen for the item being deleted
  @override
  void injectSetupDataFromItemInstance({
    required TFC_InstanceOfAttributeSet<dynamic> attributeInstance,
  }) {
    super.injectSetupDataFromItemInstance(attributeInstance: attributeInstance);

    // If this is a defining relationship, then delete the contents of this Set when the item is deleted
    if (shouldDeleteContentsWhenItemIsDeleted) {
      _listenToOnDeleteAndDeleteContents();
    }
  }
}