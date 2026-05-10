# Windows 本地 Claude Code + 阿里云百炼（含 Coding Plan）+ Trae/VS Code 插件接入指南

本文档面向在本地 Windows 机器安装 Claude Code，并将模型请求接入阿里云百炼（Anthropic API 兼容接口），再通过 Trae IDE（VS Code 系 IDE）中的 Claude Code 插件调用本地 Claude Code 使用的场景。

---

## 1. 你最终会得到什么

- 本机可在终端运行 `claude`（Claude Code CLI）。
- `claude` 的调用会被重定向到阿里云百炼的 Anthropic 兼容网关，而不是 Anthropic 官方。
- 在 Trae / VS Code 中安装 “Claude Code for VS Code” 后，插件会复用同一套本地配置，无需再弹出 Anthropic 登录。

---

## 2. 必要前置条件（Windows）

### 2.1 Node.js（按需）

- 若你使用本文档的默认方案（第 3.1 节“官方原生安装”），**不强制要求 Node.js**。
- 若你使用第 3.2 节“npm 全局安装”，则需要 Node.js v18 或更高版本（百炼文档与 Claude Code npm 安装说明均要求 v18+）。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code  
  https://code.claude.com/docs/en/getting-started

下载与安装：
- https://nodejs.org/en/download/

验证：

```bash
node -v
npm -v
```

### 2.2 Git for Windows 或 WSL（至少一个，默认推荐 Git for Windows）

Claude Code 在 Windows 上运行时，常见两种方式：

- 方案 A（默认推荐，最省事）：安装 Git for Windows（带 Git Bash），直接在 Windows 上运行 `claude`，Trae/VS Code 插件也更容易复用同一套本机配置与项目路径。
- 方案 B（可选）：安装 WSL2，在 Linux 环境里运行 `claude`，更适合你的项目本来就在 WSL、或依赖 Linux 工具链的情况。

阿里云百炼文档明确提到 Windows 需要 WSL 或 Git for Windows 才能使用 Claude Code。来源：阿里云百炼 Claude Code 文档（按量付费版）与 Coding Plan 文档。  
https://help.aliyun.com/zh/model-studio/claude-code  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

Anthropic 官方也说明：原生 Windows 方案需要 Git for Windows（Claude Code 内部会使用 Git Bash 执行命令）。来源：  
https://code.claude.com/docs/en/getting-started

Git for Windows 下载：
- https://git-scm.com/download/win

WSL 安装（微软官方）：
- https://learn.microsoft.com/windows/wsl/install

如果你选方案 A，建议安装完成后确认 `bash.exe` 路径存在，通常是：

- `C:\Program Files\Git\bin\bash.exe`

若后续出现 Claude Code 找不到 Git Bash 的情况，可在第 7 节按官方方式设置 `CLAUDE_CODE_GIT_BASH_PATH`。

---

## 3. 安装 Claude Code（CLI）

### 3.1 默认推荐：官方原生安装（Windows PowerShell / WinGet）

Anthropic 官方将原生安装作为推荐方式，并提供 PowerShell 安装脚本与 WinGet 安装。来源：  
https://code.claude.com/docs/en/getting-started

Windows PowerShell：

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

如果你的环境启用了 PowerShell 脚本执行限制或企业安全策略阻止远程脚本，请改用 WinGet（见下）或 npm 安装（第 3.2 节）。

WinGet（可选）：

```powershell
winget install Anthropic.ClaudeCode
claude --version
```

### 3.2 备选：npm 全局安装（与百炼文档一致）

阿里云百炼文档给出的安装方式是 npm 全局安装（按量付费与 Coding Plan 均如此）：  
https://help.aliyun.com/zh/model-studio/claude-code  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### 3.3 CC-Switch 模式（推荐给多 Provider / 多模型切换用户）

如果你已经安装 CC-Switch（桌面版），建议把 Claude Code 的 Provider 管理交给 CC-Switch。这样你可以在 GUI 里切换百炼、DeepSeek、官方等 Provider，不需要每次手改 `%USERPROFILE%\.claude\settings.json`。

建议流程：

