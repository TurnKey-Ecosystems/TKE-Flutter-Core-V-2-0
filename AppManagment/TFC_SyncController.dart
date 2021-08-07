import '../Serialization/TFC_SerializingContainers.dart';
import '../DataStructures/TFC_Change.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../APIs/TFC_ICloudSyncInterface.dart';


/** Manages the sync loop. */
class TFC_SyncController {
  /** We keep these two in a list so we can hot swap between which one is
   *  being pushed and which one is waiting to be pushed. */
  static final List<TFC_AutoSavingSet> _changeLists = [
    TFC_AutoSavingSet("tfc_changeList0"),
    TFC_AutoSavingSet("tfc_changeList1"),
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
  static void _swapChangeLists() {
    _indexOfChangeListThatIsBeingPushed.value =
      (_indexOfChangeListThatIsBeingPushed.value + 1) % 2;
  }

  /** Gets the list of changes that are actively being pushed.  */
  static TFC_SerializingSet get _changesBeingPushed {
    return _changeLists[_indexOfChangeListThatIsBeingPushed.value].serializingSet;
  }

  /** Gets the list of changes that will be pushed at the next sync event. */
  static TFC_SerializingSet get _changesToPush {
    int changeListIndex = (_indexOfChangeListThatIsBeingPushed.value + 1) % 2;
    return _changeLists[changeListIndex].serializingSet;
  }

  /** Add a change to be pushed at the next sync event. */
  static void commitChange(TFC_Change change) {
    _changesToPush.add(change);
  }

  /** Add a list of changes to be pushed at the next sync event. */
  static void commitChanges(List<TFC_Change> changes) {
    _changesToPush.addAll(changes);
  }
  



  /** The number of seconds to wait between each sync event. */
  static const int SECONDS_TO_WAIT_BETWEEN_SYNCS = 5;

  /** Whether or not the push in the last sync event was successful. */
  static final TFC_AutoSavingProperty<bool> _lastPushWasSuccessful =
    TFC_AutoSavingProperty(
      initialValue: false,
      fileNameWithoutExtension: "tfc_lastPushWasSuccessful",
    );

  /** Constantly pulls and applies changes from the cloud, push local
   * changes to the cloud, waits a few seconds, and then does it all again. */
  static void startSyncLoop({
    required TFC_ICloudSyncInterface syncInterface,
  }) async {
    // Run until the app closes.
    while (true) {
      /* We do this now so that any thread that is actively writing to
      * changesToPush will be done by the time we get around to pushing
      * it.*/
      if (_lastPushWasSuccessful.value) {
        _swapChangeLists();
      }

      // Pull any new changes from the cloud
      List<TFC_Change> newChangesFromCloud =
        await syncInterface.getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell();
      
      // Sort out the item creation and deltion changes
      Map<String, TFC_Change> itemCreationAndDeltionChanges = {};
      List<TFC_Change> changesToAttributes = [];
      for (TFC_Change change in newChangesFromCloud) {
        // Put item creation and deltion changes in a list
        if (
          change.changeType == TFC_ChangeType.ITEM_CREATION
          || change.changeType == TFC_ChangeType.ITEM_DELETION
        ) {
          // Sometimes an item will be both created and deleted since the last sync event.
          bool thereIsAlreadyAMoreRecentChange =
            itemCreationAndDeltionChanges.containsKey(change.itemID)
            && itemCreationAndDeltionChanges[change.itemID]!.changeTimePosix > change.changeTimePosix;
          if (!thereIsAlreadyAMoreRecentChange) {
            itemCreationAndDeltionChanges[change.itemID] = change;
          }
        
        // Put attribute changes in a different list
        } else {
          changesToAttributes.add(change);
        }
      }

      // Apply item changes first becuase some new items might get created.
      // TODO: Make the events from these changes get triggered all in one batch.

      // Apply attribute changes
      // TODO: Make the events from these changes get triggered all in one batch.

      // Perform any nessecary actions that need to take place bewteen the pull an dthe push
      syncInterface.performSomeActionsAfterPushingButBeforePulling();

      // Push local changes
      _lastPushWasSuccessful.value = await syncInterface.pushChanges(
        _changesBeingPushed.toList() as List<TFC_Change>,
      );

      // Now that the changes have been pushed, empty the change list.
      if (_lastPushWasSuccessful.value) {
        List<TFC_Change> changesToDelete = _changesBeingPushed.toList() as List<TFC_Change>;
        for (TFC_Change change in changesToDelete) {
          _changesBeingPushed.remove(change);
        }
      }

      // The app shouldn't be constantly syncing, so wait a few seconds before syncing again.
      await Future.delayed(Duration(seconds: SECONDS_TO_WAIT_BETWEEN_SYNCS));
    }
  }
}
