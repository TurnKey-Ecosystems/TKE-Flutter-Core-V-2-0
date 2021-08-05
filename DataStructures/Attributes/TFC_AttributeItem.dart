import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/DataStructures/TFC_SyncLevel.dart';

import '../TFC_Item.dart';
import '../TFC_AllItemsManager.dart';
import 'TFC_Attribute.dart';
import 'TFC_InstanceOfAttribute.dart';


// Provides a control pannel for an instance of an item attribute
class TFC_AttributeItem<ItemClassType extends TFC_Item> extends TFC_Attribute<TFC_InstanceOfAttributeProperty<String>> {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Expose the value of the attribute
  ItemClassType get value {
    return getItemFromItemID(attributeInstance.value);
  }

  // Changes to the attribute made through this class are considered local changes
  void set value(ItemClassType newValue) {
    return attributeInstance.setValue(
      newValue: newValue.itemID,
      changeSource: TFC_ChangeSource.DEVICE,
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
    required TFC_SyncLevel syncLevel,
    required this.getDefaultItemOnCreateNew,
    required this.getItemFromItemID,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
  );
}