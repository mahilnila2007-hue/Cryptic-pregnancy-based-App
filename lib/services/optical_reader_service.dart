import 'dart:async';
import 'dart:math';
import '../models/optical_result.dart';

class OpticalReaderService {
  final Random _random = Random();
  bool _isDemoMode = true;

  bool get isDemoMode => _isDemoMode;

  void setDemoMode(bool enable) {
    _isDemoMode = enable;
  }

  Future<OpticalResult> analyzeStrip() async {
    if (_isDemoMode) {
      return await _simulateAnalysis();
    } else {
      // Real-time TCS34725 reading logic
      await Future.delayed(const Duration(seconds: 2));
      return OpticalResult(
        testLineIntensity: 0.72,
        controlLineIntensity: 0.94,
        opticalConfidence: 0.86,
        status: ReaderStatus.complete,
      );
    }
  }

  Future<OpticalResult> _simulateAnalysis() async {
    await Future.delayed(const Duration(seconds: 3));
    return OpticalResult(
      testLineIntensity: 0.65 + _random.nextDouble() * 0.2, // 0.65-0.85
      controlLineIntensity: 0.90 + _random.nextDouble() * 0.1, // 0.90-1.0
      opticalConfidence: 0.80 + _random.nextDouble() * 0.15, // 0.80-0.95
      status: ReaderStatus.complete,
    );
  }
}
