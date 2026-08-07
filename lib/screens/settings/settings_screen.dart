// ============================================================================
// 设置页 - SettingsScreen
// 扣子App底部Tab第4页：完整设置列表(10项)+个人中心+主题切换
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/semantic_colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../animations/micro_interactions.dart';
import '../../widgets/common/state_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // === 标题 ===
            SliverToBoxAdapter(
              child: Container(
                height: AppSpacing.topBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text('设置', style: AppTextStyles.title.copyWith(
                      color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                    )),
                  ],
                ),
              ),
            ),
            // === 个人信息卡片 ===
            SliverToBoxAdapter(
              child: _buildProfileCard(isDark),
            ),
            SliverToBoxAdapter(child: SectionDivider(height: 8)),
            // === 设置项列表 ===
            SliverToBoxAdapter(
              child: _buildSettingsSection(isDark),
            ),
            SliverToBoxAdapter(child: SectionDivider(height: 8)),
            // === 法律/信息 ===
            SliverToBoxAdapter(
              child: _buildInfoSection(isDark),
            ),
            // === 退出登录 ===
            SliverToBoxAdapter(
              child: _buildLogoutButton(context, isDark),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // 个人信息卡: 头像64dp圆形 + 昵称 + 账号
  Widget _buildProfileCard(bool isDark) {
    return PressScaleWidget(
      onTap: () {
        // TODO: navigate to personal-profile
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md16),
        child: Row(
          children: [
            // 头像 64dp 圆形
            Container(
              width: AppSizes.avatarLarge,
              height: AppSizes.avatarLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: BrandColors.brandGradient,
              ),
              child: const Center(
                child: Text('K', style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700,
                )),
              ),
            ),
            const SizedBox(width: 16),
            // 昵称 + 账号
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('卡尔', style: AppTextStyles.subtitle.copyWith(
                    color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text('karl@sylab.ai', style: AppTextStyles.label.copyWith(
                    color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
              color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // 主设置项
  Widget _buildSettingsSection(bool isDark) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'title': '个人信息', 'route': '/personal-profile'},
      {'icon': Icons.lock_outline_rounded, 'title': '账号安全', 'route': '/account-security'},
      {'icon': Icons.palette_outlined, 'title': '主题设置', 'route': '/theme'},
      {'icon': Icons.devices_outlined, 'title': '设备管理', 'route': '/device-info'},
      {'icon': Icons.extension_outlined, 'title': 'MCP配置', 'route': '/mcpconfig'},
      {'icon': Icons.notifications_outlined, 'title': '推送通知', 'route': ''},
      {'icon': Icons.link_outlined, 'title': '渠道管理', 'route': ''},
      {'icon': Icons.feedback_outlined, 'title': '意见反馈', 'route': '/feedback'},
    ];

    return Column(
      children: items.map((item) => _buildSettingsItem(
        isDark: isDark,
        icon: item['icon'] as IconData,
        title: item['title'] as String,
        onTap: () {
          if ((item['route'] as String).isNotEmpty) {
            // TODO: navigate
          }
        },
      )).toList(),
    );
  }

  // 设置项: 高度56dp, 左侧图标24dp+标题16sp, 右侧箭头
  Widget _buildSettingsItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return PressScaleWidget(
      onTap: onTap,
      child: Container(
        height: AppSizes.avatarLarge + 16,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20,
                color: isDark ? DarkThemeColors.fgSecondary : LightThemeColors.fgSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w400,
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              )),
            ),
            Icon(Icons.chevron_right_rounded, size: 20,
              color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // 法律/信息
  Widget _buildInfoSection(bool isDark) {
    final items = [
      {'title': 'App信息', 'route': '/app-info'},
      {'title': '关于', 'route': '/about'},
    ];

    return Column(
      children: items.map((item) => _buildSettingsItem(
        isDark: isDark,
        icon: Icons.info_outline_rounded,
        title: item['title'] as String,
        onTap: () {},
      )).toList(),
    );
  }

  // 退出登录: 红色文字, 居中, 点击弹出确认Dialog
  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md16),
      child: PressScaleWidget(
        onTap: () => _showLogoutConfirm(context, isDark),
        child: Container(
          width: double.infinity,
          height: AppSizes.buttonHeightSmall,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: StateColors.error, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            '退出登录',
            style: AppTextStyles.body.copyWith(
              color: StateColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: logout
            },
            child: Text('确认', style: TextStyle(color: StateColors.error)),
          ),
        ],
      ),
    );
  }
}
