import '../AppManagment/TFC_DiskController.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../Serialization/TFC_AutoSaving.dart';

abstract class TFC_ItemUtilities {
  static const String FILE_EXTENTION = ".itm";
  static const String ITEM_ID_DIVIDER = "-";

  static String generateLocalItemID(String itemType) {
    TFC_AutoSavingProperty nextItemIndex = getNextItemIDIndex(itemType);
    String itemID = itemType + ITEM_ID_DIVIDER + TFC_FlutterApp.deviceID.value + ITEM_ID_DIVIDER + nextItemIndex.value.toString().padLeft(10, "0");
    nextItemIndex.value++;
    return itemID;
  }

  static TFC_AutoSavingProperty getNextItemIDIndex(String itemType) {
    return TFC_AutoSavingProperty(0, "next"+ itemType + "ItemIDIndex");
  }

  static String getDefaultItemIDForItemType(String itemType) {
    return itemType + ITEM_ID_DIVIDER + "default";
  }

  static bool itemExists(String itemID) {
    if (itemID != null) {
      String fileName = TFC_ItemUtilities.generateFileName(itemID);
      return TFC_DiskController.fileExists(fileName);
    } else {
      return false;
    }
  }

  static String generateFileName(String itemID) {
    return itemID + FILE_EXTENTION;
  }
}