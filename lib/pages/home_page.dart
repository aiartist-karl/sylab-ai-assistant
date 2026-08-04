import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../common/app_constant.dart';
import '../common/storage_util.dart';
import '../model/conversation_model.dart';
import 'chat_page.dart';

/// 首页 - 会话管理列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ConversationModel> _conversations = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversations = StorageUtil.getAllConversations();
    });
  }

  /// 创建新会话
  Future<void> _createConversation() async {
    // 弹出工作区选择对话框
    String selectedWorkspace = AppConstant.defaultWorkspace;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        String title = '';
        String workspace = AppConstant.defaultWorkspace;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('新建会话'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '会话标题',
                      hintText: '输入会话标题（可选）',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => title = v,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '工作区',
                      hintText: 'default',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      workspace = v.isNotEmpty ? v : AppConstant.defaultWorkspace;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop({
                      'title': title.isNotEmpty ? title : '新会话',
                      'workspace': workspace.isNotEmpty ? workspace : AppConstant.defaultWorkspace,
                    });
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final conversation = ConversationModel.create(
        id: _uuid.v4(),
        title: result['title']!,
        workspace: result['workspace']!,
      );
      await StorageUtil.conversationBox.put(conversation.id, conversation);

      // 导航到聊天页
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversation: conversation,
              onConversationUpdated: _loadConversations,
            ),
          ),
        );
        _loadConversations();
      }
    }
  }

  /// 删除会话
  Future<void> _deleteConversation(ConversationModel conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除会话'),
        content: Text('确定要删除会话「${conversation.title}」吗？所有消息将被清除。'),
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
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 删除消息
      await StorageUtil.deleteMessagesForConversation(conversation.id);
      // 删除会话
      await StorageUtil.conversationBox.delete(conversation.id);
      _loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sylab AI 助手',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async => _loadConversations(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conv = _conversations[index];
                  return _buildConversationCard(conv);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createConversation,
        icon: const Icon(Icons.add),
        label: const Text('新会话'),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    colorScheme.secondary.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '开始新的对话',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮创建您的第一个会话\n支持多轮对话、工具调用、多模态生成',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _createConversation,
              icon: const Icon(Icons.add),
              label: const Text('创建新会话'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 会话卡片
  Widget _buildConversationCard(ConversationModel conv) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(conv.id),
        direction: DismissDirection.endToStart,
        background: Container(
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          await _deleteConversation(conv);
          return false; // 已在 _deleteConversation 中处理
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    conversation: conv,
                    onConversationUpdated: _loadConversations,
                  ),
                ),
              );
              _loadConversations();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 左侧图标
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.8),
                          colorScheme.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 中间内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conv.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                conv.workspace,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              conv.createdAtFormatted,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 右侧箭头
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
