import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../common/log_util.dart';
import '../common/storage_util.dart';
import '../model/message_model.dart';
import '../model/conversation_model.dart';
import '../core/agent_engine.dart';
import '../toolkit/image_generator.dart';
import '../toolkit/video_generator.dart';
import '../toolkit/office_generator.dart';

/// 聊天页面 - 商业化 UI 升级版
class ChatPage extends StatefulWidget {
  /// 当前会话
  final ConversationModel conversation;

  /// 用于侧边栏通知刷新的回调
  final VoidCallback? onConversationUpdated;

  const ChatPage({
    super.key,
    required this.conversation,
    this.onConversationUpdated,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<MessageModel> _messageList = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late ConversationModel _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _loadHistoryMessage();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============ 数据加载 ============

  void _loadHistoryMessage() {
    final List<MessageModel> history =
        StorageUtil.getMessagesForConversation(_conversation.id);
    setState(() {
      _messageList.clear();
      _messageList.addAll(history);
    });
    LogUtil.i('聊天页', '加载会话 [${_conversation.title}] 消息: ${_messageList.length}条');
  }

  Future<void> _saveMessageToLocal(MessageModel msg) async {
    await StorageUtil.saveMessage(msg);
  }

  // ============ 发送消息 ============

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final String userInput = text.trim();
    _inputController.clear();

    // 添加用户消息
    final userMsg = MessageModel(
      role: 'user',
      content: userInput,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation.id,
    );
    setState(() {
      _messageList.add(userMsg);
      _isLoading = true;
    });
    await _saveMessageToLocal(userMsg);
    _scrollToBottom();

    // 如果是第一条消息，自动用用户输入作为会话标题
    if (_messageList.length == 1) {
      _conversation.title = userInput.length > 20
          ? '${userInput.substring(0, 20)}...'
          : userInput;
      _conversation.touch();
      await _conversation.save();
      widget.onConversationUpdated?.call();
    }

    // 识别指令并分发
    if (userInput.startsWith('生成图片')) {
      await _handleImageCommand(userInput);
    } else if (userInput.startsWith('生成视频')) {
      await _handleVideoCommand(userInput);
    } else if (userInput.startsWith('生成文档')) {
      await _handleDocCommand(userInput);
    } else {
      // 普通对话：走 Agent Service 流式输出
      await _handleAgentStream(userInput);
    }

    // 更新会话时间
    _conversation.touch();
    await _conversation.save();
    widget.onConversationUpdated?.call();

    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  // ============ 指令处理 ============

  Future<void> _handleImageCommand(String input) async {
    final prompt = input.replaceFirst('生成图片', '').trim();
    final aiMsg = MessageModel(
      role: 'assistant',
      content: '⏳ 正在生成图片，请稍候...',
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation.id,
    );
    setState(() => _messageList.add(aiMsg));
    await _saveMessageToLocal(aiMsg);

    final result = await ImageGenerator.generateImage(prompt);
    setState(() {
      aiMsg.content = result != null
          ? '✅ 图片已生成并保存到相册\n\n图片地址：$result'
          : '❌ 图片生成失败，请检查密钥配置';
    });
    await aiMsg.save();
  }

  Future<void> _handleVideoCommand(String input) async {
    final prompt = input.replaceFirst('生成视频', '').trim();
    final aiMsg = MessageModel(
      role: 'assistant',
      content: '⏳ 正在生成视频，预计需要2-5分钟...',
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation.id,
    );
    setState(() => _messageList.add(aiMsg));
    await _saveMessageToLocal(aiMsg);

    final result = await VideoGenerator.generateVideo(prompt);
    setState(() {
      aiMsg.content = result != null
          ? '✅ 视频已生成并保存到相册\n\n视频地址：$result'
          : '❌ 视频生成失败，请检查密钥配置';
    });
    await aiMsg.save();
  }

  Future<void> _handleDocCommand(String input) async {
    final content = input.replaceFirst('生成文档', '').trim();
    final aiMsg = MessageModel(
      role: 'assistant',
      content: '⏳ 正在生成文档，请稍候...',
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation.id,
    );
    setState(() => _messageList.add(aiMsg));
    await _saveMessageToLocal(aiMsg);

    final result = await OfficeGenerator.generateWord('AI文档', content);
    setState(() {
      aiMsg.content = result != null
          ? '✅ Word文档已生成：$result'
          : '❌ 文档生成失败';
    });
    await aiMsg.save();
  }

  // ============ Agent Service 流式对话 ============

  Future<void> _handleAgentStream(String userInput) async {
    // 构建完整的对话历史（包含系统提示词）
    final List<Map<String, dynamic>> apiMessages = [
      {
        'role': 'system',
        'content': '你是Sylab AI助手，一个商用级智能助手。回答简洁专业，善于使用工具帮助用户完成任务。',
      },
    ];

    // 添加历史消息
    for (final msg in _messageList) {
      if (msg.isText && (msg.role == 'user' || msg.role == 'assistant')) {
        apiMessages.add(msg.toApiMap());
      }
    }

    // 添加一个空的 AI 占位消息（用于流式填充文本）
    final aiTextMsg = MessageModel(
      role: 'assistant',
      content: '',
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      conversationId: _conversation.id,
    );
    setState(() => _messageList.add(aiTextMsg));
    _scrollToBottom();

    try {
      final Stream<AgentEvent> stream = await AgentEngine.chatStreamAgent(
        messages: apiMessages,
        workspace: _conversation.workspace,
      );

      await for (final event in stream) {
        switch (event.type) {
          case AgentEventType.text:
            // 追加文本到当前 AI 消息
            setState(() {
              aiTextMsg.content += event.content;
            });
            _scrollToBottom();
            break;

          case AgentEventType.toolCall:
            // 插入工具调用消息
            final toolCallMsg = MessageModel.toolCall(
              toolName: event.toolName,
              toolArgs: event.toolArgs,
              timeStamp: DateTime.now().millisecondsSinceEpoch,
            );
            toolCallMsg.conversationId = _conversation.id;
            setState(() => _messageList.add(toolCallMsg));
            await _saveMessageToLocal(toolCallMsg);
            _scrollToBottom();
            break;

          case AgentEventType.toolResult:
            // 插入工具结果消息
            final toolResultMsg = MessageModel.toolResult(
              toolName: event.toolName,
              toolOutput: event.toolOutput,
              timeStamp: DateTime.now().millisecondsSinceEpoch,
            );
            toolResultMsg.conversationId = _conversation.id;
            setState(() => _messageList.add(toolResultMsg));
            await _saveMessageToLocal(toolResultMsg);
            _scrollToBottom();
            break;

          case AgentEventType.error:
            final errorMsg = MessageModel.error(
              content: event.content,
              timeStamp: DateTime.now().millisecondsSinceEpoch,
            );
            errorMsg.conversationId = _conversation.id;
            setState(() => _messageList.add(errorMsg));
            await _saveMessageToLocal(errorMsg);
            break;

          case AgentEventType.done:
            break;
        }
      }

      // 保存最终的 AI 文本消息
      if (aiTextMsg.content.isNotEmpty) {
        await _saveMessageToLocal(aiTextMsg);
      }
    } catch (e) {
      LogUtil.e('对话流', 'Agent Service 请求失败: $e');
      setState(() {
        if (aiTextMsg.content.isEmpty) {
          aiTextMsg.content = '❌ AI 响应失败: $e';
          aiTextMsg.type = 'error';
        }
      });
      await _saveMessageToLocal(aiTextMsg);
    }
  }

  // ============ UI 辅助 ============

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============ 构建 UI ============

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _conversation.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '工作区: ${_conversation.workspace}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空对话',
            onPressed: _showClearDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messageList.isEmpty
                ? _buildWelcomeView()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messageList.length,
                    itemBuilder: (context, index) {
                      final msg = _messageList[index];
                      return _buildMessageWidget(msg);
                    },
                  ),
          ),
          // 加载指示器
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI 正在思考...',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 欢迎页面
  Widget _buildWelcomeView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sylab AI 助手',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '智能对话 · 工具调用 · 多模态生成',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureCard(
              icon: Icons.chat_bubble_outline,
              title: '智能对话',
              subtitle: '基于 Agent Service 的多轮对话，支持完整上下文理解',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.build_outlined,
              title: '工具调用',
              subtitle: 'AI 自动调用工具完成任务，实时展示执行过程',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.image_outlined,
              title: '多模态生成',
              subtitle: '输入"生成图片"、"生成视频"、"生成文档"即可使用',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 输入区域
  Widget _buildInputArea() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    hintText: '输入消息，或试试：生成图片 一只猫',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  enabled: !_isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoading
                  ? Container(
                      key: const ValueKey('loading'),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('send'),
                      width: 48,
                      height: 48,
                      child: IconButton(
                        onPressed: () => _sendMessage(_inputController.text),
                        icon: const Icon(Icons.send_rounded),
                        color: colorScheme.onPrimary,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 清空对话确认
  Future<void> _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空当前会话的所有消息吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageUtil.deleteMessagesForConversation(_conversation.id);
      setState(() => _messageList.clear());
    }
  }

