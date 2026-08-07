// ============================================================================
// 技能商店页 - SkillStoreScreen
// 扣子App底部Tab第2页：搜索+分类Tab+技能卡片网格
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/semantic_colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/shadows.dart';
import '../../animations/micro_interactions.dart';

class SkillStoreScreen extends StatefulWidget {
  const SkillStoreScreen({super.key});

  @override
  State<SkillStoreScreen> createState() => _SkillStoreScreenState();
}

class _SkillStoreScreenState extends State<SkillStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['推荐', '职场', '创作', '技术', '生活', '教育'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // === 搜索框 ===
            _buildSearchBar(isDark),
            // === 分类Tab ===
            _buildTabBar(isDark),
            // === 技能网格 ===
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) => _buildSkillGrid(isDark, tab)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 搜索框: 圆角24dp(=pill), 左侧搜索图标, placeholder灰色
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding, AppSpacing.ms12,
        AppSpacing.pagePadding, AppSpacing.sm8,
      ),
      child: Container(
        height: AppSizes.searchBoxHeight,
        decoration: BoxDecoration(
          color: isDark ? DarkThemeColors.bgInput : LightThemeColors.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: isDark ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? DarkThemeColors.fgPlaceholder : LightThemeColors.fgPlaceholder,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: AppTextStyles.body.copyWith(
                  color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '搜索技能...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: isDark ? DarkThemeColors.fgPlaceholder : LightThemeColors.fgPlaceholder,
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab标签栏: 横向滚动, 选中accent下划线+加粗, 未选中灰色
  // 切换时underline slide 200ms
  Widget _buildTabBar(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
        unselectedLabelColor: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body,
        indicatorColor: BrandColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return BrandColors.primary.withOpacity(0.1);
          }
          return null;
        }),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // 技能卡片网格: 每行2个, 50%宽
  Widget _buildSkillGrid(bool isDark, String category) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _mockSkills.length,
        itemBuilder: (context, index) => _buildSkillCard(isDark, index),
      ),
    );
  }

  // 技能卡片: 宽度50%屏宽, 圆角12dp, 阴影default, 图标48x48, 标题14sp, 描述12sp灰色
  // 卡片按压: scale 0.95 按压反馈150ms, 松开回弹
  Widget _buildSkillCard(bool isDark, int index) {
    final skill = _mockSkills[index % _mockSkills.length];
    return CardPressWidget(
      onTap: () {
        // TODO: navigate to skill detail
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.ms12),
        decoration: BoxDecoration(
          color: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
            width: 0.5,
          ),
          boxShadow: AppShadows.defaultShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标 48x48
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: skill['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                skill['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            // 标题 14sp 加粗
            Text(
              skill['title'] as String,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 描述 12sp 灰色
            Expanded(
              child: Text(
                skill['desc'] as String,
                style: AppTextStyles.label.copyWith(
                  color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 安装按钮
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  index.isEven ? '已安装' : '安装',
                  style: AppTextStyles.label.copyWith(
                    color: BrandColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _mockSkills = <Map<String, dynamic>>[
    {
      'title': 'PPT生成', 'desc': 'AI一键生成专业演示文稿',
      'icon': 'slideshow', 'color_val': 0xFF5147FF,
    },
    {
      'title': '周报助手', 'desc': '自动汇总本周工作生成周报',
      'icon': 'article', 'color_val': 0xFF3A96FF,
    },
    {
      'title': 'AI绘画', 'desc': '输入描述生成精美图片',
      'icon': 'brush', 'color_val': 0xFFFF6B6B,
    },
    {
      'title': '深度研究', 'desc': '多源信息搜集与分析报告',
      'icon': 'search', 'color_val': 0xFF22C55E,
    },
    {
      'title': '代码助手', 'desc': '智能代码生成与调试',
      'icon': 'code', 'color_val': 0xFFF59E0B,
    },
    {
      'title': '翻译大师', 'desc': '多语言实时精准翻译',
      'icon': 'translate', 'color_val': 0xFF8B5CF6,
    },
  ];

  static IconData _skillIcon(String name) {
    switch (name) {
      case 'slideshow': return Icons.slideshow_rounded;
      case 'article': return Icons.article_rounded;
      case 'brush': return Icons.brush_rounded;
      case 'search': return Icons.search_rounded;
      case 'code': return Icons.code_rounded;
      case 'translate': return Icons.translate_rounded;
      default: return Icons.apps_rounded;
    }
  }
}
