import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/monitoring_provider.dart';
import '../providers/device_provider.dart';
import '../providers/risk_provider.dart';
import '../models/risk_result.dart';
import '../core/theme/colors.dart';

class MonitorScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTest;

  const MonitorScreen({Key? key, this.onNavigateToTest}) : super(key: key);

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  String _selectedMetricForGraph = 'Heart Rate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer3<MonitoringProvider, DeviceProvider, RiskProvider>(
        builder: (context, monitoring, device, riskProv, child) {
          final current = monitoring.currentData;
          final baseline = monitoring.baselineData;
          final isDemo = monitoring.isDemoMode;
          final isConnected = isDemo || device.isWearableConnected;

          // When Demo Mode is OFF and hardware is not connected/transmitting, score is 0
          int finalScore = 0;
          RiskLevel level = RiskLevel.low;

          if (isConnected && current.heartRate > 0) {
            int score = 0;
            if ((current.heartRate - baseline.baseHeartRate).abs() > 10) score += 20;
            if ((current.temperature - baseline.baseTemperature).abs() > 0.5) score += 30;
            if ((current.hrv - baseline.baseHrv).abs() > 15) score += 20;
            finalScore = score > 100 ? 100 : score;

            if (finalScore > 30) level = RiskLevel.moderate;
            if (finalScore > 60) level = RiskLevel.high;
          }

          final risk = RiskResult(
            physiologicalScore: finalScore,
            opticalConfidence: riskProv.currentRisk.opticalConfidence,
            finalScreeningConfidence: riskProv.currentRisk.finalScreeningConfidence,
            riskLevel: level,
          );

          return CustomScrollView(
            slivers: [
              // TOP HEADER ILLUSTRATION HERO BANNER
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  height: 220.0,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.asset(
                      'assets/header_illustration.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/header_illustration.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A. WEARABLE STATUS & REAL-TIME WAITING STATE
                      _buildWearableStatusCard(context, monitoring, device),

                      const SizedBox(height: 18),

                      // D. PHYSIOLOGICAL RISK CARD
                      _buildPhysiologicalRiskCard(context, risk, isConnected && current.heartRate > 0),

                      const SizedBox(height: 18),

                      // B. LIVE PHYSIOLOGICAL DATA
                      _buildSectionHeading('LIVE PHYSIOLOGICAL DATA', Icons.sensors),
                      const SizedBox(height: 8),
                      _buildLivePhysiologicalDataGrid(context, current),

                      const SizedBox(height: 18),

                      // E. LIVE GRAPH
                      _buildSectionHeading('LIVE TELEMETRY GRAPH', Icons.show_chart),
                      const SizedBox(height: 8),
                      _buildLiveGraphCard(context, monitoring),

                      const SizedBox(height: 18),

                      // C. PERSONAL BASELINE COMPARISON
                      _buildSectionHeading('PERSONAL BASELINE COMPARISON', Icons.analytics_outlined),
                      const SizedBox(height: 8),
                      _buildBaselineCard(context, current, baseline, isConnected && current.heartRate > 0),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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
  // A. WEARABLE STATUS
  // ----------------------------------------------------
  Widget _buildWearableStatusCard(
      BuildContext context, MonitoringProvider monitoring, DeviceProvider device) {
    final isDemo = monitoring.isDemoMode;
    final isConnected = isDemo || device.isWearableConnected;

    String connectionStatus;
    Color statusColor;

    if (isDemo || device.isWearableConnected) {
      connectionStatus = 'Connected';
      statusColor = AppColors.success;
    } else {
      connectionStatus = 'Disconnected';
      statusColor = AppColors.error;
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
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
                Icons.watch_outlined,
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
                    'SOBI Wearable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        connectionStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      if (isConnected) ...[
                        const SizedBox(width: 10),
                        Text(
                          '•  Battery: ${monitoring.batteryLevel}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(bool isLive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.primary.withOpacity(0.12)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isLive ? AppColors.primary : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'LIVE' : 'IDLE',
            style: TextStyle(
              color: isLive ? AppColors.primary : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // B. LIVE PHYSIOLOGICAL DATA
  // ----------------------------------------------------
  Widget _buildLivePhysiologicalDataGrid(BuildContext context, dynamic current) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildGridStat(
          context,
          'Heart Rate',
          '${current.heartRate}',
          'BPM',
          Icons.favorite,
          AppColors.error,
        ),
        _buildGridStat(
          context,
          'SpO₂',
          '${current.spo2}',
          '%',
          Icons.water_drop,
          Colors.blueAccent,
        ),
        _buildGridStat(
          context,
          'Body Temp',
          current.temperature.toStringAsFixed(1),
          '°C',
          Icons.thermostat,
          Colors.orange,
        ),
        _buildGridStat(
          context,
          'HRV',
          '${current.hrv}',
          'ms',
          Icons.monitor_heart,
          AppColors.primary,
        ),
        _buildGridStat(
          context,
          'GSR (Skin Conductance)',
          current.gsr.toStringAsFixed(2),
          'µS',
          Icons.electric_bolt,
          AppColors.success,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildGridStat(BuildContext context, String label, String value,
      String unit, IconData icon, Color iconColor,
      {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.nearBlack,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // D. PHYSIOLOGICAL RISK
  // ----------------------------------------------------
  Widget _buildPhysiologicalRiskCard(BuildContext context, RiskResult risk, bool hasActiveData) {
    Color badgeColor;
    String statusText;

    if (!hasActiveData) {
      badgeColor = Colors.grey;
      statusText = 'NO DATA';
    } else {
      switch (risk.riskLevel) {
        case RiskLevel.high:
          badgeColor = AppColors.error;
          statusText = 'HIGH';
          break;
        case RiskLevel.moderate:
          badgeColor = AppColors.warning;
          statusText = 'MODERATE';
          break;
        case RiskLevel.low:
        default:
          badgeColor = AppColors.success;
          statusText = 'LOW';
          break;
      }
    }

    final bool isSustainedDeviation = hasActiveData && risk.physiologicalScore >= 35;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PHYSIOLOGICAL RISK',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.nearBlack,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: badgeColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${risk.physiologicalScore}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/ 100',
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveData
                ? 'Based on deviation from your personalized physiological baseline.'
                : 'Waiting for live telemetry to calculate risk score.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          if (isSustainedDeviation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sustained physiological deviation detected.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onNavigateToTest,
              icon: const Icon(Icons.science, size: 18),
              label: const Text('VIEW TEST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // E. LIVE GRAPH
  // ----------------------------------------------------
  Widget _buildLiveGraphCard(BuildContext context, MonitoringProvider monitoring) {
    final history = monitoring.history;
    final spots = _getSpotsForSelectedMetric(history);
    double maxY = _getMaxYForMetric();
    double minY = 0.0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metric selector chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGraphChip('Heart Rate'),
                  const SizedBox(width: 8),
                  _buildGraphChip('HRV'),
                  const SizedBox(width: 8),
                  _buildGraphChip('Temperature'),
                  const SizedBox(width: 8),
                  _buildGraphChip('SpO₂'),
                  const SizedBox(width: 8),
                  _buildGraphChip('GSR'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: monitoring.isDemoMode,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxYForMetric() {
    switch (_selectedMetricForGraph) {
      case 'Heart Rate':
        return 120.0;
      case 'HRV':
        return 100.0;
      case 'Temperature':
        return 42.0;
      case 'SpO₂':
        return 100.0;
      case 'GSR':
        return 1.0;
      default:
        return 100.0;
    }
  }

  Widget _buildGraphChip(String metric) {
    final isSelected = _selectedMetricForGraph == metric;
    return ChoiceChip(
      label: Text(
        metric,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.white : AppColors.nearBlack,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMetricForGraph = metric;
          });
        }
      },
    );
  }

  List<FlSpot> _getSpotsForSelectedMetric(List<dynamic> history) {
    if (history.isEmpty) {
      return List.generate(10, (index) => FlSpot(index.toDouble(), 0.0));
    }
    List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      double val = 0.0;
      switch (_selectedMetricForGraph) {
        case 'Heart Rate':
          val = item.heartRate.toDouble();
          break;
        case 'HRV':
          val = item.hrv.toDouble();
          break;
        case 'Temperature':
          val = item.temperature;
          break;
        case 'SpO₂':
          val = item.spo2.toDouble();
          break;
        case 'GSR':
          val = item.gsr;
          break;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  // ----------------------------------------------------
  // C. PERSONAL BASELINE
  // ----------------------------------------------------
  Widget _buildBaselineCard(
      BuildContext context, dynamic current, dynamic baseline, bool hasActiveData) {
    if (!hasActiveData) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Personal Baseline Comparison',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.nearBlack),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Waiting for live sensor data to perform baseline deviation analysis.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Personal Baseline Comparison',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.nearBlack),
            ),
            const SizedBox(height: 12),
            _buildBaselineRow(
              'Temperature',
              '${current.temperature.toStringAsFixed(1)} °C',
              '${baseline.baseTemperature.toStringAsFixed(1)} °C',
              (current.temperature - baseline.baseTemperature).abs() <= 0.4
                  ? 'Within baseline'
                  : 'Physiological deviation detected',
              (current.temperature - baseline.baseTemperature).abs() <= 0.4,
            ),
            const Divider(height: 20),
            _buildBaselineRow(
              'Heart Rate',
              '${current.heartRate} BPM',
              '${baseline.baseHeartRate} BPM',
              (current.heartRate - baseline.baseHeartRate).abs() <= 8
                  ? 'Within baseline'
                  : 'Physiological deviation detected',
              (current.heartRate - baseline.baseHeartRate).abs() <= 8,
            ),
            const Divider(height: 20),
            _buildBaselineRow(
              'HRV',
              '${current.hrv} ms',
              '${baseline.baseHrv} ms',
              (current.hrv - baseline.baseHrv).abs() <= 10
                  ? 'Within baseline'
                  : 'Physiological deviation detected',
              (current.hrv - baseline.baseHrv).abs() <= 10,
            ),
            const Divider(height: 20),
            _buildBaselineRow(
              'GSR',
              '${current.gsr.toStringAsFixed(2)} µS',
              '${baseline.baseGsr.toStringAsFixed(2)} µS',
              (current.gsr - baseline.baseGsr).abs() <= 0.04
                  ? 'Within baseline'
                  : 'Physiological deviation detected',
              (current.gsr - baseline.baseGsr).abs() <= 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaselineRow(String label, String currentVal, String baselineVal,
      String status, bool isNormal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isNormal ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isNormal ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Current: $currentVal', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(width: 12),
            Text('Baseline: $baselineVal', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}
