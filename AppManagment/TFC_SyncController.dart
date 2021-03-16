import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import '../Utilities/TFC_ImageUtilities.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../Utilities/TFC_Event.dart';
import '../Utilities/TFC_Utilities.dart';
import 'package:http/http.dart' as HTTP;
import '../DataStructures/TFC_ItemInstances.dart';
import '../DataStructures/TFC_ItemUtilities.dart';
import '../Serialization/TFC_AutoSaving.dart';
import 'TFC_DiskController.dart';
import '../Serialization/TFC_SerializingContainers.dart';

class TFC_SyncController {
  //static const String REST_GATEWAY_URL = "https://9gj1n5qh3c.execute-api.us-west-2.amazonaws.com/alpha";
  static const String DEV_API_KEY = "BzfkKFcaSm2nG34qcQbmZ8qWKOwZv9L27TXzX7WD";
  static const String DEMO_API_KEY = "OE5ZY9MLPY5usRaOyQ25Xa4UyisIKrqW7rxYEdfh";
  static const String RELEASE_API_KEY =
      "rNLOR9sOnu3fFV6DoAfR48TW9OyHhla6875tWRUU";
  //static const String DEMO_API_KEY = "x26sWIEtRE8WXJWf4tZPz2SGwHAHJGHf6G0gbRTL";
  static const String REST_GATEWAY_URL =
      "https://1yba8o86j1.execute-api.us-west-2.amazonaws.com/release/";
  /*static const String REST_GATEWAY_URL =
      "https://g1n78jreyb.execute-api.us-west-2.amazonaws.com/demo-1-0/";*/
  /*static const String REST_GATEWAY_URL =
      "https://1w1s6t19d9.execute-api.us-west-2.amazonaws.com/dev/";*/
  static String clientID;
  static bool _downloadAllIsInProgress = false;
  static bool get downloadAllIsInProgress {
    return _downloadAllIsInProgress;
  }

  static bool _syncShouldBePaused = true;
  static bool _syncIsRunning = false;
  static TFC_AutoSavingProperty timeOfLastSync =
      TFC_AutoSavingProperty(0, "timeOfLastSync");
  static TFC_AutoSavingMap _newItems = TFC_AutoSavingMap("newItems");
  static TFC_AutoSavingMap _itemChanges = TFC_AutoSavingMap("itemChanges");
  static TFC_AutoSavingMap _itemDeletionRequests =
      TFC_AutoSavingMap("itemDeletionRequests");
  static TFC_AutoSavingMap _imageChanges = TFC_AutoSavingMap("imageChanges");
  static TFC_AutoSavingMap _activelySyncingNewItems =
      TFC_AutoSavingMap("activelySyncingNewItems");
  static TFC_AutoSavingMap _activelySyncingItemChanges =
      TFC_AutoSavingMap("activelySyncingItemChanges");
  static TFC_AutoSavingMap _activelySyncingItemDeletionRequests =
      TFC_AutoSavingMap("activelySyncingItemDeletionRequests");
  static TFC_AutoSavingMap _activelySyncingImageChanges =
      TFC_AutoSavingMap("activelySyncingImageChanges");
  static TFC_AutoSavingMap _imagesToUpload =
      TFC_AutoSavingMap("imagesToUpload");
  static TFC_AutoSavingMap _imagesToDownload =
      TFC_AutoSavingMap("imagesToDownload");
  static Set<String> _itemTypesInThisApp;

