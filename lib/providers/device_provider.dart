import 'package:flutter/foundation.dart';

class DeviceProvider with ChangeNotifier {
  bool _isWearableConnected = true; // Default true in Demo
  bool _isOpticalReaderConnected = true;

  bool get isWearableConnected => _isWearableConnected;
  bool get isOpticalReaderConnected => _isOpticalReaderConnected;

  void setWearableConnection(bool status) {
    _isWearableConnected = status;
    notifyListeners();
  }

  void setOpticalReaderConnection(bool status) {
    _isOpticalReaderConnected = status;
    notifyListeners();
  }
}
