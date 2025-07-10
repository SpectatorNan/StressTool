# StressTool

一个使用 SwiftUI 和 AsyncHTTPClient 构建的现代 HTTP 压力测试工具，专为 macOS 设计。

## 功能特性

- 🚀 **高并发支持**：支持 1-10,000 并发连接
- 📊 **实时监控**：实时显示请求统计和响应时间
- 🎯 **多种请求方式**：支持 GET 和 POST 请求
- 📈 **性能指标**：实时计算平均响应时间、成功率等关键指标
- 💾 **持久化存储**：使用 SwiftData 保存测试日志
- ⚡ **高性能架构**：使用 AsyncHTTPClient 和并发优化，避免 UI 卡顿
- 🎨 **现代 UI**：使用 SwiftUI 构建的直观用户界面

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9 或更高版本

## 技术栈

- **框架**：SwiftUI
- **HTTP 客户端**：AsyncHTTPClient
- **数据存储**：SwiftData
- **并发处理**：Swift Concurrency (async/await)
- **网络层**：NIO (Network Input/Output)

## 安装

1. 克隆仓库：
```bash
git clone <repository-url>
cd StressTool
```

2. 使用 Xcode 打开项目：
```bash
open StressTool.xcodeproj
```

3. 构建并运行项目（⌘+R）

## 使用方法

### 基本使用

1. **输入目标 URL**：在 "请求地址" 字段输入要测试的 HTTP 端点
2. **设置并发数**：在 "并发数" 字段输入并发连接数（1-10,000）
3. **选择请求方法**：
   - GET：用于简单的 HTTP GET 请求
   - POST：用于发送 JSON 数据的 POST 请求
4. **配置请求体**（仅 POST）：在请求体字段输入 JSON 格式的数据
5. **开始测试**：点击 "开始测试" 按钮
6. **查看结果**：实时监控指标面板和请求日志

### 示例配置

#### GET 请求测试
```
URL: https://httpbin.org/get
并发数: 10
方法: GET
```

#### POST 请求测试
```
URL: https://httpbin.org/post
并发数: 50
方法: POST
请求体: {"test": "data", "timestamp": "2025-07-10"}
```

### 性能指标说明

- **总请求**：发送的请求总数
- **成功**：HTTP 状态码为 2xx 的请求数
- **失败**：网络错误或非 2xx 状态码的请求数
- **平均耗时**：所有完成请求的平均响应时间（秒）
- **总耗时**：从开始测试到结束的总时间（秒）

## 架构设计

### 核心组件

1. **ConcurrencyTester**：主要的压力测试引擎
   - 使用 Swift Concurrency 实现高并发
   - 批量日志更新避免 UI 卡顿
   - 增量平均值计算优化性能

2. **DashboardView**：实时性能指标显示面板
3. **RequestRow**：单个请求日志的显示组件
4. **Models**：数据模型层
   - `Metrics`：性能指标数据结构
   - `RequestLog`：请求日志数据结构
   - `PersistentLog`：持久化日志模型

### 性能优化

- **批量 UI 更新**：使用定时器进行批量日志刷新，减少 UI 更新频率
- **增量计算**：平均响应时间使用增量算法，避免重复计算
- **内存管理**：合理的任务生命周期管理，防止内存泄漏
- **并发控制**：使用 TaskGroup 管理并发任务

## 开发指南

### 项目结构

```
StressTool/
├── StressToolApp.swift          # 应用入口
├── ContentView.swift            # 主界面
├── ViewModel/
│   └── ConcurrencyTester.swift  # 压力测试核心逻辑
├── Views/
│   ├── DashboardView.swift      # 性能指标面板
│   └── RequestRow.swift         # 请求日志行
├── Model/
│   ├── Metrics.swift            # 性能指标模型
│   ├── RequestLog.swift         # 请求日志模型
│   ├── RequestStatus.swift      # 请求状态枚举
│   └── PersistentLog.swift      # 持久化日志模型
└── Assets.xcassets/             # 应用资源
```

### 扩展功能

如需添加新功能，可以考虑以下扩展点：

1. **新的 HTTP 方法**：在 `ConcurrencyTester` 中添加 PUT、DELETE 等方法支持
2. **自定义请求头**：扩展 UI 支持自定义 HTTP 头
3. **结果导出**：添加测试结果导出为 CSV/JSON 功能
4. **图表显示**：集成图表库显示性能趋势
5. **预设配置**：支持保存和加载测试配置

## 故障排除

### 常见问题

1. **连接超时**
   - 检查目标 URL 是否可访问
   - 确认网络连接正常
   - 降低并发数重试

2. **内存占用过高**
   - 减少并发连接数
   - 确保及时停止测试
   - 重启应用释放内存

3. **UI 响应缓慢**
   - 已通过批量更新和增量计算优化
   - 如仍有问题，可适当降低并发数

### 调试模式

在开发模式下，控制台会显示详细的 HTTP 响应头信息，帮助调试网络请求问题。

## 贡献

欢迎提交 Issue 和 Pull Request！

### 开发环境设置

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 创建 Pull Request

## 许可证

[MIT License](LICENSE)

## 作者

Created by spectator on 2025/7/10

---

⚠️ **免责声明**：本工具仅用于合法的性能测试目的。请勿用于攻击他人服务器或进行任何恶意活动。使用本工具测试第三方服务时，请确保获得适当的授权。
