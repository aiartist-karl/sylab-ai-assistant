// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// MessageModelAdapter
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      role: fields[0] as String,
      content: fields[1] as String,
      timeStamp: fields[2] as int,
      type: (fields[3] as String?) ?? 'text',
      toolName: (fields[4] as String?) ?? '',
      toolArgs: (fields[5] as String?) ?? '',
      toolOutput: (fields[6] as String?) ?? '',
      conversationId: (fields[7] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.role);
    writer.writeByte(1);
    writer.write(obj.content);
    writer.writeByte(2);
    writer.write(obj.timeStamp);
    writer.writeByte(3);
    writer.write(obj.type);
    writer.writeByte(4);
    writer.write(obj.toolName);
    writer.writeByte(5);
    writer.write(obj.toolArgs);
    writer.writeByte(6);
    writer.write(obj.toolOutput);
    writer.writeByte(7);
    writer.write(obj.conversationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
