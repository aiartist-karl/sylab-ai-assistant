// ============================================================================
// Coze Design Tokens - 语义色 + 背景色系统
// 区分亮色/暗色主题的完整背景色 + 前景色 + 边框色 + 遮罩色
// ============================================================================

import 'package:flutter/material.dart';

/// 语义色（不随主题变化）
class SemanticColors {
  SemanticColors._();

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

/// 亮色主题下的背景色 + 前景色 + 边框色
class LightThemeColors {
  LightThemeColors._();

  // ---- 背景色 (coz-bg-* 映射到亮色) ----
  static const Color bgMax = Color(0xFFF7F7FC);      // 页面最大背景 --coz-bg-max(light)
  static const Color bgPlus = Color(0xFFFFFFFF);      // 卡片/弹层背景
  static const Color bgPrimary = Color(0xFFF1F3FF);   // 一级区域背景
  static const Color bgSecondary = Color(0xFFEDF0FF); // 二级区域/分组背景
  static const Color bgTertiary = Color(0xFFF5F5F7);  // 三级区域
  static const Color bgInput = Color(0xFFFFFFFF);     // 输入框背景
  static const Color bgHover = Color(0xFFEDF0FF);     // 悬停态
  static const Color bgPressed = Color(0xFFE0E4FF);   // 按压态

  // ---- 前景色（文字） ----
  static const Color fgPrimary = Color(0xFF1A1D26);   // 主文字 90%黑
  static const Color fgSecondary = Color(0xFF4A4D5B);  // 副文字 60%黑
  static const Color fgTertiary = Color(0xFF8B8E99);   // 辅助文字 40%黑
  static const Color fgPlaceholder = Color(0xFFB0B3BD); // 占位符 25%黑
  static const Color fgDisabled = Color(0xFFCDCFD6);    // 禁用文字 15%黑
  static const Color fgWhite = Color(0xFFFFFFFF);       // 反色文字
  static const Color fgLink = Color(0xFF5147FF);        // 链接色

  // ---- 边框色 ----
  static const Color strokePrimary = Color(0xFFE0E4FF);  // 主边框
  static const Color strokeOpaque = Color(0xFFD0D4E0);   // 实色边框
  static const Color strokePlus = Color(0xFFEDF0FF);     // 浅色边框
  static const Color strokeFocus = Color(0xFF5147FF);    // 聚焦边框=品牌色

  // ---- 遮罩/阴影 ----
  static const Color maskLight = Color(0x99000000);      // 遮罩 opacity 0.6
  static const Color shadowDefault = Color(0x14000000);  // 默认阴影 8%黑
  static const Color shadowLarge = Color(0x1F000000);    // 大阴影 12%黑
  static const Color shadowSmall = Color(0x0A000000);    // 小阴影 4%黑

  // ---- 功能区域 ----
  static const Color chatUserBubble = Color(0xFF5147FF);  // 用户气泡=品牌紫
  static const Color chatAiBubble = Color(0xFFF1F3FF);   // AI气泡=浅紫
  static const Color navSelected = Color(0xFF5147FF);    // 导航选中态
  static const Color navUnselected = Color(0xFF8B8E99);  // 导航未选中

  // ---- 登录页 ----
  static const Color loginButton = Color(0xFF000000);   // 登录按钮背景
  static const Color loginButtonText = Color(0xFFFFFFFF);
}

/// 暗色主题下的背景色 + 前景色 + 边框色
class DarkThemeColors {
  DarkThemeColors._();

  // ---- 背景色 (从 --coze-bg-* RGB值直接取) ----
  static const Color bgMax = Color(0xFF212534);       // --coze-bg-10 (33,37,52)
  static const Color bgPlus = Color(0xFF272B3A);      // --coze-bg-3 (39,43,58)
  static const Color bgPrimary = Color(0xFF1C2030);   // --coze-bg-2 (28,32,48)
  static const Color bgSecondary = Color(0xFF181C2B);  // --coze-bg-1 (24,28,43)
  static const Color bgTertiary = Color(0xFF141825);   // --coze-bg-0 (20,24,37)
  static const Color bgInput = Color(0xFF272B3A);     // 输入框背景=bgPlus
  static const Color bgHover = Color(0xFF2D3145);     // 悬停态
  static const Color bgPressed = Color(0xFF353952);   // 按压态

  // ---- 前景色（文字） ----
  static const Color fgPrimary = Color(0xFFFFFFFF);     // 主文字=白
  static const Color fgSecondary = Color(0xFFB0B3BD);   // 副文字 70%白
  static const Color fgTertiary = Color(0xFF8B8E99);    // 辅助文字 50%白
  static const Color fgPlaceholder = Color(0xFF5C5F6B); // 占位符 30%白
  static const Color fgDisabled = Color(0xFF3D404D);    // 禁用文字 20%白
  static const Color fgWhite = Color(0xFFFFFFFF);
  static const Color fgLink = Color(0xFF5147FF);

  // ---- 边框色 ----
  static const Color strokePrimary = Color(0xFF2D3145);
  static const Color strokeOpaque = Color(0xFF292D3C);  // --coze-stroke-opaque (41,45,60)
  static const Color strokePlus = Color(0xFF353952);
  static const Color strokeFocus = Color(0xFF5147FF);

  // ---- 遮罩/阴影 ----
  static const Color maskDark = Color(0xB3000000);      // 暗色遮罩 0.7
  static const Color shadowDefault = Color(0x26000000); // 15%黑
  static const Color shadowLarge = Color(0x33000000);   // 20%黑
  static const Color shadowSmall = Color(0x14000000);   // 8%黑

  // ---- 功能区域 ----
  static const Color chatUserBubble = Color(0xFF5147FF);
  static const Color chatAiBubble = Color(0xFF272B3A);  // AI气泡=bgPlus
  static const Color navSelected = Color(0xFF5147FF);
  static const Color navUnselected = Color(0xFF8B8E99);

  // ---- 登录页 ----
  static const Color loginButton = Color(0xFF000000);
  static const Color loginButtonText = Color(0xFFFFFFFF);
}

/// 状态色（不变）
class StateColors {
  StateColors._();
  static const Color online = Color(0xFF22C55E);       // 在线=绿色
  static const Color offline = Color(0xFF8B8E99);      // 离线=灰色
  static const Color busy = Color(0xFFF59E0B);         // 忙碌=黄色
  static const Color error = Color(0xFFEF4444);        // 错误=红色
  static const Color interrupt = Color(0xFFEF4444);    // 中断=红色边框
}
