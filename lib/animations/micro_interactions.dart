// ============================================================================
// Coze Animation System - 微交互集合
// 按压缩放/弹性红点/骨架屏/Shimmer/Tab下划线
// ============================================================================

import 'package:flutter/material.dart';
import '../design/colors.dart';

// ======================== 1. 按压缩放 ========================

/// 按压反馈: scale 1→0.95→1, 150ms ease-out
/// 来源: CSS transition: all .15s / transform .15s ease-out
class PressScaleWidget extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PressScaleWidget({
    super.key,
    required this.child,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
    this.onLongPress,
  });

  @override
  State<PressScaleWidget> createState() => _PressScaleWidgetState();
}

class _PressScaleWidgetState extends State<PressScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _isPressed = true;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 - (1.0 - widget.scale) * _controller.value;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onLongPress: widget.onLongPress,
            behavior: HitTestBehavior.opaque,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 卡片按压: scale 1→0.98, 100ms (更轻微)
class CardPressWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CardPressWidget({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScaleWidget(
      scale: 0.98,
      duration: const Duration(milliseconds: 100),
      onTap: onTap,
      child: child,
    );
  }
}

// ======================== 2. 弹性红点 ========================

/// 红点出现: scale 0→1.2→1 弹性, 300ms elastic-out
class BadgeDot extends StatelessWidget {
  final double size;
  final bool animated;

  const BadgeDot({
    super.key,
    this.size = 6,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return _buildDot();
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: _buildDot(),
    );
  }

  Widget _buildDot() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 带脉冲的红点 - 用于newMessagePoint
/// 来源: .newMessagePoint { height:6px; width:6px; position:absolute }
class PulsingBadgeDot extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingBadgeDot({
    super.key,
    this.size = 6,
    this.color = const Color(0xFFEF4444),
  });

  @override
  State<PulsingBadgeDot> createState() => _PulsingBadgeDotState();
}

class _PulsingBadgeDotState extends State<PulsingBadgeDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.5 + 0.5 * _controller.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ======================== 3. 骨架屏 Shimmer ========================

/// 骨架屏脉冲效果
/// 灰色矩形 opacity 脉冲 1.5s infinite
class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF);
    final highlightColor = isDark ? const Color(0xFF353952) : const Color(0xFFF7F7FC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏卡片 - 模拟技能卡片加载
class SkillCardSkeleton extends StatelessWidget {
  const SkillCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerSkeleton(width: 48, height: 48, borderRadius: 12),
        const SizedBox(height: 8),
        const ShimmerSkeleton(width: 80, height: 14),
        const SizedBox(height: 4),
        const ShimmerSkeleton(width: 120, height: 12),
      ],
    );
  }
}

/// 骨架屏列表项 - 模拟设置列表加载
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 24, height: 24, borderRadius: 6),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeleton(width: 120, height: 16),
                const SizedBox(height: 4),
                ShimmerSkeleton(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== 4. 运行状态渐变球 ========================

/// running-task-status-ball
/// 来源: background:linear-gradient(281.83deg,#3a96ff 19.21%,#2824fd 91.8%)
/// border-radius:100%; width:10px; height:10px; display:inline-block
class RunningStatusBall extends StatelessWidget {
  final double size;
  final bool animated;

  const RunningStatusBall({
    super.key,
    this.size = 10,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final ball = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.72, 0.3),  // 281.83deg
          end: Alignment(-0.72, 0.7),
          colors: [Color(0xFF3A96FF), Color(0xFF2824FD)],
          stops: [0.19, 0.92],
        ),
      ),
    );

    if (!animated) return ball;

    return PulseAnimation(
      duration: const Duration(milliseconds: 1200),
      minOpacity: 0.6,
      child: ball,
    );
  }
}

/// 脉冲动画（从coze_animations中复用）
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minOpacity = 0.5,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: widget.minOpacity + (1 - widget.minOpacity) * _controller.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ======================== 5. 页面转场 ========================

/// 页面转场构建器
class CozePageTransitions {
  /// 右→左推入: 新页面从右侧滑入, 300ms ease-out
  static Route<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// 底部Sheet弹出: 从底部滑入, 250ms 弹性
  static Route<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.36, 0.66, 0.04, 1),  // 弹性曲线
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// 淡入: opacity 0→1, 200ms ease-in-out
  static Route<T> fadeIn<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