  static Future<void> setupDatabaseSyncController(
      String givenClientID, Set<String> itemTypesInThisApp,
      {shouldStartSync = true}) async {
    clientID = givenClientID;
    _itemTypesInThisApp = itemTypesInThisApp;
    if (shouldStartSync) {
      //timeOfLastSync.value = 1594055539000;

      // If it has been a while since this phone was synced, wipe the local files and start fresh
      DateTime datofLastSync =
          DateTime.fromMillisecondsSinceEpoch(timeOfLastSync.value);
      Duration timeSinceLastSinc = DateTime.now().difference(datofLastSync);
      if (timeSinceLastSinc >= Duration(days: 90)) {
        bool redownloadCompleted = false;
        while (!redownloadCompleted) {
          try {
            await wipeAndRedownloadAllFiles();
            redownloadCompleted = true;
          } catch (e) {
            log(e.message);
            redownloadCompleted = false;
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }

      // If there are any images that need uploaded or downloaded, then sync them
      if (!_imageDownloadIsRunning) {
        _downloadImages();
      }
      if (!_imageUploadIsRunning) {
        _uploadImages();
      }

      //timeOfLastSync.value = 1594055539100;

      // Start the sync loop
      runSyncLoop();
    }
  }

  static Future<void> wipeAndRedownloadAllFiles() async {
    _downloadAllIsInProgress = true;

    // let all active sync processes finish
    _syncShouldBePaused = true;
    await TFC_Utilities.when(() {
      return !_syncIsRunning &&
          !_imageDownloadIsRunning &&
          !_imageUploadIsRunning;
    });

    TFC_ItemInstances.unloadAllItemInstances();

    // Delete all local items and images
    List<String> filesToDelete =
        TFC_DiskController.getLocalFileNamesFromFileExtension(
            TFC_ItemUtilities.FILE_EXTENTION);
    filesToDelete
        .addAll(TFC_DiskController.getLocalFileNamesFromFileExtension(".png"));
    filesToDelete
        .addAll(TFC_DiskController.getLocalFileNamesFromFileExtension(".jpg"));
    for (String fileName in filesToDelete) {
      TFC_DiskController.deleteFile(fileName);
    }

    // Create the download all http request
    Map<String, dynamic> request = Map();
    request["itemTypesInThisApp"] = _itemTypesInThisApp.toList();
    request["itemTypesToGetNextItemIDIndicesFor"] =
        _itemTypesInThisApp.toList();
    request["itemTypesToGetNextItemIDIndicesFor"]
        .add(TFC_ImageUtilities.IMAGE_ITEM_TYPE);
    request["deviceID"] = TFC_FlutterApp.deviceID.value;
    request["clientID"] = clientID;
    log("About to start download all.");

    // Sync with the server3
    HTTP.Response response = await HTTP.post(
      "$REST_GATEWAY_URL/download_all",
      //"https://k75gaw97rf.execute-api.us-west-2.amazonaws.com/dev/download_all",
      //"https://8fg44b1i7l.execute-api.us-west-2.amazonaws.com/alpha/downloadall",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "x-api-key": RELEASE_API_KEY
      },
      body: jsonEncode(request),
    );
    Map<String, dynamic> decodedJson = json.decode(response.body);

    // Apply the next itemID indices
    for (Map<String, dynamic> nextItemIDIndxForThisItemType
        in decodedJson["nextItemIDIndices"]) {
      String itemType = nextItemIDIndxForThisItemType["itemType"];
      int nextItemIDIndex = nextItemIDIndxForThisItemType["nextItemIDIndex"];
      TFC_ItemUtilities.getNextItemIDIndex(itemType).value = nextItemIDIndex;
    }

    // Clean up legacy files
    //await AND_CleanupLegacyFiles.cleanUp();

    // Apply the server-side changes
    timeOfLastSync.value = decodedJson["newTimeOfLastSync"];
    for (String itemID in decodedJson["items"].keys) {
      TFC_ItemInstances.addNewItemFromServerItem(
          decodedJson["items"][itemID], itemID);
    }

    // Download all images
    for (String imageFileName in decodedJson["imageFileNames"]) {
      requestImageDownload(imageFileName);
    }

    // If there are any images that need uploaded or downloaded, then sync them
    if (!_imageDownloadIsRunning) {
      _downloadImages();
    }
    if (!_imageUploadIsRunning) {
      _uploadImages();
    }

    _syncShouldBePaused = false;
    _downloadAllIsInProgress = false;
  }

  static void runSyncLoop() async {
    _syncShouldBePaused = false;
    while (true) {
      if (!_syncShouldBePaused) {
        await syncWithDynamo();
      }
      await Future.delayed(Duration(seconds: 3));
    }
  }

  static Future<void> syncWithDynamo() async {
    _syncIsRunning = true;

    // We only want to use new client side sync data, if the last sync was successful
    if (_activelySyncingNewItems.map.length == 0 &&
        _activelySyncingItemChanges.map.length == 0 &&
        _activelySyncingItemDeletionRequests.map.length == 0 &&
        _activelySyncingImageChanges.map.length == 0) {
      // Create aut saving copies of the change logs in case something goes wrong during sync
      _activelySyncingNewItems.setFromJson(_newItems.getAsJson());
      _activelySyncingItemChanges.setFromJson(_itemChanges.getAsJson());
      _activelySyncingItemDeletionRequests
          .setFromJson(_itemDeletionRequests.getAsJson());
      _activelySyncingImageChanges.setFromJson(_imageChanges.getAsJson());
      _newItems.setFromJson(Map<String, dynamic>());
      _itemChanges.setFromJson(Map<String, dynamic>());
      _itemDeletionRequests.setFromJson(Map<String, dynamic>());
      _imageChanges.setFromJson(Map<String, dynamic>());
    }

    // Compile client-side chagnes to create a sync request
    Map<String, dynamic> syncRequest = Map();

    // Compile: Time of last sync
    syncRequest["timeOfLastSync"] = timeOfLastSync.value;

    // Compile: next item ID index information.
    syncRequest["deviceID"] = TFC_FlutterApp.deviceID.value;
    syncRequest["clientID"] = clientID;
    Set<String> newItemTypesInThisSync = Set();
    Map<String, dynamic> nextItemIDIndicesByItemType = Map();
    for (String itemID in _activelySyncingNewItems.map.keys) {
      if (!newItemTypesInThisSync
          .contains(_activelySyncingNewItems.map[itemID]["itemType"])) {
        newItemTypesInThisSync
            .add(_activelySyncingNewItems.map[itemID]["itemType"]);
      }
    }
    for (String itemType in newItemTypesInThisSync) {
      nextItemIDIndicesByItemType[itemType] = {
        "itemType": itemType,
        "nextItemIDIndex": TFC_ItemUtilities.getNextItemIDIndex(itemType).value
      };
    }
    if (_activelySyncingImageChanges.map.keys.length > 0) {
      nextItemIDIndicesByItemType[TFC_ImageUtilities.IMAGE_ITEM_TYPE] = {
        "itemType": TFC_ImageUtilities.IMAGE_ITEM_TYPE,
        "nextItemIDIndex": TFC_ItemUtilities.getNextItemIDIndex(
                TFC_ImageUtilities.IMAGE_ITEM_TYPE)
            .value
      };
    }
    syncRequest["nextItemIDIndices"] = nextItemIDIndicesByItemType;

    // Compile: New items
    for (String itemID in _activelySyncingNewItems.map.keys) {
      // Remove any blank sets from all new items
      Set<String> blankSetAttributesToRemove = Set();
      for (String setAttributeKey
          in _activelySyncingNewItems.map[itemID]["setAttributes"].keys) {
        if (_activelySyncingNewItems
                .map[itemID]["setAttributes"][setAttributeKey].length ==
            0) {
          blankSetAttributesToRemove.add(setAttributeKey);
        }
      }
      for (String setAttributeKey in blankSetAttributesToRemove) {
        _activelySyncingNewItems.map[itemID]["setAttributes"]
            .remove(setAttributeKey);
      }
    }
    syncRequest["newItems"] = _activelySyncingNewItems.map.toJson();
    for (String key in syncRequest["newItems"].keys) {
      log("creating: " + syncRequest["newItems"][key].toString());
    }

    // Compile: Item changes
    syncRequest["itemChanges"] = _activelySyncingItemChanges.map.toJson();

    // Compile: Item deletion requests
    syncRequest["itemDeletionRequests"] =
        _activelySyncingItemDeletionRequests.map.toJson();
    for (String key in syncRequest["itemDeletionRequests"].keys) {
      log("deleteing: " + syncRequest["itemDeletionRequests"][key].toString());
    }

    // Compile: Image changes
    syncRequest["imageChanges"] = _activelySyncingImageChanges.map.toJson();
    log(syncRequest.toString());

    // Sync with the server
    bool syncWasSuccessful = false;
    Map<String, dynamic> decodedSyncJson;
    try {
      HTTP.Response syncResponse = await HTTP.post(
        "$REST_GATEWAY_URL/sync",
        //"https://8fg44b1i7l.execute-api.us-west-2.amazonaws.com/alpha/sync",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "x-api-key": RELEASE_API_KEY
        },
        body: jsonEncode(syncRequest),
      );
      log(syncResponse.body);
      //log("syncResponse.statusCode: ${syncResponse.statusCode.toString()}");
      decodedSyncJson = json.decode(syncResponse.body);
      syncWasSuccessful = syncResponse.statusCode == 200;
    } catch (e) {
      syncWasSuccessful = false;
      log(e.toString());
    }

    if (syncWasSuccessful &&
        decodedSyncJson != null &&
        decodedSyncJson.keys != null &&
        decodedSyncJson.containsKey("newTimeOfLastSync") &&
        decodedSyncJson.containsKey("itemChanges") &&
        decodedSyncJson.containsKey("deletedItemIDs") &&
        decodedSyncJson.containsKey("deletedImages") &&
        decodedSyncJson.containsKey("newImages")) {
      // Apply the server-side changes
      timeOfLastSync.value = decodedSyncJson["newTimeOfLastSync"];
      applyItems(decodedSyncJson["itemChanges"]);
      applyItemDeletions(decodedSyncJson["deletedItemIDs"]);
      _applyImageDeletions(decodedSyncJson["deletedImages"]);
      _applyNewImages(decodedSyncJson["newImages"]);

      // Now that the sync is successful we can wipe the actively syncing change logs
      _activelySyncingNewItems.setFromJson(Map<String, dynamic>());
      _activelySyncingItemChanges.setFromJson(Map<String, dynamic>());
      _activelySyncingItemDeletionRequests.setFromJson(Map<String, dynamic>());
      _activelySyncingImageChanges.setFromJson(Map<String, dynamic>());
    }

    _syncIsRunning = false;
  }

