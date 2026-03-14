import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Focus Preferences"),
            _buildSettingsCard(
              children: [
                _buildToggleTile(
                  icon: Icons.vibration,
                  title: "Haptic Feedback",
                  subtitle: "Vibrate on button press",
                  providerVal: true, // Replace with actual provider value in integration
                  onChanged: (val) {
                    // Provider logic here
                  },
                ),
                _buildToggleTile(
                  icon: Icons.volume_up_outlined,
                  title: "Focus Sounds",
                  subtitle: "Play ambient sounds during session",
                  providerVal: true,
                  onChanged: (val) {
                    // Provider logic here
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.timer_outlined,
                  title: "Focus Duration",
                  subtitle: "25 minutes",
                  onTap: () => _showDurationPicker(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader("App Settings"),
            _buildSettingsCard(
              children: [
                _buildNavigationTile(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  subtitle: "Manage alerts and reminders",
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.security_outlined,
                  title: "Permissions",
                  subtitle: "Usage access & Battery optimization",
                  onTap: () => _showPermissionInfo(context),
                ),
                _buildToggleTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Pure Black Mode",
                  subtitle: "Enable OLED-friendly black theme",
                  providerVal: true,
                  onChanged: (val) {
                    // Theme logic
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader("About"),
            _buildSettingsCard(
              children: [
                _buildNavigationTile(
                  icon: Icons.info_outline,
                  title: "Version",
                  subtitle: "1.0.0 (Build 1)",
                  showArrow: false,
                  onTap: () {},
                ),
                _buildNavigationTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  subtitle: "Read our terms and conditions",
                  onTap: () {
                    // Open URL
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.accentGreen,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                Divider(
                  color: Colors.grey[800],
                  height: 1,
                  indent: 56, // Align with text
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool providerVal,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      value: providerVal,
      activeColor: AppColors.accentGreen,
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600])
          : null,
      onTap: onTap,
    );
  }

  void _showDurationPicker(BuildContext context) {
    // Simple duration picker implementation
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: 200,
          child: Center(
            child: Text("Duration Picker Placeholder", style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  void _showPermissionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBlack,
        title: const Text("Permissions Required", style: TextStyle(color: AppColors.accentGreen)),
        content: const Text(
          "To block apps effectively, please ensure 'Usage Access' and 'Display over other apps' permissions are granted.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: AppColors.accentGreen)),
          )
        ],
      ),
    );
  }
}
