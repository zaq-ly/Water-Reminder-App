import 'package:equatable/equatable.dart';
import '../../../data/models/intake_entry.dart';

class HomeState extends Equatable {
  final int todayIntakeMl;
  final int targetMl;
  final List<IntakeEntry> entries;
  final bool targetReached;
  final double progressPercent;
  final int remainingMl;
  final bool isPauseMode;
  final bool isPermissionGranted;
  final bool isFirstLaunch;
  final int preset1Ml;
  final int preset2Ml;

  const HomeState({
    this.todayIntakeMl = 0,
    this.targetMl = 2500,
    this.entries = const [],
    this.targetReached = false,
    this.progressPercent = 0.0,
    this.remainingMl = 2500,
    this.isPauseMode = false,
    this.isPermissionGranted = false,
    this.isFirstLaunch = true,
    this.preset1Ml = 200,
    this.preset2Ml = 300,
  });

  HomeState copyWith({
    int? todayIntakeMl,
    int? targetMl,
    List<IntakeEntry>? entries,
    bool? targetReached,
    double? progressPercent,
    int? remainingMl,
    bool? isPauseMode,
    bool? isPermissionGranted,
    bool? isFirstLaunch,
    int? preset1Ml,
    int? preset2Ml,
  }) {
    return HomeState(
      todayIntakeMl: todayIntakeMl ?? this.todayIntakeMl,
      targetMl: targetMl ?? this.targetMl,
      entries: entries ?? this.entries,
      targetReached: targetReached ?? this.targetReached,
      progressPercent: progressPercent ?? this.progressPercent,
      remainingMl: remainingMl ?? this.remainingMl,
      isPauseMode: isPauseMode ?? this.isPauseMode,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      preset1Ml: preset1Ml ?? this.preset1Ml,
      preset2Ml: preset2Ml ?? this.preset2Ml,
    );
  }

  @override
  List<Object?> get props => [
        todayIntakeMl,
        targetMl,
        entries,
        targetReached,
        progressPercent,
        remainingMl,
        isPauseMode,
        isPermissionGranted,
        isFirstLaunch,
        preset1Ml,
        preset2Ml,
      ];
}
