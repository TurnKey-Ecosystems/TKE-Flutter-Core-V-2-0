import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/APIs/TFC_Failable.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/APIs/TFC_IDeviceStorageAPI.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/AppManagment/TFC_DiskController.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/Utilities/TFC_Utilities.dart';

import '../DataStructures/TFC_AllItemsManager.dart';
import '../DataStructures/TFC_SyncDepth.dart';
import '../DataStructures/TFC_Change.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../APIs/TFC_ICloudSyncInterface.dart';


/** Manages the sync loop. */
class TFC_SyncController {
  /** We keep these two in a list so we can hot swap between which one is
   *  being pushed and which one is waiting to be pushed. */
  static final List<TFC_AutoSavingSet<TFC_Change>> _changeLists = [
    TFC_AutoSavingSet<TFC_Change>(
      fileNameWithoutExtension: "tfc_changeList0",
      elementToJson: (TFC_Change change) {
        return change.toJson();
      },
      elementFromJson: (dynamic json) {
        return TFC_Change.fromJson(json);
      }
    ),
    TFC_AutoSavingSet<TFC_Change>(
      fileNameWithoutExtension: "tfc_changeList1",
      elementToJson: (TFC_Change change) {
        return change.toJson();
      },
      elementFromJson: (dynamic json) {
        return TFC_Change.fromJson(json);
      }
    ),
  ];

  /** This controls which list is being pushed and which list is waiting to
   *  be pushed. */
  static final TFC_AutoSavingProperty<int> _indexOfChangeListThatIsBeingPushed =
    TFC_AutoSavingProperty(
      initialValue: 0,
      fileNameWithoutExtension: "tfc_changeListThatIsBeingPushed",
    );
  
  /** Swaps which change list is being pushed and which one is waiting to be
   *  pushed. */
  static void _swapChangesToPushToChangesBeingPushed() {
    _indexOfChangeListThatIsBeingPushed.value =
      (_indexOfChangeListThatIsBeingPushed.value + 1) % 2;
  }

  /** Gets the list of changes that are actively being pushed.  */
  static TFC_AutoSavingSet<TFC_Change> get _changesBeingPushed {
    return _changeLists[_indexOfChangeListThatIsBeingPushed.value];
  }

  /** Gets the list of changes that will be pushed at the next sync event. */
  static TFC_AutoSavingSet<TFC_Change> get _changesToPush {
    int changeListIndex = (_indexOfChangeListThatIsBeingPushed.value + 1) % 2;
    return _changeLists[changeListIndex];
  }

  /** Add a change to be pushed at the next sync event. */
  static void commitChange(TFC_Change change) {
    _changesToPush.add(change);
  }

  /** Add a list of changes to be pushed at the next sync event. */
  static void commitChanges(List<TFC_Change> changes) {
    _changesToPush.addAll(changes);
  }
  

  /** A abstraction that allows each app to implement cloud file storage in its own way. */
  static late final TFC_ICloudSyncInterface _syncInterface;

  /** Constantly pulls and applies changes from the cloud, push local
   * changes to the cloud, waits a few seconds, and then does it all again. */
  static Future<void> startTheSyncLoops({
    required TFC_ICloudSyncInterface syncInterface,
  }) async {
    // Setup the sync interface
    await syncInterface.setupSyncInterface();
    TFC_SyncController._syncInterface = syncInterface;

    // Run the sync loop
    _runPullLoop();
    _runPushLoop();
    imageDownloader.runFulfillmentLoop();
    imageUploader.runFulfillmentLoop();
    imageDeleter.runFulfillmentLoop();

    // Return once the first pull finishes (regardless of whether or not it was successful).
    await TFC_Utilities.when(() => _firstPullOfTheSessionHasBeenCompleted);
    debugPrint("Returnning from startTheSyncLoops().");
  }


  /** This is set to true when the first pull of this session completes successfully or times out. */
  static bool _firstPullOfTheSessionHasBeenCompleted = false;

