import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../core/constants/strings.dart';
import '../core/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Consumer<MonitoringProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text(AppStrings.demoMode),
                subtitle: const Text('Simulate hardware sensor data'),
                value: provider.isDemoMode,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  provider.setDemoMode(val);
                },
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text('Profile'),
            subtitle: Text('Name, Age'),
          ),
          const ListTile(
            leading: Icon(Icons.bluetooth, color: AppColors.primary),
            title: Text('SOBI Wearable'),
            subtitle: Text('Connected - Battery: 82%'),
          ),
          const ListTile(
            leading: Icon(Icons.science, color: AppColors.primary),
            title: Text('SOBI Optical Reader'),
            subtitle: Text('Connected'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Disclaimer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.disclaimerText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
