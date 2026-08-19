/**
 * 插件模块
 * 全部使用 WebAPI (Session): /api/plugin_api/*
 */
import { webApiClient } from './client';
import { API_PATHS } from '../constants';
import type { SnowflakeId } from '../types/api';

const SPACE_ID = '1';

export const pluginApi = {
  /** 插件列表 */
  list: (params?: { page?: number; page_size?: number }) =>
    webApiClient.post(API_PATHS.PLUGIN_LIST, {
      space_id: SPACE_ID,
      page_size: params?.page_size || 20,
      page_num: params?.page || 1,
    }).then((r) => {
      const data = r.data?.data || r.data;
      return {
        items: data.plugin_list || data.items || [],
        total: data.total_count || data.total || 0,
      };
    }),

  /** 插件详情 */
  get: (id: SnowflakeId) =>
    webApiClient
      .post(API_PATHS.PLUGIN_DETAIL, { plugin_id: id, space_id: SPACE_ID })
      .then((r) => r.data?.data || r.data),

  /** 创建插件 (OpenAPI spec) */
  create: (data: { name: string; description?: string; openapi_spec?: string }) =>
    webApiClient
      .post(API_PATHS.PLUGIN_CREATE, { space_id: SPACE_ID, ...data })
      .then((r) => r.data?.data || r.data),

  /** 发布插件 */
  publish: (id: SnowflakeId) =>
    webApiClient.post(API_PATHS.PLUGIN_PUBLISH, { plugin_id: id, space_id: SPACE_ID }).then((r) => r.data),

  /** 调试/调用插件工具 */
  invoke: (pluginId: SnowflakeId, toolName: string, args: Record<string, any>) =>
    webApiClient
      .post(API_PATHS.PLUGIN_DEBUG, {
        plugin_id: pluginId,
        tool_name: toolName,
        parameters: args,
        space_id: SPACE_ID,
      })
      .then((r) => r.data?.data || r.data),
};
