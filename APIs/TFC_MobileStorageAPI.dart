import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import '../APIs/TFC_IDeviceStorageAPI.dart';
import '../AppManagment/TFC_FlutterApp.dart';

class TFC_MobileStorageAPI extends TFC_IDeviceStorageAPI {
  static const _IOS_LOCAL_DIRECTORY_NAME = "local";
  static const _IOS_EXPORT_DIRECTORY_NAME = "export";
  Map<FileLocation, Directory> _directories = Map();
  Map<FileLocation, String> get _directoryPaths {
    String _localDirectoryPath = _directories[FileLocation.LOCAL].path + "/";
    String _exportDirectoryPath = _directories[FileLocation.EXPORT].path + "/";
    return {
      FileLocation.LOCAL: _localDirectoryPath,
      FileLocation.EXPORT: _exportDirectoryPath
    };
  }

  // Setup Functions
  @override
  Future setup() async {
    if (Platform.isIOS) {
      Directory iosApplicationDirectory =
          await getApplicationDocumentsDirectory();

      // Get the export and local directories
      Directory iosLocalDirectory = Directory(
          iosApplicationDirectory.path + "/" + _IOS_LOCAL_DIRECTORY_NAME);
      if (iosLocalDirectory.existsSync() != true) {
        iosLocalDirectory.createSync();
      }
      Directory iosExportDirectory = Directory(
          iosApplicationDirectory.path + "/" + _IOS_EXPORT_DIRECTORY_NAME);
      if (iosExportDirectory.existsSync() != true) {
        iosExportDirectory.createSync();
      }

      _directories[FileLocation.LOCAL] = iosLocalDirectory;
      _directories[FileLocation.EXPORT] = iosExportDirectory;
    } else if (Platform.isAndroid) {
      _directories[FileLocation.LOCAL] =
          await getApplicationDocumentsDirectory();
      _directories[FileLocation.EXPORT] = await getExternalStorageDirectory();
    } else {
      throw ("TFC_MobileStorageAPI.setup() does not handle this platform!");
    }
    await _cleanUpExportedFiles();
  }

  Future _cleanUpExportedFiles() async {
    List<File> filesToDelete = List();
    List<FileSystemEntity> allExportedFiles =
        await _directories[FileLocation.EXPORT].list().toList();
    for (FileSystemEntity exportedFileEntity in allExportedFiles) {
      // If this is not a directory
      if (Path.basenameWithoutExtension(exportedFileEntity.path) !=
          Path.basename(exportedFileEntity.path)) {
        File exportedFile = File(exportedFileEntity.path);

        try {
          DateTime timeOfLastModification = await exportedFile.lastModified();

          // If it has been more than two days since this file was changed, delete it.
          if (timeOfLastModification
              .add(Duration(days: 2))
              .isAfter(DateTime.now())) {
            filesToDelete.add(exportedFile);
          }
        } catch (e) {
          log(e.toString());
        }
      }
    }
    while (filesToDelete.length > 0) {
      File fileToDelete = filesToDelete[0];
      filesToDelete.removeAt(0);
      fileToDelete.delete();
    }
    return;
  }

  // File getter functions
  List<String> getLocalFileNamesFromFileNamePattern(String pattern) {
    List<String> matchingFileNames = List();
    List<FileSystemEntity> allTopLevelLocalFiles =
        _directories[FileLocation.LOCAL].listSync();

    allTopLevelLocalFiles.forEach((localFile) {
      String thisFileBaseName = Path.basename(localFile.path);
      String thisFileBaseNameWitoutExtension =
          Path.basenameWithoutExtension(localFile.path);

      if (RegExp(pattern).hasMatch(thisFileBaseNameWitoutExtension)) {
        matchingFileNames.add(thisFileBaseName);
      }
    });

    return matchingFileNames;
  }

  List<String> getLocalFileNamesFromFileExtension(String fileExtension) {
    List<String> matchingFileNames = List();
    List<FileSystemEntity> allTopLevelLocalFiles =
        _directories[FileLocation.LOCAL].listSync();

    allTopLevelLocalFiles.forEach((savedFile) {
      if (Path.extension(savedFile.path) == fileExtension) {
        matchingFileNames.add(Path.basename(savedFile.path));
      }
    });

    return matchingFileNames;
  }