  /** Continuosly check for changes in the cloud, and apply them. */
  static Future<void> _runPullLoop() async {
    while (true) {
      debugPrint("Starting pull.");
      // Pull any new changes from the cloud
      TFC_Failable<TFC_PullResults?> getNewChangesFromCloud_Response =
        await _syncInterface.getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell();
      debugPrint("Returned from Basic sync implementation.");

      // If everything looks good, then apply the changes.
      if (getNewChangesFromCloud_Response.succeeded) {
        // As of yet, we do not care whether or not getting new changes fails
        TFC_PullResults getNewChanges_Results = getNewChangesFromCloud_Response.returnValue!;

        // All changes from the cloud need to be applied at the device level
        for (TFC_Change change in getNewChanges_Results.changes) {
          change.changeApplicationDepth = TFC_SyncDepth.DEVICE;
        }
        
        // Apply all the new changes from the cloud
        TFC_AllItemsManager.applyChangesIfRelevant(changes: getNewChanges_Results.changes);
        
        // Let the api implementation do anything it wants to now that these changes have been applied.
        await getNewChanges_Results.afterTheseChangesAreAppledDoThis();
      }

      // Get up to date as fast as possible, and then slow down to save money.
      bool shouldRerunImmediately = getNewChangesFromCloud_Response.succeeded
        && getNewChangesFromCloud_Response.returnValue!.thereAreMoreChangesToPull;
      if (!shouldRerunImmediately) {
        // We'll wait until we're up to date before we say that the first pull of the session has been completed.
        _firstPullOfTheSessionHasBeenCompleted = true;

        // So conserve the cost of querying databases, we'll wait a bit between pull loops.
        await Future.delayed(Duration(milliseconds: (_syncInterface.secondsToWaitBetweenPullLoops * 1000).round()));
      }
    }
  }


  /** Whether or not the changes in _changesBeingPushed have been successfully pushed to the cloud. */
  static final TFC_AutoSavingProperty<bool> _changesBeingPushedHaveBeenSuccessfullyPushed =
    TFC_AutoSavingProperty(
      initialValue: false,
      fileNameWithoutExtension: "tfc_changesBeingPushedHaveBeenSuccessfullyPushed",
    );
  
  /** This is the number of push loops that there have been unpushed changes in
   *  the _changesToPush list. */
  static int _numberOfPushLoopsNewChangesHaveBeenDelayed = 0;
  
  /** This is the number of changes that were in the _changesToPush list durring the last push loop.  */
  static int _numberOfChangesToPushLastLoop = 0;

