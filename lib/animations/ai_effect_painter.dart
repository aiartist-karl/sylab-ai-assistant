// ============================================================================
// Coze Animation System - AI光环粒子效果
// 来源: CSS ai-effect-dark / ai-effect-light keyframes
// 原理: 多个粒子沿不同轨迹运动，形成环绕光效
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../design/colors.dart';

/// AI思考光环效果
/// 用于: 对话页面AI正在思考时的指示器
class AiEffectPainter extends StatefulWidget {
  final double size;
  final bool isDark;
  final bool isAnimating;

  const AiEffectPainter({
    super.key,
    this.size = 48,
    this.isDark = false,
    this.isAnimating = true,
  });

  @override
  State<AiEffectPainter> createState() => _AiEffectPainterState();
}

class _AiEffectPainterState extends State<AiEffectPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2s循环
    );
    if (widget.isAnimating) _controller.repeat();
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AiEffectPaint(
            progress: _controller.value,
            isDark: widget.isDark,
            particleCount: 6,
          ),
        );
      },
    );
  }
}

class _AiEffectPaint extends CustomPainter {
  final double progress;
  final bool isDark;
  final int particleCount;

  _AiEffectPaint({
    required this.progress,
    required this.isDark,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    // 中心光晕
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0x335147FF), const Color(0x005147FF)]
            : [const Color(0x295147FF), const Color(0x005147FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));
    canvas.drawCircle(center, radius * 0.6, centerPaint);

    // 粒子环绕
    for (int i = 0; i < particleCount; i++) {
      final angle = (progress * 2 * pi) + (i * 2 * pi / particleCount);
      // 每个粒子独立的椭圆轨迹（模拟CSS中的x-position/y-position变化）
      final rx = radius * (0.5 + 0.3 * sin(angle * 2 + i));
      final ry = radius * (0.5 + 0.3 * cos(angle * 3 + i));
      final x = center.dx + rx * cos(angle);
      final y = center.dy + ry * sin(angle);

      final particleAlpha = (0.3 + 0.7 * ((sin(angle * 2) + 1) / 2));
      final particleSize = 2.0 + 2.0 * ((cos(angle * 3) + 1) / 2);

      final paint = Paint()
        ..color = (isDark ? const Color(0xFF5147FF) : const Color(0xFF5147FF))
            .withOpacity(particleAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AiEffectPaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 简化版AI思考指示器（直接使用gif资源时使用）
class AiThinkingIndicator extends StatelessWidget {
  final bool isDark;
  final String? text;

  const AiThinkingIndicator({
    super.key,
    this.isDark = false,
    this.text = '思考中...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AiEffectPainter(size: 24, isDark: isDark),
          const SizedBox(width: 8),
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF8B8E99) : const Color(0xFF8B8E99),
              ),
            ),
        ],
      ),
    );
  }
}
