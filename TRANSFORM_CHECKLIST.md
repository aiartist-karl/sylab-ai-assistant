# Sylab APP 改造任务清单

> 基座: Expo/RN (第2/3套), 工作目录: `/app/data/所有对话/主对话/sylab-app-transform/`
> 目标服务器: 36.137.84.216:9091

## 第一阶段: 基础设施改造

| # | 任务 | 文件 | 状态 |
|---|------|------|------|
| 1 | 品牌替换 | app.json, package.json, login.tsx, theme.ts, constants/index.ts | ⏳ |
| 2 | 环境变量配置 | .env, .env.example, client.ts | ⏳ |
| 3 | API路径全面重写 | constants/index.ts | ⏳ |
| 4 | 认证API对接 | api/auth.ts (映射到真实后端端点) | ⏳ |
| 5 | SSE流式聊天修正 | api/sse.ts (映射到/v3/chat) | ⏳ |

## 第二阶段: 业务模块API重写

| # | 任务 | 文件 | 状态 |
|---|------|------|------|
| 6 | 聊天模块重写 | api/chat.ts → 用OpenAPI端点 | ⏳ |
| 7 | Bot模块重写 | api/bot.ts → 用OpenAPI+WebAPI混合 | ⏳ |
| 8 | 知识库模块重写 | api/knowledge.ts → 用WebAPI真实端点 | ⏳ |
| 9 | 工作流模块重写 | api/workflow.ts → 用WebAPI真实端点 | ⏳ |
| 10 | 记忆模块重写 | api/memory.ts → 用WebAPI真实端点 | ⏳ |
| 11 | 插件模块重写 | api/plugin.ts → 用WebAPI真实端点 | ⏳ |
| 12 | 市场模块重写 | api/market.ts → 用WebAPI marketplace端点 | ⏳ |
| 13 | 项目/自动化模块标记 | api/project.ts, api/automation.ts → 标记为扩展 | ⏳ |

## 第三阶段: 新增模块

| # | 任务 | 文件 | 状态 |
|---|------|------|------|
| 14 | 积分系统API | api/credits.ts (新增) | ⏳ |
| 15 | 积分Store | store/credits.ts (新增) | ⏳ |
| 16 | 积分页面 | app/(tabs)/credits.tsx (新增) | ⏳ |
| 17 | 类型定义补全 | types/api.ts (补积分相关类型) | ⏳ |
| 18 | 导出更新 | api/index.ts (导出积分模块) | ⏳ |

## 第四阶段: 页面与UI优化

| # | 任务 | 文件 | 状态 |
|---|------|------|------|
| 19 | 登录页品牌替换 | app/login.tsx | ⏳ |
| 20 | 聊天页API对接修正 | app/chat/[id].tsx | ⏳ |
| 21 | 对话列表API对接修正 | app/(tabs)/chat.tsx | ⏳ |
| 22 | Agent列表API对接修正 | app/(tabs)/agents.tsx | ⏳ |
| 23 | 个人中心积分入口 | app/(tabs)/profile.tsx | ⏳ |
| 24 | Tab导航调整 | app/(tabs)/_layout.tsx | ⏳ |
| 25 | 路由根布局修正 | app/_layout.tsx | ⏳ |

## 后端API路径映射表 (核心参考)

### 认证 (Session Cookie)
- 登录: POST `/api/passport/web/email/login/`
- 注册: POST `/api/passport/web/email/register/v2/`
- 登出: GET `/api/passport/web/logout/`
- 账户信息: POST `/api/passport/account/info/v2/`

### OpenAPI (Bearer PAT)
- 聊天: POST `/v3/chat` (stream=true SSE)
- 会话列表: GET `/v1/conversations?bot_id=xxx`
- 创建会话: POST `/v1/conversation/create`
- 会话详情: GET `/v1/conversation/retrieve?conversation_id=xxx`
- 消息列表: POST `/v1/conversation/message/list`
- Bot详情: GET `/v1/bots/:bot_id`
- 知识库: GET `/v1/datasets`
- 工作流运行: POST `/v1/workflow/run`
- 文件上传: POST `/v1/files/upload`

### 积分服务 (user_id header)
- 余额: POST `/token-api/api/balance`
- 消费记录: GET `/token-api/api/transactions?user_id=xxx`
- 价格表: GET `/token-api/api/pricing`
- 动作价格: GET `/token-api/api/action/pricing`
- 卡密兑换: POST `/token-api/api/card/redeem`
- 充值: POST `/token-api/api/recharge`
