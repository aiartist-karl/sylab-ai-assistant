// ============================================================================
// Coze Design Tokens - 完整色板系统
// 从扣子APK v3.0.7 CSS逆向提取，精确到每个色阶
// ============================================================================

import 'package:flutter/material.dart';

/// 扣子品牌色（Brand/Purple）
/// 来源: --coze-brand-* 系列
class BrandColors {
  BrandColors._();

  // Brand 主色阶（从深到浅）
  static const Color brand0 = Color(0xFF4C4CFF);  // --coze-brand-0 最深品牌色
  static const Color brand1 = Color(0xFF4C4CFF);  // --coze-brand-1
  static const Color brand2 = Color(0xFF5959FF);  // --coze-brand-2
  static const Color brand3 = Color(0xFF5E5EFF);  // --coze-brand-3
  static const Color brand5 = Color(0xFFA6A6FF);  // --coze-brand-5 中间色
  static const Color brand6 = Color(0xFFB8B8FF);  // --coze-brand-6
  static const Color brand7 = Color(0xFFC2C2FF);  // --coze-brand-7
  static const Color brand30 = Color(0xFF4258FF);  // --coze-brand-30
  static const Color brand50 = Color(0xFF555BFF);  // --coze-brand-50 最亮品牌色

  // 默认品牌主色（按钮/强调/链接）
  static const Color primary = Color(0xFF5147FF);  // --checkbox-background-checked / agreeButton
  static const Color accent = Color(0xFF2824FD);   // 渐变终点色

  // 品牌色渐变（用于按钮/进度条/运行球）
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3A96FF), Color(0xFF2824FD)],
    stops: [0.19, 0.92],
  );

  // running-task-status-ball 渐变
  static const LinearGradient runningBallGradient = LinearGradient(
    begin: Alignment(0.72, 0.5),  // 281.83deg
    end: Alignment(0.28, 0.5),
    colors: [Color(0xFF3A96FF), Color(0xFF2824FD)],
    stops: [0.19, 0.92],
  );
}

/// 红色系 --coze-red-*
class RedColors {
  RedColors._();
  static const Color red0 = Color(0xFFFFADB4);
  static const Color red1 = Color(0xFFF22435);
  static const Color red2 = Color(0xFFF52536);
  static const Color red3 = Color(0xFFF52536);
  static const Color red5 = Color(0xFFFF2638);
  static const Color red6 = Color(0xFFFF5260);
  static const Color red7 = Color(0xFFFF616E);
}

/// 黄色/警告系 --coze-yellow-*
class YellowColors {
  YellowColors._();
  static const Color yellow0 = Color(0xEEFB3820);
  static const Color yellow1 = Color(0xFFB25000);
  static const Color yellow2 = Color(0xFFBF5702);
  static const Color yellow3 = Color(0xFFC25802);
  static const Color yellow5 = Color(0xFFFF7A0D);
  static const Color yellow6 = Color(0xFFFF943D);
  static const Color yellow7 = Color(0xFFFFA154);
  static const Color yellow30 = Color(0xFF9C7500);
  static const Color yellow50 = Color(0xFFFFBF00);
}

/// 绿色/成功系 --coze-green-*
class GreenColors {
  GreenColors._();
  static const Color green0 = Color(0xFF74D495);
  static const Color green1 = Color(0xFF007A29);
  static const Color green2 = Color(0xFF008033);
  static const Color green3 = Color(0xFF008535);
  static const Color green5 = Color(0xFF00BF40);
  static const Color green6 = Color(0xFF00D142);
  static const Color green7 = Color(0xFF00DB45);
}

/// 橙色系 --coze-orange-*
class OrangeColors {
  OrangeColors._();
  static const Color orange3 = Color(0xFFC75D12);
  static const Color orange5 = Color(0xFFFDAD73);
}

/// 蓝色系 --coze-blue-*
class BlueColors {
  BlueColors._();
  static const Color blue3 = Color(0xFF3C6FE5);
  static const Color blue5 = Color(0xFF78B0FF);
  static const Color blue10 = Color.fromARGB(255, 23, 100, 255);
  static const Color blue20 = Color.fromARGB(255, 64, 128, 255);
  static const Color blue30 = Color(0xFF1764FF);
  static const Color blue50 = Color(0xFF4080FF);
}

/// 翡翠绿系 --coze-emerald-*
class EmeraldColors {
  EmeraldColors._();
  static const Color emerald3 = Color(0xFF068C66);
  static const Color emerald5 = Color(0xFF30F2A1);
  static const Color emerald10 = Color(0xFF00734C);
  static const Color emerald20 = Color(0xFF008055);
  static const Color emerald30 = Color(0xFF008558);
  static const Color emerald50 = Color(0xFF00BF80);
}

/// 青色系 --coze-cyan-*
class CyanColors {
  CyanColors._();
  static const Color cyan3 = Color(0xFF0882A3);
  static const Color cyan5 = Color(0xFF39D7E5);
  static const Color cyan10 = Color(0xFF006E85);
  static const Color cyan20 = Color(0xFF007991);
  static const Color cyan30 = Color(0xFF007D96);
  static const Color cyan50 = Color(0xFF00AACC);
}
