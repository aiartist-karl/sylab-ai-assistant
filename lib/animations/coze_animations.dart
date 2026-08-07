// ============================================================================
// Coze Animation System - 核心动画集合
// 包含: fadeIn/slideUp/pulse/spin/rotate-in/glint/shine 全部16个CSS keyframes
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';

// ======================== 1. fadeIn (4变体) ========================

/// fadeIn基础版: opacity 0→1, 300ms
class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// fadeIn + slideUp: opacity 0→1 + translateY(18→0), 300ms
/// 来源: @keyframes fadeIn { 0% { opacity:0; transform:translateY(18px) } }
class FadeInSlideUp extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeInSlideUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// ======================== 2. pulse 脉冲 ========================
// PulseAnimation 定义在 micro_interactions.dart 中，避免重复

// ======================== 3. spin 旋转 ========================

/// 旋转动画 (3变体): 0→360deg
/// 来源: @keyframes spin { to { transform:rotate(360deg) } }
class SpinAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool clockwise;

  const SpinAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.clockwise = true,
  });

  @override
  State<SpinAnimation> createState() => _SpinAnimationState();
}

class _SpinAnimationState extends State<SpinAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        final angle = (widget.clockwise ? 1 : -1) * _controller.value * 2 * pi;
        return Transform.rotate(angle: angle, child: child);
      },
      child: widget.child,
    );
  }
}

// ======================== 4. rotate-in 3D旋转进入 ========================

/// 旋转进入: scale(0.86) + rotateY(-15deg) + rotateX(-15deg) + opacity(0) → normal
/// 来源: @keyframes rotate-in
class RotateInTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const RotateInTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final scale = 0.86 + 0.14 * value;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-15 * (pi / 180) * (1 - value))
            ..rotateX(-15 * (pi / 180) * (1 - value))
            ..scale(scale),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// ======================== 5. shine 光泽扫过 ========================

/// 光泽扫过效果: background-position -200% → 200%, 1.5s
/// 来源: @keyframes shine { 0% { background-position:-200% } }
class ShineEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color shineColor;

  const ShineEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.shineColor = const Color(0x33FFFFFF),
  });

  @override
  State<ShineEffect> createState() => _ShineEffectState();
}

class _ShineEffectState extends State<ShineEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            final dx = -bounds.width + (bounds.width * 3 * _controller.value);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                widget.shineColor,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(dx / bounds.width),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// ======================== 6. glint 闪光 ========================

/// 闪光效果: translate(0%) → translate(100%)
/// 来源: @keyframes glint { 0% { transform:translate(0%) } }
class GlintEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GlintEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<GlintEffect> createState() => _GlintEffectState();
}

class _GlintEffectState extends State<GlintEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Positioned.fill(
              child: ClipRect(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final dx = -bounds.width + (bounds.width * 2 * _controller.value);
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        const Color(0x22FFFFFF),
                        Colors.transparent,
                      ],
                    ).createShader(Rect.fromLTWH(dx, 0, bounds.width, bounds.height));
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ======================== 7. enter / exit 转场 ========================

/// 入场转场: opacity+translate+scale组合
/// 来源: @keyframes enter { 0% { opacity:var(--tw-enter-opacity); transform:translate3d(...) scale3d(...) } }
class EnterTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double initialOpacity;
  final Offset initialTranslation;
  final double initialScale;

  const EnterTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.initialOpacity = 0,
    this.initialTranslation = Offset.zero,
    this.initialScale = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(
              initialTranslation.dx * (1 - value),
              initialTranslation.dy * (1 - value),
            )
            ..scale(initialScale + (1 - initialScale) * value),
          child: Opacity(
            opacity: initialOpacity + (1 - initialOpacity) * value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
