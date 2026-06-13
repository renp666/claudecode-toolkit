# Claude Code Toolkit — AI 编程工具链一站式方案

> 两套方案覆盖你的 AI 编程全场景：[Claude Code + CC-Switch 深度调优]，[Codex桌面版 + Codex++增强器]接入国产大模型低成本落地。新环境 30 分钟内完成全套部署。

[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=flat-square)]()
[![GitHub Pages](https://img.shields.io/badge/Preview-GitHub%20Pages-28a745?style=flat-square&logo=github)](https://renp666.github.io/claudecode-toolkit/demo.html)

---

## 在线预览

**[交互式文档](https://renp666.github.io/claudecode-toolkit/demo.html)**

| 页面 | 说明 |
|------|------|
| [首页](https://renp666.github.io/claudecode-toolkit/demo.html) | 两大产品线概览 + 快速对比 |
| [Claude Code 方案](https://renp666.github.io/claudecode-toolkit/claude-code.html) | 四层架构、核心能力、快速上手、效果数据、实施路径 |
| [Codex++ 方案](https://renp666.github.io/claudecode-toolkit/codex-codexpp.html) | 安装配置、5厂商模型、使用指南、生态资源、故障排查、成本对比 |

---

## 这是什么？

一套 AI 编程工具链配置体系，包含两大方案：

| 方案 | 定位 | 核心优势 |
|------|------|---------|
| **Claude Code 调优方案** | Anthropic Claude Code 工程化提效 | 四层架构 / 13 Skills / 7 Agents / Token 节省 50-90% |
| **Codex++ 国产大模型方案** | OpenAI Codex + 国产模型低成本落地 | 5厂商适配 / 30-50x 成本优势 / 15分钟接入 |

---

## 方案一：Claude Code 调优方案

解决 Claude Code 使用中的四大痛点：

| 问题 | 解决方式 |
|------|---------|
| Token 浪费严重 | 输出压缩（caveman）+ CLI 过滤（rtk）+ 会话管理策略 |
| Claude 做的不是你想要的 | Karpathy 四原则 + 需求对齐（grill-with-docs） |
| 每次新会话从零开始 | CLAUDE.md 分层记忆 + 13 个 Skills + 7 个 Agents |
| 配置无法复用 | 全局模板 + 项目模板 + 一键部署脚本 |

### 四层优化架构

```
第 1 层  基础层      Claude Code CLI + CC-Switch + Node.js + Git
第 2 层  行为约束层  CLAUDE.md 分层 / Rules 模块化 / Hooks 守卫 / 权限白名单
第 3 层  效率层      输出压缩（rtk + caveman）/ 成本监控（ccusage）/ Token 管理
第 4 层  工程化层    自定义 Commands / 7 个角色型智能体 / 13 个 Skills / MCP 服务器
```

### 快速开始

```powershell
# 克隆仓库
git clone https://github.com/renp666/claudecode-toolkit.git
cd claudecode-toolkit

# 一键部署全部配置
.\1-claudeCode\02-claude-optimize-调优方案\scripts\setup-claude.ps1 -Phase all -ProjectDir "D:\your-project"

# 安装提效工具（可选）
.\1-claudeCode\02-claude-optimize-调优方案\01global-全局级可复制配置\tools\install-tools.ps1 -Tool all -AddToPath
```

#### 分阶段部署

```powershell
# 阶段一：核心配置（CLAUDE.md + Rules + Hooks + Commands）
.\1-claudeCode\02-claude-optimize-调优方案\scripts\setup-claude.ps1 -Phase 1

# 阶段二：提效增强（工具 + 监控）
.\1-claudeCode\02-claude-optimize-调优方案\scripts\setup-claude.ps1 -Phase 2 -ProjectDir "D:\your-project"

# 阶段三：高级扩展（Skills + Agents）
.\1-claudeCode\02-claude-optimize-调优方案\scripts\setup-claude.ps1 -Phase 3 -ProjectDir "D:\your-project"
```

#### 手动部署

```powershell
# 1. 部署全局配置
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\01global-全局级可复制配置\CLAUDE.md" "$env:USERPROFILE\.claude\CLAUDE.md"
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\01global-全局级可复制配置\commands\*.md" "$env:USERPROFILE\.claude\commands\"

# 2. 部署项目配置
$proj = "D:\your-project"
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\02templates-项目级可复制文件目录\CLAUDE.md" "$proj\CLAUDE.md"
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\02templates-项目级可复制文件目录\.mcp.json" "$proj\.mcp.json"
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\02templates-项目级可复制文件目录\.claude" "$proj\.claude" -Recurse

# 3. 按需添加技术栈专用规则
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\02templates-项目级可复制文件目录\.claude\rules\vue3.md" "$proj\.claude\rules\"
```

### 配置详解

**CLAUDE.md 分层体系** — 全局行为准则 + 项目专属配置，源自 [Karpathy CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills)（⭐87.6K）

1. **思考先行** — 不假设，暴露权衡
2. **简洁优先** — 最小代码，不投机
3. **精准变更** — 只改必须改的
4. **目标驱动** — 定义成功标准，循环验证

**Rules 模块化** — 3 个通用基线（frontend / backend / testing）+ 6 套技术栈专用（Vue2/Vue3/React/TypeScript/Python/Go）

**Hooks 守卫** — PreToolUse 拦截危险命令 / PostToolUse 提醒 lint/test / Stop 验收检查

**角色型智能体（7 个）** — UI 设计师 / 前端架构师 / 代码审查员 / 安全扫描器 / 性能分析器 / API 测试专家 / 文档生成器

**Skills（13 个）** — 覆盖 Define → Plan → Build → Verify → Review → Ship 全生命周期

---

## 方案二：Codex++ 国产大模型方案

让 OpenAI Codex 桌面版接入 DeepSeek / Qwen / GLM / Kimi 等国产大模型，成本降低 30-50 倍。

### 核心架构

```
Codex 桌面版 App  →  Codex++ 增强器（CDP 注入）  →  国产模型 API
                                                   ├── DeepSeek (deepseek-v4-pro)
                                                   ├── 通义千问 (qwen-coder-plus)
                                                   ├── 智谱 GLM (glm-4-plus)
                                                   └── Kimi (moonshot-v1-128k)
```

### 快速开始

**第一步：安装 Codex 桌面版**
- 从 [openai.com](https://openai.com) 或 Microsoft Store 下载

**第二步：安装 Codex++ 增强器**
- 从 GitHub Releases 下载对应平台版本
- 零污染 CDP 注入，不影响原版 Codex

**第三步：配置国产模型供应商**
1. 打开 Codex++ 管理工具 → 供应商管理
2. 添加供应商，如 DeepSeek：
   - 模型 ID: `deepseek-v4-pro`
   - Base URL: `https://api.deepseek.com`
   - 上游协议: Chat Completions
3. 设为"当前使用"

### 5 家国产模型适配

| 厂商 | 推荐模型 | 上下文 | 成本（$/M tokens） |
|------|---------|--------|-------------------|
| DeepSeek | deepseek-v4-pro | 128K | ~$0.5 |
| 通义千问 | qwen-coder-plus | 128K | ~$0.8 |
| 智谱 GLM | glm-4-plus | 128K | ~$0.8（flash 免费） |
| Kimi | moonshot-v1-128k | 128K | ~$0.6 |
| 豆包 | doubao-pro | 128K | ~$0.5 |

> 对比 GPT-5.5（$15-30/M tokens），国产模型便宜 30-50 倍。

### 适用场景
- 希望使用国产大模型降低 AI 编程成本
- 国内网络环境下稳定使用 AI 编程助手
- 不同任务切换不同国产模型

---

## 目录结构

```
claudecode-toolkit/
├── 1-claudeCode/                              # Claude Code 生态
│   ├── 01-claude-ccswitch-安装配置/           #   CC-Switch 安装配置指南
│   ├── 02-claude-optimize-调优方案/           #   调优方案（核心）
│   │   ├── 01global-全局级可复制配置/         #     全局配置模板 → ~/.claude/
│   │   ├── 02templates-项目级可复制文件目录/  #     项目模板（完整可拷贝）
│   │   ├── .claude/                           #     当前项目的工作配置
│   │   └── scripts/                           #     部署脚本
│   └── 03-claude-vscode-plugin-百炼Trae接入/  #   VSCode/Trae 插件接入指南
│
├── 2-codex/                                   # Codex 生态
│   └── 01-codex-codex++/                      #   Codex++ 国产大模型落地指南
│
├── docs/                                      # GitHub Pages 部署（交互式文档）
│   ├── demo.html                              #   统一入口：两大产品线概览
│   ├── claude-code.html                       #   Claude Code 方案综合页
│   └── codex-codexpp.html                     #   Codex++ 方案综合页
│
├── 任务提示词.txt
└── 目录说明.md                                #   详细目录说明
```

---

## 新手上路

### 场景一：初次使用 Claude Code

1. 阅读 `1-claudeCode\03-claude-vscode-plugin-百炼Trae接入\` → 完成插件安装
2. 阅读 `1-claudeCode\01-claude-ccswitch-安装配置\` → 安装 CC-Switch
3. 运行一键部署脚本完成调优配置
4. 按需安装提效工具

### 场景二：初次使用 Codex + 国产模型

1. 阅读 `2-codex\01-codex-codex++\Codex++桌面版-国产大模型落地指南.md`
2. 安装 Codex 桌面版 + Codex++ 增强器
3. 按指南配置首个国产模型（推荐 DeepSeek）

### 场景三：新项目复用

```powershell
# 复制项目模板到新项目
Copy-Item "1-claudeCode\02-claude-optimize-调优方案\02templates-项目级可复制文件目录\*" "D:\new-project\" -Recurse
# 修改 CLAUDE.md 中的项目信息
# 按需删除不需要的 rules/agents/skills
```

---

## 参考来源

| 来源 | 说明 |
|------|------|
| [Karpathy CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills) | 行为准则四原则（⭐87.6K） |
| [caveman](https://github.com/juliusbrussee/caveman) | 响应压缩（⭐41K） |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 4 个 Skills（⭐44K+） |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 6 个 Skills（⭐22.8K） |
| [rtk](https://github.com/rtk-ai/rtk) | CLI 输出过滤（⭐31K） |
| [ccusage](https://github.com/ryoppippi/ccusage) | Token 用量监控（⭐13K） |
| [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code) | — |
| [Codex++](https://github.com/microsoft/codex) | Codex 桌面增强器 |

---

## License

MIT
