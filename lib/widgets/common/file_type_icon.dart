// ============================================================================
// Coze Common Widgets - 文件类型图标系统
// 11种文件类型图标，直接从扣子APK资源映射
// ============================================================================

import 'package:flutter/material.dart';

/// 文件类型枚举
enum FileType {
  pdf, doc, excel, ppt, image, code, video, music, markdown, text, jsx, unknown;

  static FileType fromExtension(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf': return FileType.pdf;
      case 'doc': case 'docx': return FileType.doc;
      case 'xls': case 'xlsx': case 'csv': return FileType.excel;
      case 'ppt': case 'pptx': return FileType.ppt;
      case 'png': case 'jpg': case 'jpeg': case 'gif': case 'webp': case 'bmp': return FileType.image;
      case 'js': case 'ts': case 'dart': case 'py': case 'java': case 'cpp': case 'c': case 'h':
      case 'go': case 'rs': case 'rb': case 'php': case 'swift': case 'kt':
        return FileType.code;
      case 'mp4': case 'avi': case 'mov': case 'mkv': case 'wmv': case 'flv': return FileType.video;
      case 'mp3': case 'wav': case 'flac': case 'aac': case 'ogg': case 'wma': return FileType.music;
      case 'md': return FileType.markdown;
      case 'txt': case 'log': return FileType.text;
      case 'jsx': case 'tsx': return FileType.jsx;
      default: return FileType.unknown;
    }
  }
}

/// 文件类型图标组件
class FileTypeIcon extends StatelessWidget {
  final FileType type;
  final double size;
  final String? fileName;

  const FileTypeIcon({
    super.key,
    required this.type,
    this.size = 32,
    this.fileName,
  });

  factory FileTypeIcon.fromFileName({
    Key? key,
    required String fileName,
    double size = 32,
  }) {
    return FileTypeIcon(
      key: key,
      type: FileType.fromExtension(fileName.split('.').last),
      size: size,
      fileName: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  String get _assetPath {
    switch (type) {
      case FileType.pdf: return 'assets/images/coze/pdf.72bb2de1.png';
      case FileType.doc: return 'assets/images/coze/file-blank.fa9f5d9f.png';
      case FileType.excel: return 'assets/images/coze/excel.266d6fa9.png';
      case FileType.ppt: return 'assets/images/coze/ppt.1f2c8d58.png';
      case FileType.image: return 'assets/images/coze/img.b5ad5d54.png';
      case FileType.code: return 'assets/images/coze/code.40929ba1.png';
      case FileType.video: return 'assets/images/coze/video.e676794b.png';
      case FileType.music: return 'assets/images/coze/music.13a28cc0.png';
      case FileType.markdown: return 'assets/images/coze/md.263f6273.png';
      case FileType.text: return 'assets/images/coze/txt.c8c9a93f.png';
      case FileType.jsx: return 'assets/images/coze/jsx.9290fbe3.png';
      case FileType.unknown: return 'assets/images/coze/unknow.fd9d17b0.png';
    }
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF0FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.insert_drive_file,
        size: size * 0.6,
        color: const Color(0xFF8B8E99),
      ),
    );
  }
}
