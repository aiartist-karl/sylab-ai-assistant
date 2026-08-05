import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../common/app_constant.dart';
import '../common/net_manager.dart';
import '../common/rate_limiter.dart';
import '../common/log_util.dart';
import '../common/global_exception.dart';
import '../model/message_model.dart';

/// Agent 事件类型
enum AgentEventType {
  text,       // 文本输出
  toolCall,   // 工具调用
  toolResult, // 工具结果
  done,       // 流结束
  error,      // 错误
}

/// Agent 事件数据
class AgentEvent {
  final AgentEventType type;
  final String content;
  final String toolName;
  final String toolArgs;
  final String toolOutput;

  AgentEvent({
    required this.type,
    this.content = '',
    this.toolName = '',
    this.toolArgs = '',
    this.toolOutput = '',
  });

  factory AgentEvent.text(String text) => AgentEvent(
    type: AgentEventType.text,
    content: text,
  );

  factory AgentEvent.toolCall(String name, String args) => AgentEvent(
    type: AgentEventType.toolCall,
    toolName: name,
    toolArgs: args,
  );

  factory AgentEvent.toolResult(String name, String output) => AgentEvent(
    type: AgentEventType.toolResult,
    toolName: name,
    toolOutput: output,
  );

  factory AgentEvent.done() => AgentEvent(type: AgentEventType.done);

  factory AgentEvent.error(String msg) => AgentEvent(
    type: AgentEventType.error,
    content: msg,
  );
}

/// Agent 引擎 - 连接 agent-service 后端
class AgentEngine {
  /// Agent Service SSE 流式对话
  /// 连接自有后端 agent-service，支持完整对话历史和工具调用事件
  static Future<Stream<AgentEvent>> chatStreamAgent({
    required List<Map<String, dynamic>> messages,
    required String workspace,
  }) async {
    return await RateLimiter.limitRun(() async {
      return await GlobalException.catchAsyncError(() async {
        final dio = Dio(BaseOptions(
          connectTimeout: AppConstant.connectTimeout,
          receiveTimeout: AppConstant.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ));

        final requestData = {
          'messages': messages,
          'workspace': workspace,
        };

        LogUtil.i('Agent引擎', '发送请求: workspace=$workspace, messages=${messages.length}条');

        final response = await dio.post(
          AppConstant.agentServiceUrl,
          data: requestData,
          options: Options(responseType: ResponseType.stream),
        );

        // 解析自定义 SSE 事件流
        final stream = response.data.stream
            .cast<List<int>>().transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.isNotEmpty)
            .expand((line) => _parseSSELine(line))
            .where((event) => event.type != AgentEventType.done);

        return stream;
      });
    });
  }

  /// 解析单行 SSE 数据
  static Iterable<AgentEvent> _parseSSELine(String line) sync* {
    // SSE 标准格式: "data: xxx"
    String data = line;
    if (line.startsWith('data: ')) {
      data = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      data = line.substring(5).trim();
    } else {
      // 非 SSE 格式行，跳过
      return;
    }

    // 流结束标记
    if (data == '[DONE]') {
      yield AgentEvent.done();
      return;
    }

    // 解析 JSON 事件
    try {
      final Map<String, dynamic> jsonData = json.decode(data);
      final String type = jsonData['type'] ?? '';

      switch (type) {
        case 'text':
          final content = jsonData['content'] ?? '';
          if (content.isNotEmpty) {
            yield AgentEvent.text(content);
          }
          break;

        case 'tool_call':
          final name = jsonData['name'] ?? '';
          final args = jsonData['args'] ?? {};
          yield AgentEvent.toolCall(
            name,
            args is String ? args : json.encode(args),
          );
          break;

        case 'tool_result':
          final name = jsonData['name'] ?? '';
          final output = jsonData['output'] ?? '';
          yield AgentEvent.toolResult(
            name,
            output is String ? output : json.encode(output),
          );
          break;

        case 'error':
          yield AgentEvent.error(jsonData['content'] ?? jsonData['message'] ?? '未知错误');
          break;

        default:
          // 未知类型，尝试作为文本处理
          if (jsonData.containsKey('content')) {
            final content = jsonData['content'] ?? '';
            if (content.isNotEmpty) {
              yield AgentEvent.text(content);
            }
          }
          break;
      }
    } catch (e) {
      // JSON 解析失败，可能是纯文本数据，尝试作为文本处理
      if (data.isNotEmpty && data != '[DONE]') {
        LogUtil.w('Agent引擎', 'SSE解析异常: $e, data=$data');
      }
    }
  }

  /// 商业 API 流式对话（备用通道，兼容原有接口）
  static Future<Stream<String>> chatStream(List<Map<String, String>> messages) async {
    return await RateLimiter.limitRun(() async {
      return await NetManager.requestWithFallback(() async {
        return await GlobalException.catchAsyncError(() async {
          final requestData = {
            'model': NetManager.nowModel,
            'messages': messages,
            'stream': true,
          };

          final response = await NetManager.dio.post(
            '/chat/completions',
            data: requestData,
            options: Options(responseType: ResponseType.stream),
          );

          // 完整 SSE 流式数据解析
          final stream = response.data.stream
              .cast<List<int>>().transform(utf8.decoder)
              .transform(const LineSplitter())
              .where((line) => line.isNotEmpty)
              .where((line) => line.startsWith('data: '))
              .map((line) => line.substring(6).trim())
              .where((jsonStr) => jsonStr != '[DONE]')
              .map((jsonStr) {
                try {
                  final Map<String, dynamic> jsonData = json.decode(jsonStr);
                  final List<dynamic> choices = jsonData['choices'] ?? [];
                  if (choices.isEmpty) return '';
                  final Map<String, dynamic> delta = choices[0]['delta'] ?? {};
                  return delta['content'] ?? '';
                } catch (_) {
                  return '';
                }
              })
              .where((text) => text.isNotEmpty);

          return stream;
        });
      });
    });
  }

  /// 普通一次性问答请求（兼容 Office 生成等场景）
  static Future<Map<String, dynamic>> chatNormal(List<Map<String, String>> messages) async {
    return await RateLimiter.limitRun(() async {
      return await NetManager.requestWithFallback(() async {
        return await GlobalException.catchAsyncError(() async {
          final Response res = await NetManager.dio.post(
            '/chat/completions',
            data: {
              'model': NetManager.nowModel,
              'messages': messages,
              'stream': false,
            },
          );
          return res.data;
        });
      });
    });
  }
}

