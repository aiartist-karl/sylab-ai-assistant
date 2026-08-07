// ============================================================================
// 对话主界面 - HomeScreen
// 扣子App核心：Bot对话 + 流式输出 + 消息气泡 + AI思考动画
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/semantic_colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/shadows.dart';
import '../../animations/coze_animations.dart';
import '../../animations/micro_interactions.dart';
import '../../animations/ai_effect_painter.dart';
import '../../widgets/common/state_widgets.dart';

/// 首页 - 对话列表/主界面
/// 路由: /
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // === 顶部导航栏 ===
            _buildTopBar(isDark),
            // === 主内容区 ===
            Expanded(
              child: _buildContent(isDark),
            ),
            // === 底部输入栏 ===
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  // ---- 顶部导航栏 ----
  // 高度56dp，左侧头像32dp圆形，中间Bot名称16sp加粗，右侧搜索图标
  Widget _buildTopBar(bool isDark) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.only(
        left: AppSpacing.md16,
        right: AppSpacing.sm8,
      ),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColors.bgMax : LightThemeColors.bgMax,
        border: Border(
          bottom: BorderSide(
            color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左侧头像 32dp 圆形
          Container(
            width: AppSizes.avatarSmall,
            height: AppSizes.avatarSmall,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BrandColors.brandGradient,
            ),
            child: const Center(
              child: Text('S', style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
            ),
          ),
          const SizedBox(width: 12),
          // Bot名称
          Expanded(
            child: Text(
              'Sylab AI',
              style: AppTextStyles.subtitle.copyWith(
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 搜索图标
          PressScaleWidget(
            onTap: () {
              // TODO: navigate to search
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.search_rounded,
                size: AppSizes.iconMedium,
                color: isDark ? DarkThemeColors.fgSecondary : LightThemeColors.fgSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 主内容区 ----
  Widget _buildContent(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          // 对话消息列表
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(
              top: AppSpacing.ml24,
              left: AppSpacing.pagePadding,
              right: AppSpacing.pagePadding,
              bottom: 100,
            ),
            itemCount: _mockMessages.length,
            itemBuilder: (context, index) => _buildMessage(index, isDark),
          ),
          // 空态
          if (_mockMessages.isEmpty) _buildEmptyState(isDark),
          // 回到底部按钮
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 80,
              child: PressScaleWidget(
                onTap: () => _scrollToBottom(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.defaultShadow,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---- 空态 (home-logo居中) ----
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isDark
                ? 'assets/images/coze/home-logo-dark.19d07f62.png'
                : 'assets/images/coze/home-logo-light.c9370b5f.png',
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) => Icon(
              Icons.smart_toy_rounded,
              size: 80,
              color: BrandColors.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '发送消息开始对话',
            style: AppTextStyles.body.copyWith(
              color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ---- 消息气泡 ----
  Widget _buildMessage(int index, bool isDark) {
    final msg = _mockMessages[index];
    final isUser = msg['role'] == 'user';

    return FadeInSlideUp(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              // AI头像
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BrandColors.brandGradient,
                ),
                child: const Center(
                  child: Text('S', style: TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // 消息气泡
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isUser ? 16 : 12,
                  vertical: isUser ? 12 : 12,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? LightThemeColors.chatUserBubble
                      : (isDark ? DarkThemeColors.chatAiBubble : LightThemeColors.chatAiBubble),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? AppRadius.chatBubbleUser : 0),
                    topRight: Radius.circular(isUser ? AppRadius.chatBubbleUser : AppRadius.chatBubbleAi),
                    bottomLeft: Radius.circular(AppRadius.chatBubbleAi),
                    bottomRight: Radius.circular(AppRadius.chatBubbleAi),
                  ),
                ),
                child: Text(
                  msg['content']!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.533,
                    color: isUser
                        ? Colors.white
                        : (isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary),
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              // 用户头像
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF),
                ),
                child: const Center(
                  child: Text('K', style: TextStyle(
                    color: Color(0xFF5147FF), fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- 底部输入栏 ----
  // 固定底部，高度自适应，左侧+号，中间TextField，右侧发送按钮
  Widget _buildInputBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
        border: Border(
          top: BorderSide(
            color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md12,
        right: AppSpacing.md12,
        top: AppSpacing.sm8,
        bottom: AppSpacing.lg33 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // + 号按钮
          PressScaleWidget(
            onTap: () => _showFileUploadSheet(isDark),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? DarkThemeColors.bgInput : LightThemeColors.bgInput,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: isDark ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque,
                  width: 0.5,
                ),
              ),
              child: TextField(
                maxLines: 5,
                minLines: 1,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '发送消息...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? DarkThemeColors.fgPlaceholder : LightThemeColors.fgPlaceholder,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13,
                  ),
                  filled: false,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 发送按钮
          PressScaleWidget(
            onTap: () => _sendMessage(''),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.primary,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 文件上传BottomSheet ----
  void _showFileUploadSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3D404D) : const Color(0xFFCDCFD6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUploadOption(Icons.camera_alt_rounded, '拍照', isDark, () {}),
                    _buildUploadOption(Icons.photo_library_rounded, '相册', isDark, () {}),
                    _buildUploadOption(Icons.insert_drive_file_rounded, '文件', isDark, () {}),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return PressScaleWidget(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24,
              color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.label.copyWith(
            color: isDark ? DarkThemeColors.fgSecondary : LightThemeColors.fgSecondary,
          )),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    // TODO: send message to backend
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Mock数据 - 后续替换为真实消息
  final List<Map<String, String>> _mockMessages = [
    {'role': 'user', 'content': '你好，请介绍一下你自己'},
    {'role': 'assistant', 'content': '你好！我是 Sylab AI，一个多智能体AI助手。我可以帮你完成各种任务，包括写作、分析、编程、搜索等。有什么我可以帮助你的吗？'},
  ];
}
