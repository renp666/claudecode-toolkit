# Codex CLI 配置模板目录

> 可直接复制到 `~/.codex/config.toml` 使用。所有模板遵循 Codex CLI v0.130+ 格式。

---

## 模板一览

| 文件名 | 适用模型 | 环境变量 | 推荐指数 |
|--------|---------|---------|---------|
| `deepseek-config.toml` | DeepSeek V4 Pro / Flash | `DEEPSEEK_API_KEY` | ★★★★★（首选） |
| `qwen-config.toml` | 通义千问 Qwen-Coder / Turbo | `DASHSCOPE_API_KEY` | ★★★★☆ |
| `glm-config.toml` | 智谱 GLM-4 Plus / Flash / Air | `ZHIPU_API_KEY` | ★★★★☆ |
| `moonshot-config.toml` | Kimi v1-8k / 32k / 128k | `MOONSHOT_API_KEY` | ★★★☆☆ |
| `multi-provider-config.toml` | 以上全部（一键通吃） | 按需设置 | ★★★★★（进阶） |
| `agents-template.md` | 通用项目说明模板 | 无 | ★★★★☆ |

## 使用方式

### 方式一：单文件替换（推荐新手）

```powershell
# Windows: 将 DeepSeek 配置设为默认
Copy-Item "config-templates\deepseek-config.toml" "$env:USERPROFILE\.codex\config.toml"
```

### 方式二：内容合并

如果已有 `config.toml`，手动复制 `[model_providers.xxx]` 和 `[model_properties.xxx]` 段追加到已有配置。

### 方式三：多供应商一键部署

```powershell
# Windows: 全量供应商配置
Copy-Item "config-templates\multi-provider-config.toml" "$env:USERPROFILE\.codex\config.toml"
# 然后设置你的 API Key 环境变量
# 启动后可用 codex -p <profile名> 切换
```

## 环境变量必填提醒

复制模板前，确保已设置对应环境变量：

```powershell
# 检查
echo $env:DEEPSEEK_API_KEY
echo $env:DASHSCOPE_API_KEY  # 通义千问
echo $env:ZHIPU_API_KEY       # 智谱 GLM
echo $env:MOONSHOT_API_KEY    # Kimi

# 设置（一次性）
[Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", "sk-你的Key", "User")
```

## 模板验证

```bash
# 替换配置后，测试连通性
codex --model deepseek-v4-pro "Hello, 请用中文介绍你自己"
```

预期：正常返回 DeepSeek 的中文回复。
