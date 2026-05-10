# Claude Code 一键部署脚本
# 用法: .\setup-claude.ps1 [-Phase all|1|2|3] [-ProjectDir <path>]
# 说明: 将本脚本所在目录（scripts\..）作为模板源，部署到目标环境

param(
    [ValidateSet("all","1","2","3")]
    [string]$Phase = "all",
    [string]$ProjectDir = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateRoot = Split-Path -Parent $ScriptDir
$GlobalClaude = "$env:USERPROFILE\.claude"

function Write-Step($msg) { Write-Host "`n>>> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "    [SKIP] $msg" -ForegroundColor Yellow }

# ============================================================
# 阶段一：核心配置
# ============================================================
function Invoke-Phase1 {
    Write-Step "阶段一：核心配置"

    # 1. 全局目录
    New-Item -ItemType Directory -Force "$GlobalClaude\commands" | Out-Null
    New-Item -ItemType Directory -Force "$GlobalClaude\tools" | Out-Null
    Write-OK "全局目录已创建: $GlobalClaude"

    # 2. 全局 CLAUDE.md
    $src = Join-Path $TemplateRoot ".claude_global\CLAUDE.md"
    $dst = "$GlobalClaude\CLAUDE.md"
    if (Test-Path $dst) {
        Write-Skip "CLAUDE.md 已存在，跳过（如需覆盖请手动删除后重试）"
    } else {
        Copy-Item $src $dst
        Write-OK "全局 CLAUDE.md 已部署"
    }

    # 3. 全局命令
    $cmdSrc = Join-Path $TemplateRoot ".claude_global\commands"
    Copy-Item "$cmdSrc\*.md" "$GlobalClaude\commands\" -Force
    Write-OK "全局命令已部署 (review.md, fix-issue.md)"

    # 4. 项目级配置（如指定了项目目录）
    if ($ProjectDir) {
        New-Item -ItemType Directory -Force "$ProjectDir\.claude\rules" | Out-Null
        New-Item -ItemType Directory -Force "$ProjectDir\.claude\commands" | Out-Null
        New-Item -ItemType Directory -Force "$ProjectDir\.claude\agents" | Out-Null
        New-Item -ItemType Directory -Force "$ProjectDir\.claude\skills\caveman" | Out-Null

        # 项目 CLAUDE.md（从模板复制，用户自行修改）
        $projClaude = Join-Path $ProjectDir "CLAUDE.md"
        if (-not (Test-Path $projClaude)) {
            Copy-Item (Join-Path $TemplateRoot "templates\CLAUDE.md") $projClaude
            Write-OK "项目 CLAUDE.md 已部署（请根据项目实际情况修改）"
        } else {
            Write-Skip "项目 CLAUDE.md 已存在"
        }

        # Rules
        Copy-Item (Join-Path $TemplateRoot ".claude\rules\*.md") "$ProjectDir\.claude\rules\" -Force
        Write-OK "Rules 已部署 (frontend.md, backend.md, testing.md)"

        # Hooks settings.json
        $settingsSrc = Join-Path $TemplateRoot ".claude\settings.json"
        $settingsDst = Join-Path $ProjectDir ".claude\settings.json"
        if (-not (Test-Path $settingsDst)) {
            Copy-Item $settingsSrc $settingsDst
            Write-OK "Hooks settings.json 已部署"
        } else {
            Write-Skip "settings.json 已存在"
        }

        # 项目命令
        Copy-Item (Join-Path $TemplateRoot ".claude\commands\*.md") "$ProjectDir\.claude\commands\" -Force
        Write-OK "项目命令已部署 (deploy.md, test-plan.md)"

        # Agents
        Copy-Item (Join-Path $TemplateRoot ".claude\agents\*.md") "$ProjectDir\.claude\agents\" -Force
        Write-OK "角色型智能体已部署 (7个)"

        # MCP 配置
        $mcpDst = Join-Path $ProjectDir ".mcp.json"
        if (-not (Test-Path $mcpDst)) {
            Copy-Item (Join-Path $TemplateRoot "templates\.mcp.json") $mcpDst
            Write-OK "MCP 配置已部署（请设置 GITHUB_TOKEN 环境变量）"
        } else {
            Write-Skip ".mcp.json 已存在"
        }
    } else {
        Write-Skip "未指定 -ProjectDir，跳过项目级配置"
    }
}

# ============================================================
# 阶段二：提效增强
# ============================================================
function Invoke-Phase2 {
    Write-Step "阶段二：提效增强"

    # ccusage
    Write-Host "    检查 ccusage..."
    try {
        npx ccusage@latest --help 2>$null | Out-Null
        Write-OK "ccusage 可用"
    } catch {
        Write-Host "    [INFO] ccusage 首次运行时会自动下载" -ForegroundColor Gray
    }

    # rtk
    $rtkPath = Get-Command rtk -ErrorAction SilentlyContinue
    if ($rtkPath) {
        Write-OK "rtk 已安装: $($rtkPath.Source)"
    } else {
        Write-Host "    [INFO] rtk 未安装，请从 https://github.com/rtk-ai/rtk/releases 下载" -ForegroundColor Yellow
    }

    # Skills 部署（从模板源复制到项目）
    if ($ProjectDir) {
        $skillsSrc = Join-Path $TemplateRoot ".claude\skills"
        $skillsDst = Join-Path $ProjectDir ".claude\skills"
        New-Item -ItemType Directory -Force $skillsDst | Out-Null

        $skillDirs = @(
            "caveman",
            "addyosmani-spec-driven-development",
            "addyosmani-planning-and-task-breakdown",
            "addyosmani-code-simplification",
            "addyosmani-shipping-and-launch",
            "cache-components",
            "frontend-code-review",
            "webapp-testing"
        )

        foreach ($skill in $skillDirs) {
            $src = Join-Path $skillsSrc $skill
            $dst = Join-Path $skillsDst $skill
            if (Test-Path $src) {
                Copy-Item $src $dst -Recurse -Force
                Write-OK "Skill: $skill 已部署"
            } else {
                Write-Skip "Skill: $skill 源不存在，跳过"
            }
        }
    }

    Write-OK "阶段二完成（部分工具需手动安装，见上方提示）"
}

# ============================================================
# 阶段三：高级扩展
# ============================================================
function Invoke-Phase3 {
    Write-Step "阶段三：高级扩展"

    # mattpocock/skills
    Write-Host "    [INFO] mattpocock/skills 按需安装: npx skills@latest add mattpocock/skills" -ForegroundColor Gray

    # claude-monitor
    $pipCmd = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCmd) {
        Write-Host "    [INFO] claude-monitor 按需安装: pip install claude-monitor" -ForegroundColor Gray
    } else {
        Write-Host "    [INFO] pip 未找到，跳过 claude-monitor" -ForegroundColor Gray
    }

    Write-OK "阶段三完成（均为按需安装，见上方提示）"
}

# ============================================================
# 主流程
# ============================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Claude Code 环境部署脚本" -ForegroundColor Cyan
Write-Host "  模板源: $TemplateRoot" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

switch ($Phase) {
    "1"   { Invoke-Phase1 }
    "2"   { Invoke-Phase2 }
    "3"   { Invoke-Phase3 }
    "all" {
        Invoke-Phase1
        Invoke-Phase2
        Invoke-Phase3
    }
}

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "`n后续步骤:"
Write-Host "  1. 在 Claude Code 中执行 /permissions 配置权限白名单"
Write-Host "  2. 根据项目实际情况修改 CLAUDE.md"
Write-Host "  3. 运行 /agents 确认角色型智能体已加载"
Write-Host "  4. 运行 /mcp 确认 MCP 服务器已连接"
Write-Host ""
