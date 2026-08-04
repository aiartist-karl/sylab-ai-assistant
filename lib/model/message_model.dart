import 'package:hive/hive.dart';
part 'message_model.g.dart';

/// 消息类型枚举
enum MessageType {
  text,       // 普通文本
  toolCall,   // 工具调用
  toolResult, // 工具结果
  error,      // 错误信息
}

/// 消息模型 - 支持多类型消息（文本、工具调用、工具结果、错误）
@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  String role;

  @HiveField(1)
  String content;

  @HiveField(2)
  int timeStamp;

  /// 消息类型：text, tool_call, tool_result, error
  @HiveField(3, defaultValue: 'text')
  String type;

  /// 工具名称（仅 tool_call/tool_result 类型使用）
  @HiveField(4, defaultValue: '')
  String toolName;

  /// 工具参数 JSON 字符串（仅 tool_call 类型使用）
  @HiveField(5, defaultValue: '')
  String toolArgs;

  /// 工具输出结果（仅 tool_result 类型使用）
  @HiveField(6, defaultValue: '')
  String toolOutput;

  /// 所属会话ID
  @HiveField(7, defaultValue: '')
  String conversationId;

  MessageModel({
    required this.role,
    required this.content,
    required this.timeStamp,
    this.type = 'text',
    this.toolName = '',
    this.toolArgs = '',
    this.toolOutput = '',
    this.conversationId = '',
  });

  /// 获取消息类型枚举
  MessageType get messageType {
    switch (type) {
      case 'tool_call':
        return MessageType.toolCall;
      case 'tool_result':
        return MessageType.toolResult;
      case 'error':
        return MessageType.error;
      default:
        return MessageType.text;
    }
  }

  /// 是否为文本消息
  bool get isText => type == 'text';

  /// 是否为工具调用
  bool get isToolCall => type == 'tool_call';

  /// 是否为工具结果
  bool get isToolResult => type == 'tool_result';

  /// 是否为错误消息
  bool get isError => type == 'error';

  /// 转换为基础 Map（用于发送给 Agent Service）
  Map<String, dynamic> toApiMap() {
    return {
      'role': role,
      'content': content,
    };
  }

  /// 创建工具调用消息
  factory MessageModel.toolCall({
    required String toolName,
    required String toolArgs,
    required int timeStamp,
  }) {
    return MessageModel(
      role: 'assistant',
      content: '调用工具: $toolName',
      timeStamp: timeStamp,
      type: 'tool_call',
      toolName: toolName,
      toolArgs: toolArgs,
    );
  }

  /// 创建工具结果消息
  factory MessageModel.toolResult({
    required String toolName,
    required String toolOutput,
    required int timeStamp,
  }) {
    return MessageModel(
      role: 'system',
      content: '工具 $toolName 执行结果',
      timeStamp: timeStamp,
      type: 'tool_result',
      toolName: toolName,
      toolOutput: toolOutput,
    );
  }

  /// 创建错误消息
  factory MessageModel.error({
    required String content,
    required int timeStamp,
  }) {
    return MessageModel(
      role: 'system',
      content: content,
      timeStamp: timeStamp,
      type: 'error',
    );
  }
}
