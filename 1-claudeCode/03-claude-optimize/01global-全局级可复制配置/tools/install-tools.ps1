# Claude Code 工具一键安装脚本
# 用途：下载并安装 rtk、ccusage、claude-monitor 等提效工具
# 使用：.\install-tools.ps1 [-Tool all|rtk|ccusage|monitor] [-AddToPath]

param(
    [ValidateSet("all", "rtk", "ccusage", "monitor")]
    [string]$Tool = "all",

    [switch]$AddToPath
)

$ErrorActionPreference = "Stop"
$ToolsDir = "$env:USERPROFILE\.claude\tools"

# ─── 工具定义 ───

$RtkRepo = "rtk-ai/rtk"
$RtkExe = "rtk.exe"

# ─── 辅助函数 ───

function Write-Step { param([string]$Msg) Write-Host ">> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "[OK] $Msg" -ForegroundColor Green }
function Write-Skip { param([string]$Msg) Write-Host "[SKIP] $Msg" -ForegroundColor Yellow }
function Write-Fail { param([string]$Msg) Write-Host "[FAIL] $Msg" -ForegroundColor Red }

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Get-PlatformAsset {
    # 根据平台选择 rtk release 资源
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "ARM64") {
        return "rtk-aarch64-pc-windows-msvc.zip"
    }
    return "rtk-x86_64-pc-windows-msvc.zip"
}

# ─── rtk 安装 ───

function Install-Rtk {
    Write-Step "安装 rtk (CLI 输出过滤器)"

    if (Test-CommandExists "rtk") {
        Write-Skip "rtk 已安装: $(Get-Command rtk | Select-Object -ExpandProperty Source)"
        return
    }

    # 获取最新 release
    Write-Step "获取 rtk 最新版本..."
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$RtkRepo/releases/latest" -Headers @{
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "claude-code-tools-installer"
    }
    $version = $release.tag_name
    $assetName = Get-PlatformAsset
    $asset = $release.assets | Where-Object { $_.name -eq $assetName }

    if (-not $asset) {
        Write-Fail "未找到匹配平台的资源: $assetName"
        Write-Host "  可用资源:" -ForegroundColor Gray
        $release.assets | ForEach-Object { Write-Host "    - $($_.name)" -ForegroundColor Gray }
        return
    }

    $downloadUrl = $asset.browser_download_url
    $zipPath = "$ToolsDir\rtk.zip"

    # 下载
    Write-Step "下载 $assetName ($version)..."
    New-Item -ItemType Directory -Force $ToolsDir | Out-Null
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

    # 解压
    Write-Step "解压到 $ToolsDir..."
    Expand-Archive -Path $zipPath -DestinationPath $ToolsDir -Force
    Remove-Item $zipPath -Force

    # 确认 rtk.exe 存在
    if (Test-Path "$ToolsDir\$RtkExe") {
        Write-Ok "rtk $version 安装成功: $ToolsDir\$RtkExe"
    } else {
        # 解压后可能在子目录，查找并移动
        $found = Get-ChildItem -Path $ToolsDir -Filter "rtk*.exe" -Recurse | Select-Object -First 1
        if ($found) {
            Move-Item $found.FullName "$ToolsDir\$RtkExe" -Force
            Write-Ok "rtk $version 安装成功: $ToolsDir\$RtkExe"
        } else {
            Write-Fail "rtk.exe 未找到，请手动检查 $ToolsDir"
        }
    }
}

# ─── ccusage 安装 ───

function Install-Ccusage {
    Write-Step "安装 ccusage (Token 用量监控)"

    if (-not (Test-CommandExists "node")) {
        Write-Fail "需要 Node.js，请先安装: https://nodejs.org"
        return
    }

    # ccusage 通过 npx 运行，无需全局安装
    Write-Step "验证 ccusage 可用性..."
    try {
        $null = & npx ccusage@latest --version 2>&1
        Write-Ok "ccusage 可用，使用方式: npx ccusage@latest daily"
    } catch {
        Write-Fail "ccusage 验证失败，请检查网络连接"
    }
}

# ─── claude-monitor 安装 ───

function Install-Monitor {
    Write-Step "安装 claude-monitor (实时限额预警)"

    if (-not (Test-CommandExists "pip")) {
        Write-Fail "需要 Python 3 + pip，请先安装: https://python.org"
        return
    }

    if (Test-CommandExists "claude-monitor") {
        Write-Skip "claude-monitor 已安装"
        return
    }

    Write-Step "pip install claude-monitor..."
    pip install claude-monitor --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "claude-monitor 安装成功，使用方式: claude-monitor --plan max5"
    } else {
        Write-Fail "claude-monitor 安装失败"
    }
}

# ─── PATH 管理 ───

function Add-ToolsToPath {
    Write-Step "将 $ToolsDir 添加到用户 PATH..."
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -like "*$ToolsDir*") {
        Write-Skip "PATH 中已包含 $ToolsDir"
        return
    }
    $newPath = "$currentPath;$ToolsDir"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    $env:PATH = "$env:PATH;$ToolsDir"
    Write-Ok "已添加到用户 PATH（当前会话已生效，新终端需重启）"
}

# ─── 主流程 ───

Write-Host ""
Write-Host "=== Claude Code 工具安装器 ===" -ForegroundColor White
Write-Host "目标目录: $ToolsDir" -ForegroundColor Gray
Write-Host ""

New-Item -ItemType Directory -Force $ToolsDir | Out-Null

switch ($Tool) {
    "rtk"     { Install-Rtk }
    "ccusage" { Install-Ccusage }
    "monitor" { Install-Monitor }
    "all"     {
        Install-Rtk
        Write-Host ""
        Install-Ccusage
        Write-Host ""
        Install-Monitor
    }
}

if ($AddToPath) {
    Write-Host ""
    Add-ToolsToPath
}

Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor White
Write-Host ""

# 输出使用提示
Write-Host "使用方式:" -ForegroundColor Cyan
Write-Host "  rtk          rtk git status          # 过滤 CLI 输出" -ForegroundColor Gray
Write-Host "  ccusage      npx ccusage@latest daily # 查看 Token 消耗" -ForegroundColor Gray
Write-Host "  monitor      claude-monitor --plan max5  # 实时限额预警" -ForegroundColor Gray
Write-Host ""
Write-Host "如需将 tools 目录加入 PATH，重新运行:" -ForegroundColor Yellow
Write-Host "  .\install-tools.ps1 -AddToPath" -ForegroundColor Gray
