// ============================================================================
// 设备管理页 - DeviceManagementScreen
// 扣子App路由 /device-info
// work-space-card组件 + browser-tab标签
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/semantic_colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/shadows.dart';
import '../../animations/micro_interactions.dart';
import '../../widgets/common/state_widgets.dart';

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设备管理'),
        actions: [
          PressScaleWidget(
            onTap: () {
              // TODO: show add device sheet
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.add_rounded, size: 24,
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // === browser-tab 标签切换 ===
          _buildBrowserTabs(isDark),
          const SizedBox(height: 16),
          // === 设备列表 ===
          ..._mockDevices.map((d) => _buildDeviceCard(isDark, d)),
        ],
      ),
    );
  }

  // browser-tab标签
  Widget _buildBrowserTabs(bool isDark) {
    return Row(
      children: [
        _buildTab(isDark, '全部', true),
        const SizedBox(width: 8),
        _buildTab(isDark, '云电脑', false),
        const SizedBox(width: 8),
        _buildTab(isDark, '云手机', false),
      ],
    );
  }

  Widget _buildTab(bool isDark, String label, bool selected) {
    return PressScaleWidget(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? BrandColors.primary.withOpacity(0.1)
              : (isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected
                ? BrandColors.primary
                : (isDark ? DarkThemeColors.fgSecondary : LightThemeColors.fgSecondary),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // work-space-card
  // 来源CSS: border:solid 1px var(--coz-stroke-opaque); border-radius:12dp; margin-top:8dp
  Widget _buildDeviceCard(bool isDark, Map<String, dynamic> device) {
    final isOnline = device['online'] as bool;

    return CardPressWidget(
      onTap: () {
        // TODO: navigate to device detail
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
        padding: const EdgeInsets.all(AppSpacing.md16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 头部: 图标 + 名称 + 在线状态 ===
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(device['color_val'] as int).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    device['icon'] == 'computer' ? Icons.computer_rounded :
                    device['icon'] == 'phone' ? Icons.phone_android_rounded :
                    Icons.memory_rounded,
                    size: 22,
                    color: Color(device['color_val'] as int),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device['name'] as String,
                        style: AppTextStyles.subtitle.copyWith(
                          color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(device['type'] as String,
                        style: AppTextStyles.label.copyWith(
                          color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 在线状态
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnlineStatusIndicator(isOnline: isOnline, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? '在线' : '离线',
                      style: AppTextStyles.label.copyWith(
                        color: isOnline ? StateColors.online : StateColors.offline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // === 配置信息 ===
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm8),
              decoration: BoxDecoration(
                color: isDark ? DarkThemeColors.bgMax : LightThemeColors.bgMax,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSpecItem(isDark, 'CPU', device['cpu'] as String),
                  _buildSpecItem(isDark, '内存', device['ram'] as String),
                  _buildSpecItem(isDark, '存储', device['storage'] as String),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // === 操作按钮 ===
            Row(
              children: [
                Expanded(
                  child: PressScaleWidget(
                    onTap: () {},
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: BrandColors.brandGradient,
                      ),
                      alignment: Alignment.center,
                      child: Text('连接', style: AppTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w500,
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PressScaleWidget(
                  onTap: () {},
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('管理', style: AppTextStyles.body.copyWith(
                      color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(bool isDark, String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
        )),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.label.copyWith(
          color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
        )),
      ],
    );
  }

  static const _mockDevices = <Map<String, dynamic>>[
    {
      'name': '云电脑 - Ubuntu',
      'type': 'Cloud Computer',
      'icon': 'computer',
      'color_val': 0xFF3A96FF,
      'online': true,
      'cpu': '2核',
      'ram': '4G',
      'storage': '60G',
    },
    {
      'name': '云手机 - Android 13',
      'type': 'Cloud Phone',
      'icon': 'phone',
      'color_val': 0xFF22C55E,
      'online': true,
      'cpu': '2核',
      'ram': '6G',
      'storage': '45G',
    },
    {
      'name': 'GPU 工作站',
      'type': 'GPU Server',
      'icon': 'memory',
      'color_val': 0xFF5147FF,
      'online': false,
      'cpu': '8核',
      'ram': '32G',
      'storage': '500G',
    },
  ];
}
