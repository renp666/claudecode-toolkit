# Tools 目录

用于放置单文件 CLI 工具（如 rtk），便于统一管理与加入 PATH。

## 一键安装

```powershell
# 安装全部工具（rtk + ccusage + claude-monitor）
.\install-tools.ps1 -Tool all -AddToPath

# 只安装 rtk
.\install-tools.ps1 -Tool rtk

# 只安装 ccusage（需 Node.js）
.\install-tools.ps1 -Tool ccusage

# 只安装 claude-monitor（需 Python）
.\install-tools.ps1 -Tool monitor
```

## 工具清单

| 工具 | 用途 | 安装方式 |
|------|------|---------|
| rtk | CLI 输出过滤，减少 50-90% Token 消耗 | 脚本自动从 GitHub releases 下载 |
| ccusage | Token 用量基线分析 | `npx ccusage@latest daily`（无需安装） |
| claude-monitor | 实时限额预警 | `pip install claude-monitor` |

## 手动安装 rtk

如果脚本下载失败，可手动操作：
1. 访问 https://github.com/rtk-ai/rtk/releases
2. 下载 `rtk-x86_64-pc-windows-msvc.zip`（Windows x64）
3. 解压 `rtk.exe` 到此目录

## PATH 配置

将此目录加入系统 PATH，即可在任意位置调用工具：

```powershell
# 方式一：使用安装脚本（推荐）
.\install-tools.ps1 -AddToPath

# 方式二：手动添加（当前会话）
$env:PATH += ";$env:USERPROFILE\.claude\tools"

# 方式三：手动添加（持久化）
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$env:USERPROFILE\.claude\tools", "User")
```
