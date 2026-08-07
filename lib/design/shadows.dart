// ============================================================================
// Coze Design Tokens - 阴影系统
// 从CSS --coz-shadow-* / box-shadow提取
// ============================================================================

import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  /// 小阴影 --coz-shadow-small
  /// 用于: 输入框、小组件
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000),  // 4%黑
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  /// 默认阴影 --coz-shadow-default
  /// 用于: 卡片、任务卡、技能卡
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x14000000),  // 8%黑
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  /// 大阴影 --coz-shadow-large
  /// 用于: 弹层、模态框、BottomSheet
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1F000000),  // 12%黑
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// 输入框专用阴影（含边框效果）
  static const List<BoxShadow> input = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// 底部导航栏阴影
  static const List<BoxShadow> navBar = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, -1),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
