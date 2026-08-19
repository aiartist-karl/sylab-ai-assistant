/**
 * sylab App 设计规范
 */
export const Colors = {
  // 主色系 - 紫色
  primary: '#6030ff',
  primaryRgb: '96, 48, 255',
  primaryShade: '#4a18e0',
  primaryTint: '#7848ff',
  primaryLight: '#f0f0f0',
  // 辅色
  secondary: '#0163aa',
  tertiary: '#6030ff',
  accent: '#a78bfa',
  // 渐变
  gradientStart: '#6030ff',
  gradientEnd: '#9333ea',
  // 功能色
  success: '#22c55e',
  warning: '#f59e0b',
  danger: '#ef4444',
  info: '#3b82f6',
  // 中性色
  light: '#f8fafc',
  medium: '#64748b',
  dark: '#1e293b',
  // 背景
  background: '#ffffff',
  backgroundSecondary: '#f8fafc',
  surface: '#ffffff',
  surfaceSecondary: '#f1f5f9',
  // 深色模式（预留）
  bgDark: '#0f172a',
  surfaceDark: '#1e293b',
  surfaceSecondaryDark: '#334155',
  // 文字
  text: '#0f172a',
  textSecondary: '#64748b',
  textTertiary: '#94a3b8',
  textLight: '#94a3b8',
  textInverse: '#ffffff',
  // 边框
  border: '#e2e8f0',
  borderLight: '#f1f5f9',
  borderDark: '#334155',
  // 聊天气泡
  bubbleUser: '#e8f5e9',
  bubbleAssistant: '#f5f5f5',
  bubbleAssistantDark: '#1e293b',
};

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 20,
  xl: 28,
  xxl: 40,
};

export const BorderRadius = {
  xs: 6,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 9999,
};

export const FontSize = {
  xs: 11,
  sm: 13,
  md: 15,
  lg: 17,
  xl: 20,
  xxl: 24,
  xxxl: 30,
};

export const Shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 6,
  },
  glow: {
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 8,
  },
};
