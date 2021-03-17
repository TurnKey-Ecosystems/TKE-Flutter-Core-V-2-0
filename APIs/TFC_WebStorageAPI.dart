import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as DartHTML;
import '../Utilities/TFC_Utilities.dart';

import '../AppManagment/TFC_FlutterApp.dart';
import '../APIs/TFC_IDeviceStorageAPI.dart';

class TFC_WebStorageAPI extends TFC_IDeviceStorageAPI {
  DartHTML.Storage _webStorage;

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
  Uint8List readFileAsBytes(String fileName, FileLocation fileLocation) {
    String contentsAsString = readFileAsString(fileName, fileLocation);
    return base64.decode(contentsAsString);
  }

  @override
  String readFileAsString(String fileName, FileLocation fileLocation) {
    String filePath = _getFileLocationPrefix(fileLocation) + fileName;
    return _webStorage[filePath];
  }

  // Write Functions
  @override
  void writeFileAsBytes(
      String fileName, Uint8List contents, FileLocation fileLocation) {
    String contentsAsString = base64.encode(contents);
    writeFileAsString(fileName, contentsAsString, fileLocation);
  }

  @override
  void writeFileAsString(
      String fileName, String contents, FileLocation fileLocation) {
    String filePath = _getFileLocationPrefix(fileLocation) + fileName;
    _webStorage[filePath] = contents;
  }

  // Image Functions
  Future<Uint8List> getExternalImageBytes() async {
    DartHTML.InputElement uploadInput = DartHTML.FileUploadInputElement();
    uploadInput.click();

    Uint8List uploadedImageBytes;
    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
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
    return uploadedImageBytes;
  }

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
    List<String> fileNamesFromRequestedFileLocation = List();
    List<String> allFilePaths = _webStorage.keys;
    String fileLocationPrefix = _getFileLocationPrefix(fileLocation);
    for (String filePath in allFilePaths) {
      if (filePath.startsWith(fileLocationPrefix)) {
        String fileName = filePath.substring(fileLocationPrefix.length);
        fileNamesFromRequestedFileLocation.add(fileName);
      }
    }
    return fileNamesFromRequestedFileLocation;
  }

  String _getFileLocationPrefix(FileLocation fileLocation) {
    String fileLocationAsString;
    if (fileLocation == FileLocation.LOCAL) {
      fileLocationAsString = "local";
    } else if (fileLocation == FileLocation.EXPORT) {
      fileLocationAsString = "export";
    } else {
      throw ("TFC_WebStorageAPI._getFileLocationPrefix() does not support $fileLocation!");
    }
    return fileLocationAsString + "/";
  }
}
