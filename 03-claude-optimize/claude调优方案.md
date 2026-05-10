# Claude Code 调优方案（可复用版）

> **当前状态**：Claude Code CLI + CC-Switch 已调通
> **目标**：建立一套可复用的 Claude Code 高效工作环境，覆盖产品/设计/研发/测试/部署/办公全链路
> **原则**：功能在精不在多，先稳定再增强，一切可验证
> **最后更新**：2026-05-10

---

## 目录

- [0. 核心问题与优化策略](#0-核心问题与优化策略)
  - [0.1 效率瓶颈](#01-效率瓶颈)
  - [0.2 四层优化架构](#02-四层优化架构)
- [1. 环境规划（全局 + 项目模板）](#1-环境规划全局--项目模板)
  - [1.1 设计思路](#11-设计思路)
  - [1.2 全局目录（用户级）](#12-全局目录用户级)
  - [1.3 项目模板目录（可拷贝复用）](#13-项目模板目录可拷贝复用)
  - [1.4 前置条件](#14-前置条件)
- [2. 阶段一：核心配置（建立稳定基础）](#2-阶段一核心配置建立稳定基础)
  - [2.1 CLAUDE.md 分层配置](#21-claudemd-分层配置)
  - [2.2 Rules 模块化](#22-rules-模块化)
  - [2.3 Hooks 基础守卫](#23-hooks-基础守卫)
  - [2.4 权限白名单](#24-权限白名单)
  - [2.5 自定义命令（.claude/commands/）](#25-自定义命令claudecommands)
  - [2.6 阶段一验收](#26-阶段一验收)
- [3. 阶段二：提效增强（减少 Token 浪费与重复操作）](#3-阶段二提效增强减少-token-浪费与重复操作)
  - [3.1 Token/成本监控](#31-token成本监控)
  - [3.2 输出压缩](#32-输出压缩)
  - [3.3 常用 MCP 服务器](#33-常用-mcp-服务器)
  - [3.4 阶段二验收](#34-阶段二验收)
- [4. 阶段三：高级扩展（按需引入）](#4-阶段三高级扩展按需引入)
  - [4.1 mattpocock/skills（工程纪律技能包）](#41-mattpocockskills工程纪律技能包)
  - [4.2 角色型智能体——完整解决方案](#42-角色型智能体完整解决方案)
    - [4.2.1 Trae IDE vs Claude Code：能力对比](#421-trae-ide-vs-claude-code能力对比)
    - [4.2.2 统一角色体系（7 个核心角色）](#422-统一角色体系7-个核心角色)
    - [4.2.3 Claude Code Sub-agents 完整配置](#423-claude-code-sub-agents-完整配置)
    - [4.2.4 统一触发矩阵](#424-统一触发矩阵)
    - [4.2.5 部署 Checklist](#425-部署-checklist)
  - [4.3 第三方 Skills（按需引入）](#43-第三方-skills按需引入)
  - [4.4 可选工具](#44-可选工具)
- [5. 不纳入基线清单（避免复杂化）](#5-不纳入基线清单避免复杂化)
- [6. Token 管理最佳实践](#6-token-管理最佳实践)
  - [6.1 上下文窗口规则](#61-上下文窗口规则)
  - [6.2 原生命令速查](#62-原生命令速查)
  - [6.3 会话管理原则](#63-会话管理原则)
  - [6.4 每日工作流](#64-每日工作流)
- [7. CC-Switch 模型切换规范](#7-cc-switch-模型切换规范)
  - [7.1 稳定切换规则](#71-稳定切换规则)
  - [7.2 切换后固定执行](#72-切换后固定执行)
  - [7.3 常见错误](#73-常见错误)
- [8. 快速部署 Checklist（新环境复用）](#8-快速部署-checklist新环境复用)
- [9. 参考来源](#9-参考来源)

---

## 0. 核心问题与优化策略

### 0.1 效率瓶颈

Claude Code 的效率瓶颈不在模型能力，而在**上下文管理**：

| 问题 | 表现 | 根因 |
|------|------|------|
| Token 浪费 | 一次会话消耗 80K-200K Token，大部分是冗余输出 | CLI 命令输出未过滤、响应风格冗长 |
| 上下文腐烂 | 长会话后 Claude 开始"犯糊涂"、矛盾、遗忘 | 超过 120K Token 后检索准确率显著下降 |
| 需求偏差 | Claude 做的不是你想要的 | 缺少实现前的需求对齐机制 |
| 无法复用 | 每次新会话从零开始 | 缺少跨会话记忆和项目知识沉淀 |

### 0.2 四层优化架构

架构逻辑：**能用 → 做对 → 高效 → 工程化**，逐层递进，每层依赖下层。

```
┌──────────────────────────────────────────────────────────────┐
│  第 4 层：工程化层                                             │
│  "规模化协作"                                                  │
│  ├─ 自定义 Commands（review/deploy/fix-issue，复用高频操作）   │
│  ├─ 角色型智能体（7 个角色，按需调用，上下文隔离）              │
│  ├─ Skills（mattpocock/skills，工程纪律流程）                 │
│  └─ MCP 服务器（GitHub/Filesystem，扩展外部能力）             │
├──────────────────────────────────────────────────────────────┤
│  第 3 层：效率层                                               │
│  "用更少 Token 做更多事"                                       │
│  ├─ 输出压缩：rtk（CLI 输出过滤）+ caveman（响应风格压缩）    │
│  ├─ 成本监控：ccusage（用量分析）+ Usage Monitor（实时预警）   │
│  └─ Token 管理：/clear（切话题）、/compact（压缩）、/context  │
├──────────────────────────────────────────────────────────────┤
│  第 2 层：行为约束层                                           │
│  "让 Claude 做对事"                                            │
│  ├─ CLAUDE.md（全局 + 项目分层，定义行为准则）                 │
│  ├─ Rules（.claude/rules/，按模块拆分路径化规则）             │
│  ├─ Hooks（PreToolUse/PostToolUse/Stop，确定性守卫）          │
│  └─ 权限白名单（/permissions，减少重复确认）                  │
├──────────────────────────────────────────────────────────────┤
│  第 1 层：基础层（已就绪）                                     │
│  "能跑起来"                                                    │
│  ├─ Claude Code CLI + CC-Switch                               │
│  ├─ Node.js + Git + PowerShell 7                              │
│  └─ 网络/代理/密钥配置                                        │
└──────────────────────────────────────────────────────────────┘
```

**各层与文档章节对应关系**：

| 层级 | 核心目标 | 对应章节 |
|------|---------|---------|
| 第 1 层：基础层 | 能用 | [§1.4 前置条件](#14-前置条件) |
| 第 2 层：行为约束层 | 做对 | [§2. 阶段一：核心配置](#2-阶段一核心配置建立稳定基础) |
| 第 3 层：效率层 | 高效 | [§3. 阶段二：提效增强](#3-阶段二提效增强减少-token-浪费与重复操作)、[§6. Token 管理](#6-token-管理最佳实践) |
| 第 4 层：工程化层 | 规模化 | [§4. 阶段三：高级扩展](#4-阶段三高级扩展按需引入) |

---

## 1. 环境规划（全局 + 项目模板）

### 1.1 设计思路

- **全局目录**（`~/.claude/`）：放"所有项目都通用"的行为准则、常用命令、用户级设置
- **项目目录**（`<project>/.claude/`）：放"只对这个项目有意义"的规则、命令、技能
- **项目模板**：可将项目级配置整体拷贝到新项目，实现快速复用

### 1.2 全局目录（用户级）

> 已落地到本地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude_global\`

```
~/.claude/
  CLAUDE.md                # 全局行为准则
  settings.json            # 用户级设置（hooks、权限、MCP）
  commands/                # 个人常用命令（所有项目共享）
    review.md
    fix-issue.md
  tools/                   # 放置单文件工具（如 rtk），便于统一管理与加入 PATH
    install-tools.ps1      # 一键下载安装工具（rtk/ccusage/claude-monitor）
    README.md
```

### 1.3 项目模板目录（可拷贝复用）

> 已落地到本地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude\` + `d:\开发环境安装\ClaudeCode\03-claude-optimize\templates\`

```
<project>/
  CLAUDE.md                # 项目专属上下文（模板见 templates/CLAUDE.md）
  .mcp.json                # MCP 服务器配置（模板见 templates/.mcp.json）
  .claude/
    settings.json          # 项目级设置（hooks 守卫）
    rules/                 # 路径化规则（按模块拆分）
      frontend.md
      backend.md
      testing.md
    commands/              # 项目专属命令
      deploy.md
      test-plan.md
    agents/                # 角色型智能体（7 个，按需调用）
      ui-designer.md
      frontend-architect.md
      code-reviewer.md
      security-scanner.md
      performance-analyzer.md
      api-tester.md
      doc-generator.md
    skills/                # 项目专属技能（13 个，按需启用）
      addyosmani-spec-driven-development/SKILL.md
      addyosmani-planning-and-task-breakdown/SKILL.md
      addyosmani-frontend-ui-engineering/SKILL.md
      addyosmani-api-and-interface-design/SKILL.md
      addyosmani-code-simplification/SKILL.md
      addyosmani-shipping-and-launch/SKILL.md
      mattpocock-grill-with-docs/SKILL.md
      mattpocock-tdd/SKILL.md
      mattpocock-diagnose/SKILL.md
      caveman/SKILL.md
      cache-components/SKILL.md
      frontend-code-review/SKILL.md
      webapp-testing/SKILL.md
```

> **复用方式**：将整个 `.claude/` 目录 + `CLAUDE.md` + `.mcp.json` 拷贝到新项目，按项目实际情况修改即可。
> **一键部署**：使用 `scripts\setup-claude.ps1`，详见 §8。

### 1.4 前置条件

- **Node.js**（用于 `npx` 安装 ccusage / MCP servers）
- **Git**（用于配合 Claude Code 工作流）
- **Python 3.x**（仅当使用 `claude-monitor` 时需要）
- **Windows 用户**建议安装 **PowerShell 7（pwsh）**，用于 hooks/脚本一致性

---

## 2. 阶段一：核心配置（建立稳定基础）

> 目标：让 Claude Code 在每个项目中都能"正确做事"——知道项目规范、自动验证、减少重复确认。

### 2.1 CLAUDE.md 分层配置

Claude Code 支持**多级 CLAUDE.md**，按作用域自动叠加加载。

#### 第一层：全局行为准则（用户级）

> 已落地到本地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude_global\CLAUDE.md`

放置在 `%USERPROFILE%\.claude\CLAUDE.md`（Windows）或 `~/.claude/CLAUDE.md`（macOS/Linux）。

**内容原则**：只放通用行为约束，不超过 50 行。避免堆砌过多指令——LLM 一致性遵循能力约 150-200 条，Claude Code 系统提示已占用约 50 条。

已落地文件内容（融合 Karpathy 四原则）：

```md
# 全局行为准则
> 基础版：参考 Karpathy CLAUDE.md（⭐87.6K）四原则，结合实际工程实践融合而成。

## 1. 思考先行（Think Before Coding）
- 不确定时主动提问，不假设——声明你的假设
- 存在多种实现方式时，列出各方案的权衡，不偷偷选一种
- 有更简洁的方案就主动提出，必要时反驳不合理需求
- 遇到困惑立即停下，明确说出哪里不清楚

## 2. 简洁优先（Simplicity First）
- 只做被要求的功能，不添加"灵活性"和"可扩展性"
- 一次性代码不做抽象；不为不可能的场景写错误处理
- 如果 200 行能缩到 50 行，重写它
- 测试标准：高级工程师会觉得过度设计吗？如果是，简化

## 3. 精准变更（Surgical Changes）
- 只改必须改的，不顺手"改进"旁边的代码/注释/格式
- 不重构没坏的东西，匹配现有风格
- 你的变更产生的孤立代码（无用 import/变量/函数）必须清理
- 预存在的死代码只报告，不删除（除非被要求）

## 4. 目标驱动（Goal-Driven Execution）
- 将任务转化为可验证的目标，用测试循环验证直到通过
- 多步任务先列计划：`[步骤] → 验证: [检查点]`

## 5. 输出与边界
- 响应精简，避免重复叙述
- 代码变更后给出：变更摘要、验证结果、风险点
- 不添加未被要求的注释；不修改未被明确要求的文件
- 不引入未在项目中使用过的第三方库；不在代码中硬编码密钥
```

> **来源**：[andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)（⭐87.6K），原版为 4 条原则共 30 行。本模板融合了"输出与边界"（工程实践）为第 5 节，总计 38 行。
> **权衡说明**：四原则偏向"谨慎优先于速度"，简单任务（typo 修复、明显单行修改）无需严格遵循，自行判断。

Windows 部署命令：
```powershell
# 方式一：使用一键脚本（推荐）
.\scripts\setup-claude.ps1 -Phase 1

# 方式二：手动部署
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude" | Out-Null
Copy-Item ".claude_global\CLAUDE.md" "$env:USERPROFILE\.claude\CLAUDE.md"
Copy-Item ".claude_global\commands\*.md" "$env:USERPROFILE\.claude\commands\"
```

#### 第二层：项目专属配置（项目级）

在项目根目录创建 `CLAUDE.md`，只写项目专属内容，**不重复**全局已有的行为准则：

> 已落地模板：`d:\开发环境安装\ClaudeCode\03-claude-optimize\templates\CLAUDE.md`

```md
# 项目上下文

## 项目信息
- 项目目标：[一句话描述]
- 技术栈：[前端/后端/数据库/部署]
- 成功指标：[可量化的标准]

## 目录结构
- `src/`：源代码
- `tests/`：测试
- `docs/`：文档

## 常用命令
- 安装：`npm install`
- 启动：`npm run dev`
- 测试：`npm test`
- 构建：`npm run build`
- Lint：`npm run lint`

## 编码规范
- 语言：TypeScript strict mode
- 测试：新功能必须有测试
- 提交：conventional commits

## Token 管理
- 响应尽量精简
- 话题切换时建议 /clear 开启新会话
```

> **加载顺序**：先加载用户级 → 再加载项目级，两者叠加生效。
> **便捷方式**：也可在项目中运行 `/init`，Claude 会自动分析代码库并生成初始 CLAUDE.md。

### 2.2 Rules 模块化

> 已落地到本地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude\rules\`

```powershell
New-Item -ItemType Directory -Force ".claude\rules" | Out-Null
```

**frontend.md**（`.claude/rules/frontend.md`）：
```md
---
globs: ["frontend/**", "src/components/**"]
---
- 组件单一职责，不超过 200 行
- 使用 TypeScript strict mode
- 样式使用 CSS Modules 或 Tailwind
- 优先使用现有公共组件，避免重复实现
```

**backend.md**（`.claude/rules/backend.md`）：
```md
---
globs: ["backend/**", "src/api/**", "src/services/**"]
---
- API 必须有输入验证
- 错误统一使用 AppError 类
- 数据库操作必须有事务保护
- 所有外部调用必须有超时和重试
```

**testing.md**（`.claude/rules/testing.md`）：
```md
---
globs: ["**/*.test.*", "**/*.spec.*"]
---
- 测试命名：describe > it > expect
- 每个测试独立，不依赖执行顺序
- Mock 外部依赖，不 Mock 被测单元
- 覆盖正常路径 + 边界条件 + 错误处理
```

#### 2.2.1 技术栈差异化规则（按需拷贝）

以上 3 个 rules 是**通用基线**，适用于任何项目。但不同技术栈有截然不同的编码模式——Vue 2（Options API）和 Vue 3（Composition API）的写法完全不同，TypeScript 和 Python 的规则差异巨大。

**策略**：通用 rules 保留为基线 + 在 `templates/.claude/rules/` 下提供**技术栈专用规则模板**，按需拷贝到项目的 `.claude/rules/` 目录。

> 已落地模板目录：`d:\开发环境安装\ClaudeCode\03-claude-optimize\templates\.claude\rules\`

| 模板文件 | 适用技术栈 | 核心规则要点 |
|---------|-----------|------------|
| `vue2.md` | Vue 2 + JS/JSX | Options API、Vuex、scoped CSS、`v-for :key` |
| `vue3.md` | Vue 3 + TS/TSX | Composition API + `<script setup>`、Pinia、composables |
| `react.md` | React + TSX | 函数组件 + Hooks、React Query、Context 边界 |
| `typescript.md` | TypeScript 通用 | strict mode、泛型命名、工具类型、`export type` |
| `python.md` | Python 3.10+ | Ruff、Pydantic、async/httpx、pyproject.toml + uv |
| `go.md` | Go 1.21+ | errgroup、接口小而精、table-driven tests |

**使用方式**：
```powershell
# 例如：Vue 3 + TypeScript 项目
Copy-Item "templates\.claude\rules\vue3.md" "D:\my-vue-app\.claude\rules\vue3.md"
Copy-Item "templates\.claude\rules\typescript.md" "D:\my-vue-app\.claude\rules\typescript.md"

# 例如：Python 后端项目
Copy-Item "templates\.claude\rules\python.md" "D:\my-api\.claude\rules\python.md"
```

> **注意**：通用 rules（frontend/backend/testing）和栈专用 rules 会按 glob 匹配**同时生效**，无需删除通用规则。栈专用规则更具体，会覆盖通用规则中的重叠部分。

### 2.3 Hooks 基础守卫

编辑 `.claude/settings.json`（项目级）：

> 已落地到本地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude\settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const input=require('fs').readFileSync('/dev/stdin','utf8');const d=JSON.parse(input);if(/rm\\s+-rf\\s+[\\/]|git\\s+push\\s+.*--force|DROP\\s+TABLE|format\\s+[a-z]:/i.test(d.tool_input?.command||'')){console.error('BLOCKED: dangerous command');process.exit(1)}\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo '文件已修改，请确认是否需要运行 lint/test'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '验收提醒：请确认输出包含 1)变更摘要 2)验证结果 3)风险点'"
          }
        ]
      }
    ]
  }
}
```

> **来源**：[Hooks Guide](https://code.claude.com/docs/en/hooks-guide)、[Hooks Blog](https://claude.com/blog/how-to-configure-hooks)
> **说明**：Hooks 是"保证型机制"——提示只是建议，Hook 是保证。上述为基础模板，实际项目中应替换为真实的 lint/test 命令。

### 2.4 权限白名单

在 Claude Code 中执行 `/permissions`，将常用安全命令加入白名单，避免重复确认：

```
npm run lint
npm test
npm run build
git status
git diff
git log
```

> **来源**：[Best Practices > Configure permissions](https://code.claude.com/docs/en/best-practices)

### 2.5 自定义命令（.claude/commands/）

自定义命令是高频操作的快捷入口，写一次、处处可用。

**review.md**（全局：`~/.claude/commands/review.md`）
> 已落地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude_global\commands\review.md`
```md
---
description: 审查代码质量与潜在问题
allowed-tools: Read, Bash(git:*)
---

审查当前分支的代码变更：

1. 读取 `git diff` 了解变更范围
2. 检查：代码质量、潜在 bug、边界情况、性能问题
3. 检查：安全漏洞、错误处理、文档是否充分
4. 按严重程度分类输出：Critical / High / Medium / Low
```

**fix-issue.md**（全局：`~/.claude/commands/fix-issue.md`）
> 已落地：`d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude_global\commands\fix-issue.md`
```md
---
description: 分析并修复 GitHub Issue
argument-hint: issue-number
allowed-tools: Bash(gh:*), Read, Write
---

分析并修复 GitHub Issue: $ARGUMENTS

步骤：
1. 使用 `gh issue view $ARGUMENTS` 获取 Issue 详情
2. 阅读相关代码，定位问题根因
3. 制定修复方案并实现
4. 运行测试验证修复
5. 提交代码，commit message 关联 Issue
```

**deploy.md**（项目级：`.claude/commands/deploy.md`）：
```md
---
description: 部署前检查清单
allowed-tools: Bash(npm:*), Bash(git:*)
---

执行部署前检查：

1. 运行完整测试套件，确认全部通过
2. 运行 lint 检查，确认无错误
3. 检查环境变量配置
4. 确认数据库迁移状态
5. 检查回滚方案
6. 输出检查结果摘要，标注通过/失败项
```

**test-plan.md**（项目级：`.claude/commands/test-plan.md`）：
```md
---
description: 生成测试计划
allowed-tools: Read, Glob, Grep, Write
---

根据需求或变更生成测试计划。

1. 分析变更范围，确定影响的模块
2. 梳理正常路径、边界条件、错误处理场景
3. 推荐测试类型（单元/集成/E2E）和工具
4. 输出结构化测试计划（Markdown 表格）
5. 生成测试文件骨架（可选）
```

> **来源**：[Custom Slash Commands](https://code.claude.com/docs/en/best-practices#use-cli-tools)、[dotclaude.com/commands](https://dotclaude.com/commands)
> **说明**：命令文件名即为命令名——`review.md` → `/review`。全局命令（`~/.claude/commands/`）对所有项目生效，项目命令（`.claude/commands/`）仅对当前项目生效。

### 2.6 阶段一验收

```powershell
# 1. 全局 CLAUDE.md 存在
Get-Content "$env:USERPROFILE\.claude\CLAUDE.md" -TotalCount 5

# 2. 项目 CLAUDE.md 存在
Get-Content ".\CLAUDE.md" -TotalCount 5

# 3. Rules 目录存在
Get-ChildItem ".claude\rules"

# 4. settings.json 配置正确
Get-Content ".claude\settings.json"

# 5. 新会话自动加载上下文
claude  # 输入 /status 确认

# 6. 自定义命令可用
claude  # 输入 /review 应触发代码审查
```

---

## 3. 阶段二：提效增强（减少 Token 浪费与重复操作）

> 目标：在核心配置稳定运行后，引入工具减少 Token 消耗、提升响应速度。

### 3.1 Token/成本监控

**ccusage**——用量基线：
```bash
npx ccusage@latest daily
npx ccusage@latest monthly --breakdown
```

> **来源**：[ryoppippi/ccusage](https://github.com/ryoppippi/ccusage)（⭐13K）
> **作用**：没有基线数据，所有优化都是盲人摸象。

**Claude-Code-Usage-Monitor**——实时限额预警：
```bash
pip install claude-monitor
claude-monitor --plan max5    # Max5 计划
claude-monitor --plan max20   # Max20 计划
```

> **来源**：[Maciek-roboblog/Claude-Code-Usage-Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor)（⭐7.6K）

### 3.2 输出压缩

**rtk**——CLI 命令输出过滤（减少 50-90%）：

```powershell
# Windows: 从 https://github.com/rtk-ai/rtk/releases 下载 rtk.exe
# 建议放置到 ~/.claude/tools/rtk/ 并加入 PATH
rtk init -g
```

> **来源**：[rtk-ai/rtk](https://github.com/rtk-ai/rtk)（⭐31K）
> **注意**：仅对 Bash 工具调用生效，Claude 内置工具（Read/Grep/Glob）不经过 rtk。

**caveman**——响应风格压缩（减少 65-87%）：

SKILL.md 已落地到本地：
> `d:\开发环境安装\ClaudeCode\03-claude-optimize\.claude\skills\caveman\SKILL.md`

通过 mattpocock/skills 安装时自带 `/caveman` 命令。独立安装时将 SKILL.md 放置到 `.claude/skills/caveman/SKILL.md` 即可。

核心功能：
- 三档压缩强度：Lite（保留语法）/ Full（省略冠词）/ Ultra（电报式）
- 触发命令：`/caveman`、`/caveman lite|full|ultra`、`/caveman off`
- 扩展命令：`/caveman-commit`（提交信息压缩）、`/caveman-review`（审查压缩）
- 安全边界：安全审计、客户文档、法律合规场景不压缩
- 代码块、技术术语、错误信息始终保持原文

> **来源**：[juliusbrussee/caveman](https://github.com/juliusbrussee/caveman)（⭐41K）

### 3.3 常用 MCP 服务器

在项目根目录创建 `.mcp.json`：

> 已落地模板：`d:\开发环境安装\ClaudeCode\03-claude-optimize\templates\.mcp.json`

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

> **来源**：[MCP Servers 官方仓库](https://github.com/modelcontextprotocol/servers)
> **注意**：
> - 凭证通过环境变量注入，不要写入仓库
> - Windows 下路径使用正斜杠（`/`）或双反斜杠（`\\`）
> - 先用 `npx -y <package> --help` 验证包名是否可用
> - MCP 不要一次装太多，按需扩展

### 3.4 阶段二验收

```powershell
# 1. ccusage 有数据
npx ccusage@latest daily

# 2. rtk 过滤生效（运行 git status，输出应明显精简）
rtk git status

# 3. caveman 生效（输入 /caveman 后响应变为短句风格）

# 4. MCP 服务器连接正常（在 Claude 中输入 /mcp 查看状态）
```

---

## 4. 阶段三：高级扩展（按需引入）

> 目标：根据项目需要，逐步引入工程化工具和角色型智能体。

### 4.1 mattpocock/skills（工程纪律技能包）

```bash
npx skills@latest add mattpocock/skills
```

核心 Skills：

| Skill | 命令 | 用途 |
|-------|------|------|
| grill-with-docs | `/grill-with-docs` | 实现前需求对齐 + 构建 CONTEXT.md |
| tdd | `/tdd` | 红-绿-重构循环 |
| diagnose | `/diagnose` | 纪律化调试 |
| to-prd | `/to-prd` | 对话 → PRD → GitHub Issue |
| caveman | `/caveman` | 超压缩通信 |

> **来源**：[mattpocock/skills](https://github.com/mattpocock/skills)（⭐35.3K）

### 4.2 角色型智能体——完整解决方案

> 原则：不作为默认流程，仅在需要特定视角审阅时启用。每次任务只启用 1 个角色。

#### 4.2.1 Trae IDE vs Claude Code：能力对比

| 维度 | Trae IDE 内置智能体 | Claude Code Sub-agents |
|------|-------------------|----------------------|
| **配置方式** | IDE 内置，开箱即用 | `.claude/agents/*.md` 文件定义 |
| **触发方式** | Agent 对话模式自动匹配 | `@agent-name` 显式调用 或 Claude 自动委托 |
| **上下文隔离** | ❌ 共享主对话上下文 | ✅ 独立 context window，不污染主对话 |
| **工具权限控制** | ❌ 无法限制，继承全部 | ✅ `tools:` 字段精确控制（Read/Write/Bash 等） |
| **模型选择** | ❌ 继承主模型 | ✅ 可指定 haiku/sonnet/opus/inherit |
| **持久记忆** | ❌ 无 | ✅ `memory: project` 项目级记忆 |
| **自定义提示词** | ❌ 不可修改 | ✅ 完全自定义 |
| **并行执行** | ❌ 单次单角色 | ✅ 支持并行子代理（Agent Teams） |
| **角色数量** | 8 个内置 | 无限制，按需创建 |
| **复用到新环境** | 需安装 Trae IDE | 拷贝 `.claude/agents/` 目录即可 |

**结论**：
- **Trae IDE 优势**：零配置、快速上手、适合在 IDE 内日常使用
- **Claude Code 优势**：上下文隔离（核心）、权限精细控制、模型选择、持久记忆、可复用
- **最佳方案**：两者结合——IDE 内用 Trae 内置角色快速审阅，CLI 中用 Claude Code Sub-agents 做深度工程化任务

#### 4.2.2 统一角色体系（7 个核心角色）

基于 Trae IDE 内置角色 + Claude Code 官方最佳实践，设计以下 7 个覆盖全链路的角色。每个角色在 Trae IDE 中直接可用，在 Claude Code CLI 中通过 `.claude/agents/` 文件实现。

| # | 角色 | Trae IDE 内置 | Claude Code 需自建 | 适用阶段 |
|---|------|--------------|------------------|---------|
| 1 | UI 设计师 | ✅ `ui-designer` | 需自建 | 设计 |
| 2 | 前端架构师 | ✅ `frontend-architect` | 需自建 | 研发 |
| 3 | 后端架构师/代码审查员 | ✅ `backend-architect` | 需自建 | 研发 |
| 4 | 安全扫描器 | ❌ 无 | 需自建 | 审查/上线前 |
| 5 | 性能分析器 | ✅ `performance-expert-1` | 需自建 | 测试/优化 |
| 6 | API 测试专家 | ✅ `api-test-pro` | 需自建 | 测试 |
| 7 | 文档生成器 | ❌ 无 | 需自建 | 文档 |

> **说明**：Trae IDE 的 `compliance-checker`（法律合规）和 `ai-integration-eng`（AI集成）为特定场景角色，不在通用基线中。`devops-architect` 的职责可通过自定义命令 `/deploy` 覆盖。

#### 4.2.3 Claude Code Sub-agents 完整配置

以下为每个角色的完整 `.md` 文件，直接放入 `.claude/agents/` 目录即可使用。

**ui-designer.md**
```md
---
name: ui-designer
description: >
  UI 设计审阅与组件规范检查。Use when creating user interfaces,
  designing components, reviewing visual consistency, or building design systems.
tools: Read, Glob, Grep
model: sonnet
---

你是一位资深 UI 设计师。审阅时按以下维度逐项检查：

## 检查维度

### 1. 视觉一致性
- 颜色使用是否统一（检查是否使用设计 Token/CSS 变量，而非硬编码色值）
- 间距系统是否一致（4px/8px 网格）
- 字体层级是否清晰（标题/正文/辅助文字）

### 2. 组件质量
- 组件是否单一职责，不超过 200 行
- 是否有可复用的公共组件被重复实现
- Props 接口设计是否合理（避免 boolean 地狱）

### 3. 无障碍（WCAG 2.1）
- 图片是否有 alt 属性
- 表单元素是否有 label
- 颜色对比度是否满足 AA 标准（4.5:1）
- 键盘导航是否可用

### 4. 响应式适配
- 移动端布局是否正确
- 断点是否合理
- 触摸目标是否 >= 44px

## 输出格式
按严重程度分类：🔴 必须修复 / 🟡 建议改进 / 🟢 做得好的地方

## 规则
- 只报告真实的 UI/UX 问题，不报告代码风格偏好
- 如质量良好，直接说"UI 审查通过"，不硬凑反馈
```

**frontend-architect.md**
```md
---
name: frontend-architect
description: >
  前端架构审阅与组件实现检查。Use when reviewing React/Vue/Angular components,
  state management, frontend performance, or framework architecture decisions.
tools: Read, Glob, Grep, Bash
model: sonnet
---

你是一位资深前端架构师。审阅时关注以下维度：

## 检查维度

### 1. 组件架构
- 组件职责是否单一，层级是否清晰
- 是否存在不必要的 prop drilling（应使用 Context/Pinia/Redux）
- 组件间耦合度是否过高

### 2. 状态管理
- 状态是否放在正确的层级（本地 vs 全局）
- 是否存在不必要的全局状态
- 异步状态处理是否正确（loading/error/success）

### 3. 性能
- 是否存在不必要的重渲染（React.memo、useMemo、useCallback 使用是否合理）
- Bundle 体积是否有优化空间（代码分割、Tree Shaking）
- 图片/资源是否使用懒加载
- 列表是否使用虚拟滚动（>100 项时）

### 4. 工程规范
- TypeScript 类型定义是否完整
- 错误边界（Error Boundary）是否配置
- 路由守卫和权限控制是否完善

## 输出格式
**[严重程度: CRITICAL/WARNING/INFO]** `文件:行号`
问题描述 + 修复建议

## 规则
- 基于实际代码分析，不做猜测
- 关注架构层面问题，不纠结代码风格细节
```

**code-reviewer.md**
```md
---
name: code-reviewer
description: >
  代码审查员，覆盖后端 API、数据库、业务逻辑。Use proactively after code changes,
  when reviewing pull requests, or when asked to review code quality.
tools: Read, Glob, Grep, Bash
model: sonnet
memory: project
---

你是一位高级代码审查员。审查代码时按以下优先级逐项检查：

## 审查维度（按优先级）

### 1. 安全漏洞（最高优先级）
- SQL 注入、XSS、命令注入
- 硬编码密钥或凭据
- 不安全的反序列化
- 路径遍历

### 2. 正确性
- 空指针/边界条件
- 并发安全（共享状态、死锁风险）
- 资源泄漏（未关闭的连接、流）
- 错误处理是否完整

### 3. 性能
- N+1 查询
- 不必要的数据库调用或网络请求
- 大对象在循环内创建
- 缺失的索引（如果能看到 SQL）

### 4. 可维护性
- 方法过长（>30 行）
- 过深嵌套（>3 层）
- 命名不清晰

## 输出格式
**[严重程度: CRITICAL/WARNING/INFO]** `文件路径:行号`
问题描述（一句话）
建议修复方式（具体到代码级别）

## 规则
- 只报告真实问题，不报告风格偏好
- 如果代码质量好，直接说"没有发现问题"，不硬凑反馈
- 审查完后更新 agent memory，记录发现的模式和项目特有约定
```

**security-scanner.md**
```md
---
name: security-scanner
description: >
  安全漏洞扫描器。Use when explicitly asked for a security scan,
  or when reviewing authentication, file upload, database query, or API endpoint code.
tools: Read, Glob, Grep
model: sonnet
---

你是一位安全工程师。只关注安全漏洞，不报告风格或质量问题。

## 检查项（按优先级）

### 1. 注入漏洞
- SQL 注入：检查原始 SQL 拼接、ORM 误用
- XSS：检查未转义的用户输入渲染
- 命令注入：检查 shell 命令拼接
- 路径遍历：检查文件路径拼接

### 2. 认证/授权
- 认证逻辑缺陷（绕过、固定 session）
- 授权绕过（越权访问）
- 密钥硬编码（API Key、密码、Token）
- JWT 配置错误（无过期、弱密钥）

### 3. 敏感数据
- 日志中泄露敏感信息（密码、Token、身份证号）
- .env 文件是否在 .gitignore 中
- 加密算法是否安全（禁用 MD5/SHA1 用于密码）

### 4. 依赖安全
- 检查 package.json/requirements.txt 中是否有已知漏洞依赖
- 检查依赖版本是否过旧

## 输出格式
**[SEVERITY: CRITICAL/HIGH/MEDIUM/LOW]** `文件:行号`
漏洞描述 + 修复建议（具体到代码级别）

## 规则
- 只报告确认的安全漏洞，不报告猜测
- 如无安全问题，直接报告"未发现安全漏洞"
- 不报告代码风格或质量问题
```

**performance-analyzer.md**
```md
---
name: performance-analyzer
description: >
  性能分析与优化建议。Use when investigating slow page loads,
  high memory usage, database bottlenecks, or when asked to optimize performance.
tools: Read, Glob, Grep, Bash
model: sonnet
---

你是一位性能工程师。分析时按以下维度逐项检查：

## 检查维度

### 1. 前端性能
- Bundle 体积分析（是否有未使用的依赖）
- 首屏加载（关键渲染路径是否优化）
- 图片优化（格式、尺寸、懒加载）
- 第三方脚本影响（是否异步加载）

### 2. 后端性能
- 数据库查询（N+1、缺失索引、全表扫描）
- API 响应时间（是否有不必要的串行调用）
- 缓存策略（是否合理使用 Redis/CDN）
- 连接池配置

### 3. 资源使用
- 内存泄漏风险（事件监听器未移除、定时器未清理）
- 并发/锁竞争
- 文件句柄/连接未关闭

## 输出格式
**[影响: HIGH/MEDIUM/LOW]** `位置`
性能问题描述 + 量化影响（如"预计减少 50% 加载时间"）+ 优化建议

## 规则
- 基于实际代码分析，引用具体代码行
- 给出可量化的优化预期
- 优先修复 HIGH 影响项
```

**api-tester.md**
```md
---
name: api-tester
description: >
  API 测试专家。Use when generating API test cases, reviewing API contracts,
  designing load tests, or when asked to test API endpoints.
tools: Read, Glob, Grep, Write, Bash
model: sonnet
---

你是一位 API 测试专家。为 API 生成全面的测试用例。

## 工作流程
1. 阅读 API 定义（路由、Controller、Schema）
2. 分析请求/响应格式
3. 生成测试用例

## 测试覆盖维度

### 1. 契约测试
- 请求参数类型、必填项、边界值
- 响应格式与文档一致性
- HTTP 状态码正确性

### 2. 功能测试
- 正常流程（Happy Path）
- 边界条件（空值、极大值、特殊字符）
- 错误处理（4xx/5xx 响应）

### 3. 安全测试
- 未认证访问
- 越权访问（不同角色）
- 注入攻击（SQL/XSS）

### 4. 性能测试（基准）
- 单次响应时间基准
- 并发请求场景

## 输出格式
生成可直接运行的测试代码（优先 Jest/Vitest/pytest），包含：
- 测试文件
- 测试用例描述
- 断言

## 规则
- 测试必须可独立运行
- Mock 外部依赖
- 覆盖正常+异常路径
```

**doc-generator.md**
```md
---
name: doc-generator
description: >
  技术文档生成器。Use after feature additions, API changes,
  README updates, or when asked to generate or update documentation.
tools: Read, Glob, Grep, Write, Bash
model: sonnet
---

你是一位技术文档工程师。为代码生成清晰、准确的文档。

## 工作流程
1. 阅读相关代码，理解功能和 API
2. 检查现有文档是否过时
3. 生成或更新文档

## 输出要求

### API 文档
- 端点路径、方法、描述
- 请求参数（类型、必填、默认值）
- 响应格式（成功/失败）
- 使用示例（curl / 代码）

### README 格式
- 项目简介（一句话）
- 安装步骤
- 快速开始
- API 概览
- 贡献指南

### 代码注释
- 复杂逻辑添加说明
- 公共 API 添加 JSDoc/docstring

## 规则
- 不修改现有代码逻辑
- 文档风格与项目一致
- 语言简洁、结构清晰
- 包含可运行的代码示例
```

#### 4.2.4 统一触发矩阵

| 场景 | 在 Trae IDE 中（Agent 模式） | 在 Claude Code CLI 中 |
|------|---------------------------|---------------------|
| UI 组件设计/审查 | 描述需求，自动触发 `ui-designer` | `@ui-designer 审查登录表单组件` |
| 前端架构审查 | 描述需求，自动触发 `frontend-architect` | `@frontend-architect 审查状态管理方案` |
| 后端代码审查 | 描述需求，自动触发 `backend-architect` | `@code-reviewer 审查 src/api/ 最近变更` |
| 安全扫描 | 无内置角色，需手动描述 | `@security-scanner 扫描 src/ 认证模块` |
| 性能分析 | 描述需求，自动触发 `performance-expert-1` | `@performance-analyzer 分析首页加载性能` |
| API 测试 | 描述需求，自动触发 `api-test-pro` | `@api-tester 为 /api/users 生成测试用例` |
| 文档生成 | 无内置角色，需手动描述 | `@doc-generator 为 src/api/ 生成 API 文档` |

#### 4.2.5 部署 Checklist

```powershell
# 创建项目级 agents 目录
New-Item -ItemType Directory -Force ".claude\agents" | Out-Null

# 逐个创建 agent 文件（复制上述提示词内容）
# ui-designer.md / frontend-architect.md / code-reviewer.md
# security-scanner.md / performance-analyzer.md / api-tester.md / doc-generator.md

# 验证：在 Claude Code 中输入 /agents，应看到自建角色列表
# 调用：@code-reviewer 审查当前变更
```

> **来源**：
> - Claude Code 官方：[Sub-agents 文档](https://code.claude.com/docs/en/sub-agents)
> - Trae IDE 内置智能体：[Trae IDE 文档](https://docs.trae.ai/ide/custom-agents-ready-for-one-click-import?_lang=zh)
> - 实战参考：[腾讯云 - Claude Code 自定义 Agent 实战](https://cloud.tencent.com/developer/article/2657591)

### 4.3 第三方 Skills 评估与安装

> 评估 9 个开源 Skills 仓库，决策标准：**是否与现有 agents/commands/rules 冗余**、**是否填补开发流程缺口**。

#### 评估矩阵

| # | 来源 | ⭐ | 决策 | 原因 |
|---|------|-----|------|------|
| 1 | addyosmani/agent-skills | 22.8K | ✅ 安装 6 个 | 20-skill 体系覆盖全生命周期，选 6 个填补 Define/Plan/Build/Review/Ship 缺口 |
| 2 | mattpocock/skills | 44K+ | ✅ 安装 4 个 | grill-with-docs（需求对齐）、tdd（红绿重构）、diagnose（纪律化调试）、caveman（压缩） |
| 3 | anthropics/frontend-design | 4.8K | ⏭️ 跳过 | 与 ui-designer agent 功能重叠 |
| 4 | vercel/next.js cache-components | — | ✅ 安装 | Next.js 官方，`'use cache'`/PPR 专项，无替代 |
| 5 | Shubhamsaboo/awesome-llm-apps | 109K | ⏭️ 跳过 | fullstack-developer 过于通用，与 CLAUDE.md 全面重叠 |
| 6 | langgenius/dify frontend-code-review | 141K | ✅ 安装 | 前端专项 review checklist，与 code-reviewer agent 互补 |
| 7 | google-gemini/gemini-cli code-reviewer | 59K | ⏭️ 跳过 | 与 code-reviewer agent + addyosmani 重叠 |
| 8 | anthropics/webapp-testing | 4.8K | ✅ 安装 | Playwright E2E 测试，填补测试自动化缺口 |
| 9 | facebook/react fix | 237K | ⏭️ 跳过 | React 内部专用（修复 jscodeshift codemod），不可移植 |

#### 已安装 Skills（13 个）

| Skill 目录 | 来源 | 触发场景 | 核心能力 |
|------------|------|---------|---------|
| `caveman` | mattpocock/skills | 大文件压缩、长会话优化 | Lite/Full/Ultra 三档压缩，安全降级 |
| `mattpocock-grill-with-docs` | mattpocock/skills | 编码前需求对齐 | 领域模型质询、共享术语构建、CONTEXT.md + ADR 自动生成 |
| `mattpocock-tdd` | mattpocock/skills | 功能开发/修 bug | 红-绿-重构循环、垂直切片（非水平批量）、集成测试优先 |
| `mattpocock-diagnose` | mattpocock/skills | 疑难 bug/性能回退 | 纪律化诊断循环：复现→最小化→假设→插桩→修复→回归测试 |
| `addyosmani-spec-driven-development` | addyosmani | 编码前 → 先写规格 | 4 阶段门控（Specify→Plan→Tasks→Implement），6 维规格面 |
| `addyosmani-planning-and-task-breakdown` | addyosmani | 需求复杂、需拆分子任务 | 垂直切片策略、依赖图、XS/S/M/L/XL 任务分级、检查点系统 |
| `addyosmani-frontend-ui-engineering` | addyosmani | 构建/修改用户界面 | 生产级 UI 构建、设计系统遵循、无障碍、交互模式、组件架构 |
| `addyosmani-api-and-interface-design` | addyosmani | 设计 API/模块边界 | Hyrum's Law、接口稳定性、版本化策略、前后端契约设计 |
| `addyosmani-code-simplification` | addyosmani | 代码审查/重构阶段 | Chesterton's Fence 原则、Rule of 500、5 大简化原则、TS/Python/React 专项指南 |
| `addyosmani-shipping-and-launch` | addyosmani | 功能完成 → 准备发布 | 发布前清单（质量/安全/性能/可达性/基础设施）、特性标志生命周期、灰度发布阈值 |
| `cache-components` | vercel/next.js | Next.js 缓存相关开发 | `'use cache'` 指令、`cacheLife()`/`cacheTag()`/`updateTag()`/`revalidateTag()`、PPR 决策树 |
| `frontend-code-review` | langgenius/dify | 前端代码审查 | 双模式 review（待提交变更 / 指定文件）、结构化输出模板、规则目录 |
| `webapp-testing` | anthropics/skills | Web 应用端到端测试 | Playwright 测试决策树、with_server.py 服务生命周期管理、侦查-行动模式 |

#### 冗余分析（未安装的 4 个）

| Skill | 替代方案 | 冗余说明 |
|-------|---------|---------|
| frontend-design (Anthropic) | `ui-designer` agent（§3.3） | agent 已包含设计规范、Figma 集成、设计系统知识 |
| fullstack-developer (awesome-llm-apps) | `.claude_global/CLAUDE.md` + 所有 agents | 全栈最佳实践已被 Karpathy 原则 + 7 个 agent 完整覆盖 |
| code-reviewer (gemini-cli) | `code-reviewer` agent + addyosmani skills | agent 已包含安全/性能/质量三维审查，addyosmani 提供简化/发布维度 |
| fix (react) | `git-commit` skill + `/fix-issue` command | React 内部 codemod 工具，不适用于外部项目 |

#### 部署方式

- **自动部署**：`setup-claude.ps1` 会将 13 个 skill 目录复制到目标项目 `.claude/skills/`
- **手动按需**：从 `03-claude-optimize/.claude/skills/` 复制单个目录到项目 `.claude/skills/`
- **引用原则**：先装常用 skill，确认使用频率后再考虑全量安装

### 4.4 可选工具

**claude-mem**（跨会话记忆）：
```bash
# 从 https://github.com/thedotmack/claude-mem 安装
# 自动捕获会话 → AI 压缩 → 注入未来会话
```

> **注意**：收益不稳定，调试成本高。更稳妥做法是用文件沉淀上下文（plan.md/notes.md）+ `/resume`。

---

## 5. 不纳入基线清单（避免复杂化）

| 工具 | 原因 |
|------|------|
| claude-code-router（多模型路由） | 代理层破坏 skills 兼容性，排障成本高 |
| Ollama 本地模型作为默认方案 | 推理质量显著低于 Claude，API 兼容性不完整 |
| SuperClaude_Framework | 增加抽象层，与极简原则冲突 |
| OpenClaude | 第三方分支，法律和兼容性风险 |

> 以上仅作"风险认知"保留在文档中，不写入快速部署 Checklist。

---

## 6. Token 管理最佳实践

### 6.1 上下文窗口规则

- **120K 以下**：模型保持最佳性能
- **120K-500K**：质量开始下降
- **500K+**：输出质量可能不如 200K 的会话，但成本翻倍

### 6.2 原生命令速查

| 命令 | 用途 | 何时使用 |
|------|------|---------|
| `/context` | 查看上下文占用 | 每 15-20 条消息检查一次 |
| `/rewind` | 回退到之前的对话点 | 发现方向错误时 |
| `/compact` | 手动压缩上下文 | 在 60% 阈值时主动使用 |
| `/clear` | 清空会话重新开始 | 切换不相关话题时 |
| `/cost` | 查看当前消耗 | 关键节点检查 |
| `/model` | 切换模型 | 简单任务降级到 Sonnet |
| `/resume` | 恢复之前的会话 | 需要继续之前的工作时 |

### 6.3 会话管理原则

```
会话 1: 需求分析 + PRD（~30K Token）→ /compact → 继续
会话 2: 架构设计（新会话，/clear）
会话 3: 前端实现（新会话，/clear）
会话 4: 后端实现（新会话，/clear）
会话 5: 联调测试（新会话，/clear）
```

**核心原则：一个会话只做一件事，话题切换时开新会话。**

### 6.4 每日工作流

| 时间 | 动作 | 命令 |
|------|------|------|
| 开始工作 | 查看前日消耗 | `npx ccusage@latest daily` |
| 开始会话 | 确认模型选择 | `/model` |
| 每 15 条消息 | 检查上下文 | `/context` |
| 话题切换 | 开新会话 | `/clear` |
| 结束工作 | 查看当日消耗 | `npx ccusage@latest daily` |
| 每周复盘 | 分析成本分布 | `npx ccusage@latest monthly --breakdown` |

---

## 7. CC-Switch 模型切换规范

### 7.1 稳定切换规则

每个 Provider 内以下字段保持同厂商一致：
- `ANTHROPIC_MODEL`
- `ANTHROPIC_SMALL_FAST_MODEL`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL`
- `ANTHROPIC_DEFAULT_SONNET_MODEL`
- `ANTHROPIC_DEFAULT_OPUS_MODEL`
- `CLAUDE_CODE_SUBAGENT_MODEL`

### 7.2 切换后固定执行

```bash
# 1. 新开终端
# 2. 验证状态
claude  # 进入后输入 /status
```

### 7.3 常见错误

- 当前 Provider 是 A，但模型填了 B 厂商模型名
- 只改了 `ANTHROPIC_MODEL`，未同步默认模型字段
- 切换后未重开会话，仍使用旧配置缓存

---

## 8. 快速部署 Checklist（新环境复用）

> **推荐方式**：使用一键部署脚本 `d:\开发环境安装\ClaudeCode\03-claude-optimize\scripts\setup-claude.ps1`

### 一键部署（推荐）

```powershell
# 部署全部三个阶段（全局 + 项目级 + 提效工具）
.\scripts\setup-claude.ps1 -Phase all -ProjectDir "D:\your-project"

# 只部署阶段一（核心配置）
.\scripts\setup-claude.ps1 -Phase 1

# 只部署阶段二（提效增强，需先完成阶段一）
.\scripts\setup-claude.ps1 -Phase 2 -ProjectDir "D:\your-project"
```

### 手动部署

#### 阶段一：核心配置（约 30 分钟）

```powershell
# === Windows（PowerShell）===

# 1. 创建全局目录并部署全局配置
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\commands" | Out-Null
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\tools" | Out-Null
Copy-Item ".claude_global\CLAUDE.md" "$env:USERPROFILE\.claude\CLAUDE.md"
Copy-Item ".claude_global\commands\*.md" "$env:USERPROFILE\.claude\commands\"

# 2. 创建项目级配置
$proj = "D:\your-project"
New-Item -ItemType Directory -Force "$proj\.claude\rules","$proj\.claude\commands","$proj\.claude\agents","$proj\.claude\skills\caveman" | Out-Null
Copy-Item "templates\CLAUDE.md" "$proj\CLAUDE.md"
Copy-Item "templates\.mcp.json" "$proj\.mcp.json"
Copy-Item ".claude\rules\*.md" "$proj\.claude\rules\"
Copy-Item ".claude\settings.json" "$proj\.claude\settings.json"
Copy-Item ".claude\commands\*.md" "$proj\.claude\commands\"
Copy-Item ".claude\agents\*.md" "$proj\.claude\agents\"

# 3. 配置权限白名单（在 Claude Code 中执行 /permissions）
```

```bash
# === macOS/Linux（bash）===

# 1. 创建全局目录并部署全局配置
mkdir -p ~/.claude/commands ~/.claude/tools
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude_global/CLAUDE.md ~/.claude/CLAUDE.md
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude_global/commands/*.md ~/.claude/commands/

# 2. 创建项目级配置
proj="/path/to/your-project"
mkdir -p $proj/.claude/{rules,commands,agents,skills/caveman}
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/templates/CLAUDE.md $proj/CLAUDE.md
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/templates/.mcp.json $proj/.mcp.json
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude/rules/*.md $proj/.claude/rules/
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude/settings.json $proj/.claude/settings.json
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude/commands/*.md $proj/.claude/commands/
cp d:/开发环境安装/ClaudeCode/03-claude-optimize/.claude/agents/*.md $proj/.claude/agents/
```

#### 阶段二：提效增强

```powershell
# 4. 安装 ccusage（用量监控）
npx ccusage@latest daily

# 5. 安装 rtk（输出压缩）
# 从 https://github.com/rtk-ai/rtk/releases 下载并加入 PATH
rtk init -g

# 6. 安装 caveman（响应压缩）
# SKILL.md 已在本地：03-claude-optimize\.claude\skills\caveman\SKILL.md
# 复制到项目：Copy-Item ".claude\skills\caveman" "<project>\.claude\skills\caveman" -Recurse
```

#### 阶段三：高级扩展

```powershell
# 7. 安装 mattpocock/skills（按需）
npx skills@latest add mattpocock/skills

# 8. 安装使用监控（按需）
pip install claude-monitor
```

---

## 8.1 本地文件系统总览

以下为本文档配套的完整文件系统结构，所有文件均已落地到本地：

```
d:\开发环境安装\ClaudeCode\03-claude-optimize\
├── claude调优方案.md                    # 本文档
├── 分析-可行性评估.md                   # 方案可行性评估
├── .claude_global\                      # 全局配置模板（部署到 ~/.claude/）
│   ├── CLAUDE.md                        # 全局行为准则
│   ├── commands\                        # 全局自定义命令
│   │   ├── review.md                    # /review - 代码审查
│   │   └── fix-issue.md                 # /fix-issue - Issue 修复
│   └── tools\                           # 单文件工具目录（加入 PATH）
│       ├── install-tools.ps1            # 一键下载安装工具
│       └── README.md                    # 工具使用说明
├── templates\                           # 项目模板（复制到新项目）
│   ├── CLAUDE.md                        # 项目级 CLAUDE.md 模板（含 Karpathy 准则）
│   ├── .mcp.json                        # MCP 服务器配置模板
│   └── .claude\                         # （镜像项目目录结构，完整可拷贝）
│       ├── settings.json                # Hooks 守卫配置
│       ├── rules\                       # 路径化规则（通用 + 技术栈专用）
│       │   ├── frontend.md / backend.md / testing.md  # 通用基线
│       │   ├── vue2.md / vue3.md / react.md           # 框架专用
│       │   └── typescript.md / python.md / go.md      # 语言专用
│       ├── commands\                    # 项目级命令
│       │   ├── deploy.md
│       │   └── test-plan.md
│       ├── agents\                      # 角色型智能体（7 个）
│       │   └── *.md
│       └── skills\                      # 技能（13 个）
│           └── */SKILL.md
├── .claude\                             # 当前项目的工作配置
│   ├── settings.json                    # Hooks 守卫配置
│   ├── rules\                           # 路径化规则（3 个通用）
│   ├── commands\                        # 项目级命令（2 个）
│   ├── agents\                          # 角色型智能体（7 个）
│   └── skills\                          # 技能（13 个）
│       ├── addyosmani-spec-driven-development\    # /spec - 规格驱动
│       ├── addyosmani-planning-and-task-breakdown\ # /plan - 任务拆分
│       ├── addyosmani-frontend-ui-engineering\     # UI 构建
│       ├── addyosmani-api-and-interface-design\    # API 设计
│       ├── addyosmani-code-simplification\         # /code-simplify
│       ├── addyosmani-shipping-and-launch\         # /ship - 发布
│       ├── mattpocock-grill-with-docs\             # /grill-with-docs - 需求对齐
│       ├── mattpocock-tdd\                         # /tdd - 红绿重构
│       ├── mattpocock-diagnose\                    # /diagnose - 纪律化调试
│       ├── caveman\                                # /caveman - 响应压缩
│       ├── cache-components\                       # Next.js 缓存
│       ├── frontend-code-review\                   # 前端审查
│       └── webapp-testing\                         # Playwright E2E
├── CLAUDE.md                            # 项目级行为准则 + 上下文（含 Karpathy 四原则）
└── scripts\                             # 部署脚本
    ├── setup-claude.ps1                 # 一键部署脚本
    └── reinstall-claude-to-cc-switch.ps1 # 从插件迁移到 CC-Switch
```

---

## 9. 参考来源

### 官方文档
| 文档 | 链接 |
|------|------|
| Best Practices | https://code.claude.com/docs/en/best-practices |
| Hooks Guide | https://code.claude.com/docs/en/hooks-guide |
| Hooks Reference | https://code.claude.com/docs/en/hooks |
| Skills（自定义命令） | https://code.claude.com/docs/en/skills |
| Sub-agents | https://code.claude.com/docs/en/sub-agents |
| MCP | https://code.claude.com/docs/en/mcp |
| Memory | https://code.claude.com/docs/en/memory |
| Monitoring Usage | https://code.claude.com/docs/en/monitoring-usage |
| Using CLAUDE.md | https://claude.com/blog/using-claude-md-files |
| Hooks 配置博客 | https://claude.com/blog/how-to-configure-hooks |

### 社区项目（按 Star 排序）
| 项目 | Stars | 链接 |
|------|-------|------|
| andrej-karpathy-skills | ⭐87.6K | https://github.com/forrestchang/andrej-karpathy-skills |
| caveman | ⭐41K | https://github.com/juliusbrussee/caveman |
| mattpocock/skills | ⭐35.3K | https://github.com/mattpocock/skills |
| rtk | ⭐31K | https://github.com/rtk-ai/rtk |
| claude-task-master | ⭐26K | https://github.com/eyaltoledano/claude-task-master |
| addyosmani/agent-skills | ⭐22.8K | https://github.com/addyosmani/agent-skills |
| ccusage | ⭐13K | https://github.com/ryoppippi/ccusage |
| Claude-Code-Usage-Monitor | ⭐7.6K | https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor |
| Carabiner | ⭐5.6K | https://github.com/zilliztech/carabiner |

### 深度文章
| 文章 | 链接 |
|------|------|
| 17 个 Claude Code 高手工作流 | https://blog.csdn.net/2511_93721486/article/details/157028336 |
| Claude Code 自定义命令开发 | https://dotclaude.com/commands |
| Claude Code Hooks 完整参考 | https://dotclaude.com/hooks |
| 50 Claude Code Tips | https://www.builder.io/blog/claude-code-tips-best-practices |
| Claude Code Best Practice（⭐20K） | https://github.com/shanraisshan/claude-code-best-practice |
