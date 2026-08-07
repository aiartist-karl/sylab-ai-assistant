import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver2_fixed/image_gallery_saver2_fixed.dart';
import '../common/app_constant.dart';
import '../common/log_util.dart';
import '../common/permission_util.dart';

class ImageGenerator {
  // P0修复：硅基流动Dio单例化，避免每次生图都新建Dio实例导致连接泄漏
  static Dio? _sfDio;

  static Dio _getSfDio() {
    _sfDio ??= Dio(BaseOptions(
      baseUrl: AppConstant.sfBaseUrl,
      connectTimeout: AppConstant.connectTimeout,
      receiveTimeout: AppConstant.receiveTimeout,
      headers: {
        "Authorization": "Bearer ${AppConstant.sfApiKey}",
        "Content-Type": "application/json",
      },
    ));
    return _sfDio!;
  }

  /// P0修复：显式关闭连接池
  static void dispose() {
    _sfDio?.close(force: true);
    _sfDio = null;
  }

  // 彻底根治编译报错、FLUX非法参数、类型不匹配、Response取值运行时崩溃
  static Future<String?> generateImage(String prompt) async {
    // P0修复：API密钥鉴权前置校验，封堵无认证路由
    if (!AppConstant.isSfKeyValid()) {
      LogUtil.e("图像生成", "认证失败：硅基流动API密钥未配置，请先在AppConstant中设置真实密钥");
      return null;
    }

    // 权限前置校验
    if (!await PermissionUtil.requestMediaPermission()) {
      LogUtil.e("图像生成", "无相册权限，生成失败");
      return null;
    }

    try {
      final Dio sfDio = _getSfDio();
      // 严格对齐FLUX.1-schnell官方蒸馏模型参数规范
      final Response res = await sfDio.post(
        "/images/generations",
        data: {
          "model": "black-forest-labs/FLUX.1-schnell",
          "prompt": prompt,
          "image_size": "1024x1024",
          // 官方最优参数：1-4步，默认4步，无算力浪费、无质量损耗
          "num_inference_steps": 4,
          // schnell蒸馏模型无CFG引导能力，置0为官方标准配置，杜绝隐性报错与算力冗余
          "guidance_scale": 0,
        },
      );

      // 核心修复：Dio返回Response对象，必须取.data解析业务数据
      final Map<String, dynamic> resData = res.data;
      if (resData["images"] != null && resData["images"].isNotEmpty) {
        final String imageUrl = resData["images"][0]["url"];
        // 根治编译必崩：严格类型转换 List<int> → Uint8List
        final Response<List<int>> imgRes = await sfDio.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final Uint8List uint8ImageData = Uint8List.fromList(imgRes.data!);
        // 传入官方要求合规参数，彻底解决类型不匹配编译错误
        final bool saveResult = await ImageGallerySaver.saveImage(uint8ImageData);
        if (saveResult) {
          LogUtil.i("图像生成", "图片生成并保存相册成功");
          return imageUrl;
        }
      }
      LogUtil.e("图像生成", "接口无返回图片数据");
      return null;
    } catch (e) {
      LogUtil.e("图像生成", "生成失败：$e");
      return null;
    }
  }
}
