import 'package:dio/dio.dart';
import 'app_constant.dart';
import 'log_util.dart';

class NetManager {
  static String nowModel = AppConstant.mainModel;
  static String _currentBaseUrl = AppConstant.primaryBaseUrl;
  static String _currentApiKey = AppConstant.primaryApiKey;

  static Dio get dio {
    return Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: AppConstant.connectTimeout,
      receiveTimeout: AppConstant.receiveTimeout,
      headers: {
        "Authorization": "Bearer \$_currentApiKey",
        "Content-Type": "application/json",
      },
    ));
  }

  /// 带降级重试的请求：主节点失败 -> 备用1 -> 备用2
  static Future<T> requestWithFallback<T>(Future<T> Function() request) async {
    // 尝试主节点
    _currentBaseUrl = AppConstant.primaryBaseUrl;
    _currentApiKey = AppConstant.primaryApiKey;
    try {
      return await request();
    } catch (e) {
      LogUtil.e("网络降级", "主节点失败，尝试备用1：\$e");
    }

    // 尝试备用1
    _currentBaseUrl = AppConstant.spare1BaseUrl;
    _currentApiKey = AppConstant.spare1ApiKey;
    nowModel = AppConstant.spare1Model;
    try {
      return await request();
    } catch (e) {
      LogUtil.e("网络降级", "备用1失败，尝试备用2：\$e");
    }

    // 尝试备用2
    _currentBaseUrl = AppConstant.spare2BaseUrl;
    _currentApiKey = AppConstant.spare2ApiKey;
    nowModel = AppConstant.spare2Model;
    return await request();
  }
}
