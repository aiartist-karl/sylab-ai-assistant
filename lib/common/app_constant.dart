class AppConstant {
  // 三套AI对话接口【商用降级备份】
  static const String primaryBaseUrl = "https://open.bigmodel.cn/api/paas/v4";
  static const String spare1BaseUrl = "https://api.deepseek.com/v1";
  static const String spare2BaseUrl = "https://dashscope.aliyuncs.com/compatible-mode/v1";

  static String primaryApiKey = "替换智谱GLM密钥";
  static String spare1ApiKey = "替换DeepSeek密钥";
  static String spare2ApiKey = "替换通义千问密钥";

  static const String mainModel = "glm-4-flash";
  static const String spare1Model = "deepseek-chat";
  static const String spare2Model = "qwen-turbo";

  // 【核心修复】硅基流动图文视频专属接口（独立域名+密钥，不与对话接口冲突）
  static const String sfBaseUrl = "https://api.siliconflow.cn/v1";
  static String sfApiKey = "替换硅基流动密钥";

  // 限流风控配置
  static const int maxRequestPerMinute = 20;
  static const int globalConcurrentMax = 25;

  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(seconds: 90);

  // 本地缓存目录
  static const String folderChatCache = "chat_cache";
  static const String folderOffice = "office_file";
  static const String folderLog = "app_log";
  static const String folderMediaCache = "media_cache";
}