1. 先确保本机有 `claude` 可执行文件（第 3.1 节安装即可）。
2. 打开 CC-Switch，进入 Claude 相关 Provider 管理页。
3. 新建一个 Provider（例如“阿里云百炼 PAYG”），写入百炼 Base URL、API Key 与模型映射。
4. 把该 Provider 设为当前生效 Provider（Current）。
5. 新开终端执行 `claude`，在会话中用 `/status` 检查当前 Base URL 与模型是否正确。

注意：

- CC-Switch 与 `%USERPROFILE%\.claude\settings.json` 可能同时影响最终配置。为避免冲突，建议固定以 CC-Switch 为主配置入口。
- 若你使用 CC-Switch 的“本地代理”模式，请确保代理地址、端口与目标网关一致；若不使用本地代理，直接填百炼 `/apps/anthropic` 即可。
- 为兼容百炼 `max_tokens` 限制，建议在环境变量里增加 `CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192`。

---

## 4. 选择你的接入方式：百炼按量付费 vs Coding Plan

你需要先确认自己使用的是哪一种：

- **百炼按量付费（PAYG）**：用百炼通用 API Key，走百炼 Anthropic 兼容服务。
- **百炼 Coding Plan**：用 Coding Plan 专属 API Key，走 Coding Plan 专属 Base URL（与按量付费不同）。

阿里云百炼文档明确提示两者 Base URL/API Key 不同。来源：  
https://help.aliyun.com/zh/model-studio/claude-code  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

### 4.1 建议做法：两套配置都准备好，但同一时间只启用一套

你可以把两套配置模板都保存下来（便于以后切换到 Coding Plan），但请确保**实际生效的** `%USERPROFILE%\.claude\settings.json` 里同一时间只保留一种接入方式的 Key/Base URL。

本指南默认你**当前启用按量付费（PAYG）**，后续切换 Coding Plan 时只需要替换：

- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_AUTH_TOKEN`（以及可选的模型名）

### 4.2 切换方式（推荐：保留两个模板文件，启用时覆盖 settings.json）

建议在同一目录下额外保存两个“模板文件”，例如：

- `%USERPROFILE%\.claude\settings.payg.json`
- `%USERPROFILE%\.claude\settings.codingplan.json`

日常启用按量付费时，让 `settings.json` 的内容等同于 `settings.payg.json`；未来启用 Coding Plan 时，把 `settings.codingplan.json` 的内容覆盖回 `settings.json`，再重启终端/IDE 即可。

### 4.3 避免冲突：检查系统环境变量是否覆盖了 settings.json

Claude Code 支持通过系统环境变量配置 `ANTHROPIC_*`，如果你曾经用 `setx` 设置过环境变量，可能会和 `settings.json` 产生混淆。

切换前建议在新终端里检查：

- PowerShell：`gci env:ANTHROPIC_*`
- CMD：`set ANTHROPIC_`

---

## 5. 配置 Claude Code 连接百炼（推荐：写入用户级配置文件）

Claude Code 支持把环境变量写入 `settings.json` 的 `env`，从而对每次会话生效。来源：Claude Code 环境变量说明：  
https://code.claude.com/docs/en/env-vars

### 5.1 写入 `settings.json`（Windows 路径）

用户级配置文件路径：

- `%USERPROFILE%\.claude\settings.json`  
  通常等价于：`C:\Users\你的用户名\.claude\settings.json`

如果目录不存在可以先创建：

PowerShell：

```powershell
New-Item -ItemType Directory -Force -Path $HOME\.claude
# 注意：作为人类操作时可以使用 notepad 打开编辑；若为 AI Agent 自动执行，请使用 Set-Content 写入。
notepad $HOME\.claude\settings.json
```

### 5.2 按量付费（PAYG）配置模板

当前启用按量付费时：把本节模板写入 `%USERPROFILE%\.claude\settings.json`（也建议另存一份为 `%USERPROFILE%\.claude\settings.payg.json` 便于将来切换）。

百炼按量付费 Anthropic 兼容 Base URL（华北2/北京）：

- `https://dashscope.aliyuncs.com/apps/anthropic`

