import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../providers/device_provider.dart';
import '../providers/risk_provider.dart';
import '../core/constants/strings.dart';
import '../core/theme/colors.dart';
import '../screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _bluetoothEnabled = true;
  bool _wifiEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: Consumer3<MonitoringProvider, DeviceProvider, RiskProvider>(
        builder: (context, monitoring, device, riskProv, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // PROFILE SECTION
              _buildSectionHeader(context, 'PROFILE', Icons.person_outline),
              _buildProfileCard(context, monitoring),

              const SizedBox(height: 20),

              // DEVICES SECTION
              _buildSectionHeader(context, 'DEVICES', Icons.devices_outlined),
              _buildDevicesCard(context, monitoring, device),

              const SizedBox(height: 20),

              // APP SETTINGS SECTION
              _buildSectionHeader(context, 'APP SETTINGS', Icons.tune_outlined),
              _buildAppSettingsCard(context, monitoring, riskProv),

              const SizedBox(height: 20),

              // DATA SECTION
              _buildSectionHeader(context, 'DATA', Icons.storage_outlined),
              _buildDataCard(context, monitoring),

              const SizedBox(height: 20),

              // ABOUT SECTION
              _buildSectionHeader(context, 'ABOUT', Icons.info_outline),
              _buildAboutCard(context),

              const SizedBox(height: 20),

              // LOG OUT BUTTON
              _buildLogoutButton(context),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, MonitoringProvider monitoring) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppColors.white, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sarah Jenkins',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: 28  •  Baseline Calibrated',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      monitoring.isDemoMode ? 'Demo Mode Active' : 'Real-Time Telemetry',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesCard(BuildContext context, MonitoringProvider monitoring, DeviceProvider device) {
    final isWearableConnected = monitoring.isDemoMode || device.isWearableConnected;
    final isOpticalConnected = monitoring.isDemoMode || device.isOpticalReaderConnected;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // SOBI Wearable
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.watch_outlined, color: AppColors.primary, size: 24),
            ),
            title: const Text(
              'SOBI Wearable',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(
                  isWearableConnected ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: isWearableConnected ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  isWearableConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    fontSize: 12,
                    color: isWearableConnected ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isWearableConnected) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.battery_charging_full, size: 14, color: AppColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    '${monitoring.batteryLevel}%',
                    style: const TextStyle(fontSize: 12, color: AppColors.nearBlack),
                  ),
                ],
              ],
            ),
            trailing: Switch(
              value: device.isWearableConnected,
              activeColor: AppColors.primary,
              onChanged: (val) {
                device.setWearableConnection(val);
                if (!val) {
                  monitoring.onWearableDisconnected();
                }
              },
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // SOBI Optical Reader
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.biotech_outlined, color: AppColors.primary, size: 24),
            ),
            title: const Text(
              'SOBI Optical Reader',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(
                  isOpticalConnected ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: isOpticalConnected ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  isOpticalConnected ? 'Connected (TCS34725 Ready)' : 'Disconnected',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOpticalConnected ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: device.isOpticalReaderConnected,
              activeColor: AppColors.primary,
              onChanged: (val) => device.setOpticalReaderConnection(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(
      BuildContext context, MonitoringProvider monitoring, RiskProvider riskProv) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(AppStrings.demoMode, style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              monitoring.isDemoMode
                  ? 'Simulating realistic fluctuating sensor data'
                  : 'Zero values until real ESP32 connects',
              style: const TextStyle(fontSize: 12),
            ),
            secondary: Icon(
              monitoring.isDemoMode ? Icons.science : Icons.sensors,
              color: AppColors.primary,
            ),
            value: monitoring.isDemoMode,
            activeColor: AppColors.primary,
            onChanged: (val) {
              monitoring.setDemoMode(val);
              if (!val) {
                riskProv.reset();
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Alerts on sustained baseline deviations', style: TextStyle(fontSize: 12)),
            secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Bluetooth LE', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Direct peripheral communication', style: TextStyle(fontSize: 12)),
            secondary: const Icon(Icons.bluetooth, color: AppColors.primary),
            value: _bluetoothEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _bluetoothEnabled = val;
              });
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Wi-Fi Sync', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Encrypted cloud & local sync', style: TextStyle(fontSize: 12)),
            secondary: const Icon(Icons.wifi, color: AppColors.primary),
            value: _wifiEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _wifiEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, MonitoringProvider monitoring) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: const Text('Monitoring History', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${monitoring.history.length} recent telemetry points',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () => _showHistoryModal(context, monitoring),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            title: const Text('Data Export', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Export telemetry as CSV or PDF report', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Physiological data exported successfully.')),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.security_outlined, color: AppColors.primary),
            title: const Text('Data Privacy', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('End-to-end on-device encryption', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Data Privacy & Security'),
                  content: const Text(
                    'Your physiological sensor data and optical test readings are processed locally with strict on-device encryption. No identifiable medical records are transmitted without explicit consent.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.spa, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      AppStrings.appSubtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            const Text(
              'Medical Disclaimer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.disclaimerText,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Terms & Conditions'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'SOBI terms of service and prototype testing agreement.\n\nThis application is intended strictly for biological observational research and screening support. Consult licensed healthcare practitioners for clinical diagnostic evaluations.',
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Agree & Close')),
                        ],
                      ),
                    );
                  },
                  child: const Text('Terms & Conditions', style: TextStyle(fontSize: 12)),
                ),
                Text(
                  'v1.0.0 (Build 1)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, MonitoringProvider monitoring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MONITORING HISTORY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: monitoring.history.isEmpty
                  ? const Center(child: Text('No historical sessions recorded yet.'))
                  : ListView.builder(
                      itemCount: monitoring.history.length,
                      itemBuilder: (context, index) {
                        final item = monitoring.history[monitoring.history.length - 1 - index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(Icons.favorite, color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              'HR: ${item.heartRate} BPM  |  Temp: ${item.temperature.toStringAsFixed(1)} °C',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              'SpO₂: ${item.spo2}%  •  HRV: ${item.hrv}ms  •  GSR: ${item.gsr.toStringAsFixed(2)}µS',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
