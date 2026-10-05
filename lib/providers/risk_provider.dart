import 'package:flutter/foundation.dart';
import '../models/risk_result.dart';
import '../models/physiological_data.dart';
import '../models/baseline_data.dart';
import '../models/optical_result.dart';

class RiskProvider with ChangeNotifier {
  RiskResult _currentRisk = RiskResult.initial();
  RiskResult get currentRisk => _currentRisk;

  void calculatePhysiologicalRisk(PhysiologicalData current, BaselineData baseline) {
    // Simple heuristic for prototype
    int score = 0;
    
    if ((current.heartRate - baseline.baseHeartRate).abs() > 10) score += 20;
    if ((current.temperature - baseline.baseTemperature).abs() > 0.5) score += 30;
    if ((current.hrv - baseline.baseHrv).abs() > 15) score += 20;
    
    // Cap at 100
    int finalScore = score > 100 ? 100 : score;
    
    RiskLevel level = RiskLevel.low;
    if (finalScore > 30) level = RiskLevel.moderate;
    if (finalScore > 60) level = RiskLevel.high;

    _currentRisk = RiskResult(
      physiologicalScore: finalScore,
      opticalConfidence: _currentRisk.opticalConfidence,
      finalScreeningConfidence: _currentRisk.finalScreeningConfidence,
      riskLevel: level,
    );
    notifyListeners();
  }

  void updateWithOpticalResult(OpticalResult optical) {
    // Fusion logic
    double fusionScore = (_currentRisk.physiologicalScore * 0.4) + (optical.opticalConfidence * 100 * 0.6);
    int finalScore = fusionScore.round();
    
    RiskLevel level = RiskLevel.low;
    if (finalScore > 40) level = RiskLevel.moderate;
    if (finalScore > 75) level = RiskLevel.high;
    
    _currentRisk = RiskResult(
      physiologicalScore: _currentRisk.physiologicalScore,
      opticalConfidence: optical.opticalConfidence,
      finalScreeningConfidence: finalScore,
      riskLevel: level,
    );
    notifyListeners();
  }

  void reset() {
    _currentRisk = RiskResult.initial();
    notifyListeners();
  }
}
