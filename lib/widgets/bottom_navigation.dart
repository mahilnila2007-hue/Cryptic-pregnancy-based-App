import 'package:flutter/material.dart';
import '../screens/monitor_screen.dart';
import '../screens/test_screen.dart';
import '../screens/profile_screen.dart';
import '../core/theme/colors.dart';

class SobiMainScreen extends StatefulWidget {
  const SobiMainScreen({Key? key}) : super(key: key);

  @override
  _SobiMainScreenState createState() => _SobiMainScreenState();
}

class _SobiMainScreenState extends State<SobiMainScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MonitorScreen(
        onNavigateToTest: () => _navigateToTab(1),
      ),
      const TestScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          onTap: _navigateToTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'MONITOR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.radio_button_unchecked_rounded),
              activeIcon: Icon(Icons.radio_button_checked_rounded),
              label: 'TEST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
