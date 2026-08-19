/**
 * 项目模块 (APP 端扩展)
 *
 * 注意: 后端暂无原生 Project 概念，此模块为 APP 端扩展。
 * 暂用 WebAPI draft_project 接口（可能不存在），降级返回空列表。
 */
import { webApiClient } from './client';
import type { SnowflakeId } from '../types/api';

export const projectApi = {
  /** 项目列表 */
  list: async (params?: any) => {
    try {
      const resp = await webApiClient.get(
        '/api/intelligence_api/draft_project/inner_taskList',
        { params },
      );
      const data = resp.data?.data || resp.data;
      return {
        items: data.project_list || data.items || [],
        total: data.total || 0,
      };
    } catch {
      return { items: [], total: 0 };
    }
  },

  /** 项目详情 */
  get: async (_id: SnowflakeId) => {
    // TODO: 对接 draft_project 详情接口
    return null;
  },

  /** 创建项目 */
  create: async (data: { name: string; description?: string }) => {
    try {
      const resp = await webApiClient.post(
        '/api/intelligence_api/draft_project/create',
        data,
      );
      return resp.data?.data || resp.data;
    } catch {
      return null;
    }
  },

  /** 删除项目 */
  delete: async (id: SnowflakeId) => {
    try {
      const resp = await webApiClient.post(
        '/api/intelligence_api/draft_project/delete',
        { project_id: id },
      );
      return resp.data;
    } catch {
      return null;
    }
  },
};