  // ============ 消息组件 ============

  Widget _buildMessageWidget(MessageModel msg) {
    switch (msg.messageType) {
      case MessageType.toolCall:
        return _buildToolCallCard(msg);
      case MessageType.toolResult:
        return _buildToolResultCard(msg);
      case MessageType.error:
        return _buildErrorBubble(msg);
      case MessageType.text:
      default:
        final isUser = msg.role == 'user';
        return _buildTextBubble(msg, isUser);
    }
  }

  /// 用户/助手 文本气泡（支持 Markdown）
  Widget _buildTextBubble(MessageModel msg, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isUser
                  ? SelectableText(
                      msg.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : _buildMarkdownContent(msg.content),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.secondary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
        ],
      ),
    );
  }

  /// Markdown 渲染内容
  Widget _buildMarkdownContent(String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
        code: TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.shade100,
          color: Colors.pink.shade700,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border(
            left: BorderSide(color: Colors.blue, width: 3),
          ),
        ),
        listBullet: const TextStyle(fontSize: 15, color: Colors.black87),
        h1: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        h2: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        h3: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      builders: {
        'code': _CodeBlockBuilder(context),
      },
    );
  }

  /// 工具调用卡片（可折叠）
  Widget _buildToolCallCard(MessageModel msg) {
    return _CollapsibleToolCard(
      icon: Icons.build,
      iconColor: Colors.orange,
      title: '调用工具: ${msg.toolName}',
      subtitle: _formatToolArgs(msg.toolArgs),
      content: msg.toolArgs,
    );
  }

  /// 工具结果卡片（可折叠）
  Widget _buildToolResultCard(MessageModel msg) {
    return _CollapsibleToolCard(
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      title: '工具结果: ${msg.toolName}',
      subtitle: msg.toolOutput.length > 80
          ? '${msg.toolOutput.substring(0, 80)}...'
          : msg.toolOutput,
      content: msg.toolOutput,
    );
  }

  /// 错误消息气泡
  Widget _buildErrorBubble(MessageModel msg) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        margin: const EdgeInsets.only(left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.content,
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化参数显示
  String _formatToolArgs(String args) {
    try {
      final decoded = json.decode(args);
      if (decoded is Map) {
        return decoded.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      }
      return args;
    } catch (_) {
      return args;
    }
  }
}

