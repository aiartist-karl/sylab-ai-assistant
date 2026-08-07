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

  // P0修复：API密钥有效性校验，封堵使用占位符密钥的无认证请求
  // 占位符前缀列表——所有未替换的默认密钥均以此开头
  static const List<String> _placeholderPrefixes = ["替换"];

  /// 校验单个API密钥是否已正确配置（非空、非占位符）
  static bool isValidApiKey(String key) {
    if (key.isEmpty) return false;
    for (final prefix in _placeholderPrefixes) {
      if (key.startsWith(prefix)) return false;
    }
    return true;
  }

  /// 校验对话接口链路是否至少有一组可用密钥
  /// 返回第一个可用的密钥对应的节点标识，全部不可用则返回null
  static String? getAvailableChatNode() {
    if (isValidApiKey(primaryApiKey)) return "primary";
    if (isValidApiKey(spare1ApiKey)) return "spare1";
    if (isValidApiKey(spare2ApiKey)) return "spare2";
    return null;
  }

  /// 校验硅基流动接口密钥是否可用
  static bool isSfKeyValid() => isValidApiKey(sfApiKey);
}