  /** Continuously checks for local changes, and pushes them when this functions deems it fit to do so. */
  static Future<void> _runPushLoop() async {
    // Keep watching and pushing until the app is closed
    while (true) {
      debugPrint("Starting push.");
      // Determine whehter or not any changes have been commited since the last push loop
      bool changesHaveBeenCommittedSinceLastLoop =
        _changesToPush.allElements.length > _numberOfChangesToPushLastLoop;
      debugPrint("_changesToPush.allElements.length: ${_changesToPush.allElements.length}");
      debugPrint("_numberOfChangesToPushLastLoop: ${_numberOfChangesToPushLastLoop}");
      debugPrint("changesHaveBeenCommittedSinceLastLoop: ${changesHaveBeenCommittedSinceLastLoop}");
      _numberOfChangesToPushLastLoop = _changesToPush.allElements.length;

      // If changes are still coming in, then it might make sense to wait a little bit longer before we push.
      bool shouldDelayPushingChangesToPush =
        changesHaveBeenCommittedSinceLastLoop
        && _numberOfPushLoopsNewChangesHaveBeenDelayed < _syncInterface.maxPushLoopsToDelayPushingWhileChangesAreContinuingToBeMade;
      debugPrint("_numberOfPushLoopsNewChangesHaveBeenDelayed: ${_numberOfPushLoopsNewChangesHaveBeenDelayed}");
      debugPrint("shouldDelayPushingChangesToPush: ${shouldDelayPushingChangesToPush}");

      // If everything looks good, then make the changesToPush become changesBeingPushed.
      if (
        // We only care about pushing if there are actually changes to push
        _changesToPush.allElements.length > 0
        // Sometimes we want to delay pushing to let more changes come in
        && !shouldDelayPushingChangesToPush
        /* We want to wait to push any new changes, until the last
         * batch of changes has been successfully pushed. */
        && _changesBeingPushedHaveBeenSuccessfullyPushed.value
      ) {
        // We update this variable first, so that if something goes wrong the changes don't get discarded.
        _changesBeingPushedHaveBeenSuccessfullyPushed.value = false;
        _swapChangesToPushToChangesBeingPushed();
        _numberOfChangesToPushLastLoop = 0;
        _numberOfPushLoopsNewChangesHaveBeenDelayed = 0;
      
      /* If there were changes to push, but we chose not to push
       * them, then record that they have been delayed another push
       * loop. */
      } else if (_changesToPush.allElements.length > 0) {
        _numberOfPushLoopsNewChangesHaveBeenDelayed++;
        debugPrint("Delaying: ${_numberOfPushLoopsNewChangesHaveBeenDelayed}");
      }

      // Push the changes in the _changesBeingPushed list.
      if (_changesBeingPushed.allElements.length > 0) {
        _changesBeingPushedHaveBeenSuccessfullyPushed.value = (await _syncInterface.pushChanges(
          _changesBeingPushed.allElements.toList(),
        )).succeeded;
      
        // If everything looks good, then perform some clean up.
        if (_changesBeingPushedHaveBeenSuccessfullyPushed.value) {
          // Now that the changes have been pushed, empty the change list.
          List<TFC_Change> changesToDelete = _changesBeingPushed.allElements.toList();
          for (TFC_Change change in changesToDelete) {
            _changesBeingPushed.remove(change);
          }
        }
      // If there were no changes, then, by default, this push was successful.
      } else {
        _changesBeingPushedHaveBeenSuccessfullyPushed.value = true;
      }

      // Wait a little bit to let changes keep accumulating or stop accumulating
      await Future.delayed(Duration(milliseconds: (_syncInterface.secondsToWaitBetweenPushLoops * 1000).round()));
    }
  }


  /** Download an image. */
  static final TFC_AsyncQueueManager<Uint8List> imageDownloader = 
    TFC_AsyncQueueManager(
      queueSaveName: "tfc_namesOfImageFilesToDownload",
      fulfillRequest: (String key) => _syncInterface.downloadImage(fileName: key),
    );

  /** These are the images that need to get uploaded. */
  static final TFC_AsyncQueueManagerWithLargeFile<void, Uint8List> imageUploader = 
    TFC_AsyncQueueManagerWithLargeFile(
      queueSaveName: "tfc_namesOfImageFilesToUpload",
      valueToString: (Uint8List value) => base64Encode(value),
      valueFromString: (String string) => base64Decode(string),
      fulfillRequest: (String key, Uint8List value) => _syncInterface.uploadImage(fileName: key, bytes: value),
    );

  /** Delete an image. */
  static final TFC_AsyncQueueManager<void> imageDeleter = 
    TFC_AsyncQueueManager(
      queueSaveName: "tfc_namesOfImageFilesToDelete",
      fulfillRequest: (String key) => _syncInterface.deleteImage(fileName: key),
    );
}





/** */
class TFC_AsyncQueueManager<ReturnType> {
  final TFC_AutoSavingSet<String> _requestKeys;
  final Future<TFC_Failable<ReturnType?>> Function(String) fulfillRequest;
  final Map<int, ReturnType> _returnedValues = Map();
  int _nextRequestIndex = 0;
    
  TFC_AsyncQueueManager({
    required String queueSaveName,
    required this.fulfillRequest,
  })
    : _requestKeys = TFC_AutoSavingSet(
        fileNameWithoutExtension: queueSaveName,
        elementToJson: (String element) => element,
        elementFromJson: (dynamic json) => json,
      );
  
