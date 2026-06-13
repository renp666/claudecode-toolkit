# Claude Code Hooks 说明

> 所有 hook 配置位于 `.claude/settings.json` → `hooks` 字段。
> 脚本文件位于 `.claude/hooks/`，日志输出位于 `.claude/logs/`。

---

## Hook 总览

| # | 事件 | 匹配器 | 类型 | 功能 |
|---|------|--------|------|------|
| 1 | PreToolUse | Bash | 安全守卫 | 拦截危险命令 |
| 2 | PreToolUse | Bash → `git commit` | 质量守卫 | 代码格式检查 |
| 3 | PostToolUse | Write\|Edit | 提醒 | 文件修改后提示 lint/test |
| 4 | PostToolUse | WebFetch | 审计 | 外部请求日志 |
| 5 | Stop | — | 通知 | 验收清单 + 桌面弹窗 + 提示音 |
| 6 | SubagentStop | — | 通知 | 子智能体完成弹窗 + 提示音 |
| 7 | PreCompact | — | 快照 | 上下文压缩前保存状态 |

---

## 各 Hook 详细说明

### 1. 危险命令拦截

- **事件**：`PreToolUse`
- **匹配**：所有 Bash 命令
- **阻塞**：是（exit 1 = 阻止执行）

**拦截规则**：
| 模式 | 说明 |
|------|------|
| `rm -rf /` | 防止误删根目录 |
| `git push --force` | 防止强制推送 |
| `DROP TABLE` | 防止误删数据库表 |
| `format [a-z]:` | 防止格式化磁盘 |

**绕过方式**：无（安全策略，不可绕过）

---

### 2. Git 提交前代码格式检查

- **事件**：`PreToolUse`
- **匹配**：Bash 命令中含 `git commit`
- **阻塞**：是（检查不通过时阻止提交）
- **脚本**：`.claude/hooks/pre-commit-check.ps1`

**检查流程**：
```
git commit 触发
  → 冗余分析：检测项目是否已有 husky/lint-staged/pre-commit
    → 有：跳过内置检查（避免重复）
    → 无：执行以下检查
      → 规则1: 大文件检查（>500KB）
      → 规则2: 行尾空白 + 调试语句检测
      → 规则3: ESLint（如已安装）
  → 全部通过 → 允许提交
  → 任一失败 → 阻止提交，输出详情
```

**调试语句检测覆盖**：
| 语言 | 模式 |
|------|------|
| JS/TS | `console.log/warn/error/debug`, `debugger` |
| Python | `print()`, `breakpoint()`, `pdb.set_trace()` |
| Go | `fmt.Println`, `fmt.Printf` |
| Rust | `println!`, `dbg!` |
| Ruby | `puts`, `binding.pry` |

**绕过方式**：`git commit --no-verify`

**配置环境变量**（可选）：
- `SKIP_PRECOMMIT_CHECK=1`：跳过此检查

---

### 3. 文件修改提醒

- **事件**：`PostToolUse`
- **匹配**：Write / Edit 工具
- **阻塞**：否

**效果**：终端输出 `文件已修改，请确认是否需要运行 lint/test`

---

### 4. WebFetch 审计日志

- **事件**：`PostToolUse`
- **匹配**：WebFetch 工具
- **阻塞**：否
- **输出**：`.claude/logs/web-fetch.jsonl`（JSONL 格式，每次追加一行）

**日志格式**：
```json
{"url":"https://example.com/api","time":"2026-05-11T12:00:00Z","session":"abc123"}
```

**用途**：安全审计，追溯所有外部网络请求。

**查看日志**：
```bash
cat .claude/logs/web-fetch.jsonl | jq .
```

---

### 5. 会话结束通知

- **事件**：`Stop`（Claude 响应完成、等待用户输入时）
- **匹配**：无（所有 Stop 事件）
- **阻塞**：否

**效果**：
1. 终端输出验收清单
2. Windows 右下角气泡弹窗（中文，5 秒自动消失）
3. 系统提示音 "叮"（Asterisk）

---

### 6. 子智能体完成通知

- **事件**：`SubagentStop`（子智能体任务完成时）
- **匹配**：无
- **阻塞**：否

**效果**：
1. Windows 右下角气泡弹窗（中文，3 秒自动消失）
2. 系统提示音 "叮"（Asterisk）

> 与 Stop 的区别：SubagentStop 在子任务完成时立即触发，无需等待主会话结束。

---

### 7. 上下文压缩快照

- **事件**：`PreCompact`（上下文即将压缩前）
- **匹配**：无
- **阻塞**：否
- **输出**：`.claude/logs/precompact-YYYY-MM-DD_HH-MM-SS.json`

**快照内容**：
```json
{
  "context_size": 85000,
  "compact_at": "2026-05-11_12-00-00",
  "session": "abc123"
}
```

**用途**：回溯长会话的压缩节点，排查上下文丢失问题。

**查看快照**：
```bash
ls -la .claude/logs/precompact-*.json
```

---

## 目录结构

```
.claude/
├── hooks/
│   ├── README.md                  ← 本文件
│   └── pre-commit-check.ps1       ← Git 提交检查脚本
├── logs/                          ← 自动生成（已 gitignore）
│   ├── web-fetch.jsonl            ← WebFetch 审计日志
│   └── precompact-*.json          ← 上下文压缩快照
└── settings.json                  ← Hook 配置
```

---

## 如何禁用某个 Hook

在 `.claude/settings.json` 中删除或注释对应 hook 块即可。

**临时禁用 pre-commit 检查**：
```bash
# 方式1: 使用 --no-verify
git commit --no-verify -m "skip check"

# 方式2: 设置环境变量
export SKIP_PRECOMMIT_CHECK=1
```

**完全关闭所有 hooks**：将 `hooks` 字段设为 `{}`

---

## 迁移到新项目

```bash
# 复制整个 .claude 目录即可（包含 hooks + 设置 + 技能 + 规则）
cp -r templates/.claude/ target-project/
```