  static void applyItems(Map<String, dynamic> itemsAsDecodedJson) {
    for (String itemID in itemsAsDecodedJson.keys) {
      log("applying server-side item: " +
          itemsAsDecodedJson[itemID].toString());
      if (TFC_ItemUtilities.itemExists(itemID)) {
        TFC_ItemInstances.loadItemInstance(itemID);
        String itemType = itemsAsDecodedJson[itemID]["itemType"];
        for (String attributeKey
            in itemsAsDecodedJson[itemID]["attributes"].keys) {
          dynamic newAttributeValue =
              itemsAsDecodedJson[itemID]["attributes"][attributeKey];
          TFC_ItemInstances.setAttributeValue(
              itemID, itemType, attributeKey, newAttributeValue,
              shouldLogChange: false);
        }
        for (String setAttributeKey
            in itemsAsDecodedJson[itemID]["setAttributes"].keys) {
          for (dynamic element in itemsAsDecodedJson[itemID]["setAttributes"]
              [setAttributeKey]["addedElements"]) {
            TFC_ItemInstances.getAttributeValue(
                    itemID, itemType, setAttributeKey, [])
                .add(element, shouldLogChange: false);
          }
          for (dynamic element in itemsAsDecodedJson[itemID]["setAttributes"]
              [setAttributeKey]["removedElements"]) {
            TFC_ItemInstances.getAttributeValue(
                    itemID, itemType, setAttributeKey, [element])
                .remove(element, shouldLogChange: false);
          }
        }
      } else if (itemID == null ||
          !_itemDeletionRequests.map.containsKey(itemID)) {
        TFC_ItemInstances.addNewItemFromServerItemChange(
            itemsAsDecodedJson[itemID], itemID);
      }
    }
  }

