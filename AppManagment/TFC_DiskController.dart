import 'dart:developer';
import 'dart:async';
import 'dart:typed_data';
import '../APIs/TFC_PlatformAPI.dart';
import '../APIs/TFC_IDeviceStorageAPI.dart';
import 'package:path/path.dart' as Path;

class TFC_DiskController {
  static bool _diskControllerHasBeenSetup = false;
  static bool get diskControllerHasBeenSetup {
    return _diskControllerHasBeenSetup;
  }
  static TFC_IDeviceStorageAPI get _deviceStorageAPI {
    return TFC_PlatformAPI.platformAPI.deviceStorageAPI;
  }

  // Setup Functions
  static Future setupTFCDiskController() async {
    _diskControllerHasBeenSetup = true;
    log("TFC: TFC_DiskController setup complete.");
    writeFileAsString("DiskController.txt", "TFC_DiskController setup complete.");
  }

  // File getter functions
  static List<String> getLocalFileNamesFromFileNamePattern(String pattern) {
    List<String> matchingFileNames = List();
    List<String> allLocalFileNames = listFileNames(fileLocation: FileLocation.LOCAL);

    allLocalFileNames.forEach((fileName) {
      String thisFileBaseNameWitoutExtension = Path.basenameWithoutExtension(fileName);

      if (RegExp(pattern).hasMatch(thisFileBaseNameWitoutExtension)) {
        matchingFileNames.add(fileName);
      }
    });

    return matchingFileNames;
  }

  static List<String> getLocalFileNamesFromFileExtension(String fileExtension) {
    List<String> matchingFileNames = List();
    List<String> allLocalFileNames = listFileNames(fileLocation: FileLocation.LOCAL);

    allLocalFileNames.forEach((fileName) {
      if (Path.extension(fileName) == fileExtension) {
        matchingFileNames.add(fileName);
      }
    });

    return matchingFileNames;
  }
  
  // Deletion functions
  static void deleteFile(String fileName, { FileLocation fileLocation = FileLocation.LOCAL }) {
    _deviceStorageAPI.deleteFile(fileName, fileLocation);
  }

  // Read Functions
  static Uint8List readFileAsBytes(String fileName, { FileLocation fileLocation = FileLocation.LOCAL }) {
    return _deviceStorageAPI.readFileAsBytes(fileName, fileLocation);
  }

  static String readFileAsString(String fileName, { FileLocation fileLocation = FileLocation.LOCAL }) {
    return _deviceStorageAPI.readFileAsString(fileName, fileLocation);
  }

  // Write Functions
  static void writeFileAsString(String fileName, String data, { FileLocation fileLocation = FileLocation.LOCAL }) {
    _deviceStorageAPI.writeFileAsString(fileName, data, fileLocation);
  }

  static void writeFileAsBytes(String fileName, Uint8List data, { FileLocation fileLocation = FileLocation.LOCAL }){
    _deviceStorageAPI.writeFileAsBytes(fileName, data, fileLocation);
  }
  
  // Image Functions
  static Future<Uint8List> getExternalImageBytes() async {
    return _deviceStorageAPI.getExternalImageBytes();
  }

  // Utility Functions
  static const DEFAULT_FILE_NAME_PART_SEPERATOR = "_";
  static String createFileNameWithExtension(List<String> fileNameParts, String fileExtension) {
    String newFileNameWithExtension = "";

    for (int fileNamePartIndex = 0; fileNamePartIndex < fileNameParts.length; fileNamePartIndex++) {
      newFileNameWithExtension += fileNameParts[fileNamePartIndex];

      // Add a seperatior between each file name part.
      if (fileNamePartIndex != fileNameParts.length - 1) {
        newFileNameWithExtension += DEFAULT_FILE_NAME_PART_SEPERATOR;
      }
    }
    newFileNameWithExtension += fileExtension;

    return newFileNameWithExtension;
  }

  static String exportAllFiles(){
    return _deviceStorageAPI.exportAllFiles();
  }

  static bool fileExists(String fileName, { FileLocation fileLocation = FileLocation.LOCAL }){
    return _deviceStorageAPI.fileExists(fileName, fileLocation);
  }

  static List<String> listFileNames({ FileLocation fileLocation = FileLocation.LOCAL }){
    return _deviceStorageAPI.listFileNames(fileLocation);
  }
}