// ============================================================================
// Coze Common Widgets - 空状态/错误状态/网络状态组件
// 使用扣子APK原始图片资源
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

/// 通用空状态组件
class EmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 160,
              height: 160,
              errorBuilder: (_, __, ___) => const SizedBox(width: 160, height: 160),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1D26),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? const Color(0xFF8B8E99) : const Color(0xFF8B8E99),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 任务空状态
class TaskEmptyState extends StatelessWidget {
  final VoidCallback? onCreateTask;

  const TaskEmptyState({super.key, this.onCreateTask});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imagePath: 'assets/images/coze/task-empty.4fde273d.png',
      title: '暂无任务',
      subtitle: '点击下方按钮创建你的第一个计划',
      action: onCreateTask != null
          ? ElevatedButton.icon(
              onPressed: onCreateTask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('创建新任务'),
            )
          : null,
    );
  }
}

/// 网络断开状态
class NetworkDisconnectedState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkDisconnectedState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imagePath: 'assets/images/coze/network-disconnected.5fdebd39.png',
      title: '网络连接失败',
      subtitle: '请检查网络设置后重试',
      action: onRetry != null
          ? OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
            )
          : null,
    );
  }
}

/// 服务器错误状态
class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imagePath: 'assets/images/coze/server-error.a24ca3fa.png',
      title: '服务器出错',
      subtitle: '请稍后重试',
      action: onRetry != null
          ? OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重新加载'),
            )
          : null,
    );
  }
}

/// 权限拒绝状态
class NotAllowedState extends StatelessWidget {
  const NotAllowedState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      imagePath: 'assets/images/coze/not-allowed-task.ee189977.png',
      title: '无权限访问',
      subtitle: '你没有权限执行此操作',
    );
  }
}

/// 内容违规状态
class IllegalContentState extends StatelessWidget {
  const IllegalContentState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      imagePath: 'assets/images/coze/illegal-logo.b62b5567.png',
      title: '内容审核未通过',
      subtitle: '内容包含违规信息，请修改后重试',
    );
  }
}

/// 加载遮罩
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black38,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF5147FF),
                    strokeWidth: 3,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 在线状态指示器
class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? const Color(0xFF22C55E) : const Color(0xFF8B8E99),
      ),
    );
  }
}

/// 通用分隔线
class SectionDivider extends StatelessWidget {
  final double height;

  const SectionDivider({super.key, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      color: isDark ? const Color(0xFF1C2030) : const Color(0xFFF1F3FF),
    );
  }
}
