import 'package:flutter/cupertino.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/APIs/TFC_Failable.dart';
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

    // Return once the first pull finishes (regardless of whether or not it was successful).
    await TFC_Utilities.when(() => _firstPullOfTheSessionHasBeenCompleted);
  }


  /** The number of seconds to wait between each pull loop. */
  static const double _SECONDS_TO_WAIT_BETWEEN_PULL_LOOPS = 5.0;

  /** This is set to true when the first pull of this session completes successfully or times out. */
  static bool _firstPullOfTheSessionHasBeenCompleted = false;

  /** Continuosly check for changes in the cloud, and apply them. */
  static Future<void> _runPullLoop() async {
    while (true) {
      debugPrint("Starting pull.");
      // Pull any new changes from the cloud
      TFC_Failable<List<TFC_Change>> getNewChangesFromCloud_Response =
        await _syncInterface.getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell();

      // As of yet, we do not care whether or not getting new changes fails
      List<TFC_Change> newChangesFromCloud = getNewChangesFromCloud_Response.returnValue;

      // All changes from the cloud need to be applied at the device level
      for (TFC_Change change in newChangesFromCloud) {
        change.changeApplicationDepth = TFC_SyncDepth.DEVICE;
      }
      
      // Apply all the new changes from the cloud
      TFC_AllItemsManager.applyChangesIfRelevant(changes: newChangesFromCloud);

      // Perform any nessecary actions that need to take place after the successful application
      _syncInterface.performSomeActionsAfterNewChangesAreSuccessfullyApplied(changes: newChangesFromCloud);

      // Regardless of whether or not this pull was successful or not, the first pull is done.
      _firstPullOfTheSessionHasBeenCompleted = true;

      // The app shouldn't be constantly syncing, so wait a few seconds before syncing again.
      await Future.delayed(Duration(milliseconds: (_SECONDS_TO_WAIT_BETWEEN_PULL_LOOPS * 1000).round()));
    }
  }


  /** This is the number of seconds to sleep between each push loop. */
  static final double _SECONDS_TO_WAIT_BETWEEN_PUSH_LOOPS = 5 / 4;
  
  static final TFC_AutoSavingProperty<int> _pushBatchIndex =
    TFC_AutoSavingProperty(
      initialValue: 0,
      fileNameWithoutExtension: "tfc_pushBatchIndex",
    );
  
  /** Whether or not the changes in _changesBeingPushed have been successfully pushed to the cloud. */
  static final TFC_AutoSavingProperty<bool> _changesBeingPushedHaveBeenSuccessfullyPushed =
    TFC_AutoSavingProperty(
      initialValue: false,
      fileNameWithoutExtension: "tfc_changesBeingPushedHaveBeenSuccessfullyPushed",
    );
  
  /** Baring problems when pushing _changesBeingPushed, this is the maximum number
   *  push loops to wait before attempting to push changes in _changesToPush. */
  static final int _MAX_PUSH_DELAY_LOOP_COUNT = 4;
  
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
        && _numberOfPushLoopsNewChangesHaveBeenDelayed < _MAX_PUSH_DELAY_LOOP_COUNT;
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
          pushBatchIndex: _pushBatchIndex.value,
          changes: _changesBeingPushed.allElements.toList(),
        )).succeeded;
      
        // If everything looks good, then perform some clean up.
        if (_changesBeingPushedHaveBeenSuccessfullyPushed.value) {
          // Increment the batch counter
          _pushBatchIndex.value += 1;
          
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
      await Future.delayed(Duration(milliseconds: (_SECONDS_TO_WAIT_BETWEEN_PUSH_LOOPS * 1000).round()));
    }
  }
}
