// ============================================================================
// 计划/任务页 - PlanScreen
// 扣子App底部Tab第3页: 任务列表+进度+子任务
// ============================================================================

import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/semantic_colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/shadows.dart';
import '../../animations/coze_animations.dart';
import '../../animations/micro_interactions.dart';
import '../../widgets/common/state_widgets.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['进行中', '已完成', '已暂停'];

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
            // === 顶部标题栏 ===
            _buildHeader(isDark),
            // === 状态Tab ===
            _buildStatusTabs(isDark),
            // === 任务列表 ===
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(isDark, 'running'),
                  _buildTaskList(isDark, 'done'),
                  _buildTaskList(isDark, 'paused'),
                ],
              ),
            ),
          ],
        ),
      ),
      // === 新建计划FAB ===
      floatingActionButton: PressScaleWidget(
        onTap: () => _showCreatePlanSheet(isDark),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BrandColors.brandGradient,
            boxShadow: AppShadows.large,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // 标题: "计划" + 右侧新建按钮
  Widget _buildHeader(bool isDark) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColors.bgMax : LightThemeColors.bgMax,
        border: Border(
          bottom: BorderSide(
            color: isDark ? DarkThemeColors.strokePrimary : LightThemeColors.strokePrimary,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('计划', style: AppTextStyles.title.copyWith(
            color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
          )),
        ],
      ),
    );
  }

  // 状态Tab: 进行中/已完成/已暂停
  Widget _buildStatusTabs(bool isDark) {
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
        labelColor: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
        unselectedLabelColor: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body,
        indicatorColor: BrandColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // 任务列表
  Widget _buildTaskList(bool isDark, String status) {
    if (status == 'done') {
      return TaskEmptyState();
    }

    final tasks = _mockTasks[status] ?? [];
    if (tasks.isEmpty) {
      return TaskEmptyState(onCreateTask: () => _showCreatePlanSheet(isDark));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(isDark, tasks[index]),
    );
  }

  // taskCard组件
  // 来源CSS: .taskCard { padding:12dp; transition:all .15s; position:relative }
  // .taskCardHeader { margin-bottom:6dp; justify-content:space-between; align-items:center }
  Widget _buildTaskCard(bool isDark, Map<String, dynamic> task) {
    final isRunning = task['status'] == 'running';
    final progress = task['progress'] as double? ?? 0.0;

    return CardPressWidget(
      onTap: () {
        // TODO: navigate to task detail
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md12),
        padding: const EdgeInsets.all(AppSpacing.md12),
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
          children: [
            // === taskCardHeader ===
            Row(
              children: [
                // 图标
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(task['color_val'] as int).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_taskIcon(task['icon'] as String), size: 18, color: Color(task['color_val'] as int)),
                ),
                const SizedBox(width: 10),
                // 标题
                Expanded(
                  child: Text(
                    task['title'] as String,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 状态指示
                if (isRunning) const RunningStatusBall(size: 10),
                if (task['hasNew'] == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: PulsingBadgeDot(size: 6),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // === 进度条 ===
            // 高度6dp, 圆角3dp, accent填充, 300ms动画
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.progressBarRadius),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSizes.progressBarHeight,
                backgroundColor: isDark ? const Color(0xFF2D3145) : const Color(0xFFEDF0FF),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isRunning ? BrandColors.primary : const Color(0xFF22C55E),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // === 当前步骤 / 状态文字 ===
            Row(
              children: [
                Expanded(
                  child: Text(
                    task['currentStep'] as String? ?? '已完成',
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.label.copyWith(
                    color: BrandColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // === 子任务（如果有） ===
            if (task['subTasks'] != null) ...[
              const SizedBox(height: 8),
              ...((task['subTasks'] as List).map((st) => _buildSubTaskCard(isDark, st))),
            ],
          ],
        ),
      ),
    );
  }

  // sub-task-card
  // 来源CSS: .sub-task-card-interrupt { gap:12dp; margin-top:8dp }
  Widget _buildSubTaskCard(bool isDark, Map<String, dynamic> subTask) {
    final isInterrupt = subTask['interrupted'] == true;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm8),
      padding: const EdgeInsets.all(AppSpacing.sm8),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColors.bgMax : LightThemeColors.bgPrimary,
        borderRadius: BorderRadius.circular(8),
        border: isInterrupt
            ? Border.all(color: StateColors.interrupt, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            isInterrupt ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            size: 14,
            color: isInterrupt ? StateColors.interrupt : const Color(0xFF22C55E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subTask['title'] as String,
              style: AppTextStyles.interruptText.copyWith(
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            subTask['status'] as String,
            style: AppTextStyles.label.copyWith(
              color: isInterrupt ? StateColors.interrupt : const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  // 新建计划BottomSheet
  void _showCreatePlanSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('创建新任务', style: AppTextStyles.title.copyWith(
                color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
              )),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '描述你的目标...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: isDark ? DarkThemeColors.fgPlaceholder : LightThemeColors.fgPlaceholder,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? DarkThemeColors.bgMax : LightThemeColors.bgMax,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('创建'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _mockTasks = <String, List<Map<String, dynamic>>>{
    'running': [
      {
        'title': '30天涨粉计划',
        'status': 'running',
        'progress': 0.75,
        'currentStep': '第22天: 内容创作',
        'icon': 'trending_up',
        'color_val': 0xFF5147FF,
        'hasNew': true,
        'subTasks': [
          {'title': '选题策划', 'status': '已完成', 'interrupted': false},
          {'title': '内容撰写', 'status': '进行中', 'interrupted': false},
          {'title': '发布推广', 'status': '待执行', 'interrupted': false},
        ],
      },
      {
        'title': '周报自动化',
        'status': 'running',
        'progress': 0.3,
        'currentStep': '收集数据中...',
        'icon': 'auto_graph',
        'color_val': 0xFF3A96FF,
        'hasNew': false,
      },
    ],
    'done': <Map<String, dynamic>>[],
    'paused': [
      {
        'title': '竞品分析报告',
        'status': 'paused',
        'progress': 0.5,
        'currentStep': '数据采集中断',
        'icon': 'analytics',
        'color_val': 0xFFF59E0B,
        'hasNew': false,
        'subTasks': [
          {'title': '数据收集', 'status': '已完成', 'interrupted': false},
          {'title': '对比分析', 'status': '已中断', 'interrupted': true},
        ],
      },
    ],
  };

  static IconData _taskIcon(String name) {
    switch (name) {
      case 'trending_up': return Icons.trending_up_rounded;
      case 'auto_graph': return Icons.auto_graph_rounded;
      case 'analytics': return Icons.analytics_rounded;
      default: return Icons.task_rounded;
    }
  }
}
