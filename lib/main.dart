// ============================================================================
// 主应用入口 + 底部导航 + 路由系统
// 4个Tab: 首页/技能/计划/设置
// 21个路由全映射
// ============================================================================

import 'package:flutter/material.dart';
import 'design/theme.dart';
import 'design/colors.dart';
import 'design/spacing.dart';
import 'design/typography.dart';
import 'animations/micro_interactions.dart';
import 'screens/home/home_screen.dart';
import 'screens/skill/skill_store_screen.dart';
import 'screens/plan/plan_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/device/device_management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SylabApp());
}

class SylabApp extends StatefulWidget {
  const SylabApp({super.key});

  @override
  State<SylabApp> createState() => _SylabAppState();
}

class _SylabAppState extends State<SylabApp> {
  // 主题模式: system/light/dark
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sylab AI',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

/// 主Shell - 底部4Tab导航
/// 高度56dp + SafeArea底部, 图标24dp, 文字12sp
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SkillStoreScreen(),
    PlanScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -1),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.navBarHeight,
            child: Row(
              children: [
                _buildNavItem(0, Icons.home_rounded, '首页', isDark),
                _buildNavItem(1, Icons.apps_rounded, '技能', isDark),
                _buildNavItem(2, Icons.dashboard_rounded, '计划', isDark),
                _buildNavItem(3, Icons.settings_rounded, '设置', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tab项: 选中态accent色+scale动画, 未选中灰色
  // 切换动画: 图标scale 0.9→1.0 + 颜色渐变 150ms
  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? BrandColors.primary
        : (isDark ? DarkThemeColors.navUnselected : LightThemeColors.navUnselected);

    return Expanded(
      child: PressScaleWidget(
        scale: 0.95,
        duration: const Duration(milliseconds: 150),
        onTap: () {
          setState(() => _currentIndex = index);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: AppSizes.iconMedium, color: color),
                  // 新消息红点（仅在计划Tab显示）
                  if (index == 2)
                    Positioned(
                      right: -4,
                      top: -2,
                      child: PulsingBadgeDot(size: 6),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 路由配置 - 21个路由全映射
/// 来源: APK逆向提取的React Router路由表
class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String personalProfile = '/personal-profile';
  static const String accountSecurity = '/account-security';
  static const String deviceInfo = '/device-info';
  static const String theme = '/theme';
  static const String feedback = '/feedback';
  static const String mcpConfig = '/mcpconfig';
  static const String appInfo = '/app-info';
  static const String about = '/about';
  static const String aboutIcp = '/about/icp';
  static const String privacyPolicy = '/privacy-policy';
  static const String userAgreement = '/user-agreement';
  static const String cozeAccessNote = '/coze-access-note';
  static const String dataProcessing = '/data-processing-addendum';
  static const String thirdPartySharing = '/third-party-sharing';
  static const String infoCollection = '/info-collection';
  static const String unregister = '/unregister';
  static const String unregisterPolicy = '/unregister-policy';
  static const String appAuthNote = '/app-auth-note';
  static const String userInfo = '/user-info';
}
