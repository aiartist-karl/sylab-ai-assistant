/**
 * 知识库模块
 * 全部使用 WebAPI (Session): /api/knowledge/*
 */
import { webApiClient } from './client';
import { API_PATHS } from '../constants';
import type { SnowflakeId } from '../types/api';

const SPACE_ID = '1';

export const knowledgeApi = {
  /** 知识库列表 */
  list: (params?: { page?: number; page_size?: number }) =>
    webApiClient.post(API_PATHS.KNOWLEDGE_LIST, {
      space_id: SPACE_ID,
      page_size: params?.page_size || 20,
      page_num: params?.page || 1,
    }).then((r) => {
      const data = r.data?.data || r.data;
      return {
        items: data.dataset_list || data.knowledge_list || data.items || [],
        total: data.total_count || data.total || 0,
      };
    }),

  /** 创建知识库 */
  create: (data: { name: string; description?: string }) =>
    webApiClient.post(API_PATHS.KNOWLEDGE_CREATE, { space_id: SPACE_ID, ...data }).then((r) => r.data?.data || r.data),

  /** 知识库详情 (GET + query param) */
  get: (id: SnowflakeId) =>
    webApiClient.get(API_PATHS.KNOWLEDGE_DETAIL(id)).then((r) => r.data?.data || r.data),

  /** 删除知识库 */
  delete: (id: SnowflakeId) =>
    webApiClient.post(API_PATHS.KNOWLEDGE_DELETE, { knowledge_id: id }).then((r) => r.data),

  /** 更新知识库 */
  update: (id: SnowflakeId, data: { name?: string; description?: string }) =>
    webApiClient.post(API_PATHS.KNOWLEDGE_UPDATE, { knowledge_id: id, ...data }).then((r) => r.data?.data || r.data),

  // ────────────── 文档 ──────────────

  /** 文档列表 */
  documents: (knowledgeId: SnowflakeId) =>
    webApiClient
      .post(API_PATHS.KNOWLEDGE_DOCUMENT_LIST, { knowledge_id: knowledgeId })
      .then((r) => {
        const data = r.data?.data || r.data;
        return data.document_list || data.items || [];
      }),

  /** 上传/创建文档 */
  uploadDocument: (
    knowledgeId: SnowflakeId,
    data: { document_name: string; source_type: string; content?: string; file_url?: string },
  ) =>
    webApiClient
      .post(API_PATHS.KNOWLEDGE_DOCUMENT_CREATE, { knowledge_id: knowledgeId, ...data })
      .then((r) => r.data?.data || r.data),

  /** 删除文档 */
  deleteDocument: (knowledgeId: SnowflakeId, documentId: SnowflakeId) =>
    webApiClient
      .post(API_PATHS.KNOWLEDGE_DOCUMENT_DELETE, {
        knowledge_id: knowledgeId,
        document_id: documentId,
      })
      .then((r) => r.data),

  /** 文档处理进度 */
  documentProgress: (knowledgeId: SnowflakeId, documentId: SnowflakeId) =>
    webApiClient
      .post(API_PATHS.KNOWLEDGE_DOCUMENT_PROGRESS, {
        knowledge_id: knowledgeId,
        document_id: documentId,
      })
      .then((r) => r.data?.data || r.data),
};
