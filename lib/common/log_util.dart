class LogUtil {
  static void i(String tag, String msg) {
    print('[$tag] $msg');
  }
  static void w(String tag, String msg) {
    print('[$tag WARN] $msg');
  }
  static void e(String tag, String msg) {
    print('[$tag ERROR] $msg');
  }
}