  Future<ReturnType> makeRequest({required String key}) async {
    int requestIndex = _nextRequestIndex;
    _nextRequestIndex++;
    _requestKeys.add(key);
    return Future(() async {
      await TFC_Utilities.when(() => _returnedValues.containsKey(requestIndex));
      ReturnType returnedValue = _returnedValues[requestIndex]!;
      _returnedValues.remove(requestIndex);
      return returnedValue;
    });
  }

  void runFulfillmentLoop() async {
    while (true) {
      // Upload all the images
      Set<String> requestKeys = _requestKeys.allElements;
      for (String key in requestKeys) {
        // Prepare for the worst
        TFC_Failable<ReturnType?> fulfillmentResults = TFC_Failable.failed(
          returnValue: null,
          errorObject: Exception("Something went wrong."),
        );

        // Upload the image
        fulfillmentResults = await fulfillRequest(key);

        // Clean up
        if (fulfillmentResults.succeeded) {
          TFC_DiskController.deleteFile(key, fileLocation: FileLocation.SYNC_CACHE);
          _requestKeys.remove(key);
        }
      }

      // Sleep for a little bit
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
}

class TFC_AsyncQueueManagerWithLargeFile<ReturnType, ParamValueType> {
  final TFC_AutoSavingSet<String> _requestKeys;
  final String Function(ParamValueType) _valueToString;
  final ParamValueType Function(String) _valueFromString;
  final Future<TFC_Failable<ReturnType?>> Function(String, ParamValueType) fulfillRequest;
  final Map<int, ReturnType> _returnedValues = Map();
  int _nextRequestIndex = 0;
    
  TFC_AsyncQueueManagerWithLargeFile({
    required String queueSaveName,
    required String Function(ParamValueType) valueToString,
    required ParamValueType Function(String) valueFromString,
    required this.fulfillRequest,
  })
    : _requestKeys = TFC_AutoSavingSet(
        fileNameWithoutExtension: queueSaveName,
        elementToJson: (String element) => element,
        elementFromJson: (dynamic json) => json,
      ),
      _valueToString = valueToString,
      _valueFromString = valueFromString;
  
  Future<ReturnType> makeRequest({required String key, required ParamValueType value}) async {
    int requestIndex = _nextRequestIndex;
    _nextRequestIndex++;
    TFC_DiskController.writeFileAsString(
      key,
      _valueToString(value),
      fileLocation: FileLocation.SYNC_CACHE,
    );
    _requestKeys.add(key);
    return Future(() async {
      await TFC_Utilities.when(() => _returnedValues.containsKey(requestIndex));
      ReturnType returnedValue = _returnedValues[requestIndex]!;
      _returnedValues.remove(requestIndex);
      return returnedValue;
    });
  }

  void runFulfillmentLoop() async {
    while (true) {
      // Upload all the images
      Set<String> requestKeys = _requestKeys.allElements;
      for (String key in requestKeys) {
        // Prepare for the worst
        TFC_Failable<ReturnType?> fulfillmentResults = TFC_Failable.failed(
          returnValue: null,
          errorObject: Exception("Something went wrong."),
        );

        // Upload the image
        bool localCacheFileExists = TFC_DiskController.fileExists(key, fileLocation: FileLocation.SYNC_CACHE);
        if (localCacheFileExists) {
          fulfillmentResults = await fulfillRequest(
            key,
            _valueFromString(TFC_DiskController.readFileAsString(
              key,
              fileLocation: FileLocation.SYNC_CACHE,
            )!),
          );
        }

        // Clean up
        if (fulfillmentResults.succeeded || !localCacheFileExists) {
          TFC_DiskController.deleteFile(key, fileLocation: FileLocation.SYNC_CACHE);
          _requestKeys.remove(key);
        }
      }

      // Sleep for a little bit
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
}
