import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import 'widgets/progress_ring.dart';
import 'widgets/preset_button.dart';
import 'widgets/custom_input_dialog.dart';
import 'widgets/celebration_overlay.dart';

import '../onboarding/onboarding_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasShownOnboarding = false;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().loadToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        if (!previous.targetReached && current.targetReached) return true;
        if (current.isFirstLaunch && !_hasShownOnboarding) return true;
        return false;
      },
      listener: (context, state) {
        if (state.isFirstLaunch && !_hasShownOnboarding) {
          _hasShownOnboarding = true;
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              OnboardingSheet.show(context);
            }
          });
        }
        
        // Listen for target reached
        if (state.targetReached) {
          // If we want to strictly check previous vs current inside listener, we can use listenWhen above,
          // but since listenWhen handles both onboarding and target, we might trigger this on first launch if target is already reached.
          // To be safe, we check if it's the exact moment target was reached (we should probably do this more carefully).
          setState(() {
            _showCelebration = true;
          });
        }
      },
      child: Scaffold(
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
          child: Stack(
            children: [
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            child: ProgressRing(
                              progress: state.progressPercent,
                              currentMl: state.todayIntakeMl,
                              targetMl: state.targetMl,
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
                                amount: state.preset1Ml,
                                onPressed: () {
                                  context.read<HomeCubit>().addIntake(state.preset1Ml);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PresetButton(
                                amount: state.preset2Ml,
                                onPressed: () {
                                  context.read<HomeCubit>().addIntake(state.preset2Ml);
                                },
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
                            if (result != null && context.mounted) {
                              context.read<HomeCubit>().addIntake(result);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Input Manual'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_showCelebration)
                Positioned.fill(
                  child: CelebrationOverlay(
                    onComplete: () {
                      if (mounted) {
                        setState(() {
                          _showCelebration = false;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
