import 'dart:typed_data';

enum FileLocation { LOCAL, EXPORT }

abstract class TFC_IDeviceStorageAPI {
  // Setup Functions
  Future setup();

  // Deletion functions
  void deleteFile(String fileName, FileLocation fileLocation);

  // Read Functions
  Uint8List readFileAsBytes(String fileName, FileLocation fileLocation);
  String readFileAsString(String fileName, FileLocation fileLocation);

  // Write Functions
  void writeFileAsString(String fileName, String data, FileLocation fileLocation);
  void writeFileAsBytes(String fileName, Uint8List data, FileLocation fileLocation);
  
  // Image Functions
  Future<Uint8List> getExternalImageBytes();

  // Utility Functions
  String exportAllFiles();
  bool fileExists(String fileName, FileLocation fileLocation);
  List<String> listFileNames(FileLocation fileLocation);
}