#!/usr/bin/env python3
"""
sylab 文件清理脚本 - 删除超过 7 天的过期文件
可独立运行: python3 /root/sylab-app/cleanup_old_files.py
"""

import os
import time
from pathlib import Path
from datetime import datetime

BASE_DIR = Path("/root/sylab-app-data/project-files")
MAX_AGE_SECONDS = 7 * 24 * 3600  # 7 days

def cleanup():
    if not BASE_DIR.exists():
        print(f"[{datetime.now()}] BASE_DIR does not exist: {BASE_DIR}")
        return

    now = time.time()
    deleted_files = 0
    freed_space = 0
    deleted_dirs = 0

    for conv_dir in sorted(BASE_DIR.iterdir()):
        if not conv_dir.is_dir():
            continue

        for f in sorted(conv_dir.iterdir()):
            if not f.is_file():
                continue
            mtime = f.stat().st_mtime
            age = now - mtime
            if age > MAX_AGE_SECONDS:
                size = f.stat().st_size
                try:
                    f.unlink()
                    deleted_files += 1
                    freed_space += size
                    print(f"[{datetime.now()}] Deleted: {f} ({size} bytes, age={age/3600:.1f}h)")
                except Exception as e:
                    print(f"[{datetime.now()}] Failed to delete {f}: {e}")

        # Remove empty conversation directory
        try:
            if conv_dir.exists() and not any(conv_dir.iterdir()):
                conv_dir.rmdir()
                deleted_dirs += 1
                print(f"[{datetime.now()}] Removed empty dir: {conv_dir}")
        except Exception as e:
            print(f"[{datetime.now()}] Failed to remove dir {conv_dir}: {e}")

    print(f"[{datetime.now()}] Cleanup complete: deleted {deleted_files} files, "
          f"freed {freed_space} bytes ({freed_space/1024/1024:.2f} MB), "
          f"removed {deleted_dirs} empty dirs")

if __name__ == "__main__":
    cleanup()
