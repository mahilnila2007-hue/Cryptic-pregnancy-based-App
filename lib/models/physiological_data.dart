class PhysiologicalData {
  final int heartRate;
  final int spo2;
  final int hrv;
  final double temperature;
  final double gsr;
  final DateTime timestamp;

  PhysiologicalData({
    required this.heartRate,
    required this.spo2,
    required this.hrv,
    required this.temperature,
    required this.gsr,
    required this.timestamp,
  });

  factory PhysiologicalData.empty() {
    return PhysiologicalData(
      heartRate: 0,
      spo2: 0,
      hrv: 0,
      temperature: 0.0,
      gsr: 0.0,
      timestamp: DateTime.now(),
    );
  }

  factory PhysiologicalData.emptyWithTime(DateTime time) {
    return PhysiologicalData(
      heartRate: 0,
      spo2: 0,
      hrv: 0,
      temperature: 0.0,
      gsr: 0.0,
      timestamp: time,
    );
  }
}
