$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "== 1) 卸载旧版 Claude Code（若存在） =="
try {
  winget uninstall Anthropic.ClaudeCode --silent --accept-source-agreements
} catch {
  Write-Host "winget 卸载阶段可忽略错误（可能未安装）"
}

Write-Host "== 2) 安装 Claude Code =="
winget install Anthropic.ClaudeCode --accept-source-agreements --accept-package-agreements

Write-Host "== 3) 准备 Claude 本地目录 =="
New-Item -ItemType Directory -Force -Path "$HOME\\.claude" | Out-Null

Write-Host "== 4) 写入 .claude.json（跳过 onboarding） =="
$onboarding = @'
{
  "hasCompletedOnboarding": true
}
'@
Set-Content -LiteralPath "$HOME\\.claude.json" -Value $onboarding -Encoding UTF8

Write-Host "== 5) 写入 settings.json 模板（请自行填入 API Key） =="
$settings = @'
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
'@
Set-Content -LiteralPath "$HOME\\.claude\\settings.json" -Value $settings -Encoding UTF8

Write-Host "== 6) 安装验证 =="
claude --version

Write-Host "== 完成 =="
Write-Host "下一步：打开 CC-Switch 桌面版，把 Claude 当前 Provider 切换到百炼 Provider；然后重启 Trae/VS Code。"
