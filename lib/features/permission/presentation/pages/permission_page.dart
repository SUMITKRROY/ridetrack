import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _bgLocationStatus = PermissionStatus.denied;
  bool _isBatteryOptimized = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    final bgLocationStatus = await Permission.locationAlways.status;
    final isBatteryOptimized = await Permission.ignoreBatteryOptimizations.isGranted;
    
    setState(() {
      _locationStatus = locationStatus;
      _notificationStatus = notificationStatus;
      _bgLocationStatus = bgLocationStatus;
      _isBatteryOptimized = isBatteryOptimized;
      _isChecking = false;
    });
  }

  Future<void> _requestPermissions() async {
    // Request location
    if (!_locationStatus.isGranted) {
      final status = await Permission.location.request();
      setState(() => _locationStatus = status);
    }

    // Request notification
    if (!_notificationStatus.isGranted) {
      final status = await Permission.notification.request();
      setState(() => _notificationStatus = status);
    }

    // Request background location
    if (_locationStatus.isGranted && !_bgLocationStatus.isGranted) {
      final bgStatus = await Permission.locationAlways.request();
      setState(() => _bgLocationStatus = bgStatus);
    }

    // Request battery optimization
    if (!_isBatteryOptimized) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      setState(() => _isBatteryOptimized = status.isGranted);
    }

    // After requests, navigate to home if location is granted
    if (_locationStatus.isGranted) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to continue.')),
        );
      }
    }
  }

  String _getStatusText(PermissionStatus status) {
    if (status.isGranted) return 'Enabled';
    if (status.isPermanentlyDenied) return 'Permanently Denied';
    return 'Action Required';
  }

  bool _isGood(PermissionStatus status) {
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Center'),
      ),
      body: SafeArea(
        child: _isChecking 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const Text(
                    'Setup Required',
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'KSKT Rider needs the following permissions to ensure accurate tracking and reliable operations.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyText),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPermissionCard(
                    title: 'Location',
                    description: 'Required for trip tracking',
                    status: _getStatusText(_locationStatus),
                    icon: Icons.location_on,
                    isGood: _isGood(_locationStatus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPermissionCard(
                    title: 'Notifications',
                    description: 'Required for tracking notification',
                    status: _getStatusText(_notificationStatus),
                    icon: Icons.notifications,
                    isGood: _isGood(_notificationStatus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPermissionCard(
                    title: 'Background Location',
                    description: 'Required for tracking when app is not visible',
                    status: _getStatusText(_bgLocationStatus),
                    icon: Icons.my_location,
                    isGood: _isGood(_bgLocationStatus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPermissionCard(
                    title: 'Battery Optimization',
                    description: 'Required for reliable tracking in background',
                    status: _isBatteryOptimized ? 'Enabled' : 'Action Required',
                    icon: Icons.battery_charging_full,
                    isGood: _isBatteryOptimized,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                text: 'Grant Permissions',
                onPressed: _requestPermissions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required String status,
    required IconData icon,
    required bool isGood,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text('Status: ', style: AppTextStyles.bodyMedium),
                    Text(
                      status,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isGood ? AppColors.freshGreen : AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
