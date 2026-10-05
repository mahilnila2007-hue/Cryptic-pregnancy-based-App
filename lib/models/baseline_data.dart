class BaselineData {
  final int baseHeartRate;
  final int baseSpo2;
  final int baseHrv;
  final double baseTemperature;
  final double baseGsr;

  BaselineData({
    required this.baseHeartRate,
    required this.baseSpo2,
    required this.baseHrv,
    required this.baseTemperature,
    required this.baseGsr,
  });

  factory BaselineData.defaultBaseline() {
    return BaselineData(
      baseHeartRate: 70,
      baseSpo2: 98,
      baseHrv: 45,
      baseTemperature: 36.5,
      baseGsr: 0.30,
    );
  }
}
