import 'dart:js' as js;
import 'dart:html';

import 'package:flutter/foundation.dart';

class TFC_WebExclusiveAPI {
  static setWebBackgroundColor(String hexColor) async {
    if (kIsWeb) {
      js.context.callMethod('setWebBackgroundColor', [hexColor]);
    }
  }
}
