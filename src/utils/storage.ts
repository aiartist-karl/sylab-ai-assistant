/**
 * 跨平台安全存储封装
 * - Native: 使用 expo-secure-store
 * - Web: 使用 localStorage 降级
 */
import { Platform } from "react-native";

let SecureStore: any = null;
if (Platform.OS !== "web") {
  try {
    SecureStore = require("expo-secure-store");
  } catch (e) {
    console.warn("SecureStore not available");
  }
}

export const Storage = {
  async getItem(key: string): Promise<string | null> {
    if (Platform.OS === "web") {
      return localStorage.getItem(key);
    }
    if (SecureStore) {
      return SecureStore.getItemAsync(key);
    }
    return null;
  },

  async setItem(key: string, value: string): Promise<void> {
    if (Platform.OS === "web") {
      localStorage.setItem(key, value);
      return;
    }
    if (SecureStore) {
      await SecureStore.setItemAsync(key, value);
    }
  },

  async deleteItem(key: string): Promise<void> {
    if (Platform.OS === "web") {
      localStorage.removeItem(key);
      return;
    }
    if (SecureStore) {
      await SecureStore.deleteItemAsync(key);
    }
  },
};
