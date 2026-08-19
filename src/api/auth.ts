import { noAuthClient, webApiClient } from './client';
import { API_PATHS } from '../constants';
import type { LoginRequest, RegisterRequest, LoginResponse, UserInfo, ApiResponse } from '../types/api';

export const authApi = {
  // 邮箱密码登录 → POST /api/passport/web/email/login/
  login: async (account: string, password: string) => {
    const resp = await noAuthClient.post(API_PATHS.LOGIN, {
      email: account,
      password: password,
    });
    // 后端返回格式: { code: 0, data: { session_key, user_id, ... } }
    // 需要从 cookie 中提取 session_key
    return resp.data;
  },

  // 邮箱注册 → POST /api/passport/web/email/register/v2/
  register: async (account: string, password: string, code?: string) => {
    const resp = await noAuthClient.post(API_PATHS.REGISTER, {
      email: account,
      password: password,
      code: code || '',
    });
    return resp.data;
  },

  // 登出 → GET /api/passport/web/logout/
  logout: () => webApiClient.get(API_PATHS.LOGOUT).then(r => r.data),

  // 获取账户信息 → POST /api/passport/account/info/v2/
  getMe: () => webApiClient.post<ApiResponse<UserInfo>>(API_PATHS.ME, {}).then(r => r.data),

  // 更新用户资料
  updateProfile: (data: Partial<{ name: string }>) =>
    webApiClient.post(API_PATHS.USER_UPDATE_PROFILE, data).then(r => r.data),

  // 发送注册验证码
  sendVerificationCode: async (email: string) => {
    const resp = await noAuthClient.post(API_PATHS.VERIFICATION_SEND_CODE, { email });
    return resp.data;
  },

  // 验证注册验证码
  verifyCode: async (email: string, code: string) => {
    const resp = await noAuthClient.post(API_PATHS.VERIFICATION_VERIFY, { email, code });
    return resp.data;
  },

  // 重置密码（使用验证码）
  resetPassword: async (email: string, code: string, newPassword: string) => {
    const resp = await noAuthClient.post(API_PATHS.RESET_PASSWORD, {
      email,
      code,
      password: newPassword,
    });
    return resp.data;
  },
};
