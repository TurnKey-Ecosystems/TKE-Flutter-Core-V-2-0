# Setup Sync Controller
 1. TODO: Figure out startup

# Sync Algorithm
 1. Retrieve and apply changes from the cloud.
    1. Get all change log file names.
    2. Discard the names of all change log files that have already been applied.
    3. Download all un-applied change log files.
    4. Sort attribute changes into one list, and item creation or deletion changes into another list (only keep the most recent item creation or deletion change for each item).
    5. Apply all the item creation and deletion changes.
    6. Apply all the attribute changes. (Don't bother applying any attribute changes for which the item does not exits).
    7. Add the names of the now applied-change logs to the list of applied change log file names.
 2. Commit local changes.
```diff
 - Update the auto-saving property `changesThatAreActivelyBeingCommited` to reference the other change list. (There are two, one empty and the other full of changes. Point it at the one that is full of changes.)
```
    1. Update the `changesToCommitInNextSync` pointer to point to the empty list.
    2. Compile all the changes in the `changesThatAreActivelyBeingCommited` list into a change log json, and give it the current posix time.
    3. Upload this new change log file.
    4. Add this new change log's file name to the list of applied change log file names.
 5. Repeat
    1. Schedule the sync algorithm to run again in a few seconds.
