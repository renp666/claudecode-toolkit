# Codex + DeepSeek 一键配置脚本
# 适用于：Windows 11 + PowerShell 7
# 功能：生成 .codex/config.toml 并设置环境变量
# 用法：.\scripts\setup-codex-deepseek.ps1 -ApiKey "sk-你的Key"
#       .\scripts\setup-codex-deepseek.ps1 -ApiKey "sk-你的Key" -Model "deepseek-v4-flash"

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,

    [string]$Model = "deepseek-v4-pro",

    [string]$ConfigPath = "$env:USERPROFILE\.codex\config.toml"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Codex + DeepSeek 一键配置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查 Codex CLI 是否已安装
Write-Host "[1/4] 检查 Codex CLI..." -ForegroundColor Yellow
$codexVersion = codex --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Codex CLI 未安装，请先运行: npm install -g @openai/codex" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Codex CLI 已安装: $codexVersion" -ForegroundColor Green

# 2. 设置环境变量
Write-Host "[2/4] 设置 DEEPSEEK_API_KEY 环境变量..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", $ApiKey, "User")
$env:DEEPSEEK_API_KEY = $ApiKey
Write-Host "  ✅ 环境变量已设置" -ForegroundColor Green

# 3. 创建 .codex 目录
Write-Host "[3/4] 创建配置目录..." -ForegroundColor Yellow
$codexDir = "$env:USERPROFILE\.codex"
if (-not (Test-Path $codexDir)) {
    New-Item -ItemType Directory -Path $codexDir -Force | Out-Null
}
Write-Host "  ✅ 目录已准备: $codexDir" -ForegroundColor Green

# 4. 备份原配置（如果存在）
if (Test-Path $ConfigPath) {
    $backupPath = "$ConfigPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "  🔄 检测到已有配置，备份至: $backupPath" -ForegroundColor Yellow
    Copy-Item $ConfigPath $backupPath
}

# 5. 写入配置
Write-Host "[4/4] 写入 DeepSeek 配置..." -ForegroundColor Yellow
$configContent = @"
# ============================================================
# Codex + DeepSeek 配置（自动生成 by setup-codex-deepseek.ps1）
# 生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ============================================================

# --- 默认模型 ---
model = "$Model"
model_provider = "deepseek"

# --- 模型供应商定义 ---
[model_providers.deepseek]
name = "DeepSeek"
base_url = "https://api.deepseek.com/v1"
wire_api = "responses"
env_key = "DEEPSEEK_API_KEY"
requires_openai_auth = false

# --- 模型能力声明 ---
[model_properties."deepseek-v4-pro"]
context_window = 262144
max_context_window = 262144
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]

[model_properties."deepseek-v4-flash"]
context_window = 262144
max_context_window = 262144
supports_parallel_tool_calls = true
supports_reasoning_summaries = false
input_modalities = ["text"]

# --- 多场景 Profiles ---
[profiles.deepseek-pro]
model = "deepseek-v4-pro"
model_provider = "deepseek"
model_reasoning_effort = "xhigh"

[profiles.deepseek-flash]
model = "deepseek-v4-flash"
model_provider = "deepseek"
model_reasoning_effort = "medium"

# --- 安全设置 ---
approval_mode = "default"
sandbox_mode = "workspace_write"
"@

Set-Content -Path $ConfigPath -Value $configContent -Encoding UTF8
Write-Host "  ✅ 配置已写入: $ConfigPath" -ForegroundColor Green

# 6. 验证
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  配置完成！验证步骤：" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  1. 启动 Codex: codex --model $Model"
Write-Host "  2. 输入: Hello, 请用中文介绍你自己"
Write-Host "  3. 预期: DeepSeek 正常回复"
Write-Host ""

Write-Host "  快捷命令：" -ForegroundColor Yellow
Write-Host "  - 旗舰模式: codex -p deepseek-pro" -ForegroundColor White
Write-Host "  - 快速模式: codex -p deepseek-flash" -ForegroundColor White
Write-Host "  - 通用模式: codex" -ForegroundColor White
Write-Host ""

Write-Host "  验证: codex --model $Model `"Hello, 请用中文介绍你自己`"" -ForegroundColor Green
