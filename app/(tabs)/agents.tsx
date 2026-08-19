import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, TextInput, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import { Colors, Spacing, BorderRadius, FontSize, Shadows } from '../../src/constants/theme';
import { botApi } from '../../src/api/bot';
import { EmptyState } from '../../src/components/EmptyState';
import { Ionicons } from '@expo/vector-icons';
import type { BotInfo } from '../../src/types/api';

export default function AgentsScreen() {
  const router = useRouter();
  const [agents, setAgents] = useState<BotInfo[]>([]);
  const [searchText, setSearchText] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const fetchAgents = async () => {
    try {
      const result = await botApi.list({ page: 1, page_size: 50 });
      setAgents(result.items || []);
    } catch {
      setAgents([]);
    } finally {
      setRefreshing(false);
    }
  };

  useEffect(() => { fetchAgents(); }, []);

  const filtered = agents.filter((item) =>
    !searchText || item.name?.toLowerCase().includes(searchText.toLowerCase())
  );

  const renderAgent = ({ item }: { item: BotInfo }) => (
    <TouchableOpacity
      style={styles.agentCard}
      activeOpacity={0.7}
      onPress={() => router.push({ pathname: '/chat/[id]', params: { id: item.id, bot_id: item.id } })}
    >
      <View style={styles.agentAvatar}>
        <Ionicons name="business" size={20} color={Colors.primary} />
      </View>
      <View style={styles.agentInfo}>
        <Text style={styles.agentName} numberOfLines={1}>{item.name}</Text>
        <Text style={styles.agentDesc} numberOfLines={2}>{item.description || '暂无描述'}</Text>
        <View style={styles.agentTags}>
          <View style={styles.tag}>
            <Ionicons name="person-outline" size={10} color={Colors.primary} />
            <Text style={styles.tagText}>Agent</Text>
          </View>
        </View>
      </View>
      <TouchableOpacity
        style={styles.useBtn}
        onPress={() => router.push({ pathname: '/chat/[id]', params: { id: item.id, bot_id: item.id } })}
      >
        <Ionicons name="arrow-forward" size={16} color={Colors.primary} />
      </TouchableOpacity>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* 搜索 */}
      <View style={styles.searchBar}>
        <Ionicons name="search-outline" size={18} color={Colors.textTertiary} style={{ marginRight: 8 }} />
        <TextInput
          style={styles.searchInput}
          placeholder="搜索 Agent..."
          placeholderTextColor={Colors.textTertiary}
          value={searchText}
          onChangeText={(t) => setSearchText(t)}
          onSubmitEditing={fetchAgents}
        />
      </View>

      {filtered.length === 0 ? (
        <EmptyState iconName="people" title="暂无 Agent" subtitle="请先在后台创建 Bot" />
      ) : (
        <FlatList
          data={filtered}
          renderItem={renderAgent}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => { setRefreshing(true); fetchAgents(); }} tintColor={Colors.primary} />}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  searchBar: {
    flexDirection: 'row', alignItems: 'center',
    marginHorizontal: Spacing.md, marginVertical: Spacing.sm,
    backgroundColor: Colors.backgroundSecondary,
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.md, height: 40,
  },
  searchInput: { flex: 1, fontSize: FontSize.sm, color: Colors.text, paddingVertical: 0 },
  list: { padding: Spacing.md },
  agentCard: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: '#fff', borderRadius: BorderRadius.lg,
    padding: Spacing.md, marginBottom: Spacing.sm,
    borderWidth: 1, borderColor: Colors.borderLight,
  },
  agentAvatar: {
    width: 48, height: 48, borderRadius: 14,
    backgroundColor: Colors.primaryLight,
    justifyContent: 'center', alignItems: 'center',
    marginRight: Spacing.md,
  },
  agentInfo: { flex: 1 },
  agentName: { fontSize: FontSize.md, fontWeight: '600', color: Colors.text, marginBottom: 4 },
  agentDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, lineHeight: 18, marginBottom: 6 },
  agentTags: { flexDirection: 'row', gap: 6 },
  tag: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.primaryLight, borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3, gap: 3 },
  tagText: { fontSize: 10, color: Colors.primary, fontWeight: '600' },
  useBtn: { justifyContent: 'center', padding: Spacing.sm },
});
