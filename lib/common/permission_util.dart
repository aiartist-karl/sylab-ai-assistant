import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> requestMediaPermission() async {
    // 简化实现：请求存储权限
    var status = await Permission.photos.status;
    if (status.isGranted) return true;
    status = await Permission.photos.request();
    return status.isGranted;
  }
}
