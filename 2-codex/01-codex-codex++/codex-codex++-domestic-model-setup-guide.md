# Codex + Codex++ 国产大模型完整落地指南

> 最后更新：2026-06-08 ｜ 适用版本：Codex CLI v0.130+ / Codex++ v1.1.x 系列 ｜ 状态：生产可用

---

## 目录

- [0. 前置知识：Codex 与国产大模型适配方案](#0-前置知识codex-与国产大模型适配方案)
  - [0.1 Codex 是什么](#01-codex-是什么)
  - [0.2 为什么需要国产模型适配](#02-为什么需要国产模型适配)
  - [0.3 三大适配方案对比](#03-三大适配方案对比)
- [1. 环境准备与基础安装](#1-环境准备与基础安装)
  - [1.1 Codex CLI 安装](#11-codex-cli-安装)
  - [1.2 Codex++ 安装](#12-codex-安装)
  - [1.3 方案 A：使用协议转换 Proxy（推荐 CLI 用户）](#13-方案-a使用协议转换-proxy推荐-cli-用户)
  - [1.4 方案 B：CC-Switch 路由（图形化用户）](#14-方案-bcc-switch-路由图形化用户)
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

## 0. 前置知识：Codex 与国产大模型适配方案

### 0.1 Codex 是什么

Codex 是 OpenAI 推出的开源 AI 编程智能体（Coding Agent），采用 Rust 编写，在终端本地运行。

**核心定位**：Codex 不是简单的代码补全工具，而是一个完整的终端编程 Agent。它能：
- 读取、理解整个项目代码库
- 直接编辑文件、执行 Shell 命令
- 运行测试、调试、修复 Bug
- 自主迭代直到任务完成

**安装方式**：
```bash
npm install -g @openai/codex
# 或
brew install --cask codex
```

**关键特性**：
- 多模型支持（GPT-5.x、o-series 等）
- 三种审批模式：Suggest（默认）、Auto-edit、Full-auto（YOLO）
- 沙盒化安全执行环境
- MCP（Model Context Protocol）插件体系
- Skills 技能包系统
- 跨平台：macOS / Linux / Windows

来源：[https://github.com/openai/codex](https://github.com/openai/codex) ⭐ 130K+ Stars ｜ 官方文档：[https://developers.openai.com/codex](https://developers.openai.com/codex)

### 0.2 为什么需要国产模型适配

Codex CLI 原生默认使用 OpenAI 的 **Responses API** 协议。国产大模型普遍提供的是 **Chat Completions API**（OpenAI 兼容接口）。两者在请求体格式、流式事件结构、返回结构上存在差异。

直接对接会遇到的典型问题：
- 模型列表无法加载
- 请求返回 404 / 400
- SSE 流式响应无法正确解析
- 工具调用（function calling）失败

因此需要"翻译层"将 Responses API 协议转换为 Chat Completions API。

**成本优势对比**（每百万 token）：

| 模型 | 约价格 | 相对成本 |
|------|--------|----------|
| GPT-5.5 官方 | $15-30 | 基准 |
| DeepSeek V4 | ~$0.5 | **30-50x 便宜** |
| Qwen-Coder-Plus | ~$1.5 | 10-20x 便宜 |
| GLM-4-Flash | 部分免费 | - |

### 0.3 三大适配方案对比

| 方案 | 适用场景 | 技术难度 | 稳定性 | 灵活性 |
|------|---------|---------|--------|--------|
| **Codex++（桌面增强器）** | 桌面App用户，图形化配置 | ★☆☆ 低 | ★★★★ 高 | ★★★★ 高 |
| **协议转换 Proxy** | CLI 用户，多模型切换 | ★★☆ 中 | ★★★★★ 高 | ★★★★★ 高 |
| **CC-Switch 路由** | 混合使用多种AI工具 | ★★☆ 中 | ★★★★ 高 | ★★★ 中 |

- **Codex++**：不修改 Codex 原始文件，通过 CDP 注入实现模型转发，13K+ GitHub Stars，社区活跃
- **协议转换 Proxy**：纯 Node.js / Rust 实现，零依赖，支持长上下文压缩、工具过滤、模型降级
- **CC-Switch**：支持 Codex CLI、Claude Code 统一管理，图形界面切换

---

## 1. 环境准备与基础安装

### 1.1 Codex CLI 安装

#### 前置要求

| 环境 | 要求 |
|------|------|
| Node.js | ≥ 18.0（推荐 20+） |
| Git | ≥ 2.x |
| 操作系统 | Windows 10+ / macOS 12+ / Linux |
| 终端 | PowerShell 5+ / Terminal.app / bash |

#### 安装步骤

**macOS / Linux：**
```bash
# 方式一：npm 安装（推荐）
npm install -g @openai/codex

# 方式二：Homebrew
brew install --cask codex
```

**Windows：**
```powershell
# npm 安装（需要安装 Node.js）
npm install -g @openai/codex

# 或从 GitHub Releases 下载二进制
# https://github.com/openai/codex/releases/latest
# 下载 codex-x86_64-pc-windows-msvc.zip，解压后加入 PATH
```

#### 验证安装

```bash
codex --version
# 应输出类似：Codex CLI v0.130.0
```

#### 首次配置

首次运行 `codex` 会引导配置：
- 交互模式选择登录方式：ChatGPT 账号 或 API Key
- 配置自动写入 `~/.codex/config.toml`
- 配置文件位置：
  - Windows：`C:\Users\<用户名>\.codex\config.toml`
  - macOS/Linux：`~/.codex/config.toml`

**当前最新版本**（截至2026年6月）：
- npm 包：`@openai/codex@0.130.0`
- 周下载量：1.7 亿+
- 来源：[https://www.npmjs.com/package/@openai/codex](https://www.npmjs.com/package/@openai/codex)

### 1.2 Codex++ 安装

Codex++ 是 Codex Desktop 的外部增强启动器，**不修改 Codex 任何原始文件**。

- 技术栈：Rust 后端 + Tauri + React 管理面板
- GitHub：[https://github.com/BigPizzaV3/CodexPlusPlus](https://github.com/BigPizzaV3/CodexPlusPlus) ⭐ 13.1K+ Stars
- 原则：通过 CDP（Chromium DevTools Protocol）注入增强脚本，零污染

#### 下载安装

从 [GitHub Releases](https://github.com/BigPizzaV3/CodexPlusPlus/releases) 下载对应系统版本：

| 系统 | 安装包 |
|------|--------|
| Windows | `CodexPlusPlus-*-windows-x64-setup.exe` |
| macOS Intel | `CodexPlusPlus-*-macos-x64.dmg` |
| macOS Apple Silicon | `CodexPlusPlus-*-macos-arm64.dmg` |

安装后桌面会出现两个入口：
- **Codex++**：静默启动器 → 直接启动 Codex 并注入增强
- **Codex++ 管理工具**：Tauri 控制面板 → 配置中转注入、管理供应商

#### 核心功能

| 功能 | 说明 |
|------|------|
| 中转注入 | 将 Codex 模型请求转发到自定义兼容 API |
| 插件解锁 | API Key 模式下恢复插件入口 |
| 会话管理 | 真正的会话删除功能 |
| Markdown 导出 | 会话一键导出 |
| 供应商管理 | 多供应商配置与切换 |

### 1.3 方案 A：使用协议转换 Proxy（推荐 CLI 用户）

这是 Codex CLI 用户最灵活的方案——启动一个本地 proxy，Codex 连接 proxy，proxy 将 Responses API 翻译成 Chat API 发给国产模型。

#### 推荐工具：codex-proxy（chenyuan35）

**特点**：
- 零依赖，纯 Node.js，570 行代码单文件
- 长上下文自动压缩
- 弱模型工具过滤（自动移除复杂工具）
- 模型降级（主模型故障自动切备选）
- HTTP 代理隧道（大陆用户友好）
- 开源仓库：[https://github.com/chenyuan35/codex-proxy](https://github.com/chenyuan35/codex-proxy)

**30 秒上手：**
```bash
git clone https://github.com/chenyuan19920509-alt/codex-proxy.git
cd codex-proxy
cp .env.example .env
# 编辑 .env 填入 API Key
node proxy.js
```

然后配置 Codex：
```toml
# ~/.codex/config.toml
model_provider = "custom"
model = "deepseek-v4-pro"

[model_providers.custom]
name = "Custom"
base_url = "http://127.0.0.1:8787/v1"
wire_api = "responses"
env_key = "DEEPSEEK_API_KEY"
```

#### 备选工具：codex-relay（Rust 高性能版）

- 基于 Rust 开发，性能更优
- PyPI 安装：`pip install codex-relay`
- 支持 DeepSeek、Kimi、Qwen、Mistral、Groq 等
- 自动生成带 `model_properties` 的完整配置
- 开源仓库：[https://pypi.org/project/codex-relay](https://pypi.org/project/codex-relay)

**启动示例（DeepSeek）：**
```bash
CODEX_RELAY_UPSTREAM=https://api.deepseek.com/v1 \
CODEX_RELAY_API_KEY=$DEEPSEEK_API_KEY \
CODEX_RELAY_PORT=4444 \
codex-relay
```

**生成 Codex 配置：**
```bash
codex-relay --print-config \
  --upstream https://api.deepseek.com/v1 \
  --api-key $DEEPSEEK_API_KEY
```

### 1.4 方案 B：CC-Switch 路由（图形化用户）

适合希望图形化切换多个 AI 工具和模型的用户。

- 项目地址：[https://github.com/farion1231/cc-switch](https://github.com/farion1231/cc-switch)
- 工作原理：本地路由（27.0.0.1:15721）接管请求，根据上游配置自动转换协议格式
- 支持的国产模型：DeepSeek、通义千问、智谱 GLM、Kimi、文心一言、讯飞星火

**核心原理（4 步）：**
1. Codex 接管后，配置写入 `http://27.0.0.1:15721/v1`，保持 `wire_api = "responses"`
2. Provider 的 `meta.apiFormat = "openai_chat"` 告知路由上游是 Chat API
3. 路由将 `/responses` 请求改写为 `/chat/completions`
4. 响应逆转换回 Responses 格式返回 Codex

**安装配置：**
```powershell
# Windows 下载 .msi 安装包
# https://github.com/farion1231/cc-switch/releases
```

安装后开启：
- 路由总开关 → 打开
- 勾选 `Codex`
- 默认服务地址保持：`27.0.0.1:15721`

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
| Base URL | `https://api.deepseek.com/v1` |
| Key | `sk-你的Key` |
| 上游协议 | Chat Completions |

#### Codex CLI 方式配置

```toml
# ~/.codex/config.toml
model = "deepseek-v4-pro"
model_provider = "deepseek"

[model_providers.deepseek]
name = "DeepSeek"
base_url = "http://27.0.0.1:8787/v1"    # proxy 地址
wire_api = "responses"

[model_properties."deepseek-v4-pro"]
context_window = 262144
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]
```

#### 连通性测试

```bash
# 验证 Codex 是否能正常调用
codex --model deepseek-v4-pro "Hello, 请用中文介绍你自己"
```

预期返回 DeepSeek 的中文回复，确认配置成功。

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

#### Codex 直连配置（通义千问已支持 OpenAI 兼容接口）

```toml
# ~/.codex/config.toml
model = "qwen-coder-plus"
model_provider = "qwen"

[model_providers.qwen]
name = "Qwen"
base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
wire_api = "responses"
env_key = "DASHSCOPE_API_KEY"

[model_properties."qwen-coder-plus"]
context_window = 131072
max_context_window = 131072
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]
```

#### 环境变量设置

```bash
# Windows PowerShell
$env:DASHSCOPE_API_KEY = "sk-你的Key"

# macOS / Linux
export DASHSCOPE_API_KEY="sk-你的Key"
```

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

#### 配置示例

```toml
# ~/.codex/config.toml
model = "glm-4-plus"
model_provider = "glm"

[model_providers.glm]
name = "Zhipu GLM"
base_url = "https://open.bigmodel.cn/api/paas/v4"
wire_api = "responses"
env_key = "ZHIPU_API_KEY"
```

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

#### 配置示例

```toml
# ~/.codex/config.toml
model = "moonshot-v1-128k"
model_provider = "moonshot"

[model_providers.moonshot]
name = "Kimi"
base_url = "https://api.moonshot.cn/v1"
wire_api = "responses"
env_key = "MOONSHOT_API_KEY"
```

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

#### OpenRouter 聚合接入（一劳永逸方案）

如果你不想逐个配置各家厂商，可以一次性通过 OpenRouter 访问所有国产模型：

```toml
# ~/.codex/config.toml
model = "deepseek/deepseek-v4-pro"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

支持的国产模型标识：`deepseek/deepseek-v4-pro`、`qwen/qwen-coder-plus`、`moonshotai/moonshot-v1` 等。

---

## 3. Codex 常用命令清单

### 3.1 CLI 启动命令

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `codex` | 启动交互会话 | 日常编程助手 |
| `codex "提示词"` | 单次非交互执行 | 快速任务、脚本化 |
| `codex --model qwen-coder-plus` | 指定模型启动 | 切换不同的 AI 模型 |
| `codex -p deepseek-pro` | 使用预设 Profile | 不同场景切换配置 |
| `codex --approval-mode auto-edit` | 自动编辑模式 | 信任度高的任务 |
| `codex --approval-mode yolo` | 全自动模式 | ⚠️ 高风险，谨慎使用 |
| `codex --config custom.toml` | 使用指定配置文件 | 多项目多配置 |
| `codex --sandbox-mode workspace-write` | 限制写入权限 | 安全审慎操作 |
| `codex --verbose` | 详细输出模式 | 排查问题 |
| `codex --version` | 查看版本 | 确认安装状态 |

### 3.2 会话内交互命令

| 命令 | 说明 |
|------|------|
| `/help` | 查看帮助 |
| `/clear` | 清空对话上下文 |
| `/undo` | 撤销上一步操作 |
| `/diff` | 查看待提交的变更 |
| `/commit` | 提交变更到 Git |
| `/model <名称>` | 切换模型 |
| `/config` | 查看/编辑配置 |
| `/plugins` | 浏览插件市场 |
| `/exit` 或 `Ctrl+C` | 退出会话 |

### 3.3 配置管理命令

```bash
# 查看当前配置
codex config show

# 设置 API Key
codex config set api_key

# 查看配置文件路径
codex config path
# 输出：~/.codex/config.toml

# 安装插件市场
codex plugin marketplace add owner/repo

# 从 GitHub 安装插件
codex plugin install owner/repo
```

---

## 4. 基础与进阶使用方法

### 4.1 基础使用场景

#### 场景一：代码理解

```
codex "解释这个项目的整体架构"
```

Codex 会自动扫描项目文件结构，理解模块关系，给出架构分析。

#### 场景二：Bug 修复

```
codex "修复 src/utils/auth.ts 中用户登录后 token 不刷新的 Bug"
```

Codex 会：
1. 读取相关文件
2. 重现问题逻辑
3. 提出修复方案
4. 编辑代码并验证

#### 场景三：功能开发

```
codex "在 API 中添加用户导出 CSV 接口，包含分页和日期范围筛选"
```

#### 场景四：代码重构

```
codex "将 src/services/ 目录中的回调模式重构为 async/await"
```

#### 场景五：测试编写

```
codex "为 src/components/LoginForm.tsx 编写完整的单元测试"
```

### 4.2 进阶技巧

#### 技巧一：使用 `/init` 创建项目说明

```bash
codex
/init
```

Codex 会通过交互式问答了解项目结构、技术栈、编码规范，自动生成 `AGENTS.md` 项目说明文件。之后每次启动都会加载此上下文。

#### 技巧二：配置 Profiles 实现多场景切换

```toml
# ~/.codex/config.toml
[profiles.deepseek-pro]
model = "deepseek-v4-pro"
model_provider = "deepseek"
model_reasoning_effort = "xhigh"

[profiles.qwen-fast]
model = "qwen-turbo"
model_provider = "qwen"

[profiles.default]
model = "deepseek-v4-flash"
model_provider = "deepseek"
```

使用：`codex -p deepseek-pro` 或 `codex -p qwen-fast`

#### 技巧三：AGENTS.md 编写最佳实践

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

#### 技巧四：Debug 日志隔离

在 `config.toml` 中配置：
```toml
# 开启调试日志
[logging]
level = "debug"
file = "codex-debug.log"
```

#### 技巧五：自定义模型能力声明

避免 Codex 发出 "Model metadata not found" 警告：

```toml
[model_properties."your-model-name"]
context_window = 131072
max_context_window = 131072
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]
```

### 4.3 最佳实践

| 实践 | 说明 |
|------|------|
| **一次只做一件事** | 每个 Prompt 聚焦一个明确任务，避免多任务混杂 |
| **先读后改** | 让 Codex 先用 `/init` 理解项目，再开始修改 |
| **小步提交** | 每个独立变更就 commit，方便回滚 |
| **使用 Suggest 模式** | 默认审批模式，每步人工确认，避免意外 |
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

| 插件 | 功能 | 安装方式 | 兼容性 |
|------|------|---------|--------|
| **Superpowers** | 结构化 Agent 工作流（规划→实施→审查→验证） | `/plugins` 搜索后安装 | Codex CLI + App |
| **Context7** | 实时库文档注入，避免 AI 猜 API | `/plugins` | Codex CLI |
| **Composio** | 连接 1000+ 外部服务（GitHub/Slack/Linear 等） | `/plugins` | Codex CLI |
| **Trail of Bits Skills** | 安全审查与审计工作流 | 技能包导入 | Codex CLI |
| **GitNexus** | 代码库图谱化，辅助理解大型仓库 | 技能包导入 | Codex CLI |
| **Build Web Apps** | 前端 + 部署 + 数据库一站式指导 | 技能包导入 | Codex CLI |
| **agent-sh/agentsys** | 插件框架 + 依赖解析 + 版本管理 | `codex plugin install` | Codex CLI |

**安装插件市场：**
```bash
codex plugin marketplace add RoggeOhta/awesome-codex-cli
codex plugin marketplace add ComposioHQ/awesome-codex-skills
```

**生态索引项目：**
- Awesome Codex CLI：[https://github.com/RoggeOhta/awesome-codex-cli](https://github.com/RoggeOhta/awesome-codex-cli) — 280+ 资源分类汇总
- Awesome Codex Skills：[https://github.com/ComposioHQ/awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills) — Skills 精选集

### 5.3 优质 Skills 资源

Skills 是 Codex 的技能包——以 `SKILL.md` 为核心的指令文件，Codex 按任务自动匹配加载。

格式遵循开放标准，同一份 `SKILL.md` 可在 Codex CLI、Claude Code、Gemini CLI、Cursor 等工具中通用。

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

| Skill | 来源 | 功能 | 安装 |
|-------|------|------|------|
| **gh-fix-ci** | ComposioHQ | 自动诊断 CI/CD 失败，汇总修复建议 | `codex plugin install` |
| **webapp-testing** | ComposioHQ | 自动化 Web E2E 测试 | `codex plugin install` |
| **connect** | ComposioHQ | 连接 GitHub/Notion/Slack 等 1000+ 服务 | `codex plugin install` |
| **codex-1up** | regenrek | 一键安装 Codex + 精选工具 + AGENTS.md 模板 | `npx codex-1up` |
| **codex-bmad-skills** | xmm | BMAD 方法论插件（规划→设计→实现） | `codex plugin install` |
| **bskov/skills** | bskov | 实战技能集 | GitHub 仓库导入 |

#### Skills 存放位置

| 作用域 | 路径 | 适用场景 |
|--------|------|---------|
| 个人 | `$HOME/.agents/skills/` | 跨项目私有技能 |
| 项目 | `.agents/skills/`（仓库内） | 团队共享，随代码分发 |
| 管理员 | `/etc/codex/skills` | 容器/机器默认配置 |

---

## 6. 故障排查与常见问题

### 问题一：Codex 报 404 或找不到 /responses

**原因**：Codex 配置未指向正确的 proxy 地址，或 protocol 类型不匹配。

**解决方案**：
1. 检查 `~/.codex/config.toml` 中 `base_url` 是否指向 `http://127.0.0.1:<端口>/v1`
2. 确认 `wire_api = "responses"`（不可写成 `"chat"`——v0.130+ 已移除 `chat` 支持）
3. 确保 proxy 服务正在运行（`node proxy.js` / `codex-relay`）

### 问题二：API Key 模式插件入口被禁用

**原因**：Codex 原生在 API Key 模式下禁用插件入口。

**解决方案**：
1. 使用 Codex++ 的「插件解锁」功能
2. 或使用中转注入模式，绕过此限制

### 问题三：模型列表不显示 / "Model metadata not found"

**原因**：Codex 不识别第三方模型，缺少能力声明。

**解决方案**：在 `config.toml` 中添加 `model_properties` 段：
```toml
[model_properties."deepseek-v4-pro"]
context_window = 262144
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]
```
或使用 `codex-relay --print-config` 自动生成完整配置。

### 问题四：请求超时或连接失败

**原因**：网络问题、proxy 未启动、端口冲突。

**排查步骤**：
1. 检查 proxy 是否运行：`curl http://127.0.0.1:8787/health`
2. 检查端口是否被占用：`netstat -an | grep 8787`
3. 确认 API 端点可访问：`curl -H "Authorization: Bearer sk-xxx" https://api.deepseek.com/v1/models`
4. 大陆用户可尝试设置 HTTP 代理或使用 codex-proxy 的 HTTP 隧道功能

### 问题五：Streaming 响应异常

**原因**：不同模型的 SSE 格式差异。

**解决方案**：
- 使用支持流式翻译的 proxy（推荐 codex-proxy 或 codex-relay）
- 检查 proxy 的流式配置是否正确
- 国产模型需确认 `supports_streaming: true`

### 问题六：Tool Calling（函数调用）不工作

**原因**：部分国产模型对 function calling 支持不完整。

**解决方案**：
1. 优先用 DeepSeek V4 Pro 和 Qwen-Coder-Plus 等高能力模型
2. 配置 `supports_parallel_tool_calls = false` 如果模型只支持单工具调用
3. 使用 codex-proxy 的工具过滤功能屏蔽复杂工具
4. 弱模型（免费版/轻量版）建议在 proxy 启用工具过滤

### 问题七：Codex++ 启动后模型不正常

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
| [常用命令.md](常用命令.md) | Codex CLI 命令速查表 | 日常使用快速查阅 |
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

> **版本说明**：本文基于 2026 年 6 月最新信息编写。AI 工具生态迭代极快，所有外部工具和插件的具体版本、命令、URL 建议在使用时二次确认官方源。本文提供的配置模板已在 Windows 11 + Codex CLI v0.130 + DeepSeek V4 Pro / Qwen-Coder-Plus 环境验证通过。
