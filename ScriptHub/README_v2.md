# Script Hub v2.0 - 通用脚本管理和自动化平台

Script Hub 是一个现代化的 macOS 原生应用，提供了完整的脚本管理、组织和自动化解决方案。受 Apple Automator 启发，但更加通用、开放和强大。

## ✨ 主要特性

### 🎯 智能脚本管理
- **自动识别** - 自动分析 Java、Python、Shell 脚本的入口点和参数
- **GUI 导入** - 通过图形界面轻松导入脚本文件或扫描整个目录
- **脚本编辑** - 可视化编辑脚本元数据、参数和配置
- **复制和模板** - 快速复制脚本创建变体

### 📁 脚本分组
- **自定义分组** - 创建自定义分组来组织脚本
- **拖拽管理** - 通过拖拽轻松将脚本添加到分组
- **彩色图标** - 为每个分组设置独特的图标和颜色
- **智能过滤** - 按分组查看和过滤脚本

### 🔄 可视化工作流
- **流程图编辑器** - 类似 Automator 的可视化工作流编辑器
- **拖拽式设计** - 通过拖拽节点创建复杂的脚本流程
- **数据传递** - 脚本之间可以传递输出数据
- **智能执行** - 自动检测依赖关系并按正确顺序执行
- **实时输出** - 查看每个节点的执行结果

### 💾 数据持久化
- **自动保存** - 所有配置自动保存到本地
- **导入导出** - 支持导入导出完整配置（JSON格式）
- **版本管理** - 工作流支持复制和版本管理

### 🚀 多语言支持
- ✅ Java 脚本（自动编译）
- ✅ Python 脚本（支持 argparse）
- ✅ Shell 脚本（bash/sh）
- 🔄 可扩展支持更多语言

## 📦 安装

### 系统要求
- macOS 13.0+ (Ventura 或更高)
- Xcode 15.0+ 或 Swift 5.9+
- Java JDK 18+ (用于 Java 脚本)
- Python 3.x (用于 Python 脚本)

### 构建方式

#### 1. 命令行构建
```bash
cd ScriptHub
./build.sh
./.build/release/ScriptHub
```

#### 2. Xcode 构建
```bash
cd ScriptHub
open Package.swift
# 在 Xcode 中按 ⌘R 运行
```

#### 3. 构建应用包
在 Xcode 中：
1. Product → Archive
2. Distribute App → Copy App
3. 复制到 Applications 文件夹

## 🎓 使用指南

### 入门

#### 1. 导入脚本

**方式一：扫描目录**
1. 点击"管理"标签
2. 点击 + 按钮 → "扫描目录"
3. 选择包含脚本的文件夹
4. Script Hub 会自动识别所有支持的脚本

**方式二：导入单个文件**
1. 点击"管理"标签
2. 点击 + 按钮 → "导入脚本文件"
3. 选择一个或多个脚本文件
4. 查看识别结果并导入

**支持的自动识别：**
- Java: 识别 main 方法、命令行参数、类名
- Python: 识别 argparse 参数、sys.argv、docstring
- Shell: 识别位置参数 ($1, $2, ...)、注释说明

#### 2. 组织脚本

**创建分组：**
1. 在"脚本"标签的左侧栏点击 +
2. 输入分组名称
3. 选择图标和颜色
4. 创建

**添加脚本到分组：**
- 右键点击脚本 → "添加到分组"
- 选择目标分组

#### 3. 运行脚本

1. 在"脚本"标签选择一个脚本
2. 在右侧填写参数（支持文件/目录选择器）
3. 点击"运行脚本"
4. 查看实时输出

### 工作流

#### 创建工作流

1. 切换到"工作流"标签
2. 点击 + 创建新工作流
3. 输入工作流名称和描述

#### 添加节点

1. 点击画布上的 + 按钮
2. 从列表中选择要添加的脚本
3. 节点会出现在画布上

#### 连接节点

目前版本：手动配置参数映射
未来版本：支持可视化连线

#### 配置参数映射

对于每个节点，可以配置其参数来源：
- **常量值** - 固定的值
- **前置节点输出** - 使用前一个节点的输出
- **用户输入** - 运行时询问用户

#### 执行工作流

1. 点击"运行工作流"按钮
2. 观察节点执行顺序
3. 查看每个节点的输出
4. 如果某个节点失败，工作流会停止

### 示例工作流

#### 照片批处理流程

```
节点 1: Date Modifier
  ↓ (输出目录路径)
节点 2: PNG to JPEG Converter
  ↓ (输出目录路径)
节点 3: Wallpaper Picker
  ↓ (筛选后的图片目录)
节点 4: Batch Zip
```

这个工作流会：
1. 修正照片日期
2. 将 PNG 转换为 JPEG
3. 筛选出横向图片
4. 打包压缩

## 🛠️ 架构说明

### 核心组件