  String getAbsoluteFilePath(String fileName, FileLocation fileLocation) {
    return File(_directoryPaths[fileLocation] + fileName).path;
  }

  File _getFile(String fileName, FileLocation fileLocation) {
    return File(_directoryPaths[fileLocation] + fileName);
  }

  String getFilePath(String fileName, FileLocation fileLocation) {
    return _getFile(fileName, fileLocation).path;
  }

  // Deletion functions
  void deleteFile(String fileName, FileLocation fileLocation) {
    File file = _getFile(fileName, fileLocation);

    if (file.existsSync()) {
      file.delete();
    }
  }

  // Read Functions
  Uint8List readFileAsBytes(String fileName, FileLocation fileLocation) {
    File file = _getFile(fileName, fileLocation);

    if (file.existsSync()) {
      return file.readAsBytesSync();
    } else {
      return null;
    }
  }

  String readFileAsString(String fileName, FileLocation fileLocation) {
    File file = _getFile(fileName, fileLocation);

    if (file.existsSync()) {
      return file.readAsStringSync();
    } else {
      return null;
    }
  }

  // Write Functions
  void writeFileAsBytes(
      String fileName, Uint8List contents, FileLocation fileLocation) {
    File file = _getFile(fileName, fileLocation);

    file.writeAsBytesSync(contents);
  }

  void writeFileAsString(
      String fileName, String contents, FileLocation fileLocation) {
    File file = _getFile(fileName, fileLocation);

    file.writeAsStringSync(contents);
  }

  // Image Functions
  Future<Uint8List> getExternalImageBytes() async {
    Uint8List pictureBytes;
    /*// Have the use take or pick and external image
    ImagePicker imagePicker = ImagePicker();
    PickedFile externalImageFile = await imagePicker.getImage(source: imageSource);
    if (externalImageFile != null) {
      // If the user picked an image, then copy it to the local directory
      pictureBytes = File(externalImageFile.path).readAsBytesSync();
    }*/
    return pictureBytes;
  }

  // Utility Functions
  static const DEFAULT_FILE_NAME_PART_SEPERATOR = "_";
  static String createFileNameWithExtension(
      List<String> fileNameParts, String fileExtension) {
    String newFileNameWithExtension = "";

    for (int fileNamePartIndex = 0;
        fileNamePartIndex < fileNameParts.length;
        fileNamePartIndex++) {
      newFileNameWithExtension += fileNameParts[fileNamePartIndex];

      // Add a seperatior between each file name part.
      if (fileNamePartIndex != fileNameParts.length - 1) {
        newFileNameWithExtension += DEFAULT_FILE_NAME_PART_SEPERATOR;
      }
    }
    newFileNameWithExtension += fileExtension;

    return newFileNameWithExtension;
  }

  String exportAllFiles() {
    // TODO: Put more information in this zip file name
    String fileName =
        TFC_FlutterApp.appName.toLowerCase().replaceAll(" ", "_") +
            "_all_files.zip";
    String zipFileExportPath = _directoryPaths[FileLocation.EXPORT] + fileName;
    ZipFileEncoder encoder = ZipFileEncoder();

    // Remove any existing all-file-export-zips
    if (File(zipFileExportPath).existsSync()) {
      File(zipFileExportPath).delete();
    }

    // Zip up and export all local files
    encoder.create(zipFileExportPath);
    encoder.addDirectory(_directories[FileLocation.LOCAL]);
    encoder.close();
    return zipFileExportPath;
  }

  bool fileExists(String fileName, FileLocation fileLocation) {
    return _getFile(fileName, fileLocation).existsSync();
  }

  List<String> listFileNames(FileLocation fileLocation) {
    List<String> allFileNamesAtRequestedFileLocation = List();
    List<FileSystemEntity> allFilesAtRequestedFileLocation =
        _directories[fileLocation].listSync();
    for (FileSystemEntity file in allFilesAtRequestedFileLocation) {
      allFileNamesAtRequestedFileLocation.add(Path.basename(file.path));
    }
    return allFileNamesAtRequestedFileLocation;
  }
}
