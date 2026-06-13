# Claude Code Pre-Commit Hook - Code Format Check
# Usage: echo '{"tool_input":{"command":"git commit..."}}' | powershell -NoProfile -File .claude/hooks/pre-commit-check.ps1

$ErrorActionPreference = "Stop"
$issues = @()

# Read stdin
$stdin = ""
try {
    $stream = [System.IO.StreamReader]::new([Console]::OpenStandardInput())
    if ($stream.Peek() -ne -1) { $stdin = $stream.ReadToEnd() }
    $stream.Close()
} catch {
    $stdin = $input | Out-String
}

# Parse command
$command = ""
if ($stdin) {
    try {
        $data = $stdin | ConvertFrom-Json
        $command = $data.tool_input.command
    } catch {}
}

# Only handle git commit (not merge, rebase, etc.)
if ($command -notmatch "git\s+commit\b") { exit 0 }

# Respect --no-verify flag
if ($command -match "--no-verify\b") {
    Write-Host "[pre-commit] --no-verify specified, skipping check" -ForegroundColor Yellow
    exit 0
}

Write-Host "[pre-commit] Starting code format check..." -ForegroundColor Cyan

# ============================================================
# Redundancy analysis: skip if project has its own pre-commit
# ============================================================
$hasExisting = $false
$existing = @()
if (Test-Path ".husky") { $hasExisting = $true; $existing += "Husky" }
if (Test-Path ".pre-commit-config.yaml") { $hasExisting = $true; $existing += "pre-commit" }
if (Test-Path ".git/hooks/pre-commit") { $hasExisting = $true; $existing += "Git hooks" }
if (Test-Path "package.json") {
    try {
        $pkg = Get-Content package.json | ConvertFrom-Json
        if ($pkg."lint-staged") { $hasExisting = $true; $existing += "lint-staged" }
    } catch {}
}

if ($hasExisting) {
    Write-Host "[pre-commit] Redundancy: project has $($existing -join ', '), skipping built-in checks" -ForegroundColor Green
    exit 0
}

Write-Host "[pre-commit] Redundancy: no existing checks, running built-in..." -ForegroundColor DarkGray

# ============================================================
# Get staged files
# ============================================================
$staged = git diff --cached --name-only --diff-filter=ACM 2>$null
if (-not $staged -or $staged.Count -eq 0) {
    Write-Host "[pre-commit] No staged files" -ForegroundColor Gray
    exit 0
}
$staged = $staged -split "\r?\n" | Where-Object { $_ -ne "" }
Write-Host "[pre-commit] Staged: $($staged.Count) files"

# ============================================================
# Rule 1: Large file check (> 500KB)
# ============================================================
foreach ($f in $staged) {
    if (Test-Path $f) {
        $sz = (Get-Item $f).Length
        if ($sz -gt 512000) {
            $issues += "Large file: $f ($([math]::Round($sz/1024,1)) KB), consider Git LFS"
        }
    }
}

# ============================================================
# Rule 2: Trailing whitespace + debug statements
# ============================================================
$binExts = @(".png",".jpg",".jpeg",".gif",".ico",".pdf",".zip",".gz",".tar",".exe",".dll",".so",".bin",".mp3",".mp4",".woff",".woff2",".ttf",".eot")
$wsIssues = @()
$dbgIssues = @()

foreach ($f in $staged) {
    if (-not (Test-Path $f)) { continue }
    $ext = [IO.Path]::GetExtension($f).ToLower()
    if ($binExts -contains $ext) { continue }

    $lines = Get-Content $f -ErrorAction SilentlyContinue
    if (-not $lines) { continue }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $ln = $i + 1
        $line = $lines[$i]

        if ($line -match "\s+$") {
            $wsIssues += "$f`:$ln"
        }
        if ($line -match "console\.(log|warn|error|debug)\(") {
            $dbgIssues += "$f`:$ln [JS/TS]: $($line.Trim())"
        } elseif ($line -match "^[ \t]*print\(") {
            $dbgIssues += "$f`:$ln [Python]: $($line.Trim())"
        } elseif ($line -match "fmt\.Print(ln|f)\(") {
            $dbgIssues += "$f`:$ln [Go]: $($line.Trim())"
        } elseif ($line -match "debugger;?") {
            $dbgIssues += "$f`:$ln [JS]: debugger"
        } elseif ($line -match "^[ \t]*breakpoint\(\)") {
            $dbgIssues += "$f`:$ln [Python]: breakpoint()"
        }
    }
}

if ($wsIssues.Count -gt 10) {
    $issues += "Trailing whitespace: $($wsIssues.Count) places (first 10: $($wsIssues[0..9] -join ', '))"
} elseif ($wsIssues.Count -gt 0) {
    $issues += "Trailing whitespace: $($wsIssues -join ', ')"
}

if ($dbgIssues.Count -gt 5) {
    $issues += "Debug statements: $($dbgIssues.Count) places (first 5: $($dbgIssues[0..4] -join '; '))"
} elseif ($dbgIssues.Count -gt 0) {
    $issues += "Debug statements: $($dbgIssues -join '; ')"
}

# ============================================================
# Rule 3: ESLint (if available)
# ============================================================
if (Test-Path "node_modules/.bin/eslint") {
    $jsFiles = $staged | Where-Object { $_ -match "\.(js|jsx|ts|tsx)$" }
    if ($jsFiles) {
        npx eslint --quiet $jsFiles 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $issues += "ESLint check failed, run 'npx eslint --fix'"
        }
    }
}

# ============================================================
# Output
# ============================================================
if ($issues.Count -gt 0) {
    Write-Host ""
    Write-Host "=" * 40 -ForegroundColor Red
    Write-Host " CODE CHECK FAILED" -ForegroundColor Red
    Write-Host "=" * 40 -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  x $issue" -ForegroundColor Red
    }
    Write-Host "=" * 40 -ForegroundColor Red
    Write-Host "Tip: use git commit --no-verify to bypass" -ForegroundColor Yellow
    Write-Host ""
    exit 1
} else {
    Write-Host "[pre-commit] Code check passed" -ForegroundColor Green
    exit 0
}
