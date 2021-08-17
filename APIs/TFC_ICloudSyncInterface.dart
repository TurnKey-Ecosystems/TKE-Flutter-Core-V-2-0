import 'dart:typed_data';

import 'TFC_Failable.dart';
import '../DataStructures/TFC_Change.dart';


// TODO: Maybe rename this to TFC_ICloudSyncImplementation
/** Describes the functions TFC will use to sync with the cloud. */
abstract class TFC_ICloudSyncInterface {
  /** This gives a more readable way of saying that no syncing will occur. */
  static const TFC_ICloudSyncInterface? cloudSyncDisabled = null;

  
  /** This is the number of seconds to wait between pull loops. */
  double get secondsToWaitBetweenPullLoops;
  
  /** This is the number of seconds to wait between push loops. */
  double get secondsToWaitBetweenPushLoops;
  
  /** This is the maximum number of push loops to hold off on pushing a change while new changes keep coming in. */
  int get maxPushLoopsToDelayPushingWhileChangesAreContinuingToBeMade;


  /** */
  Future<void> setupSyncInterface();


  /** Get all the changes that have showed up in the cloud since the last sync
   * event. It is okay to retrieve changes that have already been applied on 
   * this device, just make sure all the new changes are returned. */ 
  Future<TFC_Failable<TFC_PullResults?>> getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell();

  /** Pushes a batch of changes to the cloud. */
  Future<TFC_Failable<void>> pushChanges(List<TFC_Change> changes);


  /** Download an image. */
  Future<TFC_Failable<Uint8List?>> downloadImage({
    required String fileName,
  });

  /** Upload an image. */
  Future<TFC_Failable<void>> uploadImage({
    required String fileName,
    required Uint8List bytes,
  });

  /** Delete an image. */
  Future<TFC_Failable<void>> deleteImage({
    required String fileName,
  });
}





/** Uses as the return type of TFC_ICloudSyncInterface.getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell() */
class TFC_PullResults {
  /** The changes that where pulled. */
  final List<TFC_Change> changes;

  /** Whether or not there are more changes that need to be pulled. */
  final bool thereAreMoreChangesToPull;
  
  /** Performs any nessecary actions that take palce after new changes from the
   * cloud have been successfully applied. */
  final Future<void> Function()? _afterTheseChangesAreAppledDoThis;
  /** Performs any nessecary actions that take palce after new changes from the
   * cloud have been successfully applied. */
  Future<void> afterTheseChangesAreAppledDoThis() async {
    if (_afterTheseChangesAreAppledDoThis != null) {
      await _afterTheseChangesAreAppledDoThis!();
    }
  }

  /** Creates a new pull resutls object. */
  TFC_PullResults({
    required this.changes,
    required this.thereAreMoreChangesToPull,
    required Future<void> Function()? afterTheseChangesAreAppledDoThis,
  })
    : this._afterTheseChangesAreAppledDoThis = afterTheseChangesAreAppledDoThis;
}