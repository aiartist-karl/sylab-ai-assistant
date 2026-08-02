import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../common/net_manager.dart';
import '../common/rate_limiter.dart';
import '../common/log_util.dart';
import '../common/global_exception.dart';

class AgentEngine {
  // 【彻底修复SSE解析缺陷】自动过滤脏数据、解析JSON、提取纯文本，UI直接可用
  static Future<Stream<String>> chatStream(List<Map<String, String>> messages) async {
    return await RateLimiter.limitRun(() async {
      return await NetManager.requestWithFallback(() async {
        return await GlobalException.catchAsyncError(() async {
          final requestData = {
            "model": NetManager.nowModel,
            "messages": messages,
            "stream": true,
          };

          final response = await NetManager.dio.post(
            "/chat/completions",
            data: requestData,
            options: Options(responseType: ResponseType.stream),
          );

          // 完整SSE流式数据解析链路：过滤空行→去除data前缀→过滤结束符→解析JSON→提取回复文本
          final stream = response.data.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              // 过滤无效空行
              .where((line) => line.isNotEmpty)
              // 仅保留有效数据流行
              .where((line) => line.startsWith("data: "))
              // 剥离SSE协议前缀
              .map((line) => line.substring(6).trim())
              // 过滤流式结束标记
              .where((jsonStr) => jsonStr != "[DONE]")
              // 容错解析JSON，异常静默丢弃
              .map((jsonStr) {
                try {
                  final Map<String, dynamic> jsonData = json.decode(jsonStr);
                  final List<dynamic> choices = jsonData["choices"] ?? [];
                  if (choices.isEmpty) return "";
                  final Map<String, dynamic> delta = choices[0]["delta"] ?? {};
                  return delta["content"] ?? "";
                } catch (_) {
                  return "";
                }
              })
              // 过滤空文本，避免UI空白闪烁
              .where((text) => text.isNotEmpty);

          return stream;
        });
      });
    });
  }

  // 普通一次性问答请求（修复返回Response对象BUG，正确返回业务Map数据）
  static Future<Map<String, dynamic>> chatNormal(List<Map<String, String>> messages) async {
    return await RateLimiter.limitRun(() async {
      return await NetManager.requestWithFallback(() async {
        return await GlobalException.catchAsyncError(() async {
          final Response res = await NetManager.dio.post(
            "/chat/completions",
            data: {
              "model": NetManager.nowModel,
              "messages": messages,
              "stream": false,
            },
          );
          // 核心修复：返回解析后的业务Map，而非原始Response对象，适配Office生成调用
          return res.data;
        });
      });
    });
  }
}
