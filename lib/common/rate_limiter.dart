class RateLimiter {
  static Future<T> limitRun<T>(Future<T> Function() task) async {
    // 简化实现：直接执行，后续可加入令牌桶限流
    return await task();
  }
}
