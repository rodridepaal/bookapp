part of 'saved_book_model.dart';

class SavedBookAdapter extends TypeAdapter<SavedBook> {
  @override
  final int typeId = 1;

  @override
  SavedBook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedBook(
      bookId: fields[0] as String,
      status: fields[1] as String,
      finishedTimestamp: fields[2] as DateTime?,
      title: fields[3] as String,
      authors: fields[4] as String,
      thumbnailLink: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedBook obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.finishedTimestamp)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.authors)
      ..writeByte(5)
      ..write(obj.thumbnailLink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedBookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
