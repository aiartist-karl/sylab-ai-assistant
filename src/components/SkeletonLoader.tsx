import React from 'react';
import { View } from 'react-native';

type SkeletonType = 'chat-list' | 'chat-detail' | 'card-grid' | 'list';

interface SkeletonLoaderProps {
  type: SkeletonType;
  visible: boolean;
  delay?: number;
}

// 临时禁用骨架屏（排查Web端页面抖动问题）
export function SkeletonLoader({ type, visible, delay }: SkeletonLoaderProps) {
  return null;
}