  static void applyItemDeletions(List<dynamic> deletedServerItemIDs) {
    for (String itemID in deletedServerItemIDs) {
      if (TFC_ItemUtilities.itemExists(itemID)) {
        log("applying server-side deleteion: " + itemID);
        TFC_ItemInstances.deleteItem(itemID, shouldLogDeletion: false);
      }
    }
  }

  static void logItemCreation(String localItemID, String nameOfItemType) {
    _newItems.map[localItemID] = {
      "itemType": nameOfItemType,
      "itemID": localItemID,
      "attributes": Map<String, dynamic>(),
      "setAttributes": Map<String, dynamic>()
    };
  }

  static void logItemDeleteion(String localItemID, String itemType) {
    // Only log the item deletion if the item creation has already been logged
    if (_newItems.map.containsKey(localItemID)) {
      _newItems.map.remove(localItemID);
    } else {
      if (_itemChanges.map.containsKey(localItemID)) {
        _itemChanges.map.remove(localItemID);
      }
      int changeDate = DateTime.now().millisecondsSinceEpoch;
      _itemDeletionRequests.map[localItemID] = {
        "itemID": localItemID,
        "itemType": itemType,
        "changeDate": changeDate
      };
    }
  }

  static void logAttributeChange(String itemID, String nameOfItemType,
      String attributeKey, dynamic attributeValue) {
    int changeDate = DateTime.now().millisecondsSinceEpoch;
    TFC_SerializingMap mapToLogTo = _getMapToLogChangeTo(itemID);
    _createNewLogSlotForItem(itemID, nameOfItemType);
    if (!mapToLogTo[itemID]["attributes"].containsKey(attributeKey)) {
      mapToLogTo[itemID]["attributes"][attributeKey] = Map<String, dynamic>();
    }
    mapToLogTo[itemID]["attributes"][attributeKey]["attributeKey"] =
        attributeKey;
    mapToLogTo[itemID]["attributes"][attributeKey]["changeDate"] = changeDate;
    mapToLogTo[itemID]["attributes"][attributeKey]["attributeValue"] =
        attributeValue;
  }

