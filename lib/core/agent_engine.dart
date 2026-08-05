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

/// 将字节流转为字符串流（绕过 Utf8Decoder 类型问题）
Stream<String> _bytesToStringStream(Stream stream) async* {
  await for (final chunk in stream) {
    if (chunk is List<int>) {
      yield utf8.decode(chunk, allowMalformed: true);
    }
  }
}

/// Agent 引擎 - 连接 agent-service 后端
class AgentEngine {
  /// Agent Service SSE 流式对话
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
        final stringStream = _bytesToStringStream(response.data.stream);
        final linesStream = stringStream.transform(const LineSplitter());
        final stream = linesStream
            .where((String line) => line.isNotEmpty)
            .expand((String line) => _parseSSELine(line))
            .where((AgentEvent event) => event.type != AgentEventType.done);

        return stream;
      });
    });
  }

  /// 解析单行 SSE 数据
  static Iterable<AgentEvent> _parseSSELine(String line) sync* {
    String data = line;
    if (line.startsWith('data: ')) {
      data = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      data = line.substring(5).trim();
    } else {
      return;
    }

    if (data == '[DONE]') {
      yield AgentEvent.done();
      return;
    }

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
          if (jsonData.containsKey('content')) {
            final content = jsonData['content'] ?? '';
            if (content.isNotEmpty) {
              yield AgentEvent.text(content);
            }
          }
          break;
      }
    } catch (e) {
      if (data.isNotEmpty && data != '[DONE]') {
        LogUtil.w('Agent引擎', 'SSE解析异常: $e, data=$data');
      }
    }
  }

  /// 商业 API 流式对话（备用通道）
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
          final stringStream = _bytesToStringStream(response.data.stream);
          final linesStream = stringStream.transform(const LineSplitter());
          final stream = linesStream
              .where((String line) => line.isNotEmpty)
              .where((String line) => line.startsWith('data: '))
              .map((String line) => line.substring(6).trim())
              .where((String jsonStr) => jsonStr != '[DONE]')
              .map((String jsonStr) {
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
              .where((String text) => text.isNotEmpty);

          return stream;
        });
      });
    });
  }

  /// 普通一次性问答请求
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
