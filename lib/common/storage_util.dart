import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/message_model.dart';

class StorageUtil {
  // 全局唯一消息存储Box，强绑定MessageModel类型
  static late Box<MessageModel> chatBox;

  // 初始化Hive+注册适配器（APP启动一次性调用）
  static Future<void> initHive() async {
    await Hive.initFlutter();
    // 注册模型适配器，解决反序列化失效问题
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    chatBox = await Hive.openBox<MessageModel>('chat_message_box');
  }
}
