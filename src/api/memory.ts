/**
 * 记忆模块
 * - 数据库 CRUD → WebAPI (Session): /api/knowledge/database/*
 * - 记忆变量 → WebAPI (Session): /api/knowledge/memory/*
 */
import { webApiClient } from './client';
import { API_PATHS } from '../constants';
import type { SnowflakeId } from '../types/api';

export const memoryApi = {
  // ────────────── 结构化数据库 ──────────────

  /** 数据库列表 */
  databases: (params?: { knowledge_id?: string }) =>
    webApiClient.get(API_PATHS.DATABASE_LIST, { params }).then((r) => {
      const data = r.data?.data || r.data;
      return data.database_list || data.items || [];
    }),

  /** 数据库详情 */
  getDatabase: (databaseId: SnowflakeId) =>
    webApiClient
      .get(API_PATHS.DATABASE_GET_BY_ID, { params: { database_id: databaseId } })
      .then((r) => r.data?.data || r.data),

  /** 添加数据库 */
  addDatabase: (data: { knowledge_id: string; name: string; fields: any[] }) =>
    webApiClient.post(API_PATHS.DATABASE_ADD, data).then((r) => r.data?.data || r.data),

  /** 删除数据库 */
  deleteDatabase: (databaseId: SnowflakeId) =>
    webApiClient.post(API_PATHS.DATABASE_DELETE, { database_id: databaseId }).then((r) => r.data),

  /** 记录列表 */
  listRecords: (databaseId: SnowflakeId, params?: { page?: number; page_size?: number }) =>
    webApiClient
      .post(API_PATHS.DATABASE_LIST_RECORDS, { database_id: databaseId, ...params })
      .then((r) => {
        const data = r.data?.data || r.data;
        return {
          items: data.records || data.items || [],
          total: data.total || 0,
        };
      }),

  /** 更新记录 */
  updateRecords: (databaseId: SnowflakeId, records: any[]) =>
    webApiClient
      .post(API_PATHS.DATABASE_UPDATE_RECORDS, { database_id: databaseId, records })
      .then((r) => r.data),

  // ────────────── 记忆变量 ──────────────

  /** 获取记忆变量元数据 */
  getVariables: (botId?: SnowflakeId) =>
    webApiClient
      .post(API_PATHS.MEMORY_VARIABLES, { bot_id: botId })
      .then((r) => r.data?.data || r.data),

  /** 设置 KV 记忆 */
  setKvMemory: (data: { bot_id?: string; key: string; value: any; value_type?: string }) =>
    webApiClient
      .post(API_PATHS.MEMORY_SET_KV, data)
      .then((r) => r.data?.data || r.data),

  /** 删除画像记忆 */
  delProfileMemory: (data: { bot_id?: string; memory_id: string }) =>
    webApiClient
      .post(API_PATHS.MEMORY_DEL_PROFILE, data)
      .then((r) => r.data),
};
