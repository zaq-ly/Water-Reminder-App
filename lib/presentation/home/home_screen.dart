import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'widgets/progress_ring.dart';
import 'widgets/preset_button.dart';
import 'widgets/custom_input_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static dummy values for now
    const int currentMl = 1200;
    const int targetMl = 2500;
    const double progress = currentMl / targetMl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(AppRouter.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Center(
                  child: ProgressRing(
                    progress: progress,
                    currentMl: currentMl,
                    targetMl: targetMl,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Tambah Asupan Air',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: PresetButton(
                      amount: 200,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PresetButton(
                      amount: 500,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => const CustomInputDialog(),
                  );
                  if (result != null) {
                    // TODO: Handle manual input
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Input Manual'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
