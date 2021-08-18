import '../Utilities/TFC_Event.dart';
import '../DataStructures/TFC_AllItemsManager.dart';
import '../DataStructures/TFC_Item.dart';
import '../DataStructures/Attributes/TFC_Attribute.dart';

class TFC_ImageVariantItem extends TFC_Item {
  // Static Properties
  static const String ITEM_TYPE = "TFC_ImageVariantItem";
  String get itemType { return ITEM_TYPE; }
 

  // Attributes
  /*final TFC_AttributeString someString = TFC_AttributeString(
    attributeKey: "someString",
    valueOnCreateNew: "",
    syncLevel: TFC_SyncLevel.CLOUD,
  );*/
  /*final TFC_AttributeItemSet<SomeItem> someItems = TFC_AttributeItemSet(
    attributeKey: "someItems",
    getItemFromItemID: (String itemID) { return SomeItem.fromItemID(itemID); },
    syncLevel: TFC_SyncLevel.CLOUD,
    shouldDeleteContentsWhenItemIsDeleted: true,
  );*/


  // Constructors
  TFC_ImageVariantItem.createNew() : super.createNew();
  
  TFC_ImageVariantItem.fromItemID(String itemID) : super.fromItemID(itemID);



  // Managed by tke-cli DO NOT TOUCH
  static Set<TFC_ImageVariantItem> get allTFC_ImageVariantItemItems {
    Set<TFC_ImageVariantItem> allItemsOfThisType = Set();
    Set<String> itemIDs = TFC_AllItemsManager.getItemIDsForItemType(ITEM_TYPE);
    for (String itemID in itemIDs) allItemsOfThisType.add(TFC_ImageVariantItem.fromItemID(itemID));
    return allItemsOfThisType;
  }

  // Managed by tke-cli DO NOT TOUCH
  static TFC_Event get onTFC_ImageVariantItemCreatedOrDestroyed {
    return TFC_AllItemsManager.getOnItemOfTypeCreatedOrDestroyedEvent(itemType: ITEM_TYPE);
  }

  // Managed by tke-cli DO NOT TOUCH
  List<TFC_Attribute> getAllAttributes() {
    return [];
  }
}