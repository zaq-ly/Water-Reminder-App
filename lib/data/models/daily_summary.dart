import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'daily_summary.freezed.dart';

@freezed
class DailySummary with _$DailySummary {
  const factory DailySummary({
    required String date, // Format YYYY-MM-DD
    required int totalMl,
    required int targetMl,
  }) = _DailySummary;
}

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 1;

  @override
  DailySummary read(BinaryReader reader) {
    return DailySummary(
      date: reader.readString(),
      totalMl: reader.readInt(),
      targetMl: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer.writeString(obj.date);
    writer.writeInt(obj.totalMl);
    writer.writeInt(obj.targetMl);
  }
}
