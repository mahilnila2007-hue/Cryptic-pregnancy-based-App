import 'dart:async';
import '../models/physiological_data.dart';

class BluetoothService {
  final StreamController<PhysiologicalData> _dataController = StreamController<PhysiologicalData>.broadcast();
  bool _isConnected = false;

  Stream<PhysiologicalData> get dataStream => _dataController.stream;
  bool get isConnected => _isConnected;

  void emitData(PhysiologicalData data) {
    if (_isConnected) {
      _dataController.add(data);
    }
  }

  Future<void> connect() async {
    _isConnected = true;
  }

  Future<void> disconnect() async {
    _isConnected = false;
  }
}
