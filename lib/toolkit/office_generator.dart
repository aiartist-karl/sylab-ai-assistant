import 'dart:io';
import 'package:docx_creator/docx_creator.dart';
import 'package:path_provider/path_provider.dart';
import '../common/app_constant.dart';
import '../common/log_util.dart';
import '../core/agent_engine.dart';

class OfficeGenerator {
  // 【完全修复】官方真实API生成标准Word文档
  static Future<String?> generateWord(String title, String content) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String filePath = "${dir.path}/${AppConstant.folderOffice}/$title.docx";
      final file = File(filePath);
      if (!await file.parent.exists()) await file.parent.create(recursive: true);

      // AI优化文档内容
      final messages = [
        {"role": "system", "content": "优化办公文档内容，排版规整、语句通顺、适合正式文档输出"},
        {"role": "user", "content": content}
      ];
      final res = await AgentEngine.chatNormal(messages);
      final String finalContent = res["choices"][0]["message"]["content"];

      // 修复：1.1.2官方标准Fluent Builder语法（无虚构API）
      final doc = docx()
          .h1(title)
          .p(finalContent);

      // 修复：官方正确导出方法
      await DocxExporter().exportToFile(doc.build(), filePath);

      LogUtil.i("文档生成", "标准无乱码Word文档生成成功：$filePath");
      return filePath;
    } catch (e) {
      LogUtil.e("文档生成", "生成失败：$e");
      return null;
    }
  }
}
