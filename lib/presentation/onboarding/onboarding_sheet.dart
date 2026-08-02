import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_reminder/presentation/settings/bloc/settings_cubit.dart';
import 'package:water_reminder/presentation/home/bloc/home_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingSheet extends StatefulWidget {
  const OnboardingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const OnboardingSheet(),
    );
  }

  @override
  State<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<OnboardingSheet> {
  final _weightController = TextEditingController();
  double? _targetMlPreview;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _calculatePreview() {
    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight > 0) {
      setState(() {
        _targetMlPreview = weight * 30;
      });
    } else {
      setState(() {
        _targetMlPreview = null;
      });
    }
  }

  Future<void> _requestPermissionsAndComplete(bool useDefault) async {
    // Request notification permissions first
    await Permission.notification.request();
    
    // Request exact alarm (usually directs to settings on Android 12+)
    var alarmStatus = await Permission.scheduleExactAlarm.status;
    if (!alarmStatus.isGranted) {
      alarmStatus = await Permission.scheduleExactAlarm.request();
    }

    if (!mounted) return;

    if (alarmStatus.isDenied || alarmStatus.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Izin Alarm Diperlukan'),
          content: const Text('Agar pengingat bisa tepat waktu di HP Anda, tolong izinkan "Alarms & Reminders" di pengaturan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Nanti Saja'),
            )
          ],
        )
      );
    }

    if (!mounted) return;

    final weight = double.tryParse(_weightController.text);
    
    if (useDefault || weight == null || weight <= 0) {
      await context.read<SettingsCubit>().completeOnboarding();
    } else {
      await context.read<SettingsCubit>().completeOnboarding(weightKg: weight);
    }
    
    if (!mounted) return;
    await context.read<HomeCubit>().loadToday();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 24.0 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '💧 Selamat datang!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Mau atur target minum berdasarkan berat badan?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculatePreview(),
            decoration: const InputDecoration(
              labelText: 'Berat Badan',
              suffixText: 'kg',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_targetMlPreview != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Target Anda: ${_targetMlPreview!.toInt()} ml/hari',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton(
            onPressed: () => _requestPermissionsAndComplete(false),
            child: const Text('Pakai Target Ini ✓'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _requestPermissionsAndComplete(true),
            child: const Text('Pakai Default 2L'),
          ),
        ],
      ),
    );
  }
}
