import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final int targetMl;
  final int intervalMinutes;
  final int activeStartHour;
  final int activeStartMinute;
  final int activeEndHour;
  final int activeEndMinute;
  final bool pauseMode;
  final double? bodyWeightKg;
  final bool autoCalcTarget;
  final int preset1Ml;
  final int preset2Ml;

  const SettingsState({
    this.targetMl = 2500,
    this.intervalMinutes = 90,
    this.activeStartHour = 8,
    this.activeStartMinute = 0,
    this.activeEndHour = 22,
    this.activeEndMinute = 0,
    this.pauseMode = false,
    this.bodyWeightKg,
    this.autoCalcTarget = false,
    this.preset1Ml = 200,
    this.preset2Ml = 500,
  });

  SettingsState copyWith({
    int? targetMl,
    int? intervalMinutes,
    int? activeStartHour,
    int? activeStartMinute,
    int? activeEndHour,
    int? activeEndMinute,
    bool? pauseMode,
    double? bodyWeightKg,
    bool? autoCalcTarget,
    int? preset1Ml,
    int? preset2Ml,
  }) {
    return SettingsState(
      targetMl: targetMl ?? this.targetMl,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      activeStartHour: activeStartHour ?? this.activeStartHour,
      activeStartMinute: activeStartMinute ?? this.activeStartMinute,
      activeEndHour: activeEndHour ?? this.activeEndHour,
      activeEndMinute: activeEndMinute ?? this.activeEndMinute,
      pauseMode: pauseMode ?? this.pauseMode,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      autoCalcTarget: autoCalcTarget ?? this.autoCalcTarget,
      preset1Ml: preset1Ml ?? this.preset1Ml,
      preset2Ml: preset2Ml ?? this.preset2Ml,
    );
  }

  @override
  List<Object?> get props => [
        targetMl,
        intervalMinutes,
        activeStartHour,
        activeStartMinute,
        activeEndHour,
        activeEndMinute,
        pauseMode,
        bodyWeightKg,
        autoCalcTarget,
        preset1Ml,
        preset2Ml,
      ];
}
