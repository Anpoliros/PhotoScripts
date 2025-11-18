# Script Hub - macOS 脚本管理工具

一个 macOS 原生应用，用于管理和运行 PhotoScripts 项目中的所有脚本。

## 功能特性

- 🎯 **自动脚本识别** - 自动扫描和加载项目中的 Java 脚本
- 🖥️ **现代 GUI 界面** - 使用 SwiftUI 构建的原生 macOS 界面
- ⚙️ **动态参数配置** - 根据脚本类型自动生成参数输入界面
- 📁 **文件/目录选择器** - 方便的文件和目录选择对话框
- 📊 **实时输出显示** - 实时查看脚本执行输出和错误信息
- 🔍 **脚本搜索** - 快速搜索和筛选脚本

## 系统要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本
- Java JDK 18 或更高版本

## 安装和运行

### 方法一：使用 Xcode

1. 打开 Xcode
2. 选择 "Open Existing Project"
3. 导航到 `ScriptHub` 目录并选择 `Package.swift`
4. 点击运行按钮 (⌘R)

### 方法二：命令行构建

```bash
cd ScriptHub
swift build -c release
.build/release/ScriptHub
```

### 方法三:使用 Xcode 构建应用程序包

1. 在 Xcode 中打开项目
2. 选择 Product > Archive
3. 导出应用程序到 Applications 文件夹

## 项目结构

```
PhotoScripts/
├── ScriptHub/                  # macOS 应用源代码
│   ├── ScriptHub/
│   │   ├── ScriptHubApp.swift      # 应用入口
│   │   ├── ContentView.swift       # 主视图
│   │   ├── ScriptDetailView.swift  # 脚本详情视图
│   │   ├── Models.swift            # 数据模型
│   │   ├── ConfigLoader.swift      # 配置加载器
│   │   └── ScriptExecutor.swift    # 脚本执行引擎
│   ├── Package.swift           # Swift Package 配置
│   └── README.md              # 本文档
├── scripts_config.json        # 脚本配置文件
└── src/                       # Java 脚本源代码
```

## 配置说明

脚本配置文件 `scripts_config.json` 定义了所有可用的脚本及其参数。格式如下：

```json
{
  "scripts": [
    {
      "id": "unique-id",
      "name": "脚本名称",
      "description": "脚本描述",
      "type": "java",
      "scriptPath": "src/ScriptName.java",
      "className": "ScriptName",
      "icon": "sf-symbol-name",
      "parameters": [
        {
          "name": "param_name",
          "label": "参数标签",
          "type": "text|integer|boolean|choice|directory|file",
          "required": true,
          "defaultValue": "默认值",
          "description": "参数描述",
          "options": ["option1", "option2"]
        }
      ],
      "warnings": ["警告信息"]
    }
  ]
}
```

### 支持的参数类型

- `text` - 文本输入
- `integer` - 整数输入
- `boolean` - 开关切换
- `choice` - 选项选择（需要提供 options）
- `directory` - 目录选择器
- `file` - 文件选择器

## 已支持的脚本

1. **File Grouper** - 将文件按指定大小分组
2. **Date Modifier** - 修改文件日期为创建日期
3. **Batch Zip** - 批量压缩子目录
4. **PNG to JPEG Converter** - PNG 转 JPEG 格式
5. **Wallpaper Picker** - 选择横向图片作为壁纸
6. **Wallpaper Picker (Metadata)** - 使用 EXIF 元数据选择壁纸

## 扩展支持其他脚本类型

要添加对 Python 或其他类型脚本的支持：

1. 在 `scripts_config.json` 中添加脚本配置，设置 `type` 为相应类型
2. 在 `ScriptExecutor.swift` 中添加新的执行方法（参考 `executeJavaScript`）
3. 更新执行逻辑以支持新的脚本类型

## 使用示例

1. 启动应用
2. 从左侧列表选择要运行的脚本
3. 在右侧配置脚本参数
4. 点击"运行脚本"按钮
5. 在输出面板查看执行结果

## 开发说明

### 添加新脚本

1. 在 `src/` 目录添加新的 Java 脚本
2. 在 `scripts_config.json` 中添加脚本配置
3. 重启应用或点击刷新按钮

### 自定义界面

所有 UI 组件都在 SwiftUI 视图文件中定义，可以轻松自定义：

- `ContentView.swift` - 主界面布局
- `ScriptDetailView.swift` - 脚本详情和参数输入
- `Models.swift` - 数据模型定义

## 故障排除

### 脚本未显示

- 确保 `scripts_config.json` 在正确的位置
- 检查 JSON 格式是否正确
- 查看控制台输出的错误信息

### Java 编译失败

- 确保已安装 Java JDK 18+
- 检查 `JAVA_HOME` 环境变量
- 验证脚本路径和类名是否正确

### 权限错误

- macOS 可能需要授予应用文件访问权限
- 在系统偏好设置 > 安全性与隐私 中检查权限

## 许可证

与 PhotoScripts 项目相同

## 贡献

欢迎提交问题报告和功能请求！
