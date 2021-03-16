import 'dart:io';
import 'dart:math';
import 'dart:ui' as DartUI;
import 'package:flutter/foundation.dart';
import '../AppManagment/TFC_DiskController.dart';
import '../AppManagment/TFC_SyncController.dart';
import '../DataStructures/TFC_ItemUtilities.dart';
//import 'package:axiom_nameplate_data/items/AND_PictureInfo.dart';
import 'package:image/image.dart' as DartImg;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class TFC_ImageUtilities {
  static const IMAGE_ITEM_TYPE = "image";
  static const String THUMBNAIL_FILE_EXTENSION = ".jpg";
  static const int _THUMBNAIL_WIDTH = 450; // 5
  static const int _THUMBNAIL_HEIGHT = 360; // 4

  static Future<TFC_PictureData> importImage(Uint8List orignalImageBytes) async {
    // Get the image ID
    String imageID = TFC_ItemUtilities.generateLocalItemID(IMAGE_ITEM_TYPE);

    // Get the image bytes
    Uint8List compressedImageBytes = await FlutterImageCompress.compressWithList(orignalImageBytes);
    DartImg.Image scaledImage =
        await compute(_resizeOriginalImage, compressedImageBytes);
    TFC_ImageSize scaledImageSize =
        TFC_ImageSize(scaledImage.width, scaledImage.height);

    // Save the image locally
    String scaledImageFileName = getImageFileName(imageID, ".jpg");
    TFC_DiskController.writeFileAsBytes(scaledImageFileName, DartImg.encodeJpg(scaledImage));
    TFC_SyncController.logImageCreation(imageID, scaledImageFileName);
    String thumbnailImageID = await createThumbnailAsync(scaledImage);
    return TFC_PictureData(
        imageID, thumbnailImageID, scaledImageSize, ".jpg");
    /*TFC_PictureData picuteData = await compute(_importImage, imageFile);
    return picuteData;*/
  }

  static Future<DartImg.Image> _resizeOriginalImage(
      Uint8List compressedImageBytes) async {
    int targetPixelCount = 500000;
    DartImg.Image compressedImage = DartImg.decodeJpg(compressedImageBytes);

    if (compressedImage.width * compressedImage.height > targetPixelCount) {
      // Scale the image
      int scaledImageWidth = sqrt((compressedImage.width * targetPixelCount) /
              (compressedImage.height))
          .round();
      int scaledImageHeight = (targetPixelCount / scaledImageWidth).round();
      DartImg.Image scaledImage = DartImg.copyResize(
        compressedImage,
        width: scaledImageWidth,
        height: scaledImageHeight,
        interpolation: DartImg.Interpolation.cubic,
      );
      return scaledImage;
    } else {
      return compressedImage;
    }
  }

  static Future<String> createThumbnailAsync(DartImg.Image sourceImage) async {
    // Allocate an imageID for this thumbnail
    String thumbnailImageID =
        TFC_ItemUtilities.generateLocalItemID(IMAGE_ITEM_TYPE);

    List<int> croppedImageBytes =
        await compute(_createThumbnailImage, sourceImage);

    // Write the thumbnail to the local storage
    String thumbnailFileName = getThumbnailFileName(thumbnailImageID);
    TFC_DiskController.writeFileAsBytes(
        thumbnailFileName, croppedImageBytes);

    // Write the thumbnail to the database
    TFC_SyncController.logImageCreation(thumbnailImageID, thumbnailFileName);

    return thumbnailImageID;
  }

  static List<int> _createThumbnailImage(DartImg.Image sourceImage) {
    TFC_ImageSize originalImageSize =
        TFC_ImageSize(sourceImage.width, sourceImage.height);
    TFC_ImageSize scaledImageSize;

    // Scale the image to just fill the thumbnail dimensions
    double widthRatio = _THUMBNAIL_WIDTH / originalImageSize.width;
    double heightRatio = _THUMBNAIL_HEIGHT / originalImageSize.height;
    Axis axisToScale =
        (widthRatio >= heightRatio) ? Axis.horizontal : Axis.vertical;
    // Calculate the scaled image size
    if (axisToScale == Axis.horizontal) {
      int scaledImageHeight = (originalImageSize.height *
              (_THUMBNAIL_WIDTH / originalImageSize.width))
          .toInt();
      scaledImageSize = TFC_ImageSize(_THUMBNAIL_WIDTH, scaledImageHeight);
    } else {
      int scaledImageWidth = (originalImageSize.width *
              (_THUMBNAIL_HEIGHT / originalImageSize.height))
          .toInt();
      scaledImageSize = TFC_ImageSize(scaledImageWidth, _THUMBNAIL_HEIGHT);
    }
    // Scale the image
    DartImg.Image scaledDartImage = DartImg.copyResize(
      sourceImage,
      width: scaledImageSize.width,
      height: scaledImageSize.height,
      interpolation: DartImg.Interpolation.cubic,
    );

    // Get the top left corner of the cropped image
    int cropX = ((scaledImageSize.width - _THUMBNAIL_WIDTH) / 2).floor();
    int cropY = ((scaledImageSize.height - _THUMBNAIL_HEIGHT) / 2).floor();

    // Crop the thumbnail
    DartImg.Image croppedImage = DartImg.copyCrop(
        scaledDartImage, cropX, cropY, _THUMBNAIL_WIDTH, _THUMBNAIL_HEIGHT);
    return DartImg.encodeJpg(croppedImage);
  }

  static String getImageFileName(String imageID, String imageFileExtension) {
    return "$imageID$imageFileExtension";
  }

  static String getThumbnailFileName(String thumbnailImageID) {
    return "$thumbnailImageID$THUMBNAIL_FILE_EXTENSION";
  }

  /*static String getEditedImageFileName(String imageID, String imageFileExtension) {
    return "$_IMAGE_FILE_PREFIX-$imageID-edited$imageFileExtension";
  }*/

  static Future<TFC_ImageSize> getImageSzieFromBytes(
      Uint8List imageBytes) async {
    DartUI.Image image = await decodeImageFromList(imageBytes);
    return TFC_ImageSize(image.width, image.height);
  }

  static void deleteImage(String imageID, String fileName,
      {bool shouldLogDeletion = true}) {
    TFC_DiskController.deleteFile(fileName);
    if (shouldLogDeletion) {
      TFC_SyncController.logImageDeletion(imageID, fileName);
    }
  }
}

class TFC_PictureData {
  final String imageID;
  final String thumbnailImageID;
  final TFC_ImageSize size;
  final String fileExtension;

  TFC_PictureData(this.imageID, this.thumbnailImageID,
      this.size, this.fileExtension);
}

class TFC_ImageSize {
  int width;
  int height;

  TFC_ImageSize(this.width, this.height);
}
