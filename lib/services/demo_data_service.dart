import 'dart:async';
import 'dart:math';
import '../models/physiological_data.dart';

class DemoDataService {
  final Random _random = Random();
  Timer? _timer;
  final StreamController<PhysiologicalData> _dataController = StreamController<PhysiologicalData>.broadcast();

  Stream<PhysiologicalData> get dataStream => _dataController.stream;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _dataController.add(_generateRandomData());
    });
  }

  void stop() {
    _timer?.cancel();
  }

  PhysiologicalData _generateRandomData() {
    // Generate realistic fluctuating data
    return PhysiologicalData(
      heartRate: 75 + _random.nextInt(10) - 5, // 70-85
      spo2: 97 + _random.nextInt(3), // 97-99
      hrv: 40 + _random.nextInt(10) - 5, // 35-50
      temperature: 36.4 + _random.nextDouble() * 0.4, // 36.4-36.8
      gsr: 0.30 + _random.nextDouble() * 0.05, // 0.30-0.35
      timestamp: DateTime.now(),
    );
  }
}
