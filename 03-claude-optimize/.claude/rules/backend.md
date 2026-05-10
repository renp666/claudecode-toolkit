---
globs: ["backend/**", "src/api/**", "src/services/**"]
---
- API 必须有输入验证
- 错误统一使用 AppError 类
- 数据库操作必须有事务保护
- 所有外部调用必须有超时和重试
