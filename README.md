# Claude Code 调优方案（可复用版）

> 一套可复用的 Claude Code 高效工作环境配置，覆盖产品/设计/研发/测试/部署全链路。新环境 30 分钟内完成全套部署。

[![Claude Code](https://img.shields.io/badge/Claude-Code-6366f1?style=flat-square&logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=flat-square)]()
[![GitHub Pages](https://img.shields.io/badge/Preview-GitHub%20Pages-28a745?style=flat-square&logo=github)](https://renp666.github.io/claudecode-pages/demo.html)

---

## 在线预览

**[Claude Code 调优方案 — 交互式文档](https://renp666.github.io/claudecode-pages/demo.html)**

包含页面：
- [首页](https://renp666.github.io/claudecode-pages/demo.html) — 四层架构概览、核心能力、实施路径
- [方案概览](https://renp666.github.io/claudecode-pages/overview.html) — 核心问题、四层架构详解、环境规划
- [核心能力](https://renp666.github.io/claudecode-pages/capabilities.html) — CLAUDE.md、Rules、Hooks、Commands、Agents、Skills
- [实施路径](https://renp666.github.io/claudecode-pages/roadmap.html) — 三阶段时间线、Skills 评估、CC-Switch
- [效果数据](https://renp666.github.io/claudecode-pages/metrics.html) — Token 管理、命令速查、会话策略
- [快速上手](https://renp666.github.io/claudecode-pages/quickstart.html) — 前置条件、一键部署、手动部署、验证清单

---

## 这是什么？

一套经过实战验证的 Claude Code 配置体系，解决以下问题：

| 问题 | 本方案的解决方式 |
|------|----------------|
| Token 浪费严重 | 输出压缩（caveman）+ CLI 过滤（rtk）+ 会话管理策略 |
| Claude 做的不是你想要的 | Karpathy 四原则 + 需求对齐（grill-with-docs） |
| 每次新会话从零开始 | CLAUDE.md 分层记忆 + 13 个 Skills + 7 个 Agents |
| 配置无法复用 | 全局模板 + 项目模板 + 一键部署脚本 |

## 核心特性

### 四层优化架构

```
第 4 层  工程化层    自定义 Commands / 7 个角色型智能体 / 13 个 Skills / MCP 服务器
第 3 层  效率层      输出压缩（rtk + caveman）/ 成本监控（ccusage）/ Token 管理
第 2 层  行为约束层  CLAUDE.md 分层 / Rules 模块化 / Hooks 守卫 / 权限白名单
第 1 层  基础层      Claude Code CLI + CC-Switch + Node.js + Git
```

### Skills 覆盖全生命周期（13 个）

```
DEFINE          PLAN           BUILD          VERIFY         REVIEW          SHIP
┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
│ Spec │ ───▶ │ Task │ ───▶ │ Code │ ───▶ │ Test │ ───▶ │  QA  │ ───▶ │ Live │
│      │      │      │      │      │      │      │      │      │      │      │
└──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
 /spec          /plan         UI/API        /tdd          /review        /ship
                              构建          /diagnose     /simplify
```

### 角色型智能体（7 个）

| 角色 | 用途 | 隔离上下文 |
|------|------|-----------|
| UI 设计师 | 视觉一致性、组件质量、无障碍 | ✅ |
| 前端架构师 | 组件架构、状态管理、性能 | ✅ |
| 代码审查员 | 安全漏洞、正确性、性能、可维护性 | ✅ |
| 安全扫描器 | 注入漏洞、认证授权、敏感数据 | ✅ |
| 性能分析器 | 前端/后端/资源瓶颈 | ✅ |
| API 测试专家 | 契约测试、功能测试、安全测试 | ✅ |
| 文档生成器 | API 文档、README、代码注释 | ✅ |

---

## 快速开始

### 方式一：一键部署（推荐）

```powershell
# 克隆仓库
git clone https://github.com/renp666/claudecode-toolkit.git
cd claudecode-toolkit

# 部署全部配置到目标项目
.\03-claude-optimize\scripts\setup-claude.ps1 -Phase all -ProjectDir "D:\your-project"

# 安装提效工具（可选）
.\03-claude-optimize\.claude_global\tools\install-tools.ps1 -Tool all -AddToPath
```

### 方式二：手动部署

```powershell
# 1. 部署全局配置
Copy-Item "03-claude-optimize\.claude_global\CLAUDE.md" "$env:USERPROFILE\.claude\CLAUDE.md"
Copy-Item "03-claude-optimize\.claude_global\commands\*.md" "$env:USERPROFILE\.claude\commands\"

# 2. 部署项目配置（templates 包含完整 .claude 结构）
$proj = "D:\your-project"
Copy-Item "03-claude-optimize\templates\CLAUDE.md" "$proj\CLAUDE.md"
Copy-Item "03-claude-optimize\templates\.mcp.json" "$proj\.mcp.json"
Copy-Item "03-claude-optimize\templates\.claude" "$proj\.claude" -Recurse

# 3. 根据技术栈按需添加专用规则
Copy-Item "03-claude-optimize\templates\.claude\rules\vue3.md" "$proj\.claude\rules\"
Copy-Item "03-claude-optimize\templates\.claude\rules\typescript.md" "$proj\.claude\rules\"
```

### 方式三：分阶段部署

```powershell
# 阶段一：核心配置（CLAUDE.md + Rules + Hooks + Commands）
.\03-claude-optimize\scripts\setup-claude.ps1 -Phase 1

# 阶段二：提效增强（工具 + 监控，需先完成阶段一）
.\03-claude-optimize\scripts\setup-claude.ps1 -Phase 2 -ProjectDir "D:\your-project"

# 阶段三：高级扩展（Skills + Agents，需先完成阶段二）
.\03-claude-optimize\scripts\setup-claude.ps1 -Phase 3 -ProjectDir "D:\your-project"
```

---

## 目录结构

```
ClaudeCode/
├── 01-claude-vscode-plugin/           # Claude VSCode 插件安装指南
├── 02-claude-ccswitch/                # Claude + CC-Switch 安装指南
├── 03-claude-optimize/                # 调优方案（核心）
│   ├── CLAUDE.md                      #   项目行为准则（Karpathy 四原则）
│   ├── claude调优方案.md              #   主文档：9 章完整方案
│   │
│   ├── .claude_global/                #   全局配置模板 → ~/.claude/
│   │   ├── CLAUDE.md                  #     全局行为准则
│   │   ├── commands/                  #     全局命令（/review, /fix-issue）
│   │   └── tools/                     #     工具安装脚本
│   │
│   ├── templates/                     #   项目模板（完整可拷贝）
│   │   ├── CLAUDE.md                  #     项目上下文模板
│   │   ├── .mcp.json                  #     MCP 服务器配置
│   │   └── .claude/                   #     完整 .claude 结构
│   │       ├── settings.json
│   │       ├── rules/                 #       9 个规则（通用 + 技术栈）
│   │       ├── commands/              #       2 个命令
│   │       ├── agents/                #       7 个智能体
│   │       └── skills/                #       13 个技能
│   │
│   ├── .claude/                       #   当前项目的工作配置
│   └── scripts/                       #   部署脚本
│
├── 任务提示词.txt
└── 目录说明.md                        #   本文档
```

---

## 配置详解

### CLAUDE.md 分层体系

| 层级 | 文件位置 | 内容 | 加载时机 |
|------|---------|------|---------|
| 全局 | `~/.claude/CLAUDE.md` | Karpathy 四原则 + 行为准则 | 所有项目自动加载 |
| 项目 | `<project>/CLAUDE.md` | 项目信息 + 技术栈 + 常用命令 | 进入项目目录时加载 |

核心原则（源自 [Karpathy CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills)）：

1. **思考先行** — 不假设，暴露权衡
2. **简洁优先** — 最小代码，不投机
3. **精准变更** — 只改必须改的
4. **目标驱动** — 定义成功标准，循环验证

### Rules 模块化

通用基线（所有项目）：
- `frontend.md` — 组件单一职责、TypeScript strict、CSS Modules/Tailwind
- `backend.md` — 输入验证、AppError、事务保护、超时重试
- `testing.md` — describe > it > expect、独立测试、Mock 外部依赖

技术栈专用（按需拷贝）：
- `vue2.md` / `vue3.md` / `react.md` / `typescript.md` / `python.md` / `go.md`

### Hooks 守卫

```json
{
  "PreToolUse": "拦截危险命令（rm -rf /、git push --force、DROP TABLE）",
  "PostToolUse": "文件修改后提醒运行 lint/test",
  "Stop": "验收提醒：变更摘要 + 验证结果 + 风险点"
}
```

### 工具安装

```powershell
# 一键安装全部工具
.\03-claude-optimize\.claude_global\tools\install-tools.ps1 -Tool all -AddToPath

# 单独安装
.\install-tools.ps1 -Tool rtk       # CLI 输出过滤（减少 50-90% Token）
.\install-tools.ps1 -Tool ccusage   # Token 用量监控
.\install-tools.ps1 -Tool monitor   # 实时限额预警
```

---

## 使用场景

### 场景一：新项目初始化

```powershell
# 复制 templates 到新项目
Copy-Item "03-claude-optimize\templates\*" "D:\new-project\" -Recurse
# 修改 CLAUDE.md 中的项目信息
# 按需删除不需要的 rules/agents/skills
```

### 场景二：已有项目增强

```powershell
# 只添加 .claude 配置
Copy-Item "03-claude-optimize\templates\.claude" "D:\existing-project\.claude" -Recurse
# 添加项目级 CLAUDE.md
Copy-Item "03-claude-optimize\templates\CLAUDE.md" "D:\existing-project\CLAUDE.md"
```

### 场景三：全局配置更新

```powershell
# 更新全局行为准则
Copy-Item "03-claude-optimize\.claude_global\CLAUDE.md" "$env:USERPROFILE\.claude\CLAUDE.md"
# 更新全局命令
Copy-Item "03-claude-optimize\.claude_global\commands\*.md" "$env:USERPROFILE\.claude\commands\"
```

---

## 技术栈支持

| 技术栈 | Rules 文件 | 适用场景 |
|--------|-----------|---------|
| Vue 2 + JS/JSX | `vue2.md` | Options API、Vuex、scoped CSS |
| Vue 3 + TS/TSX | `vue3.md` | Composition API、Pinia、composables |
| React + TSX | `react.md` | 函数组件 + Hooks、React Query |
| TypeScript 通用 | `typescript.md` | strict mode、泛型、工具类型 |
| Python 3.10+ | `python.md` | Ruff、Pydantic、async/httpx |
| Go 1.21+ | `go.md` | errgroup、table-driven tests |

---

## 参考来源

| 来源 | Stars | 链接 |
|------|-------|------|
| Karpathy CLAUDE.md | 87.6K | https://github.com/forrestchang/andrej-karpathy-skills |
| caveman | 41K | https://github.com/juliusbrussee/caveman |
| mattpocock/skills | 44K+ | https://github.com/mattpocock/skills |
| addyosmani/agent-skills | 22.8K | https://github.com/addyosmani/agent-skills |
| rtk | 31K | https://github.com/rtk-ai/rtk |
| ccusage | 13K | https://github.com/ryoppippi/ccusage |
| Claude Code 官方文档 | — | https://docs.anthropic.com/en/docs/claude-code |

---

## License

MIT
