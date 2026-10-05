import 'dart:async';
import '../models/physiological_data.dart';
import 'demo_data_service.dart';
import 'bluetooth_service.dart';

class WearableService {
  final DemoDataService _demoDataService = DemoDataService();
  final BluetoothService _bluetoothService = BluetoothService();
  
  bool _isDemoMode = true;
  StreamSubscription? _subscription;
  
  final StreamController<PhysiologicalData> _unifiedDataController = StreamController<PhysiologicalData>.broadcast();
  Stream<PhysiologicalData> get dataStream => _unifiedDataController.stream;

  bool get isDemoMode => _isDemoMode;
  BluetoothService get bluetoothService => _bluetoothService;

  void setDemoMode(bool enable) {
    _isDemoMode = enable;
    _reconnect();
  }

  void _reconnect() {
    _subscription?.cancel();
    if (_isDemoMode) {
      _demoDataService.start();
      _subscription = _demoDataService.dataStream.listen((data) {
        _unifiedDataController.add(data);
      });
    } else {
      // In real-time mode, completely stop demo data generation
      _demoDataService.stop();
      _subscription = _bluetoothService.dataStream.listen((data) {
        _unifiedDataController.add(data);
      });
    }
  }

  void dispose() {
    _subscription?.cancel();
    _demoDataService.stop();
    _unifiedDataController.close();
  }
}
