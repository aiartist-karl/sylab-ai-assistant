import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../common/app_constant.dart';
import '../common/log_util.dart';

class ImageGenerator {
  // 硅基流动专属Dio，彻底隔离对话接口路由
  static Dio _initSfDio() {
    return Dio(BaseOptions(
      baseUrl: AppConstant.sfBaseUrl,
      connectTimeout: AppConstant.connectTimeout,
      receiveTimeout: AppConstant.receiveTimeout,
      headers: {
        "Authorization": "Bearer ${AppConstant.sfApiKey}",
        "Content-Type": "application/json",
      },
    ));
  }

  // 生成图片并保存到应用文档目录（跨平台兼容）
  static Future<String?> generateImage(String prompt) async {
    try {
      final Dio sfDio = _initSfDio();
      // 严格对齐FLUX.1-schnell官方蒸馏模型参数规范
      final Response res = await sfDio.post(
        "/images/generations",
        data: {
          "model": "black-forest-labs/FLUX.1-schnell",
          "prompt": prompt,
          "image_size": "1024x1024",
          "num_inference_steps": 4,
          "guidance_scale": 0,
        },
      );

      final Map<String, dynamic> resData = res.data;
      if (resData["images"] != null && resData["images"].isNotEmpty) {
        final String imageUrl = resData["images"][0]["url"];
        final Response<List<int>> imgRes = await sfDio.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final Uint8List uint8ImageData = Uint8List.fromList(imgRes.data!);
        
        // 保存到应用文档目录（iOS/Android通用）
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = 'sylab_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final File savedFile = File('${appDocDir.path}/$fileName');
        await savedFile.writeAsBytes(uint8ImageData);
        
        LogUtil.i("图像生成", "图片已保存到: ${savedFile.path}");
        return savedFile.path;
      }
      LogUtil.e("图像生成", "接口无返回图片数据");
      return null;
    } catch (e) {
      LogUtil.e("图像生成", "生成失败：$e");
      return null;
    }
  }
}
