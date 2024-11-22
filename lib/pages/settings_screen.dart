import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _darkModeEnabled = false;
  bool _offlineMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // App Preferences
          SwitchListTile.adaptive(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
                Get.changeThemeMode(ThemeMode.light);
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          SwitchListTile.adaptive(
            title: const Text('Offline Mode'),
            subtitle: const Text('Listen without internet'),
            value: _offlineMode,
            onChanged: (bool value) {
              Get.snackbar('Coming Soon...', 'This Feature Coming Soon!',
                  backgroundColor: Colors.purple.shade900,
                  icon: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 30,
                      )));
              return;
              setState(() {
                _offlineMode = value;
              });
            },
            secondary: const Icon(Icons.offline_bolt),
          ),

          SwitchListTile.adaptive(
            title: const Text('Notifications'),
            subtitle: const Text('Receive app updates and recommendations'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Implement notification toggle logic
              });
            },
            secondary: const Icon(Icons.notifications),
          ),

          // App Update Section
          ListTile(
            title: const Text('Check for Updates'),
            subtitle: const Text('Ensure you have the latest version'),
            leading: const Icon(Icons.system_update),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement app update check logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checking for updates...')),
              );
            },
          ),

          // About Section
          const Divider(),
          ListTile(
            title: const Text('About Dhwani Music'),
            subtitle: const Text('Learn more about our app'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show About Dialog
              showAboutDialog(
                context: context,
                applicationName: 'Dhwani Music',
                applicationVersion: _appVersion,
                applicationIcon: const FlutterLogo(),
                children: [
                  const Text('Your ultimate music companion'),
                  const Text('Developed with ❤️ by Your Team'),
                ],
              );
            },
          ),

          const Expanded(child: SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  'Dhwani Music',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Version $_appVersion',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
