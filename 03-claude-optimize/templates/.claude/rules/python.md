---
globs: ["**/*.py"]
---
- 使用 Ruff 进行 lint 和格式化
- 数据校验使用 Pydantic v2 模型
- 异步 IO 使用 async/await + httpx
- 依赖管理使用 uv + pyproject.toml
- 类型注解完整，使用 mypy strict 检查
- 环境变量使用 pydantic-settings 管理
