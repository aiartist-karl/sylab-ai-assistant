/**
 * 自动化模块 (APP 端扩展)
 *
 * 注意: 后端暂无原生 Automation 概念，此模块为 APP 端扩展。
 * 后续可对接 workflow_api + 定时触发实现。
 * 当前返回空数据，确保 UI 层不崩溃。
 */
import type { SnowflakeId } from '../types/api';

export const automationApi = {
  /** 自动化列表 */
  list: async (_params?: any) => {
    return { items: [], total: 0 };
  },

  /** 自动化详情 */
  get: async (_id: SnowflakeId) => {
    return null;
  },

  /** 创建自动化 */
  create: async (_data: any) => {
    return null;
  },

  /** 删除自动化 */
  delete: async (_id: SnowflakeId) => {
    return null;
  },
};
