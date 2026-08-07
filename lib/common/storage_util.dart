import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/message_model.dart';

class StorageUtil {
  // 全局唯一消息存储Box，强绑定MessageModel类型
  static late Box<MessageModel> chatBox;

  // P0修复：补齐缺失的本地持久化表（Box）
  // 对应AppConstant中声明的四个缓存目录，此前仅初始化chatBox，其余三个Box缺失导致读写崩溃
  static late Box<Map> officeBox;   // 办公文档元数据表
  static late Box<Map> logBox;      // 日志记录表
  static late Box<Map> mediaCacheBox; // 媒体缓存表

  // 初始化Hive+注册适配器（APP启动一次性调用）
  static Future<void> initHive() async {
    await Hive.initFlutter();
    // 注册模型适配器，解决反序列化失效问题
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    // P0修复：一次性打开全部所需的Hive Box，杜绝运行时"table not found"崩溃
    chatBox = await Hive.openBox<MessageModel>('chat_message_box');
    officeBox = await Hive.openBox<Map>('office_file_box');
    logBox = await Hive.openBox<Map>('app_log_box');
    mediaCacheBox = await Hive.openBox<Map>('media_cache_box');
  }

  /// P0修复：应用退出时安全关闭所有Box，释放文件锁
  static Future<void> disposeAll() async {
    await chatBox.close();
    await officeBox.close();
    await logBox.close();
    await mediaCacheBox.close();
  }
}