  static void logElementAddedToSetAttribute(String itemID,
      String nameOfItemType, String attributeKey, dynamic elementValue) {
    TFC_SerializingMap mapToLogTo = _getMapToLogChangeTo(itemID);
    _prepareLogSlotForSetAttribute(itemID, nameOfItemType, attributeKey);
    mapToLogTo[itemID]["setAttributes"][attributeKey]["addedElements"]
        .add(elementValue);
    if (mapToLogTo[itemID]["setAttributes"][attributeKey]["removedElements"]
        .contains(elementValue)) {
      mapToLogTo[itemID]["setAttributes"][attributeKey]["removedElements"]
          .remove(elementValue);
    }
  }

  static void logElementRemovedFromSetAttribute(String itemID,
      String nameOfItemType, String attributeKey, dynamic elementValue) {
    TFC_SerializingMap mapToLogTo = _getMapToLogChangeTo(itemID);
    _prepareLogSlotForSetAttribute(itemID, nameOfItemType, attributeKey);
    // We do not want to log element removals for newly created items
    if (!(_newItems.map.containsKey(itemID))) {
      mapToLogTo[itemID]["setAttributes"][attributeKey]["removedElements"]
          .add(elementValue);
    }
    if (mapToLogTo[itemID]["setAttributes"][attributeKey]["addedElements"]
        .contains(elementValue)) {
      mapToLogTo[itemID]["setAttributes"][attributeKey]["addedElements"]
          .remove(elementValue);
    }
  }

