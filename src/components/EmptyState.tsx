import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors, Spacing, FontSize, BorderRadius } from '../constants/theme';
import { Ionicons } from '@expo/vector-icons';

interface EmptyStateProps {
  icon?: string;
  iconName?: string;
  title: string;
  subtitle?: string;
  isDark?: boolean;
}

export const EmptyState: React.FC<EmptyStateProps> = ({ icon, iconName, title, subtitle, isDark }) => (
  <View style={styles.container}>
    <View style={styles.iconCircle}>
      {iconName ? (
        <Ionicons name={iconName as any} size={32} color={Colors.primary} />
      ) : (
        <Text style={styles.icon}>{icon}</Text>
      )}
    </View>
    <Text style={[styles.title, { color: isDark ? Colors.textInverse : Colors.text }]}>{title}</Text>
    {subtitle ? <Text style={[styles.subtitle, { color: isDark ? '#888' : Colors.textTertiary }]}>{subtitle}</Text> : null}
  </View>
);

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: Spacing.xxl },
  iconCircle: {
    width: 80, height: 80, borderRadius: 40,
    backgroundColor: Colors.primaryLight,
    justifyContent: 'center', alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  icon: { fontSize: 36 },
  title: { fontSize: FontSize.lg, fontWeight: '600', marginBottom: Spacing.xs, color: Colors.text },
  subtitle: { fontSize: FontSize.sm, textAlign: 'center', color: Colors.textTertiary, lineHeight: 18 },
});
