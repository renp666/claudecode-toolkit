# Codex++ 桌面版 + 国产大模型完整落地指南

> 最后更新：2026-06-13 ｜ 适用版本：Codex 桌面版 v0.130+ / Codex++ v1.1.x 系列 ｜ 状态：生产可用

---

## 目录

- [0. 前置知识：Codex 桌面版与国产大模型适配](#0-前置知识codex-桌面版与国产大模型适配)
  - [0.1 Codex 桌面版是什么](#01-codex-桌面版是什么)
  - [0.2 为什么需要国产模型适配](#02-为什么需要国产模型适配)
  - [0.3 适配方案：Codex++ 桌面增强器](#03-适配方案codex-桌面增强器)
- [1. 安装与配置](#1-安装与配置)
  - [1.1 安装 Codex 桌面版](#11-安装-codex-桌面版)
  - [1.2 安装 Codex++ 增强器](#12-安装-codex-增强器)
  - [1.3 可选：CC-Switch 路由（图形化多工具管理）](#13-可选cc-switch-路由图形化多工具管理)
- [2. 国产大模型配置指南](#2-国产大模型配置指南)
  - [2.1 DeepSeek 接入配置](#21-deepseek-接入配置)
  - [2.2 通义千问(Qwen)接入配置](#22-通义千问qwen接入配置)
  - [2.3 智谱 GLM 接入配置](#23-智谱-glm-接入配置)
  - [2.4 Kimi(Moonshot)接入配置](#24-kimimoonshot接入配置)
  - [2.5 其他国产模型接入](#25-其他国产模型接入)
- [3. Codex 常用命令清单](#3-codex-常用命令清单)
- [4. 基础与进阶使用方法](#4-基础与进阶使用方法)
- [5. Codex 生态资源](#5-codex-生态资源)
- [6. 故障排查与常见问题](#6-故障排查与常见问题)
- [7. 附录：信息溯源与可信度标注](#7-附录信息溯源与可信度标注)
- [配套资源](#配套资源)

---

## 0. 前置知识：Codex 桌面版与国产大模型适配

### 0.1 Codex 桌面版是什么

Codex 是 OpenAI 推出的 AI 编程智能体（Coding Agent），提供桌面应用版本，图形界面操作。

**核心能力**：
- 读取、理解整个项目代码库
- 直接编辑文件、执行 Shell 命令
- 运行测试、调试、修复 Bug
- 自主迭代直到任务完成

**Codex 桌面版安装**：从 [openai.com/codex](https://openai.com/codex) 下载对应系统版本安装即可。

来源：[https://github.com/openai/codex](https://github.com/openai/codex) ⭐ 130K+ Stars

### 0.2 为什么需要国产模型适配

Codex 原生默认使用 OpenAI 的 API。国产大模型（DeepSeek、通义千问等）提供的是 OpenAI 兼容接口，直接对接会遇到协议不兼容问题。

**成本优势对比**（每百万 token）：

| 模型 | 约价格 | 相对成本 |
|------|--------|----------|
| GPT-5.5 官方 | $15-30 | 基准 |
| DeepSeek V4 | ~$0.5 | **30-50x 便宜** |
| Qwen-Coder-Plus | ~$1.5 | 10-20x 便宜 |
| GLM-4-Flash | 部分免费 | - |

### 0.3 适配方案：Codex++ 桌面增强器

Codex++ 是 Codex 桌面版的外部增强启动器，**不修改 Codex 任何原始文件**。通过 CDP（Chromium DevTools Protocol）注入增强脚本，将 Codex 的模型请求转发到国产大模型。

- 技术栈：Rust 后端 + Tauri + React 管理面板
- GitHub：[https://github.com/BigPizzaV3/CodexPlusPlus](https://github.com/BigPizzaV3/CodexPlusPlus) ⭐ 13.1K+ Stars
- 原则：零污染，不修改原始文件

| 特性 | 说明 |
|------|------|
| **技术难度** | ★☆☆ 低 — 图形化配置，无需命令行 |
| **稳定性** | ★★★★ 高 — 社区活跃维护 |
| **灵活性** | ★★★★ 高 — 多供应商管理，随时切换 |

核心功能：中转注入 / 插件解锁 / 会话管理 / Markdown 导出 / 供应商管理

---

## 1. 安装与配置

> 安装顺序很重要：先装 Codex 桌面版 → 启动一次后完全退出 → 再装 Codex++。

### 1.1 安装 Codex 桌面版

**Windows：**

- **Microsoft Store**（推荐）：[https://apps.microsoft.com/detail/9plm9xgg6vks](https://apps.microsoft.com/detail/9plm9xgg6vks?hl=zh-CN&gl=CN)
- 或从 [openai.com/codex](https://openai.com/codex) 下载

**macOS：**
- 从 [openai.com/codex](https://openai.com/codex) 下载 dmg 安装包

安装完成后：
1. 打开 Codex，完成首次登录（ChatGPT 账号 或 API Key 均可）
2. **关键步骤**：确认能正常进入主界面后，**完全退出 Codex**（包括后台进程）。右键系统托盘图标 → 退出，确保进程完全关闭
3. 关闭后不要再打开原生 Codex — 后续统一通过 Codex++ 入口启动

### 1.2 安装 Codex++ 增强器

Codex++ 是 Codex 的外部增强启动器，通过脚本注入实现模型转发，**不修改 Codex 任何原始文件**。

**下载：**从 [GitHub Releases](https://github.com/BigPizzaV3/CodexPlusPlus/releases) 下载对应系统版本：

| 系统 | 安装包 |
|------|--------|
| Windows | `CodexPlusPlus-*-windows-x64-setup.exe` |
| macOS Intel | `CodexPlusPlus-*-macos-x64.dmg` |
| macOS Apple Silicon | `CodexPlusPlus-*-macos-arm64.dmg` |

**安装步骤：**
1. 双击安装包，建议安装到非系统盘（如 `D:\codex++`）
2. 安装完成后桌面会生成两个图标：
   - **Codex++** — 静默启动器，直接启动 Codex 并加载增强
   - **Codex++ 管理工具** — 控制面板，用于配置供应商、修复、切换模型
3. 首次打开 Codex++ 管理工具，它会自动检测已安装的 Codex 位置和版本
4. 如果某项显示缺失，进入「安装维护」点击「修复」即可

#### 配置国产模型供应商

以 DeepSeek 为例，完整配置流程：

1. 打开 **Codex++ 管理工具** → 左侧选择「供应商配置」
2. 点击「添加供应商」，按以下参数填写：

| 参数 | 值 | 说明 |
|------|-----|------|
| 名称 | `deepseek` | 自定义，便于识别 |
| 接入模式 | 纯 API | |
| 配置模型 | `deepseek-v4-pro` | 或 `deepseek-v4-flash` |
| Base URL | `https://api.deepseek.com` | **注意：不要带 `/v1`** |
| Key | `sk-你的Key` | 从 DeepSeek 开放平台获取 |
| 上游协议 | Chat Completions | **关键！** 选错会导致 404 |

3. 点击「更多选项」展开 → 确认「上游协议」为 `Chat Completions`
4. 点击「保存」
5. 在供应商列表中，将该供应商 **设为「当前使用」**

> **重要提示**：Base URL 填 `https://api.deepseek.com` 即可，不要加 `/v1` 后缀。上游协议必须选 `Chat Completions`，如果选 `Responses API` 会报 404。

#### 启动验证

1. 双击桌面 **Codex++** 图标（不是原生 Codex）
2. Codex 启动后在对话框输入简单测试，如 `你好，请用中文介绍你自己`
3. 正常返回回复即代表接入成功

### 1.3 可选：CC-Switch 路由（图形化多工具管理）

如果你同时使用 Codex 和 Claude Code，CC-Switch 可以在一个图形界面中统一管理多个 AI 工具的模型路由。

- 项目地址：[https://github.com/farion1231/cc-switch](https://github.com/farion1231/cc-switch)
- 安装：从 [Releases](https://github.com/farion1231/cc-switch/releases) 下载 `.msi`（Windows）或 `.dmg`（macOS）
- 支持的国产模型：DeepSeek、通义千问、智谱 GLM、Kimi、文心一言、讯飞星火

> 日常使用推荐 Codex++ 即可，CC-Switch 作为多工具场景的补充方案。

---

## 2. 国产大模型配置指南

### 2.1 DeepSeek 接入配置

DeepSeek 是目前性价比最高的国产编程模型，社区反馈在代码生成、重构、Debug 场景表现优异。

#### API 获取

1. 访问 [https://platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)
2. 注册/登录 → 控制台 → API Keys → 创建密钥
3. ⚠️ Key 仅创建时显示一次，务必妥善保存
4. 建议设置用量限制，控制成本

#### 可用模型（2026年6月）

| 模型名称 | 用途 | 上下文窗口 |
|----------|------|------------|
| `deepseek-v4-pro` | 旗舰编程模型（推荐） | 128K |
| `deepseek-v4-flash` | 轻量快速模型 | 128K |
| `deepseek-chat` | 通用对话（将于 2026/07 弃用） | 64K |

⚠️ `deepseek-chat` 和 `deepseek-reasoner` 将于 2026/07/24 弃用，请迁移到新模型名。

#### Codex++ 方式配置

在 Codex++ 管理工具 → 供应商配置 → 添加供应商：

| 参数 | 值 |
|------|-----|
| 名称 | `deepseek` |
| 接入模式 | 纯 API |
| 配置模型 | `deepseek-v4-pro` |
| Base URL | `https://api.deepseek.com` |
| Key | `sk-你的Key` |
| 上游协议 | Chat Completions |

#### 连通性验证

通过 Codex++ 启动 Codex 后，在对话中输入 `Hello, 请用中文介绍你自己`，预期返回 DeepSeek 的中文回复即配置成功。

### 2.2 通义千问（Qwen）接入配置

通义千问的 Qwen-Coder 系列在代码质量上表现优秀，且提供阿里云百炼平台原生支持。

#### API 获取

1. 访问 [阿里云百炼平台](https://dashscope.aliyun.com/)
2. 注册 → API-KEY 管理 → 创建 API Key
3. 新用户通常有免费额度

#### 可用模型

| 模型名称 | 用途 | 上下文 |
|----------|------|--------|
| `qwen-coder-plus` | 专业编程模型（推荐） | 128K |
| `qwen-max` | 通用最强模型 | 32K |
| `qwen-plus` | 均衡性价比 | 131K |
| `qwen-turbo` | 快速轻量 | 1M |

#### Codex++ 方式配置

在 Codex++ 管理工具中添加供应商：

| 参数 | 值 |
|------|-----|
| 名称 | `qwen` |
| 接入模式 | 纯 API |
| 配置模型 | `qwen-coder-plus` |
| Base URL | `https://dashscope.aliyuncs.com/compatible-mode/v1` |
| Key | `sk-你的Key` |
| 上游协议 | Chat Completions |

### 2.3 智谱 GLM 接入配置

智谱 GLM-4 系列在中文编程场景表现稳定，且有免费额度可用。

#### API 获取

1. 访问 [https://open.bigmodel.cn/](https://open.bigmodel.cn/)
2. 注册 → 控制台 → API Keys → 创建密钥

#### 可用模型

| 模型名称 | 用途 | 上下文 |
|----------|------|--------|
| `glm-4-plus` | 最强编程模型 | 128K |
| `glm-4-flash` | 免费快速模型 | 128K |
| `glm-4-air` | 轻量性价比 | 128K |

#### Codex++ 方式配置

在 Codex++ 管理工具中添加供应商：

| 参数 | 值 |
|------|-----|
| 名称 | `glm` |
| 接入模式 | 纯 API |
| 配置模型 | `glm-4-plus` |
| Base URL | `https://open.bigmodel.cn/api/paas/v4` |
| Key | `你的Key` |
| 上游协议 | Chat Completions |

### 2.4 Kimi（Moonshot）接入配置

月之暗面 Kimi 以超长上下文著称（最高 128K），适合大型项目分析。

#### API 获取

1. 访问 [https://platform.moonshot.cn/](https://platform.moonshot.cn/)
2. 注册 → 控制台 → API Keys

#### 可用模型

| 模型名称 | 上下文 |
|----------|--------|
| `moonshot-v1-8k` | 8K |
| `moonshot-v1-32k` | 32K |
| `moonshot-v1-128k` | 128K |

#### Codex++ 方式配置

在 Codex++ 管理工具中添加供应商：

| 参数 | 值 |
|------|-----|
| 名称 | `moonshot` |
| 接入模式 | 纯 API |
| 配置模型 | `moonshot-v1-128k` |
| Base URL | `https://api.moonshot.cn/v1` |
| Key | `sk-你的Key` |
| 上游协议 | Chat Completions |

### 2.5 其他国产模型接入

#### 豆包（火山引擎 / ByteDance）

- API 平台：[https://www.volcengine.com/product/doubao](https://www.volcengine.com/product/doubao)
- 模型：`doubao-pro-32k`、`doubao-lite`
- 通过火山引擎方舟平台接入

#### 文心一言（百度千帆）

- API 平台：[https://console.bce.baidu.com/qianfan/](https://console.bce.baidu.com/qianfan/)
- 模型：`ernie-4.0`、`ernie-speed`
- API 格式非 OpenAI 兼容，需要通过协议转换 proxy

#### 讯飞星火

- API 平台：[https://xinghuo.xfyun.cn/](https://xinghuo.xfyun.cn/)
- 模型：`spark-v4.0`、`spark-lite`
- API 格式非 OpenAI 兼容，需要通过协议转换 proxy

#### OpenRouter 聚合接入

通过 OpenRouter 一次性访问所有国产模型。在 Codex++ 管理工具中添加供应商：

| 参数 | 值 |
|------|-----|
| 名称 | `openrouter` |
| 接入模式 | 纯 API |
| 配置模型 | `deepseek/deepseek-v4-pro` |
| Base URL | `https://openrouter.ai/api/v1` |
| Key | `sk-or-你的Key` |
| 上游协议 | Chat Completions |

支持的国产模型标识：`deepseek/deepseek-v4-pro`、`qwen/qwen-coder-plus`、`moonshotai/moonshot-v1` 等。

---

## 3. Codex++ 常用操作

### 3.1 日常使用流程

1. 打开 **Codex++ 管理工具**，确认目标供应商已设为「当前使用」
2. 点击 **Codex++** 启动器，Codex 桌面版自动加载增强
3. 在 Codex 对话界面中直接输入任务，模型请求会自动路由到国产模型

### 3.2 管理工具操作

| 操作 | 说明 |
|------|------|
| 添加供应商 | 管理工具 → 供应商配置 → 添加供应商 |
| 切换供应商 | 在供应商列表中选择 → 点击「当前使用」 |
| 会话导出 | 在 Codex++ 中可将会话导出为 Markdown |
| 插件管理 | 管理工具中可解锁/管理插件 |

### 3.3 Codex 对话基本操作

| 操作 | 方式 |
|------|------|
| 新建对话 | Codex 界面中点击新建会话 |
| 清空上下文 | 对话中输入 `/clear` |
| 撤销操作 | `/undo` 撤销上一步 |
| 查看变更 | `/diff` 查看待提交的文件修改 |
| 提交代码 | `/commit` 自动生成 commit message 并提交 |
| 切换模型 | 在 Codex++ 管理工具中切换供应商后重新启动 |

---

## 4. 基础与进阶使用方法

### 4.1 基础使用场景

#### 场景一：代码理解

在 Codex 对话中输入：
```
解释这个项目的整体架构
```

Codex 会自动扫描项目文件结构，理解模块关系，给出架构分析。

#### 场景二：Bug 修复

```
修复 src/utils/auth.ts 中用户登录后 token 不刷新的 Bug
```

Codex 会读取文件 → 分析问题 → 提出修复 → 编辑代码并验证。

#### 场景三：功能开发

```
在 API 中添加用户导出 CSV 接口，包含分页和日期范围筛选
```

#### 场景四：代码重构

```
将 src/services/ 目录中的回调模式重构为 async/await
```

#### 场景五：测试编写

```
为 src/components/LoginForm.tsx 编写完整的单元测试
```

### 4.2 进阶技巧

#### 技巧一：使用 AGENTS.md 让 Codex 更懂你的项目

在项目根目录创建 `AGENTS.md`，Codex 启动时自动读取：

```markdown
# 项目开发指南

## 技术栈
- 前端：React 19 + TypeScript + Tailwind CSS
- 后端：Node.js + Express + PostgreSQL
- 测试：Vitest + Playwright

## 编码规范
- 使用函数式组件，避免 Class
- API 错误统一返回 { error: string, code: number } 格式
- 提交信息遵循 Conventional Commits

## 常用命令
- `npm run dev`：启动开发服务器
- `npm run test`：运行测试
- `npm run lint`：代码检查
```

#### 技巧二：在 Codex++ 中管理多供应商

在 Codex++ 管理工具中可以添加多个供应商（如 DeepSeek 用于日常编码、Qwen-Coder 用于特定场景），根据需要随时切换。

#### 技巧三：会话导出与记录

Codex++ 支持将会话导出为 Markdown，方便归档和团队分享。

### 4.3 最佳实践

| 实践 | 说明 |
|------|------|
| **一次只做一件事** | 每个 Prompt 聚焦一个明确任务，避免多任务混杂 |
| **先读后改** | 让 Codex 先理解项目结构，再开始修改 |
| **小步提交** | 每个独立变更就 commit，方便回滚 |
| **写清楚验收标准** | "当 XX 时，应返回 YY" 比 "修 Bug" 更有效 |
| **善用 Skills** | 安装社区 Skills 标准化常见工作流 |
| **定期清理上下文** | 长会话用 `/clear` 重置，避免 Token 浪费 |

---

## 5. Codex 生态资源

### 5.1 协议转换工具

Codex CLI（v0.130+）移除了 `wire_api = "chat"` 支持，所有第三方模型都需要协议转换。以下是生产可用方案：

| 工具 | 语言 | 特点 | 安装方式 | Stars | 可信度 |
|------|------|------|---------|-------|--------|
| **codex-proxy** | Node.js | 零依赖，长上下文压缩，工具过滤，HTTP隧道，模型降级 | `git clone` 后 `node proxy.js` | 社区新项目 | ★★★★ |
| **codex-relay** | Rust | 高性能，自动配置生成，支持模型属性声明 | `pip install codex-relay` | 社区 | ★★★★ |
| **Moon Bridge** | Go | Deepeek 专精，图文教程完善 | `git clone` 后 `go run` | 社区 | ★★★☆ |
| **CodeProxy CLI** | Python | 多上游配置，自动模型映射 | `pip install codeproxy` | 社区 | ★★★☆ |
| **CC-Switch** | - | 图形界面，多AI工具统一管理 | `.msi`/`.dmg` 安装包 | 活跃维护 | ★★★★ |

- codex-proxy：[https://github.com/chenyuan35/codex-proxy](https://github.com/chenyuan35/codex-proxy)
- codex-relay：[https://pypi.org/project/codex-relay](https://pypi.org/project/codex-relay)
- Moon Bridge：[https://github.com/ZhiYi-R/moon-bridge](https://github.com/ZhiYi-R/moon-bridge)
- CC-Switch：[https://github.com/farion1231/cc-switch](https://github.com/farion1231/cc-switch)

### 5.2 社区优质插件

| 插件 | 功能 | 兼容性 |
|------|------|--------|
| **Superpowers** | 结构化 Agent 工作流（规划→实施→审查→验证） | Codex 桌面版 |
| **Context7** | 实时库文档注入，避免 AI 猜 API | Codex 桌面版 |
| **Composio** | 连接 1000+ 外部服务（GitHub/Slack/Linear 等） | Codex 桌面版 |
| **Trail of Bits Skills** | 安全审查与审计工作流 | Codex 桌面版 |
| **GitNexus** | 代码库图谱化，辅助理解大型仓库 | Codex 桌面版 |
| **Build Web Apps** | 前端 + 部署 + 数据库一站式指导 | Codex 桌面版 |

**生态索引项目：**
- Awesome Codex CLI：[https://github.com/RoggeOhta/awesome-codex-cli](https://github.com/RoggeOhta/awesome-codex-cli) — 280+ 资源分类汇总
- Awesome Codex Skills：[https://github.com/ComposioHQ/awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills) — Skills 精选集

### 5.3 优质 Skills 资源

Skills 是 Codex 的技能包——以 `SKILL.md` 为核心的指令文件，Codex 按任务自动匹配加载，同一份 `SKILL.md` 可在 Codex、Claude Code 等工具中通用。

#### 官方推荐 Skills（openai/skills）

- 仓库：[https://github.com/openai/skills](https://github.com/openai/skills) ⭐ 19.3K+

| Skill | 功能 | 适用场景 |
|-------|------|---------|
| **create-plan** | 编写代码前强制输出执行计划 | 多文件中大型任务 |
| **frontend-skill** | 更美观的前端页面生成 | 前端/独立开发者 |
| **cli-creator** | 将脚本封装为可复用 CLI 工具 | 后端/基础设施 |
| **mcp-builder** | MCP Server 构建向导 | AI 工具链开发者 |
| **figma-implement-design** | 设计稿到代码实现 | 前端 + 设计师协作 |

#### 社区精选 Skills

| Skill | 来源 | 功能 |
|-------|------|------|
| **gh-fix-ci** | ComposioHQ | 自动诊断 CI/CD 失败，汇总修复建议 |
| **webapp-testing** | ComposioHQ | 自动化 Web E2E 测试 |
| **connect** | ComposioHQ | 连接 GitHub/Notion/Slack 等 1000+ 服务 |
| **codex-1up** | regenrek | 一键安装 Codex + 精选工具 + AGENTS.md 模板 |
| **codex-bmad-skills** | xmm | BMAD 方法论插件（规划→设计→实现） |
| **bskov/skills** | bskov | 实战技能集 |

---

## 6. 故障排查与常见问题

### 问题一：Codex++ 启动后模型无响应或报 404

**原因**：上游协议选择错误，或供应商配置不正确。

**解决方案**：
1. 确认从 **Codex++ 入口** 启动（非原生 Codex 图标）
2. 打开 Codex++ 管理工具 → 检查供应商「上游协议」是否为 `Chat Completions`（选 `Responses API` 会 404）
3. 检查 Base URL：DeepSeek 应为 `https://api.deepseek.com`（不带 `/v1`）
4. 确认 API Key 正确且账户有余额

### 问题二：Codex++ 启动后按钮灰色无法操作

**原因**：Codex 后台进程未完全退出，或 Codex++ 未正确检测到 Codex。

**解决方案**：
1. 右键系统托盘 → 完全退出 Codex 及其后台进程
2. 打开 Codex++ 管理工具 →「安装维护」→ 点击「修复」
3. 重新通过 Codex++ 启动

### 问题三：配置保存后模型仍使用默认

**原因**：供应商未设为「当前使用」，或未重启 Codex。

**解决方案**：
1. 在 Codex++ 管理工具的供应商列表中将目标供应商 **设为「当前使用」**
2. 切换供应商后必须重新通过 Codex++ 启动 Codex
3. 启动后在对话中测试，检查 DeepSeek 开放平台账单是否有消耗来确认

### 问题四：连接超时或网络异常

**原因**：网络问题或 API 端点不可达。

**排查步骤**：
1. 检查网络连接是否正常
2. 测试 API 端点是否可达（浏览器访问对应模型官网）
3. 大陆用户如网络不稳定可尝试使用代理

### 问题五：Tool Calling（函数调用）不工作

**原因**：部分国产模型的 function calling 支持不完整。

**解决方案**：
1. 优先用 DeepSeek V4 Pro 和 Qwen-Coder-Plus 等高能力模型
2. 弱模型（免费版/轻量版）建议切换为高能力模型

### 问题六：Codex++ 启动后模型不正常

**排查清单**：
- [ ] 确认从 Codex++ 入口启动（非原生 Codex）
- [ ] 在 Codex++ 管理工具检查后端状态灯是否为绿色
- [ ] 确认供应商已设为「当前使用」
- [ ] 检查供应商配置中 Base URL 和 Key 是否正确
- [ ] 如使用代理/VPN，确认网络连通

---

## 7. 附录：信息溯源与可信度标注

| 信息类别 | 来源 | 类型 | 可信度 |
|----------|------|------|--------|
| Codex CLI 安装与版本 | [npm @openai/codex](https://www.npmjs.com/package/@openai/codex) | 官方 npm 包 | ★★★★★ |
| Codex CLI 源码 | [github.com/openai/codex](https://github.com/openai/codex) | 官方仓库 130K+ Stars | ★★★★★ |
| Codex 官方文档 | [developers.openai.com/codex](https://developers.openai.com/codex) | 官方文档 | ★★★★★ |
| Codex CLI Changelog | [developers.openai.com/codex/changelog](https://developers.openai.com/codex/changelog) | 官方更新日志 | ★★★★★ |
| Codex++ 项目 | [github.com/BigPizzaV3/CodexPlusPlus](https://github.com/BigPizzaV3/CodexPlusPlus) | 开源社区 13.1K Stars | ★★★★ |
| CC-Switch 项目 | [github.com/farion1231/cc-switch](https://github.com/farion1231/cc-switch) | 开源社区 | ★★★★ |
| codex-proxy | [github.com/chenyuan35/codex-proxy](https://github.com/chenyuan35/codex-proxy) | 开源社区 | ★★★★ |
| codex-relay | [pypi.org/project/codex-relay](https://pypi.org/project/codex-relay) | PyPI 发布 | ★★★★ |
| DeepSeek API | [platform.deepseek.com](https://platform.deepseek.com) | 官方平台 | ★★★★★ |
| 通义千问 API | [阿里云百炼](https://dashscope.aliyun.com/) | 官方平台 | ★★★★★ |
| 智谱 GLM API | [open.bigmodel.cn](https://open.bigmodel.cn) | 官方平台 | ★★★★★ |
| Kimi API | [platform.moonshot.cn](https://platform.moonshot.cn) | 官方平台 | ★★★★★ |
| Awesome Codex CLI | [github.com/RoggeOhta/awesome-codex-cli](https://github.com/RoggeOhta/awesome-codex-cli) | 社区精选 280+ 资源 | ★★★★ |
| Awesome Codex Skills | [github.com/ComposioHQ/awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills) | 社区精选 | ★★★★ |
| 社区教程（掘金） | 多篇 Codex++ 实战教程 | 社区实践验证 | ★★★ |
| 社区教程（CSDN） | Codex + DeepSeek + Qwen 实测教程 | 社区实践验证 | ★★★ |

---

## 配套资源

本目录还包含以下配套文件，与主文档配合使用：

| 文件 | 用途 | 适用场景 |
|------|------|---------|
| [CLAUDE.md](CLAUDE.md) | 项目行为准则（Karpathy 四原则 + Codex 专用上下文） | 维护本文档时的行为约束 |
| `常用命令.md` | Codex 常用操作速查表 | 日常使用快速查阅 |
| [分析-可行性评估.md](分析-可行性评估.md) | Codex + 国产模型方案评估 | 决策参考 |
| [config-templates/](config-templates/) | 直接可用的配置模板（6 个） | 一键复制 config.toml |
| [scripts/setup-codex-deepseek.ps1](scripts/setup-codex-deepseek.ps1) | DeepSeek 一键配置脚本 | Windows 自动部署 |

### config-templates 快速索引

| 模板文件 | 模型 |
|----------|------|
| `deepseek-config.toml` | DeepSeek V4 Pro / Flash |
| `qwen-config.toml` | 通义千问 Qwen-Coder / Turbo |
| `glm-config.toml` | 智谱 GLM-4 Plus / Flash |
| `moonshot-config.toml` | Kimi v1-8k / 32k / 128k |
| `multi-provider-config.toml` | 以上全部（一文件通吃） |
| `agents-template.md` | 通用项目说明模板 |

> **版本说明**：本文基于 2026 年 6 月最新信息编写。AI 工具生态迭代极快，所有外部工具和插件的具体版本、URL 建议在使用时二次确认官方源。本文方案已在 Windows 11 + Codex 桌面版 + Codex++ v1.1.x + DeepSeek V4 Pro / Qwen-Coder-Plus 环境验证通过。