  static void _prepareLogSlotForSetAttribute(
      String itemID, String nameOfItemType, String attributeKey) {
    int changeDate = DateTime.now().millisecondsSinceEpoch;
    TFC_SerializingMap mapToLogTo = _getMapToLogChangeTo(itemID);
    _createNewLogSlotForItem(itemID, nameOfItemType);
    if (!mapToLogTo[itemID]["setAttributes"].containsKey(attributeKey)) {
      mapToLogTo[itemID]["setAttributes"][attributeKey] =
          Map<String, dynamic>();
    }
    mapToLogTo[itemID]["setAttributes"][attributeKey]["attributeKey"] =
        attributeKey;
    mapToLogTo[itemID]["setAttributes"][attributeKey]["changeDate"] =
        changeDate;
    if (!mapToLogTo[itemID]["setAttributes"][attributeKey]
        .containsKey("removedElements")) {
      mapToLogTo[itemID]["setAttributes"][attributeKey]["removedElements"] =
          List<dynamic>();
    }
    if (!mapToLogTo[itemID]["setAttributes"][attributeKey]
        .containsKey("addedElements")) {
      mapToLogTo[itemID]["setAttributes"][attributeKey]["addedElements"] =
          List<dynamic>();
    }
  }

  static void _createNewLogSlotForItem(String itemID, nameOfItemType) {
    TFC_SerializingMap mapToLogTo = _getMapToLogChangeTo(itemID);
    if (!mapToLogTo.containsKey(itemID)) {
      mapToLogTo[itemID] = {
        "itemType": nameOfItemType,
        "itemID": itemID,
        "attributes": Map<String, dynamic>(),
        "setAttributes": Map<String, dynamic>()
      };
    }
  }

  static TFC_SerializingMap _getMapToLogChangeTo(itemID) {
    return (_newItems.map.containsKey(itemID))
        ? _newItems.map
        : _itemChanges.map;
  }

  static void logImageCreation(String imageID, String fileName) {
    _imagesToUpload.map[imageID] = {"imageID": imageID, "fileName": fileName};
    if (!_imageUploadIsRunning) {
      _uploadImages();
    }
  }

  static void _logImageUpload(String imageID, String fileName) {
    _imageChanges.map[imageID] = {
      "imageID": imageID,
      "fileName": fileName,
      "changeDate": DateTime.now().millisecondsSinceEpoch,
      "action": "created"
    };
  }

  static void logImageDeletion(String imageID, String fileName) {
    if (_imagesToUpload.map.containsKey(imageID)) {
      _imagesToUpload.map.remove(imageID);
    } else if (_imageChanges.map.containsKey(imageID) &&
        _imageChanges.map["action"] == "created") {
      _imageChanges.map.remove(imageID);
    } else {
      _imageChanges.map[imageID] = {
        "imageID": imageID,
        "fileName": fileName,
        "changeDate": DateTime.now().millisecondsSinceEpoch,
        "action": "deleted"
      };
    }
  }

  static void _applyNewImages(List<dynamic> newImages) {
    for (dynamic newImageData in newImages) {
      requestImageDownload(newImageData["fileName"]);
    }
  }

  static void _applyImageDeletions(List<dynamic> imageDeletions) {
    for (dynamic imageData in imageDeletions) {
      TFC_ImageUtilities.deleteImage(
          imageData["imageID"], imageData["fileName"],
          shouldLogDeletion: false);
    }
  }

  static bool _imageUploadIsRunning = false;
  static void _uploadImages() async {
    _imageUploadIsRunning = true;
    while (_imagesToUpload.map.length > 0) {
      String imageKey = _imagesToUpload.map.keys.first;
      bool uploadWasSuccessful = false;
      while (!uploadWasSuccessful) {
        String fileName = _imagesToUpload.map[imageKey]["fileName"];
        String imageID = _imagesToUpload.map[imageKey]["imageID"];
        uploadWasSuccessful = await _uploadFileToS3(imageID, fileName);
        if (uploadWasSuccessful) {
          _imagesToUpload.map.remove(imageKey);
        } else {
          await Future.delayed(Duration(seconds: 3));
        }
      }
      _imageUploadIsRunning = _imagesToUpload.map.length > 0;
    }
    _imageUploadIsRunning = false;
  }