// ============ 可折叠工具卡片组件 ============

class _CollapsibleToolCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String content;

  const _CollapsibleToolCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  State<_CollapsibleToolCard> createState() => _CollapsibleToolCardState();
}

class _CollapsibleToolCardState extends State<_CollapsibleToolCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        margin: const EdgeInsets.only(left: 40),
        decoration: BoxDecoration(
          color: widget.iconColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.iconColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题栏（点击展开/折叠）
            InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                  if (_expanded) {
                    _animController.forward();
                  } else {
                    _animController.reverse();
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 18, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.iconColor,
                            ),
                          ),
                          if (!_expanded)
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _sizeAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _expanded ? 3.14159 : 0,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: widget.iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 展开内容
            SizeTransition(
              sizeFactor: _sizeAnimation,
              axisAlignment: -1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '详情',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: widget.content));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已复制到剪贴板'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            widget.content,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 代码块构建器（带复制按钮） ============

class _CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  _CodeBlockBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String code = element.textContent;
    // 去除末尾换行
    if (code.endsWith('\n')) {
      code = code.substring(0, code.length - 1);
    }

    // 检测语言
    String? language;
    if (element.attributes['class'] != null) {
      final classes = element.attributes['class']!.split(' ');
      for (final cls in classes) {
        if (cls.startsWith('language-')) {
          language = cls.substring(9);
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 代码块标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D3F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language ?? 'code',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('代码已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 14, color: Colors.white60),
                      SizedBox(width: 4),
                      Text(
                        '复制',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 代码内容
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
