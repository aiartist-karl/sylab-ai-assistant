import 'dart:async';
import 'dart:io';
// 根治编译必崩：补齐路径工具依赖，解决未定义函数报错
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver2_fixed/image_gallery_saver2_fixed.dart';
import '../common/app_constant.dart';
import '../common/log_util.dart';
import '../common/permission_util.dart';

class VideoGenerator {
  // 硅基流动专属Dio，提交+轮询全程独立路由，杜绝路由错乱404
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

  // 完整合规视频生成逻辑，适配官方2-5分钟生成时长
  static Future<String?> generateVideo(String prompt) async {
    if (!await PermissionUtil.requestMediaPermission()) {
      LogUtil.e("视频生成", "无相册权限，生成失败");
      return null;
    }

    try {
      final Dio sfDio = _initSfDio();
      // 提交视频生成任务
      final Response submitRes = await sfDio.post(
        "/video/submit",
        data: {
          "model": "Wan-AI/Wan2.2-T2V-A14B",
          "prompt": prompt,
          "negative_prompt": "抖动、模糊、卡顿、画面断裂、低画质",
          "image_size": "1280x720",
        },
      );

      // 核心修复：解析Response.data业务数据
      final Map<String, dynamic> submitData = submitRes.data;
      final String? requestId = submitData["requestId"];
      if (requestId == null) {
        LogUtil.e("视频提交", "未获取到任务ID");
        return null;
      }
      LogUtil.i("视频任务", "任务提交成功，ID：$requestId，开始轮询结果");

      // 60次×5秒=5分钟超长轮询，适配官方视频生成耗时
      String? videoUrl;
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(milliseconds: 5000));
        final Response statusRes = await sfDio.post(
          "/video/status",
          data: {"requestId": requestId},
        );
        // 核心修复：解析轮询结果Response.data
        final Map<String, dynamic> statusData = statusRes.data;
        final String status = statusData["status"] ?? "";
        if (status == "Succeed") {
          videoUrl = statusData["results"]["videos"][0]["url"];
          break;
        } else if (status == "Failed") {
          LogUtil.e("视频生成", "任务失败：${statusData["reason"]}");
          return null;
        }
      }

      if (videoUrl != null) {
        // 合规下载+相册保存完整逻辑
        final Directory cacheDir = await getTemporaryDirectory();
        final String videoPath = "${cacheDir.path}/ai_video_${DateTime.now().millisecondsSinceEpoch}.mp4";
        await sfDio.download(videoUrl, videoPath);
        await ImageGallerySaver.saveFile(videoPath);
        LogUtil.i("视频生成", "视频生成并保存成功：$videoUrl");
        return videoUrl;
      }
      LogUtil.e("视频生成", "任务轮询超时（5分钟）");
      return null;
    } catch (e) {
      LogUtil.e("视频生成", "生成失败：$e");
      return null;
    }
  }
}
