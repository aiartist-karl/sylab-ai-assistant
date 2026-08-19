import { useState, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Colors as LightColors } from '../constants/theme';

const DarkColors = {
  primary: '#7848ff',
  primaryRgb: '120, 72, 255',
  primaryShade: '#6030ff',
  primaryTint: '#9b6dff',
  primaryLight: '#2d1b69',
  secondary: '#3b82f6',
  tertiary: '#7848ff',
  accent: '#a78bfa',
  gradientStart: '#4a18e0',
  gradientEnd: '#7c3aed',
  success: '#22c55e',
  warning: '#f59e0b',
  danger: '#ef4444',
  info: '#3b82f6',
  light: '#1e293b',
  medium: '#94a3b8',
  dark: '#f8fafc',
  background: '#0f172a',
  backgroundSecondary: '#1e293b',
  surface: '#1e293b',
  surfaceSecondary: '#334155',
  bgDark: '#0f172a',
  surfaceDark: '#1e293b',
  surfaceSecondaryDark: '#334155',
  text: '#f1f5f9',
  textSecondary: '#94a3b8',
  textTertiary: '#64748b',
  textLight: '#64748b',
  textInverse: '#0f172a',
  border: '#334155',
  borderLight: '#1e293b',
  borderDark: '#475569',
  bubbleUser: '#2d1b69',
  bubbleAssistant: '#1e293b',
  bubbleAssistantDark: '#0f172a',
};

const THEME_KEY = 'app_dark_mode';

export function useTheme() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(THEME_KEY).then(saved => {
      if (saved === 'true') setIsDark(true);
    }).catch(() => {});
  }, []);

  const toggleDark = useCallback(() => {
    setIsDark(prev => {
      const next = !prev;
      AsyncStorage.setItem(THEME_KEY, String(next)).catch(() => {});
      return next;
    });
  }, []);

  const Colors = isDark ? DarkColors : LightColors;

  return { isDark, Colors, toggleDark };
}
