import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useAuthStore } from '../src/store/auth';
import { Colors } from '../src/constants/theme';

function RootLayoutNav() {
  const { isRestoring, user } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isRestoring) return;
    const inAuthGroup = segments[0] === 'login' || segments[0] === 'register' || segments[0] === 'forgot-password';
    if (!user && !inAuthGroup) {
      router.replace('/login');
    } else if (user && inAuthGroup) {
      router.replace('/(tabs)');
    }
  }, [isRestoring, user, segments]);

  if (isRestoring) {
    return (
      <View style={styles.loading}>
        <ActivityIndicator size="large" color={Colors.primary} />
      </View>
    );
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar style="auto" />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="login" />
        <Stack.Screen name="(tabs)" />
        <Stack.Screen
          name="chat/[id]"
          options={{
            headerShown: true,
            title: "sylab 对话",
            headerStyle: { backgroundColor: "#fff" },
            headerTitleStyle: { fontSize: 17, fontWeight: "700" },
            headerShadowEnabled: false,
            headerTitleContainerStyle: { paddingHorizontal: 0 },
            headerRightContainerStyle: { paddingRight: 16 },
            headerLeftContainerStyle: { paddingLeft: 16 },
          }}
        />
        <Stack.Screen name="register" options={{ headerShown: false }} />
        <Stack.Screen name="forgot-password" options={{ headerShown: false }} />
        <Stack.Screen
          name="projects/[id]"
          options={{
            headerShown: true,
            title: '项目文件',
            headerStyle: { backgroundColor: '#fff' },
            headerTitleStyle: { fontSize: 17, fontWeight: '700' },
            headerShadowEnabled: false,
            headerTitleContainerStyle: { paddingHorizontal: 0 },
            headerRightContainerStyle: { paddingRight: 16 },
            headerLeftContainerStyle: { paddingLeft: 16 },
          }}
        />
      </Stack>
    </GestureHandlerRootView>
  );
}

export default function RootLayout() {
  const restore = useAuthStore((s) => s.restore);

  useEffect(() => {
    restore();
  }, []);

  return <RootLayoutNav />;
}

const styles = StyleSheet.create({
  loading: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff' },
});
