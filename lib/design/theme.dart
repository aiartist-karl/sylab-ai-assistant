// ============================================================================
// Coze Design Tokens - 全局主题系统
// 构建完整ThemeData，支持亮/暗切换
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'semantic_colors.dart';
import 'spacing.dart';
import 'shadows.dart';
import 'typography.dart';

/// 主题管理器
class AppTheme {
  AppTheme._();

  /// 亮色主题
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: LightThemeColors.bgMax,
    colorScheme: const ColorScheme.light(
      primary: BrandColors.primary,
      secondary: BrandColors.brand30,
      surface: LightThemeColors.bgPlus,
      error: SemanticColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: LightThemeColors.fgPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: LightThemeColors.bgMax,
      foregroundColor: LightThemeColors.fgPrimary,
      centerTitle: true,
      titleTextStyle: AppTextStyles.title.copyWith(color: LightThemeColors.fgPrimary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: LightThemeColors.bgPlus,
      selectedItemColor: LightThemeColors.navSelected,
      unselectedItemColor: LightThemeColors.navUnselected,
      selectedLabelStyle: AppTextStyles.label.copyWith(
        color: LightThemeColors.navSelected,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: AppTextStyles.label.copyWith(
        color: LightThemeColors.navUnselected,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: LightThemeColors.bgPlus,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: LightThemeColors.strokePrimary, width: 0.5),
      ),
      shadowColor: LightThemeColors.shadowDefault,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BrandColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTextStyles.loginButton,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BrandColors.primary,
        textStyle: AppTextStyles.body,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BrandColors.primary,
        side: const BorderSide(color: BrandColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        minimumSize: const Size(0, AppSizes.buttonHeightSmall),
        textStyle: AppTextStyles.body,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightThemeColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: LightThemeColors.strokeOpaque),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: LightThemeColors.strokeOpaque),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: BrandColors.primary, width: 1.5),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: LightThemeColors.fgPlaceholder),
    ),
    dividerTheme: const DividerThemeData(
      color: LightThemeColors.strokePrimary,
      thickness: 0.5,
      space: 0,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minHeight: AppSizes.avatarLarge + 16,
      iconColor: LightThemeColors.fgSecondary,
      textColor: LightThemeColors.fgPrimary,
      titleTextStyle: AppTextStyles.body.copyWith(
        color: LightThemeColors.fgPrimary,
        fontWeight: FontWeight.w400,
      ),
      subtitleTextStyle: AppTextStyles.label.copyWith(
        color: LightThemeColors.fgTertiary,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: LightThemeColors.bgPlus,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg16),
      ),
      titleTextStyle: AppTextStyles.subtitle.copyWith(color: LightThemeColors.fgPrimary),
      contentTextStyle: AppTextStyles.body.copyWith(color: LightThemeColors.fgSecondary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: LightThemeColors.bgPlus,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      dragHandleColor: LightThemeColors.fgPlaceholder,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return LightThemeColors.fgPlaceholder;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return BrandColors.primary;
        return LightThemeColors.strokeOpaque;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: BrandColors.primary,
      linearTrackColor: LightThemeColors.bgSecondary,
      circularTrackColor: LightThemeColors.bgSecondary,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: LightThemeColors.fgPrimary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.sm6),
      ),
      textStyle: AppTextStyles.label.copyWith(color: LightThemeColors.fgWhite),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: LightThemeColors.fgPrimary,
      contentTextStyle: AppTextStyles.body.copyWith(color: LightThemeColors.fgWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// 暗色主题
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DarkThemeColors.bgMax,
    colorScheme: const ColorScheme.dark(
      primary: BrandColors.primary,
      secondary: BrandColors.brand30,
      surface: DarkThemeColors.bgPlus,
      error: SemanticColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DarkThemeColors.fgPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: DarkThemeColors.bgMax,
      foregroundColor: DarkThemeColors.fgPrimary,
      centerTitle: true,
      titleTextStyle: AppTextStyles.title.copyWith(color: DarkThemeColors.fgPrimary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DarkThemeColors.bgPlus,
      selectedItemColor: DarkThemeColors.navSelected,
      unselectedItemColor: DarkThemeColors.navUnselected,
      selectedLabelStyle: AppTextStyles.label.copyWith(
        color: DarkThemeColors.navSelected,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: AppTextStyles.label.copyWith(
        color: DarkThemeColors.navUnselected,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: DarkThemeColors.bgPlus,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: DarkThemeColors.strokeOpaque, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BrandColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTextStyles.loginButton,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BrandColors.primary,
        textStyle: AppTextStyles.body,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BrandColors.primary,
        side: const BorderSide(color: BrandColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        minimumSize: const Size(0, AppSizes.buttonHeightSmall),
        textStyle: AppTextStyles.body,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkThemeColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: DarkThemeColors.strokeOpaque),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: DarkThemeColors.strokeOpaque),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: BrandColors.primary, width: 1.5),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: DarkThemeColors.fgPlaceholder),
    ),
    dividerTheme: const DividerThemeData(
      color: DarkThemeColors.strokePrimary,
      thickness: 0.5,
      space: 0,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minHeight: AppSizes.avatarLarge + 16,
      iconColor: DarkThemeColors.fgSecondary,
      textColor: DarkThemeColors.fgPrimary,
      titleTextStyle: AppTextStyles.body.copyWith(
        color: DarkThemeColors.fgPrimary,
        fontWeight: FontWeight.w400,
      ),
      subtitleTextStyle: AppTextStyles.label.copyWith(
        color: DarkThemeColors.fgTertiary,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: DarkThemeColors.bgPlus,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg16),
      ),
      titleTextStyle: AppTextStyles.subtitle.copyWith(color: DarkThemeColors.fgPrimary),
      contentTextStyle: AppTextStyles.body.copyWith(color: DarkThemeColors.fgSecondary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: DarkThemeColors.bgPlus,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      dragHandleColor: DarkThemeColors.fgPlaceholder,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return DarkThemeColors.fgPlaceholder;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return BrandColors.primary;
        return DarkThemeColors.strokeOpaque;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: BrandColors.primary,
      linearTrackColor: DarkThemeColors.bgSecondary,
      circularTrackColor: DarkThemeColors.bgSecondary,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DarkThemeColors.fgPrimary,
      contentTextStyle: AppTextStyles.body.copyWith(color: DarkThemeColors.bgMax),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// 当前主题上下文扩展 - 快速访问扣子设计Token
extension ThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor => isDarkMode ? DarkThemeColors.bgMax : LightThemeColors.bgMax;
  Color get bgCardColor => isDarkMode ? DarkThemeColors.bgPlus : LightThemeColors.bgPlus;
  Color get fgPrimary => isDarkMode ? DarkThemeColors.fgPrimary : LightThemeColors.fgPrimary;
  Color get fgSecondary => isDarkMode ? DarkThemeColors.fgSecondary : LightThemeColors.fgSecondary;
  Color get fgTertiary => isDarkMode ? DarkThemeColors.fgTertiary : LightThemeColors.fgTertiary;
  Color get fgPlaceholder => isDarkMode ? DarkThemeColors.fgPlaceholder : LightThemeColors.fgPlaceholder;
  Color get strokeColor => isDarkMode ? DarkThemeColors.strokeOpaque : LightThemeColors.strokeOpaque;
  Color get accentColor => BrandColors.primary;
}
