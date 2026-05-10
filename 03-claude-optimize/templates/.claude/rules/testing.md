---
globs: ["**/*.test.*", "**/*.spec.*"]
---
- 测试命名：describe > it > expect
- 每个测试独立，不依赖执行顺序
- Mock 外部依赖，不 Mock 被测单元
- 覆盖正常路径 + 边界条件 + 错误处理
