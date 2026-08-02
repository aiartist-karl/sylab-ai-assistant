import 'dart:async';
import 'package:flutter/material.dart';
import '../common/log_util.dart';
import '../common/storage_util.dart';
import '../model/message_model.dart';
import '../core/agent_engine.dart';
import '../toolkit/image_generator.dart';
import '../toolkit/video_generator.dart';
import '../toolkit/office_generator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<MessageModel> _messageList = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistoryMessage();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============ Hive本地消息存取（来自Table 6修复版逻辑） ============

  Future<void> _loadHistoryMessage() async {
    // 原生模型读取，自动适配序列化，无类型异常
    final List<MessageModel> historyList = StorageUtil.chatBox.values.toList();
    setState(() {
      _messageList.clear();
      _messageList.addAll(historyList);
    });
    LogUtil.i("消息加载", "Hive适配器加载完成，历史消息：${_messageList.length}条");
  }

  void _saveMessageToLocal() {
    // 批量原生模型存储，性能更优、无冗余转换
    StorageUtil.chatBox.clear();
    final Map<int, MessageModel> tempMap = {};
    for (var msg in _messageList) {
      tempMap[msg.timeStamp] = msg;
    }
    StorageUtil.chatBox.putAll(tempMap);
  }

  // ============ 发送消息 ============

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final String userInput = text.trim();
    _inputController.clear();

    // 添加用户消息
    final userMsg = MessageModel(
      role: "user",
      content: userInput,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {
      _messageList.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    // 添加AI占位消息
    final aiMsg = MessageModel(
      role: "assistant",
      content: "",
      timeStamp: DateTime.now().millisecondsSinceEpoch + 1,
    );
    setState(() {
      _messageList.add(aiMsg);
    });

    // 识别指令并分发
    if (userInput.startsWith("生成图片")) {
      await _handleImageCommand(userInput, aiMsg);
    } else if (userInput.startsWith("生成视频")) {
      await _handleVideoCommand(userInput, aiMsg);
    } else if (userInput.startsWith("生成文档")) {
      await _handleDocCommand(userInput, aiMsg);
    } else {
      // 普通对话：流式输出
      await _handleChatStream(userInput, aiMsg);
    }

    setState(() {
      _isLoading = false;
    });
    _saveMessageToLocal();
    _scrollToBottom();
  }

  // ============ 指令处理 ============

  Future<void> _handleImageCommand(String input, MessageModel aiMsg) async {
    final prompt = input.replaceFirst("生成图片", "").trim();
    setState(() => aiMsg.content = "正在生成图片，请稍候...");
    final result = await ImageGenerator.generateImage(prompt);
    setState(() {
      aiMsg.content = result != null
          ? "✅ 图片已生成并保存到相册\n图片地址：$result"
          : "❌ 图片生成失败，请检查密钥配置";
    });
  }

  Future<void> _handleVideoCommand(String input, MessageModel aiMsg) async {
    final prompt = input.replaceFirst("生成视频", "").trim();
    setState(() => aiMsg.content = "正在生成视频，预计需要2-5分钟...");
    final result = await VideoGenerator.generateVideo(prompt);
    setState(() {
      aiMsg.content = result != null
          ? "✅ 视频已生成并保存到相册\n视频地址：$result"
          : "❌ 视频生成失败，请检查密钥配置";
    });
  }

  Future<void> _handleDocCommand(String input, MessageModel aiMsg) async {
    final content = input.replaceFirst("生成文档", "").trim();
    setState(() => aiMsg.content = "正在生成文档，请稍候...");
    final result = await OfficeGenerator.generateWord("AI文档", content);
    setState(() {
      aiMsg.content = result != null
          ? "✅ Word文档已生成：$result"
          : "❌ 文档生成失败";
    });
  }

  // ============ 流式对话 ============

  Future<void> _handleChatStream(String userInput, MessageModel aiMsg) async {
    try {
      final messages = [
        {"role": "system", "content": "你是Sylab AI助手，一个商用级智能助手，回答简洁专业。"},
        {"role": "user", "content": userInput},
      ];

      final Stream<String> stream = await AgentEngine.chatStream(messages);

      await for (final chunk in stream) {
        setState(() {
          aiMsg.content += chunk;
        });
      }
    } catch (e) {
      setState(() {
        aiMsg.content = "❌ AI响应失败：$e";
      });
      LogUtil.e("对话流", "流式请求失败：$e");
    }
  }

  // ============ UI辅助 ============

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

  // ============ 构建UI ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sylab AI助手'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messageList.isEmpty
                ? const Center(
                    child: Text(
                      '发送消息开始对话\n支持指令：生成图片、生成视频、生成文档',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messageList.length,
                    itemBuilder: (context, index) {
                      final msg = _messageList[index];
                      final isUser = msg.role == "user";
                      return _buildMessageBubble(msg, isUser);
                    },
                  ),
          ),
          // 加载指示器
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // 输入区域
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: '输入消息或指令（如：生成图片 一只猫）',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _sendMessage(_inputController.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
