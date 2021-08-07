import '../TFC_SyncDepth.dart';
import '../TFC_Change.dart';
import '../TFC_Item.dart';
import '../TFC_AllItemsManager.dart';
import 'TFC_Attribute.dart';


// Provides a control pannel for an instance of an item attribute
class TFC_AttributeItem<ItemClassType extends TFC_Item> extends TFC_Attribute {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Expose the value of the attribute
  ItemClassType get value {
    return getItemFromItemID(attributeInstance.valueAsProperty);
  }

  // Changes to the attribute made through this class are considered local changes
  void set value(ItemClassType newValue) {
    TFC_AllItemsManager.applyChangesIfRelevant(
      changes: [
        TFC_ChangeAttributeSetValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: newValue.itemID,
        ),
      ],
    );
  }


  // Allow devs to define their own default values
  final ItemClassType Function() getDefaultItemOnCreateNew;

  // This is the value this attribute should have when it's item is first created.
  String get valueOnCreateNew {
    return getDefaultItemOnCreateNew().itemID;
  }


  // Creates a new property attribute
  TFC_AttributeItem({
    required String attributeKey,
    required TFC_SyncDepth syncDepth,
    required this.getDefaultItemOnCreateNew,
    required this.getItemFromItemID,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
  );
  

  /** Gets the attribute init change object for this attribute. */
  @override
  TFC_ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  }) {
    return TFC_ChangeAttributeInit.property(
      changeApplicationDepth: syncDepth,
      itemID: itemID,
      attributeKey: attributeKey,
      value: valueOnCreateNew,
    );
  }
}