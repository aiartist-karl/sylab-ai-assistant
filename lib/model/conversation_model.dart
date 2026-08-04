import 'package:hive/hive.dart';
part 'conversation_model.g.dart';

/// 会话模型 - 支持多会话管理
@HiveType(typeId: 1)
class ConversationModel extends HiveObject {
  /// 会话唯一ID
  @HiveField(0)
  String id;

  /// 会话标题
  @HiveField(1)
  String title;

  /// 关联的工作区
  @HiveField(2)
  String workspace;

  /// 创建时间
  @HiveField(3)
  int createdAt;

  /// 最后更新时间
  @HiveField(4)
  int updatedAt;

  ConversationModel({
    required this.id,
    required this.title,
    required this.workspace,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新会话的工厂方法
  factory ConversationModel.create({
    required String id,
    String title = '新会话',
    String workspace = 'default',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ConversationModel(
      id: id,
      title: title,
      workspace: workspace,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新时间戳
  void touch() {
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// 格式化为创建时间字符串
  String get createdAtFormatted {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    return '${dt.month}/${dt.day}';
  }

  /// 格式化为完整时间字符串
  String get fullTimeFormatted {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'Conversation($id, $title, $workspace)';
}
