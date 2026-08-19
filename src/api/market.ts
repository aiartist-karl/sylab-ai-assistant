/**
 * 市场模块
 * 全部使用 WebAPI (Session): /api/marketplace/*
 */
import { webApiClient } from './client';
import { API_PATHS } from '../constants';
import type { SnowflakeId } from '../types/api';

export const marketApi = {
  /** 分类列表 */
  categories: () =>
    webApiClient.get(API_PATHS.MARKET_CATEGORIES).then((r) => {
      const data = r.data?.data || r.data;
      return data.categories || data.items || [];
    }),

  /** 搜索 Agent/产品 */
  search: (params?: { keyword?: string; category?: string; page?: number; page_size?: number }) =>
    webApiClient.get(API_PATHS.MARKET_SEARCH, { params }).then((r) => {
      const data = r.data?.data || r.data;
      return {
        items: data.product_list || data.items || [],
        total: data.total || 0,
      };
    }),

  /** 产品详情 */
  productDetail: (productId: SnowflakeId) =>
    webApiClient
      .get(API_PATHS.MARKET_PRODUCT, { params: { product_id: productId } })
      .then((r) => r.data?.data || r.data),
};
