# 轻琴 (PianoEase) — iPad 原生智能练琴 App

> 让每个人都能轻松弹完一首钢琴曲。针对初学者的 iPad 原生辅助练琴工具，支持 MIDI 键盘实时接入、瀑布流与简谱双模跟随、智能音准节奏判定及练习热力图分析。

---

## 🎹 项目简介

**轻琴 (PianoEase)** 是为 iPad 设计的原生智能练琴应用（Phase 1.5）。
解决移动端浏览器不支持 Web MIDI 的硬件痛点，直接通过 iPadOS 原生 **CoreMIDI** 框架驱动 USB 与蓝牙 MIDI 键盘，实现低延迟（< 20ms）高精度的弹奏捕捉与交互反馈。

结合**「左手简化曲谱」**教学体系与自适应练琴引擎，帮助零基础及初学者摆脱繁杂五线谱视奏门槛，轻松弹完完整乐曲。

---

## ✨ 核心特性

- **双模乐谱跟随**：
  - **瀑布流视效 (Waterfall Flow)**：基于 Apple 原生 **SpriteKit** 2D 游戏引擎构建，稳定提供 60fps 流畅下落动画与光效反馈。
  - **自绘简谱 (Jianpu View)**：基于 **SwiftUI Canvas** 自主绘制动态光标简谱，专为初学者优化视奏体验。
- **低延迟 MIDI 交互**：
  - 原生 **CoreMIDI** 支持，即插即用（USB-C / Lightning 转接）及低功耗蓝牙 (BLE MIDI) 无线连接。
  - 实时响应判定，延迟低于 20ms。
- **智能弹奏判定引擎**：
  - 音符判定（Perfect / Good / Miss / Wrong Note）与时机偏移量分析（Early / Late）。
  - 支持左右手分离练习与合手练习模式。
- **数据驱动练习报告**：
  - 练习结算评分、击键准度分布统计。
  - **小节热力图 (Measure Heatmap)**：直观标示失误集中区，精准定位薄弱小节。
- **离线离岛曲库**：
  - 预置 Chart v0 格式曲目资源（如《River Flows in You》、《天空之城》、《岁月神偷》等）。
  - 本地 **SwiftData** 持久化存储练习记录与历史数据。

---

## 🛠 技术架构与技术栈

| 模块 | 技术选型 | 说明 |
|---|---|---|
| **语言与 UI** | Swift 5.9+ / SwiftUI | iPadOS 声明式界面，支持横屏自适应与触控交互 |
| **MIDI 驱动** | CoreMIDI | 原生驱动层，支持 USB + 蓝牙 MIDI 设备枚举与事件收发 |
| **音符瀑布流** | SpriteKit | 2D 物理与图形引擎，保障 60fps 稳定高刷与粒子动效 |
| **简谱渲染** | SwiftUI Canvas | 自绘二维矢量简谱视图，支持高亮定位与小节切换 |
| **状态响应** | `@Observable` | iOS 17+ 响应式模型解耦 UI 与练习引擎 |
| **本地存储** | SwiftData | 练习历史会话 (`PracticeSessionModel`) 与小节统计 (`MeasureStatModel`) |

### 模块结构
```text
PianoEase/
├── .agents/                    # 项目规范与开发守则
├── doc/                        # 产品与架构文档
│   ├── 01_product_requirements.md  # 详细产品需求文档 (PRD)
│   └── 10_technical_design.md      # 系统技术架构与详细设计
├── pianoease/                  # iPad App 源码根目录
│   ├── Engine/                 # 核心练琴引擎、评测算法与指标模型
│   ├── Services/               # CoreMIDI 管理器、Chart 解析器、曲目库
│   ├── Store/                  # SwiftData 模型与数据仓库
│   ├── Views/                  # 视图层 (瀑布流/简谱/练习控台/报告/MIDI弹窗)
│   ├── Models/                 # 业务实体 (Song, ChartModels)
│   ├── Theme/                  # 颜色与设计规范
│   └── Resources/              # 内置乐谱 JSON 与清单配置
└── pianoease.xcodeproj         # Xcode 工程文件
```

---

## 🚀 快速开始

### 开发环境要求
- **macOS** 14.0 (Sonoma) 或更高版本
- **Xcode** 15.0+ / Swift 5.9+
- **运行终端**：iPad / iPadOS 17.0+ 模拟器或实体设备（推荐配合外接 MIDI 键盘实机调试）

### 运行步骤
1. 克隆本仓库到本地：
   ```bash
   git clone git@github.com:zhud423/PianoEase.git
   ```
2. 打开 Xcode 工程：
   ```bash
   open pianoease.xcodeproj
   ```
3. 选择目标设备为 **Any iPad** 或你的实际 iPad 设备。
4. 按下 `Cmd + R` 编译并运行。

---

## 📄 开源与开发规范
- 开发规范参见 [.agents/AGENTS.md](.agents/AGENTS.md)
- 需求规范参见 [doc/01_product_requirements.md](doc/01_product_requirements.md)
- 技术设计参见 [doc/10_technical_design.md](doc/10_technical_design.md)
