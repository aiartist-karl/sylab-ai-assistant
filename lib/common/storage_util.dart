import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/message_model.dart';
import '../model/conversation_model.dart';

/// 存储工具 - 管理 Hive 本地数据持久化
class StorageUtil {
  /// 消息存储 Box（按会话ID分组）
  static late Box<MessageModel> chatBox;

  /// 会话列表 Box
  static late Box<ConversationModel> conversationBox;

  /// 初始化 Hive 并注册所有适配器
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // 注册 MessageModel 适配器（typeId: 0）
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }

    // 注册 ConversationModel 适配器（typeId: 1）
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConversationModelAdapter());
    }

    // 打开消息 Box
    chatBox = await Hive.openBox<MessageModel>('chat_message_box');

    // 打开会话 Box
    conversationBox = await Hive.openBox<ConversationModel>('conversation_box');
  }

  /// 获取指定会话的所有消息（按时间排序）
  static List<MessageModel> getMessagesForConversation(String conversationId) {
    return chatBox.values
        .where((msg) => msg.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
  }

  /// 删除指定会话的所有消息
  static Future<void> deleteMessagesForConversation(String conversationId) async {
    final keysToDelete = chatBox.keys
        .where((key) {
          final msg = chatBox.get(key);
          return msg != null && msg.conversationId == conversationId;
        })
        .toList();
    await chatBox.deleteAll(keysToDelete);
  }

  /// 保存消息到本地
  static Future<void> saveMessage(MessageModel msg) async {
    await chatBox.put(msg.timeStamp, msg);
  }

  /// 获取所有会话（按更新时间降序）
  static List<ConversationModel> getAllConversations() {
    return conversationBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
