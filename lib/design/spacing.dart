// ============================================================================
// Coze Design Tokens - 尺寸/间距系统
// 从CSS var(--app)缩放系统逆向，映射到Flutter逻辑像素
// 基准: 1 var(--app) unit ≈ 1dp (在375宽设备上)
// ============================================================================

import 'package:flutter/material.dart';

/// 间距系统 - 从CSS calc(N*var(--app))提取的所有间距值
class AppSpacing {
  AppSpacing._();

  // 微型间距 (1-4dp)
  static const double xs1 = 1.0;
  static const double xs2 = 2.0;
  static const double xs3 = 3.0;
  static const double xs4 = 4.0;

  // 小型间距 (5-8dp)
  static const double sm5 = 5.0;
  static const double sm6 = 6.0;
  static const double sm7 = 7.0;
  static const double sm8 = 8.0;

  // 中小型间距 (9-12dp)
  static const double ms9 = 9.0;
  static const double ms10 = 10.0;
  static const double ms11 = 11.0;
  static const double ms12 = 12.0;   // 最常用：卡片内边距、列表间距

  // 中型间距 (13-16dp)
  static const double md13 = 13.0;
  static const double md14 = 14.0;
  static const double md15 = 15.0;
  static const double md16 = 16.0;   // 常用：页面边距、区块间距

  // 中大型间距 (17-24dp)
  static const double ml17 = 17.0;
  static const double ml18 = 18.0;
  static const double ml19 = 19.0;
  static const double ml20 = 20.0;
  static const double ml21 = 21.0;
  static const double ml22 = 22.0;
  static const double ml23 = 23.0;
  static const double ml24 = 24.0;   // 登录页padding

  // 大型间距 (25-40dp)
  static const double lg25 = 25.0;
  static const double lg26 = 26.0;
  static const double lg28 = 28.0;
  static const double lg29 = 29.0;
  static const double lg32 = 32.0;
  static const double lg33 = 33.0;   // 底部输入栏padding-bottom
  static const double lg34 = 34.0;
  static const double lg36 = 36.0;
  static const double lg39 = 39.0;
  static const double lg40 = 40.0;   // 登录按钮底部距离

  // 超大间距 (41-60dp)
  static const double xl41 = 41.0;
  static const double xl44 = 44.0;
  static const double xl46 = 46.0;
  static const double xl48 = 48.0;
  static const double xl50 = 50.0;   // 登录按钮高度/输入框高度

  // 命名间距常量（语义化）
  static const double pagePadding = 12.0;       // 页面水平padding
  static const double cardPadding = 12.0;        // 卡片内边距
  static const double cardMargin = 8.0;          // 卡片外边距
  static const double sectionGap = 16.0;         // 区块间距
  static const double listItemHeight = 56.0;     // 设置列表项高度
  static const double navBarHeight = 56.0;       // 底部导航栏高度
  static const double topBarHeight = 56.0;       // 顶部导航栏高度
  static const double inputBarHeight = 50.0;     // 输入框高度
  static const double bottomSafePadding = 24.0;  // 底部安全区额外padding
  static const double topSafePadding = 16.0;     // 顶部安全区额外padding
}

/// 圆角系统 - 从CSS border-radius提取
class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs2 = 2.0;
  static const double sm4 = 4.0;
  static const double sm5 = 5.0;
  static const double sm6 = 6.0;
  static const double md12 = 12.0;   // 卡片圆角
  static const double lg16 = 16.0;   // 弹层/大卡片圆角
  static const double xl24 = 24.0;   // 底部Sheet顶部圆角
  static const double pill = 30.0;   // 登录按钮/胶囊圆角
  static const double full = 1000.0; // 完全圆角（输入框/圆形按钮）

  // 语义化圆角
  static const double card = 12.0;
  static const double sheet = 24.0;
  static const double input = 1000.0;  // 输入框pill形状
  static const double button = 30.0;   // 按钮圆角
  static const double avatar = 0.5;    // 50%用BorderRadius.circular
  static const double badge = 1000.0;  // 红点完全圆
  static const double chatBubble = 16.0;  // 消息气泡
  static const double chatBubbleUser = 16.0;
  static const double chatBubbleAi = 16.0;  // AI气泡左上角=0
}

/// 组件尺寸系统
class AppSizes {
  AppSizes._();

  // 头像尺寸
  static const double avatarSmall = 32.0;    // 导航栏头像
  static const double avatarMedium = 48.0;   // 列表头像
  static const double avatarLarge = 64.0;    // 个人中心头像
  static const double avatarXlarge = 120.0;  // 编辑头像（user-avatar-ijQMck）

  // 图标尺寸
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;    // 导航栏图标
  static const double iconLarge = 32.0;
  static const double iconXlarge = 48.0;    // 技能卡片图标

  // 按钮尺寸
  static const double buttonHeight = 50.0;  // 登录按钮高度
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMini = 28.0;

  // 红点/角标
  static const double badgeDot = 6.0;      // newMessagePoint 6x6
  static const double badgeCount = 16.0;

  // 在线状态球
  static const double statusBall = 10.0;   // running-task-status-ball

  // 进度条
  static const double progressBarHeight = 6.0;
  static const double progressBarRadius = 3.0;

  // 浏览器标签卡
  static const double browserTabHeight = 44.0;

  // 停止按钮
  static const double stopButtonWidth = 280.0;
  static const double stopButtonHeight = 141.0;

  // 搜索框
  static const double searchBoxHeight = 50.0;
  static const double searchBoxRadius = 1000.0;

  // 底部Sheet
  static const double sheetCornerRadius = 16.0;
}
