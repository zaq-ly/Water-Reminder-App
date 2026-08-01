import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'intake_entry.freezed.dart';

@freezed
abstract class IntakeEntry with _$IntakeEntry {
  const factory IntakeEntry({
    required String id,
    required int amountMl,
    required DateTime timestamp,
  }) = _IntakeEntry;
}

class IntakeEntryAdapter extends TypeAdapter<IntakeEntry> {
  @override
  final int typeId = 0;

  @override
  IntakeEntry read(BinaryReader reader) {
    return IntakeEntry(
      id: reader.readString(),
      amountMl: reader.readInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, IntakeEntry obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.amountMl);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
