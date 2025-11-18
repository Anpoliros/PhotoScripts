# 快速开始指南

## 🚀 使用 Script Hub (推荐)

Script Hub 是一个现代化的 macOS 应用，让你通过图形界面轻松使用所有脚本。

### 方法 1: 直接运行（最简单）

如果你的系统已经安装了 Swift 工具链：

```bash
cd ScriptHub
./build.sh
./.build/release/ScriptHub
```

### 方法 2: 使用 Xcode（推荐开发者）

1. 打开终端，进入项目目录
2. 运行以下命令：

```bash
cd ScriptHub
open Package.swift
```

3. Xcode 会自动打开项目
4. 点击运行按钮 (▶️) 或按 `⌘R`

### 方法 3: 构建独立应用

在 Xcode 中：
1. 选择 `Product > Archive`
2. 点击 `Distribute App`
3. 选择 `Copy App`
4. 将应用复制到 `Applications` 文件夹

## 📝 使用 Script Hub

1. **启动应用** - 从左侧列表可以看到所有可用的脚本
2. **选择脚本** - 点击任意脚本查看详情
3. **配置参数** - 在右侧面板填写脚本参数
   - 点击文件夹图标可以方便地选择目录
   - 所有必填参数都标有红色 `*`
4. **运行** - 点击"运行脚本"按钮
5. **查看输出** - 在输出面板实时查看执行结果

## 🔧 命令行使用

如果你更喜欢命令行，这里是快速参考：

### File Grouper - 文件分组
```bash
java -cp out/production/Scripts FileGrouper 200 true ./Photos
```

### Date Modifier - 修改日期
```bash
java -cp out/production/Scripts DateModifier "*" true ./Photos
```

### Batch Zip - 批量压缩
```bash
java -cp out/production/Scripts BatchZip /usr/local/bin/7z ./Photos
```

### PNG to JPEG - 格式转换
```bash
java -cp out/production/Scripts PngToJpegConverter reserve cascade ./Photos
```

### Wallpaper Picker - 壁纸筛选
```bash
java -cp out/production/Scripts WallpaperPicker reserve cascade ./output ./Photos
```

## ❓ 常见问题

### Q: Script Hub 启动后没有显示脚本？
**A:** 确保 `scripts_config.json` 文件在项目根目录。应用会自动查找这个配置文件。

### Q: 编译失败？
**A:** 确保系统已安装：
- Java JDK 18 或更高版本
- Swift 5.9 或更高版本（macOS 13+ 自带）

检查 Java 版本：
```bash
java -version
javac -version
```

### Q: 脚本执行失败？
**A:** 检查：
1. 所有必填参数是否已填写
2. 路径是否正确（可以拖拽文件夹到路径输入框）
3. 查看输出面板的错误信息

### Q: 如何添加新的脚本？
**A:**
1. 在 `src/` 目录添加新的 `.java` 文件
2. 在 `scripts_config.json` 中添加脚本配置
3. 重启 Script Hub 或点击刷新按钮

## 💡 提示

- **自动编译**: Script Hub 会在首次运行脚本时自动编译 Java 代码
- **路径选择**: 使用文件夹图标按钮，不需要手动输入路径
- **实时输出**: 脚本运行时可以实时看到输出信息
- **错误提示**: 如果有错误，会在输出面板用红色显示

## 📚 更多信息

- [完整文档](README.md)
- [Script Hub 详细说明](ScriptHub/README.md)
- [原始中文说明](readme.txt)

## 🎯 示例工作流

### 整理照片库
1. 打开 Script Hub
2. 选择 "Date Modifier" - 统一修改日期和创建日期
3. 选择 "File Grouper" - 将照片按 200 张一组分组
4. 选择 "Batch Zip" - 批量压缩每组照片

### 制作壁纸集合
1. 打开 Script Hub
2. 选择 "Wallpaper Picker (Metadata)"
3. 选择包含图片的目录
4. 设置输出目录
5. 运行脚本，所有横向图片会被筛选出来

---

**享受使用 Script Hub！** 🎉
