class GlobalException {
  static Future<T> catchAsyncError<T>(Future<T> Function() task) async {
    try {
      return await task();
    } catch (e) {
      print('全局异常捕获：\$e');
      rethrow;
    }
  }
}
