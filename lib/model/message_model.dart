import 'package:hive/hive.dart';
part 'message_model.g.dart';

// 唯一固定typeId，杜绝适配冲突
@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  String role;

  @HiveField(1)
  String content;

  @HiveField(2)
  int timeStamp;

  MessageModel({
    required this.role,
    required this.content,
    required this.timeStamp,
  });
}