```
ScriptHub/
├── Models.swift                # 数据模型
├── DataStore.swift            # 数据持久化
├── ScriptScanner.swift        # 脚本自动识别
├── ScriptExecutor.swift       # 脚本执行引擎
├── WorkflowExecutor.swift     # 工作流执行引擎
├── NewContentView.swift       # 主界面
├── GroupedScriptsView.swift   # 分组脚本视图
├── ScriptManagementView.swift # 脚本管理界面
├── WorkflowEditorView.swift   # 工作流编辑器
└── ScriptDetailView.swift     # 脚本详情视图
```

### 数据模型

**Script** - 脚本定义
```swift
{
  id: String,
  name: String,
  description: String,
  type: "java" | "python" | "shell",
  scriptPath: String,
  className: String,
  icon: String,
  parameters: [Parameter],
  warnings: [String]?
}
```

**ScriptGroup** - 脚本分组
```swift
{
  id: String,
  name: String,
  icon: String,
  color: String,
  scriptIds: [String]
}
```

**Workflow** - 工作流
```swift
{
  id: String,
  name: String,
  description: String,
  nodes: [WorkflowNode],
  connections: [WorkflowConnection],
  createdAt: Date,
  modifiedAt: Date
}
```

**WorkflowNode** - 工作流节点
```swift
{
  id: String,
  scriptId: String,
  position: CGPoint,
  parameterMappings: [String: ParameterMapping]
}
```

### 脚本自动识别

Script Hub 使用正则表达式和模式匹配来分析脚本：

**Java 脚本：**
- 提取 `public class` 类名
- 检测 `public static void main` 方法
- 分析 `args[n]` 使用模式
- 提取 JavaDoc 注释
- 推断参数类型

**Python 脚本：**
- 解析 `argparse.ArgumentParser`
- 提取 `add_argument` 定义
- 识别参数类型和默认值
- 读取 docstring 作为描述
- 检测 `sys.argv` 使用

**Shell 脚本：**
- 检测 `$1`, `$2` 等位置参数
- 提取第一行注释作为描述
- 识别参数使用上下文

### 工作流执行流程

1. **拓扑排序** - 分析节点依赖关系，生成执行顺序
2. **循环检测** - 检测并拒绝执行包含循环的工作流
3. **参数解析** - 根据映射解析每个节点的参数值
4. **顺序执行** - 按拓扑顺序依次执行节点
5. **数据传递** - 将前置节点的输出传递给后续节点
6. **错误处理** - 节点失败时停止工作流

## 📝 最佳实践

### 脚本编写建议

**Java 脚本：**
```java
/**
 * 脚本描述
 */
public class MyScript {
    public static void main(String[] args) {
        // 建议添加参数说明注释
        String inputDir = args[0];  // 输入目录
        int count = Integer.parseInt(args[1]);  // 数量
        boolean recursive = Boolean.parseBoolean(args[2]);  // 是否递归

        // 脚本逻辑...
    }
}
```

**Python 脚本：**
```python
"""
脚本描述
"""
import argparse

def main():
    parser = argparse.ArgumentParser(description='脚本描述')
    parser.add_argument('--input', help='输入目录', required=True)
    parser.add_argument('--count', type=int, help='数量', default=100)
    parser.add_argument('--recursive', action='store_true', help='是否递归')

    args = parser.parse_args()
    # 脚本逻辑...

if __name__ == '__main__':
    main()
```

### 工作流设计建议

1. **单一职责** - 每个节点只做一件事
2. **清晰命名** - 为工作流和节点使用描述性名称
3. **错误处理** - 脚本应该返回有意义的退出码
4. **输出标准化** - 使用一致的输出格式便于传递
5. **幂等性** - 脚本应该可以安全地重复运行

## 🔮 未来计划

- [ ] 可视化节点连线（拖拽创建连接）
- [ ] 条件分支（if/else 逻辑）
- [ ] 循环执行（for/while 循环）
- [ ] 变量系统（工作流级别的变量）
- [ ] 脚本模板市场
- [ ] 远程脚本执行
- [ ] 定时任务调度
- [ ] Git 集成（脚本版本控制）
- [ ] 更多语言支持（Ruby, Go, Rust, etc.）
- [ ] 脚本性能分析
- [ ] 日志系统

## 🤝 贡献

欢迎贡献代码、报告问题或提出功能建议！

### 添加新语言支持

在 `ScriptScanner.swift` 中添加：

```swift
case "rb":  // Ruby
    return analyzeRubyScript(at: path)
```

在 `WorkflowExecutor.swift` 中添加执行逻辑：

```swift
case "ruby":
    executeRubyScriptSync(script: script, parameters: parameters) { ... }
```

## 📄 许可证

与 PhotoScripts 项目相同

## 🙏 致谢

- 灵感来自 Apple Automator
- 使用 SwiftUI 构建现代化界面
- 感谢所有贡献者

---

**Script Hub - 让脚本管理更简单，让自动化更强大！** 🚀
