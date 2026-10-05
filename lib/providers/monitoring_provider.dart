import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/physiological_data.dart';
import '../models/baseline_data.dart';
import '../services/wearable_service.dart';

class MonitoringProvider with ChangeNotifier {
  final WearableService _wearableService = WearableService();
  StreamSubscription<PhysiologicalData>? _dataSubscription;
  
  PhysiologicalData _currentData = PhysiologicalData.empty();
  PhysiologicalData get currentData => _currentData;
  
  BaselineData _baselineData = BaselineData.defaultBaseline();
  BaselineData get baselineData => _baselineData;

  final List<PhysiologicalData> _history = [];
  List<PhysiologicalData> get history => List.unmodifiable(_history);

  int _batteryLevel = 88;
  int get batteryLevel => _batteryLevel;

  bool get isDemoMode => _wearableService.isDemoMode;

  MonitoringProvider() {
    // Start in Demo Mode by default
    _wearableService.setDemoMode(true);
    _initZeroHistory();
    _subscribeToWearable();
  }

  void _initZeroHistory() {
    _history.clear();
    final now = DateTime.now();
    for (int i = 0; i < 15; i++) {
      _history.add(PhysiologicalData.emptyWithTime(now.subtract(Duration(seconds: 15 - i))));
    }
  }

  void _subscribeToWearable() {
    _dataSubscription?.cancel();
    _dataSubscription = _wearableService.dataStream.listen((data) {
      _currentData = data;
      _history.add(data);
      if (_history.length > 30) {
        _history.removeAt(0);
      }
      notifyListeners();
    });
  }

  void setDemoMode(bool enable) {
    if (enable == _wearableService.isDemoMode) return;

    _wearableService.setDemoMode(enable);

    if (!enable) {
      // Demo Mode OFF:
      // 1. Reset all values to exactly ZERO
      // 2. Clear previous demo graph curves
      // 3. Initialize graphs to completely flat zero lines
      _resetToZero();
    } else {
      // Demo Mode ON:
      _history.clear();
    }
    _subscribeToWearable();
    notifyListeners();
  }

  void onWearableDisconnected() {
    if (!isDemoMode) {
      _resetToZero();
      notifyListeners();
    }
  }

  void receiveRealTimeData(PhysiologicalData data) {
    if (!isDemoMode) {
      _wearableService.bluetoothService.emitData(data);
    }
  }

  void _resetToZero() {
    _currentData = PhysiologicalData.empty();
    _initZeroHistory();
  }

  void setBatteryLevel(int level) {
    _batteryLevel = level;
    notifyListeners();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _wearableService.dispose();
    super.dispose();
  }
}