新加坡：

- `https://dashscope-intl.aliyuncs.com/apps/anthropic`

来源：阿里云百炼 Claude Code 文档（按量付费版）：  
https://help.aliyun.com/zh/model-studio/claude-code

示例（把 `YOUR_API_KEY` 与模型名替换成你的实际值）：

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
    "CLAUDE_CODE_SUBAGENT_MODEL": "qwen3.6-plus"
  }
}
```

说明：

- 百炼文档示例使用 `ANTHROPIC_AUTH_TOKEN` 承载 API Key。
- Claude Code 同时也支持 `ANTHROPIC_API_KEY`（发送为 `X-Api-Key` 头），以及 `ANTHROPIC_AUTH_TOKEN`（发送为 `Authorization: Bearer ...`）。来源：Claude Code 环境变量说明。  
  https://code.claude.com/docs/en/env-vars

### 5.3 Coding Plan 配置模板（专属 Base URL）

暂不启用 Coding Plan 时：把本节模板先保存为 `%USERPROFILE%\.claude\settings.codingplan.json` 即可；等未来要切换时，再用它覆盖 `%USERPROFILE%\.claude\settings.json`。

Coding Plan 文档给出的专属 Base URL：

- `https://coding.dashscope.aliyuncs.com/apps/anthropic`

来源：阿里云百炼 Claude Code（Coding Plan）文档：  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

