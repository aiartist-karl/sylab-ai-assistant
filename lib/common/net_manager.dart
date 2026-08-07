import 'package:dio/dio.dart';
import 'app_constant.dart';
import 'log_util.dart';

class NetManager {
  static String nowModel = AppConstant.mainModel;
  static String _currentBaseUrl = AppConstant.primaryBaseUrl;
  static String _currentApiKey = AppConstant.primaryApiKey;

  // P0修复：Dio单例化，杜绝每次访问getter都新建Dio实例导致的连接池泄漏
  // 原BUG：dio getter 每次返回 Dio(BaseOptions(...))，每次请求创建新Dio+新HttpClient，
  //        旧实例未被close，底层TCP连接永不释放，最终耗尽文件描述符引发OOM崩溃
  static Dio? _dioInstance;

  static Dio get dio {
    _dioInstance ??= Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: AppConstant.connectTimeout,
      receiveTimeout: AppConstant.receiveTimeout,
      headers: {
        "Authorization": "Bearer $_currentApiKey",
        "Content-Type": "application/json",
      },
    ));
    return _dioInstance!;
  }

  /// P0修复：降级时复用同一Dio实例，仅更新baseUrl和headers，避免创建新连接池
  static void _updateDioConfig() {
    if (_dioInstance == null) return;
    _dioInstance!.options
      ..baseUrl = _currentBaseUrl
      ..headers["Authorization"] = "Bearer $_currentApiKey";
  }

  /// P0修复：应用退出时显式关闭Dio，释放底层HttpClient连接池
  static void dispose() {
    _dioInstance?.close(force: true);
    _dioInstance = null;
  }

  /// 带降级重试的请求：主节点失败 -> 备用1 -> 备用2
  static Future<T> requestWithFallback<T>(Future<T> Function() request) async {
    // 尝试主节点
    _currentBaseUrl = AppConstant.primaryBaseUrl;
    _currentApiKey = AppConstant.primaryApiKey;
    nowModel = AppConstant.mainModel;
    _updateDioConfig();
    try {
      return await request();
    } catch (e) {
      LogUtil.e("网络降级", "主节点失败，尝试备用1：$e");
    }

    // 尝试备用1
    _currentBaseUrl = AppConstant.spare1BaseUrl;
    _currentApiKey = AppConstant.spare1ApiKey;
    nowModel = AppConstant.spare1Model;
    _updateDioConfig();
    try {
      return await request();
    } catch (e) {
      LogUtil.e("网络降级", "备用1失败，尝试备用2：$e");
    }

    // 尝试备用2
    _currentBaseUrl = AppConstant.spare2BaseUrl;
    _currentApiKey = AppConstant.spare2ApiKey;
    nowModel = AppConstant.spare2Model;
    _updateDioConfig();
    return await request();
  }
}
