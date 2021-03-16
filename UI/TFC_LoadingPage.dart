import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';
import 'TFC_CustomWidgets.dart';

class TFC_LoadingPage extends StatelessWidget {
  bool _isImagePage;
  IconData _iconData;
  String _imageLocation;
  String _loadingText;
  Color _color;

  TFC_LoadingPage.icon(this._iconData, this._loadingText, {Color color = TFC_AppStyle.COLOR_HINT}) : _isImagePage = false, _color = color;
  TFC_LoadingPage.image(this._imageLocation, this._loadingText, {Color color = TFC_AppStyle.COLOR_HINT}) : _isImagePage = true, _color = color;

  @override
  Widget build(BuildContext context) {
    double loadingAnimationWidth = TFC_AppStyle.instance.internalPageWidth / 3.25;
    double loadingAnimationHeight = loadingAnimationWidth;

    return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                getGraphics(),
                Container(
                  width: loadingAnimationWidth,
                  height: loadingAnimationHeight,
                  child: CircularProgressIndicator(
                    backgroundColor: _color,
                    strokeWidth: TFC_AppStyle.instance.pageMargins / 2.5,
                  ),
                ),
              ],
            ),
            Container(
              height: TFC_AppStyle.instance.pageMargins,
            ),
            Container(
              child: TFC_Text.body(
                _loadingText,
                color: _color,
              ),
            ),
          ],
        );
  }

  Widget getGraphics() {
    if (_isImagePage) {
      double imageSize = TFC_AppStyle.instance.internalPageWidth / 4.0;
      return Image.asset(
        _imageLocation,
        width: imageSize,
        height: imageSize,
      );
    } else  {
      double iconSize = TFC_AppStyle.instance.internalPageWidth / 4.6;
      return Icon(
        _iconData,
        size: iconSize,
        color: _color,
      );
    }
  }
}