示例（把 `YOUR_API_KEY` 与模型名替换成你的实际值；模型需在 Coding Plan 支持列表中选择）：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "YOUR_API_KEY",
    "ANTHROPIC_BASE_URL": "https://coding.dashscope.aliyuncs.com/apps/anthropic",
    "ANTHROPIC_MODEL": "qwen3.6-plus",
    "ANTHROPIC_SMALL_FAST_MODEL": "qwen3.6-plus",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "qwen3.6-plus",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen3.6-plus",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "qwen3.6-plus",
    "CLAUDE_CODE_SUBAGENT_MODEL": "qwen3.6-plus"
  }
}
```

---

## 6. 关键补充：创建 `.claude.json` 以避免启动时“连到 Anthropic 官方”

阿里云百炼文档给出一个常见报错：Claude Code 启动时去连接 `api.anthropic.com`，导致 “Unable to connect to Anthropic services …”。解决方式之一是设置 `hasCompletedOnboarding: true`。来源：  
https://help.aliyun.com/zh/model-studio/claude-code  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

Windows 下文件位置：

- `%USERPROFILE%\.claude.json`

内容：

```json
{
  "hasCompletedOnboarding": true
}
```

---

## 7. Windows 原生模式常见坑：找不到 Git Bash

Anthropic 官方文档指出：原生 Windows 下 Claude Code 内部会使用 Git Bash 执行命令。如果 Claude Code 找不到 Git Bash，可在 `settings.json` 里设置 `CLAUDE_CODE_GIT_BASH_PATH`。来源：  
https://code.claude.com/docs/en/getting-started

示例：

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

如果你已经有第 5 节的 `env` 配置，把这个键合并进去即可。

---

## 8. 运行验证（终端）

作为人类用户，可以：

1. 打开一个新终端窗口（确保环境变量/配置刷新）。
2. 进入任意项目目录。
3. 运行：

```bash
claude
```

4. 在 Claude Code 内执行：

```text
/status
```

作为 AI Agent 自动验证，请**绝对禁止**直接运行 `claude`（因为这是交互式 REPL 会导致挂起），而是应该使用非交互式命令：

```bash
claude doctor
```

你应看到当前 Base URL、模型等信息已经指向百炼，而不是 `api.anthropic.com`。来源：百炼 Coding Plan 文档也推荐用 `/status` 检查。  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

如需更全面的安装自检，Anthropic 官方提供了 `claude doctor`。来源：  
https://code.claude.com/docs/en/getting-started

---

## 9. Trae IDE / VS Code 安装插件并复用本地 Claude Code

### 9.1 安装 “Claude Code for VS Code”

Anthropic 官方 VS Code 文档给出的前置条件包括 VS Code 版本要求（VS Code 1.98.0+），并说明扩展本身包含 CLI。来源：  
https://code.claude.com/docs/en/vs-code

阿里云百炼 Coding Plan 文档给出的流程是：

- 先完成 Claude Code 的 Coding Plan 配置（也就是第 5、6 节）。
- 然后在 VS Code 扩展市场搜索 `Claude Code for VS Code` 安装。
- 若对话时仍弹出 Anthropic 登录界面，说明还没完成配置。

来源：  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

Trae 属于 VS Code 系 IDE，通常流程一致：在 Trae 的扩展市场搜索并安装相同扩展即可。

如果你是通过系统快捷方式启动 VS Code/Trae，遇到扩展仍提示登录的情况，优先按第 5、6 节确认 `%USERPROFILE%\.claude\settings.json` 与 `%USERPROFILE%\.claude.json` 已正确配置；其次可尝试从终端进入项目目录后用 `code .` 启动 VS Code 以继承当前环境变量。来源：  
https://code.claude.com/docs/en/vs-code

### 9.2 插件与“本地服务”的关系说明

绝大多数 Claude Code IDE 插件并不是“调用一个本地 HTTP 服务”，而是：

- 在本机启动 `claude` 可执行文件（子进程）；
- 通过本地配置文件/环境变量决定它最终调用哪个模型网关（这里是百炼）。

因此要让插件不弹登录、直接走百炼，最稳妥的方式仍是第 5、6 节的用户级配置。

### 9.3 使用 CC-Switch 时，Trae/VS Code 插件如何继承配置

当你启用 CC-Switch 管理 Claude Provider 时，Trae / VS Code 插件通常仍通过本机 `claude` 子进程工作。实践建议：

- 先在 CC-Switch 里把目标 Provider 设置为当前（Current）。
- 重启 Trae/VS Code（确保扩展重新读取本机最新配置）。
- 在插件会话里执行 `/status`，确认 Base URL 指向百炼而非 `api.anthropic.com`。

若插件侧仍提示登录，按顺序排查：

1. `claude` 命令是否可用（`claude --version`）。
2. `%USERPROFILE%\.claude.json` 的 `hasCompletedOnboarding` 是否为 `true`。
3. 是否存在覆盖变量（`gci env:ANTHROPIC_*`）。
4. CC-Switch 当前 Provider 是否确实为百炼 Provider。

---

## 10. 汉化/中文体验：能做到什么、不能做到什么

### 10.1 VS Code / Trae UI 中文化（可行）

这属于编辑器本体的语言包能力：

- 在扩展市场安装 “Chinese (Simplified) Language Pack for Visual Studio Code”；
- 重启编辑器后，VS Code/Tre UI 会变为中文。

这不会修改 Claude Code 扩展本身是否提供中文 UI，但能把编辑器菜单、设置界面等变为中文。

### 10.2 Claude Code for VS Code 是否有“汉化补丁”（谨慎结论）

在公开官方文档与扩展说明中，并没有提供单独的“汉化补丁”安装方式。

更现实且安全的做法通常是：

- 让 Claude 的输出语言保持中文：直接用中文提问；或在项目/用户规则里固定语言偏好（例如在 `CLAUDE.md` 里写“请始终用中文回答”）。
- 使用 `/config` 打开配置菜单进行偏好设置（百炼 Coding Plan 文档也列出了 `/config`）。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

如果你确实需要“扩展 UI 全中文”，一般只能等扩展官方提供 i18n，或自行改包（会带来升级覆盖、许可证与安全风险，不建议在生产环境采用）。

---

## 11. 你原方案还缺什么？联网核对后的补全点清单

结合阿里云百炼与 Anthropic 官方文档，常见遗漏点是：

- Windows 需要 Git for Windows 或 WSL（很多人只装 Node.js 会卡住）。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code  
  https://code.claude.com/docs/en/getting-started
- 需要创建 `%USERPROFILE%\.claude.json` 并设置 `hasCompletedOnboarding: true`，否则可能会尝试连 Anthropic 官方。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code
- Base URL 需要区分按量付费与 Coding Plan；Coding Plan 专属 Base URL 是 `https://coding.dashscope.aliyuncs.com/apps/anthropic`。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code-coding-plan
- 如果使用“旧版兼容接口”，会被强制使用 `qwen3-coder-plus`，因此应优先使用新接口（`/apps/anthropic`）。来源：  
  https://help.aliyun.com/zh/model-studio/claude-code
