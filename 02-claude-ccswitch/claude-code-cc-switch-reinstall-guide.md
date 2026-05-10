# Claude Code + CC-Switch 重装与配置指南（Windows）

本文用于“清理旧配置 -> 重装 Claude Code CLI -> 接入 CC-Switch -> 验证 Trae/VS Code 插件”的一键排障与标准化交付。

---

## 1. 目标结果

- 终端可执行 `claude --version`。
- Claude Provider 由 CC-Switch 管理（可在 GUI 切换 Provider）。
- 当前 Provider 指向阿里云百炼（PAYG 或 Coding Plan）。
- Trae / VS Code 的 Claude Code 插件复用本机配置，不再弹 Anthropic 登录。

---

## 2. 关键安装与配置路径

- Claude 用户配置目录：`%USERPROFILE%\.claude\`
- Claude 用户主配置：`%USERPROFILE%\.claude\settings.json`
- Claude onboarding 配置：`%USERPROFILE%\.claude.json`
- CC-Switch 配置目录：`%USERPROFILE%\.cc-switch\`
- CC-Switch 主设置：`%USERPROFILE%\.cc-switch\settings.json`
- CC-Switch 数据库：`%USERPROFILE%\.cc-switch\cc-switch.db`
- Git Bash（示例）：`D:\开发环境安装\Git\bin\bash.exe`

---

## 3. 卸载当前 Claude（如已安装）

PowerShell（管理员）：

```powershell
winget uninstall Anthropic.ClaudeCode
```

若提示未安装可忽略。

可选：清理 npm 全局版本（仅当你曾用 npm 安装过）：

```powershell
npm uninstall -g @anthropic-ai/claude-code
```

---

## 4. 重装 Claude Code CLI

推荐（WinGet）：

```powershell
winget install Anthropic.ClaudeCode --accept-source-agreements --accept-package-agreements
claude --version
```

若企业策略阻止 WinGet，可改用官方 PowerShell 安装脚本：

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

---

## 5. 初始化 Claude 本地基础配置

先确保 `%USERPROFILE%\.claude.json` 存在且内容为：

```json
{
  "hasCompletedOnboarding": true
}
```

这一步用于避免默认回落到 Anthropic 官方登录流程。

---

## 6. 在 CC-Switch 中配置百炼 Provider

1. 打开 CC-Switch 桌面版。
2. 在 Claude Provider 列表中新增 Provider（示例名：`阿里云百炼 PAYG`）。
3. 写入以下关键字段：
   - `ANTHROPIC_BASE_URL`
   - `ANTHROPIC_AUTH_TOKEN`（或 `ANTHROPIC_API_KEY`，二选一）
   - `ANTHROPIC_MODEL` 与默认模型映射
4. 建议额外设置：
   - `CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192`
   - `CLAUDE_CODE_GIT_BASH_PATH=D:\开发环境安装\Git\bin\bash.exe`
5. 将该 Provider 设为 Current。

PAYG（北京）Base URL：

- `https://dashscope.aliyuncs.com/apps/anthropic`

PAYG（新加坡）Base URL：

- `https://dashscope-intl.aliyuncs.com/apps/anthropic`

Coding Plan Base URL：

- `https://coding.dashscope.aliyuncs.com/apps/anthropic`

---

## 7. 推荐环境变量模板（可放入 settings.json）

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_BASE_URL": "https://dashscope.aliyuncs.com/apps/anthropic",
    "ANTHROPIC_MODEL": "qwen3.6-plus",
    "ANTHROPIC_SMALL_FAST_MODEL": "qwen3.6-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "qwen3.6-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen3.6-plus",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "qwen3.6-plus",
    "CLAUDE_CODE_SUBAGENT_MODEL": "qwen3.6-plus",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8192",
    "CLAUDE_CODE_GIT_BASH_PATH": "D:\\开发环境安装\\Git\\bin\\bash.exe"
  },
  "effortLevel": "high"
}
```

---

## 8. 验证步骤（终端 + IDE）

1. 关闭所有终端和 IDE。
2. 新开 PowerShell，运行：

```powershell
claude --version
claude
```

3. 在 Claude 会话输入：

```text
/status
```

应确认：

- Base URL 已指向百炼域名
- 当前模型为你配置的 qwen 模型

4. 打开 Trae / VS Code，重启后新建 Claude 对话，验证不再弹官方登录。

---

## 9. Skills 安装与后续维护建议

CC-Switch 已内置 skills 存储管理能力，建议：

- 将 skills 统一放在 CC-Switch 管理目录下（默认可在 `%USERPROFILE%\.cc-switch\skills\` 查看）。
- 升级 Claude Code 或切换 Provider 后，先做一次 `claude --version` 与 `/status` 验证，再安装/更新 skills。
- 团队使用时，不要把真实 API Key 写入仓库；仅共享模板文件与路径说明。

---

## 10. 常见故障速查

- `Please run /login`：通常是没读到有效 Key 或 Base URL，先查当前 Provider 与 `ANTHROPIC_*` 覆盖变量。
- `403 invalid api-key`：Key 无效、套餐/地域不匹配、或请求头类型不匹配（`AUTH_TOKEN` vs `API_KEY`）。
- `max_tokens should be [1,8192]`：增加 `CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192`。
- 找不到 Git Bash：补齐 `CLAUDE_CODE_GIT_BASH_PATH`。

