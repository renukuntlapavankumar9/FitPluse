import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Profile & Settings Screen — Athlete bio, fitness goals, preferences & device integrations
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _googleFitSync = true;
  bool _hapticFeedback = true;
  bool _workoutReminders = true;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out of FitPulse?'),
        content: const Text(
          'Your local workout data is saved. You can log back in anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showDetailModal(
              'Edit Profile',
              'Edit personal biographical information, height, weight, and fitness targets.',
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Athlete Bio Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alex Johnson',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PRO ATHLETE • HYPERTROPHY FOCUS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                // Athlete quick stats bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('76.5 kg', 'Weight'),
                    _buildVerticalDivider(),
                    _buildStatItem('180 cm', 'Height'),
                    _buildVerticalDivider(),
                    _buildStatItem('48', 'Workouts'),
                    _buildVerticalDivider(),
                    _buildStatItem('7 Days', 'Streak 🔥'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Fitness Goal Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Goal: Lean Bulk',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '76.5 / 80.0 kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 6,
                    backgroundColor: AppColors.cardSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '3.5 kg remaining to hit target goal weight.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Account & Goals
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Account & Goals',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildSettingsTile(
            Icons.person_outline,
            'Account Details',
            subtitle: 'Personal bio, email, and security',
            onTap: () => _showDetailModal(
              'Account Details',
              'Alex Johnson\nalex.johnson@example.com\nJoined: January 2026',
            ),
          ),
          _buildSettingsTile(
            Icons.track_changes_outlined,
            'Fitness Goals & Target Splits',
            subtitle: 'Muscle hypertrophy, 4-day split',
            onTap: () => _showDetailModal(
              'Fitness Goals',
              'Current split: Push / Pull / Legs / Upper / Core. Calorie target: 2,400 kcal/day.',
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: App Preferences & Integrations
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Preferences & Integrations',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildSwitchTile(
            Icons.sync_outlined,
            'Google Fit / Health Sync',
            subtitle: 'Sync workouts and active calories',
            value: _googleFitSync,
            onChanged: (val) => setState(() => _googleFitSync = val),
          ),
          _buildSwitchTile(
            Icons.vibration_outlined,
            'Haptic & Audio Rest Cues',
            subtitle: 'Vibrate when rest timer finishes',
            value: _hapticFeedback,
            onChanged: (val) => setState(() => _hapticFeedback = val),
          ),
          _buildSwitchTile(
            Icons.notifications_none_outlined,
            'Daily Workout Reminders',
            subtitle: 'Scheduled alert at 07:00 AM',
            value: _workoutReminders,
            onChanged: (val) => setState(() => _workoutReminders = val),
          ),
          const SizedBox(height: 16),

          // Section 3: Data & Security
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Data & Security',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildSettingsTile(
            Icons.file_download_outlined,
            'Export Workout Data',
            subtitle: 'Export logs in CSV / JSON format',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting FitPulse_Workouts_2026.csv...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildSettingsTile(
            Icons.logout,
            'Log Out',
            subtitle: 'Sign out from this device',
            isDestructive: true,
            onTap: _showLogoutDialog,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'FitPulse v2.0.0 (Week 3 Interactive Release)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 24, color: AppColors.border);
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title, {
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        dense: true,
        secondary: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        value: value,
        activeTrackColor: AppColors.accent,
        onChanged: onChanged,
      ),
    );
  }
}