- 原生 Windows 模式下若找不到 Git Bash，需要配置 `CLAUDE_CODE_GIT_BASH_PATH`。来源：  
  https://code.claude.com/docs/en/getting-started
- 当 `ANTHROPIC_BASE_URL` 指向非官方 host（例如代理/网关）时，Claude Code 的 MCP tool search 可能默认禁用；若你依赖 MCP 工具搜索，需要额外设置 `ENABLE_TOOL_SEARCH=true` 并确保网关转发 `tool_reference`。来源：  
  https://code.claude.com/docs/en/env-vars

---

## 12. 排错速查

### 12.1 仍弹出 Anthropic 登录 / 提示 Not logged in

- 先确认 `settings.json` 与 `.claude.json` 两个文件路径和内容无误。
- 在终端运行 `claude`，执行 `/status`，确认 Base URL 已指向百炼。
- 再回到 IDE 新开一个对话。

Coding Plan 文档明确提到：弹登录通常意味着尚未完成配置。来源：  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

### 12.2 报错 “Unable to connect to Anthropic services … api.anthropic.com”

- 核对 `ANTHROPIC_BASE_URL` 是否正确。
- 核对 `.claude.json` 的 `hasCompletedOnboarding` 是否为 `true`（且为顶层字段）。

来源：  
https://help.aliyun.com/zh/model-studio/claude-code

### 12.3 401/403 鉴权失败

- 确认 Key 是否对应同一地域或同一套餐（按量付费 vs Coding Plan）。
- Coding Plan 必须用 Coding Plan 专属 Key 与专属 Base URL。

来源：  
https://help.aliyun.com/zh/model-studio/claude-code-coding-plan

---

## 13. 安全建议（最小化风险）

- 不要把 API Key 写进项目代码仓库；优先放在用户级 `%USERPROFILE%\.claude\settings.json`。
- 若要团队分发配置，建议用企业内部密钥管理/设备管理方案统一下发，而不是把 Key 固定在仓库里。

---

## 14. 给 Trae AI 助手的执行指令 (Agent Instructions)

<agent-instructions>
当你（Trae AI 助手）被要求执行本篇安装配置文档时，请严格遵守以下自动化执行准则，避免挂起或失败：

1. **依赖检查与安装**：
   - 检查 `node` 和 `npm` 是否可用。如不可用，提示用户安装 Node.js。
   - 检查 `git` 是否可用。如不可用，使用 `winget install --id Git.Git -e --source winget` 静默安装 Git for Windows。
2. **获取 API Key**：
   - 在生成任何配置文件前，**必须先暂停执行并询问用户**提供其阿里云百炼 API Key。
3. **配置文件生成（禁止使用 GUI 程序）**：
   - 绝对**禁止**使用 `notepad` 等会阻塞进程的 GUI 程序。
   - 使用 PowerShell 的 `New-Item` 和 `Set-Content`，或 Node.js 脚本静默生成/更新 `$env:USERPROFILE\.claude\settings.json` 和 `$env:USERPROFILE\.claude.json`。
   - 在处理 `settings.json` 时，确保正确解析并合并 JSON，不要破坏现有结构。
4. **验证与测试（禁止交互式阻塞）**：
   - 绝对**禁止**直接运行 `claude` 命令进行验证，因为它是交互式 REPL，会导致你（Agent）的执行流永远卡死。
   - 使用 `claude --version` 或读取生成的配置文件内容来验证配置是否成功。
5. **插件安装与环境刷新**：
   - 提示用户在扩展市场手动搜索并安装 `Claude Code` 扩展。
   - 配置完成后，明确提示用户**手动重启 Trae IDE**，以确保环境变量和插件正确加载最新的本地配置。
</agent-instructions>
