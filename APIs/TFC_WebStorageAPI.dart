import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as DartHTML;
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_io.dart';
import '../Utilities/TFC_Utilities.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../APIs/TFC_IDeviceStorageAPI.dart';

enum _IDBMode { READ_ONLY, READ_WRITE }

class TFC_WebStorageAPI extends TFC_IDeviceStorageAPI {
  late DartHTML.Storage _webStorage;

  // Setup Functions
  @override
  Future<void> setup() async {
    _webStorage = DartHTML.window.localStorage;
  }

  // Deletion functions
  @override
  void deleteFile(String fileName, FileLocation fileLocation) {
    String filePath = _getFileLocationPrefix(fileLocation) + fileName;
    _webStorage.remove(filePath);
  }

  // Read Functions
  @override
  Uint8List? readFileAsBytes(String fileName, FileLocation fileLocation) {
    String? contentsAsString = readFileAsString(fileName, fileLocation);
    return (contentsAsString != null) ? base64.decode(contentsAsString) : null;
  }

  @override
  String? readFileAsString(String fileName, FileLocation fileLocation) {
    String? filePath = _getFileLocationPrefix(fileLocation) + fileName;
    return _webStorage[filePath];
  }

  // Write Functions
  @override
  String writeFileAsBytes(
      String fileName, Uint8List contents, FileLocation fileLocation) {
    String contentsAsString = base64.encode(contents);
    writeFileAsString(fileName, contentsAsString, fileLocation);
    return fileName;
  }

  @override
  String writeFileAsString(
      String fileName, String contents, FileLocation fileLocation) {
    String filePath = _getFileLocationPrefix(fileLocation) + fileName;
    _webStorage[filePath] = contents;
    return fileName;
  }

  // Image Functions
  /*Future<Uint8List> getExternalImageBytes() async {
    DartHTML.InputElement uploadInput = DartHTML.FileUploadInputElement();
    uploadInput.click();

    Uint8List? uploadedImageBytes;
    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        DartHTML.FileReader reader = DartHTML.FileReader();

        reader.onLoadEnd.listen((e) {
          uploadedImageBytes = reader.result;
        });

        reader.readAsArrayBuffer(file);
      }
    });
    await TFC_Utilities.when(() {
      return uploadedImageBytes != null;
    });
    return uploadedImageBytes!;
  }*/

  // Utility Functions
  @override
  String exportAllFiles() {
    String exportFileName =
        TFC_FlutterApp.appName.toLowerCase().replaceAll(" ", "_") +
            "_all_files.zip";
    String exportFilePath =
        _getFileLocationPrefix(FileLocation.EXPORT) + exportFileName;
    _webStorage[exportFilePath] = "";
    return exportFilePath;
  }

  @override
  bool fileExists(String fileName, FileLocation fileLocation) {
    String filePath = _getFileLocationPrefix(fileLocation) + fileName;
    return _webStorage.containsKey(filePath);
  }

  @override
  List<String> listFileNames(FileLocation fileLocation) {
    List<String> fileNamesFromRequestedFileLocation = [];
    String fileLocationPrefix = _getFileLocationPrefix(fileLocation);
    for (String filePath in _webStorage.keys) {
      if (filePath.startsWith(fileLocationPrefix)) {
        String fileName = filePath.substring(fileLocationPrefix.length);
        fileNamesFromRequestedFileLocation.add(fileName);
      }
    }
    return fileNamesFromRequestedFileLocation;
  }

  String _getFileLocationPrefix(FileLocation fileLocation) {
    String fileLocationAsString;
    switch (fileLocation) {
      case FileLocation.LOCAL:
        fileLocationAsString = "local";
        break;
      case FileLocation.EXPORT:
        fileLocationAsString = "export";
        break;
      case FileLocation.SYNC_CACHE:
        fileLocationAsString = "syncCache";
        break;
    }
    return fileLocationAsString + "/";
  }
}
