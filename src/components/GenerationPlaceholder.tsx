import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Platform } from 'react-native';
import { Colors, Spacing, BorderRadius, FontSize } from '../constants/theme';
import { Ionicons } from '@expo/vector-icons';

interface GenerationPlaceholderProps {
  type: 'image' | 'video';
}

export const GenerationPlaceholder: React.FC<GenerationPlaceholderProps> = ({ type }) => {
  const [showCursor, setShowCursor] = useState(true);

  useEffect(() => {
    const interval = setInterval(() => setShowCursor(prev => !prev), 530);
    return () => clearInterval(interval);
  }, []);

  const isVideo = type === 'video';
  const label = isVideo ? '正在生成视频...' : '正在生成图片...';
  const subtitle = isVideo ? '视频任务耗时较长，完成后会通知您' : '图片生成中，请稍候';

  return (
    <View style={styles.wrapper}>
      <View style={styles.card}>
        {/* Video/Image Icon */}
        <View style={styles.iconContainer}>
          {isVideo ? (
            <Ionicons name="videocam" size={48} color="#94a3b8" />
          ) : (
            <Ionicons name="image" size={48} color="#94a3b8" />
          )}
        </View>
        {/* Generating text with blinking cursor */}
        <Text style={styles.label}>
          {label}
          <Text style={[styles.cursor, { opacity: showCursor ? 1 : 0 }]}>|</Text>
        </Text>
      </View>
      {/* Subtitle below card */}
      <Text style={styles.subtitle}>{subtitle}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    alignItems: 'center',
    paddingVertical: Spacing.lg,
    width: '100%',
  },
  card: {
    width: '85%',
    minHeight: 160,
    backgroundColor: Platform.OS === 'web' ? 'rgba(255,255,255,0.85)' : 'rgba(255,255,255,0.8)',
    borderRadius: BorderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.06)',
    ...Platform.select({
      web: {
        boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
      } as any,
      default: {},
    }),
  },
  iconContainer: {
    marginBottom: Spacing.md,
    opacity: 0.6,
  },
  label: {
    fontSize: FontSize.lg,
    color: '#64748b',
    fontWeight: '500',
  },
  cursor: {
    color: '#64748b',
    fontWeight: '300',
    fontSize: FontSize.lg,
    marginLeft: 2,
  },
  subtitle: {
    fontSize: FontSize.sm,
    color: '#94a3b8',
    marginTop: Spacing.sm,
    textAlign: 'center',
  },
});
