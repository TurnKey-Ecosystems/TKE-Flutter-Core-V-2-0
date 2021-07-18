import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/TFC_AppStyle.dart';

class tu {
  double operator *(num other) {
    return TFC_AppStyle.instance.lineHeight * other.toDouble();
  }
}