# PianoEase 项目规范

## 项目结构规范

本项目遵循以下标准目录结构，后续所有产品项目均可参考：

```
project-root/
├── .agents/AGENTS.md          # 项目规范（本文件）
├── doc/                       # 产品与技术文档
│   ├── 01_*.md               # 产品类文档（PRD、调研、定位等）
│   ├── 02_*.md               # 技术类文档（架构设计、技术方案等）
│   └── ...                   # 按编号顺序组织
└── <source>/                  # 源代码目录
```

## 文档管理规范

### 文档编号规则
- `01` ~ `09`：产品文档（市场调研、产品定位、需求文档等）
- `10` ~ `19`：技术文档（技术方案、架构设计等）
- `20` ~ `29`：过程文档（code review、会议记录等）
- 编号不要求连续，预留扩展空间

### 产品文档 vs 技术文档的区分原则
- **产品文档**回答 "做什么" 和 "为什么做"：
  - 用户故事、使用场景、交互流程
  - 功能清单、优先级、验收标准
  - 成功指标、商业价值
  - 不包含具体技术实现细节
- **技术文档**回答 "怎么做"：
  - 架构设计、技术选型
  - 数据模型、接口定义
  - 文件结构、模块划分
  - 实施计划、验证方案

### 文档格式要求
- 使用 Markdown 格式
- 文档头部包含：版本号、日期、状态、作者
- 状态标记：草稿 → 评审中 → 已确认 → 已归档
- 重要决策用 `> **决策**：` 引用块标注

## iOS 项目代码规范

### 目录结构
```
AppName/
├── AppNameApp.swift           # App 入口
├── ContentView.swift          # 根视图
├── Models/                    # 数据模型（纯值类型为主）
├── Services/                  # 基础服务（MIDI、网络、解析等）
├── Engine/                    # 业务引擎（核心逻辑）
├── Views/                     # UI 视图
│   ├── FeatureA/             # 按功能模块分组
│   └── FeatureB/
├── Store/                     # 数据存储（SwiftData/API）
├── Theme/                     # 设计系统
└── Resources/                 # 静态资源
```

### 命名规范
- Swift 文件：PascalCase（`SongListView.swift`）
- 视图文件以 `View` 结尾
- 服务文件以 `Manager`、`Parser`、`Catalog` 等描述角色结尾
- 数据模型文件以 `Model` 结尾（仅 SwiftData 持久化模型）
- 值类型模型不加 `Model` 后缀

### 架构原则
- UI 层（Views）→ Domain 层（Engine）→ Infrastructure 层（Services/Store）
- 依赖方向：上层依赖下层，下层不依赖上层
- 使用协议（Protocol）解耦，便于测试和替换实现
- `@Observable` 用于需要 UI 响应的服务和引擎
- SwiftData `@Model` 仅用于持久化模型，业务逻辑使用值类型

### 对齐 Web 版原则
- 数据模型字段名、类型尽量与 Web 版 TypeScript 定义一致
- 业务逻辑（判定规则、评分算法等）必须与 Web 版保持行为一致
- chart JSON 格式完全复用 Web 版，不做格式转换
