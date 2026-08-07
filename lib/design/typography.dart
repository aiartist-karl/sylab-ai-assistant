// ============================================================================
// Coze Design Tokens - 字体排版系统
// 从CSS font-family / font-size / line-height / font-weight提取
// ============================================================================

import 'package:flutter/material.dart';

/// 字体族
class AppFonts {
  AppFonts._();

  /// 主字体 - Inter + 系统中文字体
  /// 来源: Inter,-apple-system,BlinkMacSystemFont,Segoe UI,SF Pro SC,PingFang SC
  static const String primary = 'Inter';

  /// 中文字体回退
  static const String chinese = 'PingFang SC';

  /// 等宽字体 - 用于代码块
  /// 来源: ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas
  static const String mono = 'monospace';
}

/// 字号系统 - 从CSS --fs-* 和 font-size 提取
class AppTextStyles {
  AppTextStyles._();

  /// 辅助文字 10sp - 最小文字（角标/版权信息）
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// 标签文字 12sp --fs-12（协议/标签/时间戳）
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
  );

  /// 正文小 13sp
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 正文 14sp - 最常用（卡片描述/列表项副标题/输入文字）
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.1,
  );

  /// 正文大 15sp - streaming-markdown默认字号
  /// 来源: .streaming-markdown { font-size: calc(15*var(--app)); line-height: calc(23*var(--app)) }
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.533,  // 23/15
  );

  /// 小标题 16sp - 卡片标题/导航标题/设置项
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  /// 标题 18sp - 页面标题
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.3,
  );

  /// 大标题 24sp - 启动页/欢迎页
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// 登录按钮文字 --fs-15 + font-weight:500
  static const TextStyle loginButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 协议文字 --fs-12
  static const TextStyle agreement = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 中断文字 - sub-task-card-interrupt-text
  /// font-size: calc(14*var(--app)), font-weight: 400
  static const TextStyle interruptText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ---- Markdown 渲染专用 ----

  /// Markdown H1
  static const TextStyle mdH1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Markdown H2
  static const TextStyle mdH2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  /// Markdown H3
  static const TextStyle mdH3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Markdown H4
  static const TextStyle mdH4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Markdown 正文
  static const TextStyle mdBody = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.533,
  );

  /// Markdown 代码
  static const TextStyle mdCode = TextStyle(
    fontSize: 13,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Markdown 引用
  static const TextStyle mdQuote = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.533,
    fontStyle: FontStyle.italic,
  );
}