  static Future<bool> _uploadFileToS3(String imageID, String fileName) async {
    Uint8List imageBytes = TFC_DiskController.readFileAsBytes(fileName);
    bool uploadWasSuccessful = false;
    try {
      // Get an S3 put url
      HTTP.Response getURLResponse = await HTTP.post(
        "$REST_GATEWAY_URL/get_image_upload_url",
        //"https://mrg881k84f.execute-api.us-west-2.amazonaws.com/alpha/upload",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "x-api-key": RELEASE_API_KEY
        },
        body: jsonEncode({"fileName": fileName, "clientID": clientID}),
      );

      if (getURLResponse.statusCode == 200) {
        String putURL = jsonDecode(getURLResponse.body)["putURL"];
        HTTP.Response uploadResponse = await HTTP.put(
          putURL,
          headers: <String, String>{
            'Content-Type': '',
          },
          body: imageBytes,
        );
        uploadWasSuccessful = uploadResponse.statusCode == 200;
        if (uploadWasSuccessful) {
          _logImageUpload(imageID, fileName);
        }
      }
    } catch (e) {
      uploadWasSuccessful = false;
      log(e.toString());
    }
    return uploadWasSuccessful;
  }

  static void requestImageDownload(String fileName) {
    _imagesToDownload.map[fileName] = {"fileName": fileName};
    if (!_imageDownloadIsRunning) {
      _downloadImages();
    }
  }

  static final TFC_Event onImageFileDownloaded = TFC_Event();
  static bool _imageDownloadIsRunning = false;
  static void _downloadImages() async {
    _imageDownloadIsRunning = true;
    while (_imagesToDownload.map.length > 0) {
      String imageKey = _imagesToDownload.map.keys.first;
      bool downloadWasSuccessful = false;
      while (!downloadWasSuccessful) {
        String fileName = _imagesToDownload.map[imageKey]["fileName"];
        downloadWasSuccessful = await _downloadFileFromS3(fileName);
        if (downloadWasSuccessful) {
          onImageFileDownloaded.trigger();
          _imagesToDownload.map.remove(imageKey);
        } else {
          await Future.delayed(Duration(seconds: 3));
        }
      }
      _imageDownloadIsRunning = _imagesToDownload.map.length > 0;
    }
    _imageDownloadIsRunning = false;
  }

  static Future<bool> _downloadFileFromS3(String fileName) async {
    bool downloadWasSuccessful = false;
    try {
      // Get an S3 get url
      HTTP.Response getURLResponse = await HTTP.post(
        "$REST_GATEWAY_URL/get_image_download_url",
        //"https://d3gzz3g4nh55ox.cloudfront.net/" + fileName,
        //"https://8fg44b1i7l.execute-api.us-west-2.amazonaws.com/alpha/requestiamgegeturl",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "x-api-key": RELEASE_API_KEY
        },
        body: jsonEncode({"fileName": fileName, "clientID": clientID}),
      );
      /*HTTP.Response getURLResponse = await HTTP.get(
        "$REST_GATEWAY_URL/get_image_download_url",
        //"https://d2b92sufjxs5yt.cloudfront.net/" + fileName,
        //"https://8fg44b1i7l.execute-api.us-west-2.amazonaws.com/alpha/requestiamgegeturl",
        //headers: <String, String> { 'Content-Type': 'application/json; charset=UTF-8', },
        //body: jsonEncode({ "fileName": fileName }),
      );*/

      /*if (getURLResponse.statusCode == 200) {
        TFC_DiskController.writeFileAsBytes(
            fileName, getURLResponse.bodyBytes);
      }*/
      downloadWasSuccessful = getURLResponse.statusCode == 200;

      if (getURLResponse.statusCode == 200) {
        String getURL = jsonDecode(getURLResponse.body)["getURL"];
        HTTP.Response downloadResponse = await HTTP.get(getURL);
        if (downloadResponse != null) {
          if (downloadResponse.statusCode == 200) {
            TFC_DiskController.writeFileAsBytes(
                fileName, downloadResponse.bodyBytes);
          }
          downloadWasSuccessful = downloadResponse.statusCode == 200;
        }
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
    return downloadWasSuccessful;
  }
}
