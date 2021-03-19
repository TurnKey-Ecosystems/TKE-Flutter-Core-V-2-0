import 'dart:js' as js;
import 'dart:html';

class TFC_WebExclusiveAPI {
  static setWebBackgroundColor(String hexColor) async {
    js.context.callMethod('setWebBackgroundColor', [hexColor]);
  }
}
