enum ReaderStatus { ready, reading, complete, error }

class OpticalResult {
  final double testLineIntensity;
  final double controlLineIntensity;
  final double opticalConfidence; // 0 to 1
  final ReaderStatus status;

  OpticalResult({
    required this.testLineIntensity,
    required this.controlLineIntensity,
    required this.opticalConfidence,
    required this.status,
  });

  factory OpticalResult.initial() {
    return OpticalResult(
      testLineIntensity: 0.0,
      controlLineIntensity: 0.0,
      opticalConfidence: 0.0,
      status: ReaderStatus.ready,
    );
  }
}
