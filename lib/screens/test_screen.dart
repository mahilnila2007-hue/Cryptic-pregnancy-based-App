import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../services/optical_reader_service.dart';
import '../models/optical_result.dart';
import '../models/risk_result.dart';
import '../providers/risk_provider.dart';
import '../providers/device_provider.dart';
import '../providers/monitoring_provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final OpticalReaderService _readerService = OpticalReaderService();
  ReaderStatus _readerStatus = ReaderStatus.ready;
  String _statusMessage = 'READY';
  OpticalResult? _result;
  bool _isAnalyzing = false;

  void _startAnalysis() async {
    final monitoring = Provider.of<MonitoringProvider>(context, listen: false);
    _readerService.setDemoMode(monitoring.isDemoMode);

    setState(() {
      _isAnalyzing = true;
      _readerStatus = ReaderStatus.reading;
      _statusMessage = 'Reading test strip via TCS34725 sensor...';
    });

    final result = await _readerService.analyzeStrip();

    if (!mounted) return;

    final riskProv = Provider.of<RiskProvider>(context, listen: false);
    riskProv.updateWithOpticalResult(result);

    setState(() {
      _isAnalyzing = false;
      _result = result;
      _readerStatus = ReaderStatus.complete;
      _statusMessage = 'Analysis Complete';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pregnancy Test & AI Fusion'),
      ),
      body: Consumer3<DeviceProvider, RiskProvider, MonitoringProvider>(
        builder: (context, device, riskProv, monitoring, child) {
          final isDemo = monitoring.isDemoMode;
          // If demo is off and no analysis has run, keep result null
          final resultToDisplay = isDemo ? _result : (monitoring.currentData.heartRate > 0 || _result != null ? _result : null);
          final risk = riskProv.currentRisk;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // A. OPTICAL READER STATUS
              _buildSectionHeading('OPTICAL READER STATUS', Icons.biotech_outlined),
              const SizedBox(height: 8),
              _buildReaderStatusCard(context, device, isDemo),

              const SizedBox(height: 20),

              // B. PREGNANCY TEST INSTRUCTION & ACTION
              _buildSectionHeading('PREGNANCY TEST STRIP', Icons.science_outlined),
              const SizedBox(height: 8),
              _buildPregnancyTestCard(context),

              const SizedBox(height: 20),

              // C. OPTICAL ANALYSIS
              if (_isAnalyzing || resultToDisplay != null) ...[
                _buildSectionHeading('OPTICAL ANALYSIS (TCS34725)', Icons.visibility_outlined),
                const SizedBox(height: 8),
                _buildOpticalAnalysisCard(context, resultToDisplay),
                const SizedBox(height: 20),
              ],

              // D. AI FUSION
              if (resultToDisplay != null) ...[
                _buildSectionHeading('AI FUSION MULTI-MODAL SCREENING', Icons.auto_awesome_outlined),
                const SizedBox(height: 8),
                _buildAiFusionCard(context, risk),
                const SizedBox(height: 20),

                // E. RESULT CATEGORIES
                _buildSectionHeading('SCREENING ASSESSMENT', Icons.assessment_outlined),
                const SizedBox(height: 8),
                _buildResultCategoryCard(context, risk),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeading(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // A. OPTICAL READER STATUS
  // ----------------------------------------------------
  Widget _buildReaderStatusCard(BuildContext context, DeviceProvider device, bool isDemo) {
    final isConnected = isDemo || device.isOpticalReaderConnected;
    String statusBadge;
    Color badgeColor;

    switch (_readerStatus) {
      case ReaderStatus.reading:
        statusBadge = 'READING';
        badgeColor = AppColors.warning;
        break;
      case ReaderStatus.complete:
        statusBadge = 'COMPLETE';
        badgeColor = AppColors.success;
        break;
      case ReaderStatus.error:
        statusBadge = 'ERROR';
        badgeColor = AppColors.error;
        break;
      case ReaderStatus.ready:
      default:
        statusBadge = isConnected ? 'READY' : 'OFFLINE';
        badgeColor = isConnected ? AppColors.primary : Colors.grey;
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.primaryLight.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.biotech,
                color: isConnected ? AppColors.primary : Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SOBI Optical Reader',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isConnected ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•  TCS34725 Sensor', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badgeColor.withOpacity(0.4)),
              ),
              child: Text(
                statusBadge,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // B. PREGNANCY TEST INSTRUCTIONS & BUTTON
  // ----------------------------------------------------
  Widget _buildPregnancyTestCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perform a standard urine pregnancy test and insert the strip into the SOBI Optical Reader.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _startAnalysis,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                _isAnalyzing ? 'ANALYZING TEST STRIP...' : 'START STRIP ANALYSIS',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // C. OPTICAL ANALYSIS
  // ----------------------------------------------------
  Widget _buildOpticalAnalysisCard(BuildContext context, OpticalResult? result) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                if (_isAnalyzing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOpticalStat('Test Line', result.testLineIntensity.toStringAsFixed(2)),
                  _buildOpticalStat('Control Line', result.controlLineIntensity.toStringAsFixed(2)),
                  _buildOpticalStat(
                    'Optical Confidence',
                    '${(result.opticalConfidence * 100).toStringAsFixed(0)}%',
                    isHighlighted: true,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOpticalStat(String label, String value, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.primary : AppColors.nearBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // D. AI FUSION
  // ----------------------------------------------------
  Widget _buildAiFusionCard(BuildContext context, RiskResult risk) {
    final opticalConfPercent = (risk.opticalConfidence * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFusionItem('Physiological Risk', '${risk.physiologicalScore} / 100'),
              const Icon(Icons.add, color: AppColors.primary, size: 24),
              _buildFusionItem('Optical Confidence', '$opticalConfPercent%'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 26),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Final Screening Confidence',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${risk.finalScreeningConfidence}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFusionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.nearBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // E. RESULT CATEGORIES
  // ----------------------------------------------------
  Widget _buildResultCategoryCard(BuildContext context, RiskResult risk) {
    Color cardColor;
    Color textColor;
    String statusTitle;
    String statusDescription;

    switch (risk.riskLevel) {
      case RiskLevel.high:
        cardColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        statusTitle = 'HIGH SCREENING CONFIDENCE';
        statusDescription =
            'Further clinical confirmation is recommended.\nClinical confirmation may include an appropriate pregnancy test, blood β-hCG testing, and/or obstetric evaluation.';
        break;
      case RiskLevel.moderate:
        cardColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        statusTitle = 'MODERATE SCREENING INDICATION';
        statusDescription =
            'Repeat testing or seek professional advice if appropriate. Further clinical confirmation is recommended if symptoms persist.';
        break;
      case RiskLevel.low:
      default:
        cardColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        statusTitle = 'LOW SCREENING INDICATION';
        statusDescription =
            'Continue routine monitoring. Physiological metrics remain within baseline bounds.';
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusTitle,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              statusDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
