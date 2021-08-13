import 'TFC_Failable.dart';
import '../DataStructures/TFC_Change.dart';


/** Describes the functions TFC will use to sync with the cloud. */
abstract class TFC_ICloudSyncInterface {
  /** This gives a more readable way of saying that no syncing will occur. */
  static const TFC_ICloudSyncInterface? cloudSyncDisabled = null;


  /** */
  Future<void> setupSyncInterface();


  /** Get all the changes that have showed up in the cloud since the last sync
   * event. It is okay to retrieve changes that have already been applied on 
   * this device, just make sure all the new changes are returned. */ 
  Future<TFC_Failable<List<TFC_Change>>> getAllChangesSinceLastSyncEventAndPossiblySomExtraChangesAsWell();
  

  /** Performs any nessecary actions that take palce after new changes from the
   * cloud have been successfully applied. */ 
  Future<TFC_Failable<void>?> performSomeActionsAfterNewChangesAreSuccessfullyApplied({
    required List<TFC_Change> changes,
  });


  /** Pushes a batch of changes to the cloud. */
  Future<TFC_Failable<void>> pushChanges({
    required int pushBatchIndex,
    required List<TFC_Change> changes,
  });
}