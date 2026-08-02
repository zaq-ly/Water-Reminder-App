import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_reminder/presentation/settings/bloc/settings_cubit.dart';
import 'package:water_reminder/presentation/settings/bloc/settings_state.dart';
import 'package:water_reminder/presentation/home/bloc/home_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTargetSection(context, state),
              const Divider(height: 32),
              _buildNotificationSection(context, state),
              const Divider(height: 32),
              _buildPresetSection(context, state),
              const Divider(height: 32),
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTargetSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Harian', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Target Air (ml)'),
          trailing: Text('${state.targetMl} ml', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            // Show dialog to update target
            final result = await _showNumberInputDialog(context, 'Target Harian (ml)', state.targetMl);
            if (result != null && context.mounted) {
              context.read<SettingsCubit>().updateTarget(result);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Berat Badan (kg)'),
          trailing: Text(state.bodyWeightKg != null ? '${state.bodyWeightKg?.toStringAsFixed(1)} kg' : 'Atur', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            final result = await _showNumberInputDialog(context, 'Berat Badan (kg)', state.bodyWeightKg?.toInt() ?? 60);
            if (result != null && context.mounted) {
              context.read<SettingsCubit>().setBodyWeight(result.toDouble());
            }
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Kalkulasi Otomatis (BB × 30ml)'),
          value: state.autoCalcTarget,
          onChanged: state.bodyWeightKg != null ? (value) {
            context.read<SettingsCubit>().toggleAutoCalc(value);
          } : null,
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifikasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Interval Pengingat'),
          trailing: DropdownButton<int>(
            value: [1, 15, 30, 45, 60].contains(state.intervalMinutes) ? state.intervalMinutes : 30,
            underline: const SizedBox(),
            items: [1, 15, 30, 45, 60].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value menit'),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                try {
                  await context.read<SettingsCubit>().updateInterval(value);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sukses! Harusnya notifikasi muncul.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Jam Mulai'),
          trailing: Text('${state.activeStartHour.toString().padLeft(2, '0')}:${state.activeStartMinute.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: state.activeStartHour, minute: state.activeStartMinute),
            );
            if (time != null && context.mounted) {
              context.read<SettingsCubit>().updateActiveHours(
                startHour: time.hour,
                startMinute: time.minute,
                endHour: state.activeEndHour,
                endMinute: state.activeEndMinute,
              );
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Jam Selesai'),
          trailing: Text('${state.activeEndHour.toString().padLeft(2, '0')}:${state.activeEndMinute.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: state.activeEndHour, minute: state.activeEndMinute),
            );
            if (time != null && context.mounted) {
              context.read<SettingsCubit>().updateActiveHours(
                startHour: state.activeStartHour,
                startMinute: state.activeStartMinute,
                endHour: time.hour,
                endMinute: time.minute,
              );
            }
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mode Jeda (Jangan Ganggu)'),
          subtitle: const Text('Menghentikan semua notifikasi sementara'),
          value: state.pauseMode,
          onChanged: (value) {
            context.read<SettingsCubit>().togglePause();
          },
        ),
      ],
    );
  }

  Widget _buildPresetSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preset Tombol (Di Halaman Utama)', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tombol Kiri (ml)'),
          trailing: Text('${state.preset1Ml} ml', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            final result = await _showNumberInputDialog(context, 'Preset Kiri (ml)', state.preset1Ml);
            if (result != null && context.mounted) {
              context.read<SettingsCubit>().updatePresets(preset1: result, preset2: state.preset2Ml);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tombol Kanan (ml)'),
          trailing: Text('${state.preset2Ml} ml', style: Theme.of(context).textTheme.titleMedium),
          onTap: () async {
            final result = await _showNumberInputDialog(context, 'Preset Kanan (ml)', state.preset2Ml);
            if (result != null && context.mounted) {
              context.read<SettingsCubit>().updatePresets(preset1: state.preset1Ml, preset2: result);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lainnya', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.refresh, color: Colors.red),
          title: const Text('Reset Data Hari Ini', style: TextStyle(color: Colors.red)),
          onTap: () {
            final homeCubit = context.read<HomeCubit>();
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Reset Data?'),
                content: const Text('Apakah Anda yakin ingin mereset progress air hari ini menjadi 0 ml? Data yang terhapus tidak bisa dikembalikan.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      homeCubit.resetDaily();
                      Navigator.pop(dialogContext);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Data hari ini berhasil direset.')),
                      );
                    },
                    child: const Text('Reset', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Versi'),
          trailing: Text('1.0.0'),
        ),
      ],
    );
  }

  Future<int?> _showNumberInputDialog(BuildContext context, String title, int currentValue) async {
    final controller = TextEditingController(text: currentValue.toString());
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: 'ml/kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
