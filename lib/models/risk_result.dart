enum RiskLevel { low, moderate, high }

class RiskResult {
  final int physiologicalScore; // 0-100
  final double opticalConfidence; // 0.0-1.0
  final int finalScreeningConfidence; // 0-100
  final RiskLevel riskLevel;

  RiskResult({
    required this.physiologicalScore,
    required this.opticalConfidence,
    required this.finalScreeningConfidence,
    required this.riskLevel,
  });
  
  factory RiskResult.initial() {
    return RiskResult(
      physiologicalScore: 0,
      opticalConfidence: 0.0,
      finalScreeningConfidence: 0,
      riskLevel: RiskLevel.low,
    );
  }
}
