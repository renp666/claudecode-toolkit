---
globs: ["**/*.go"]
---
- 并发使用 errgroup 管理 goroutine 生命周期
- 接口小而精（1-3 个方法），遵循 interface segregation
- 测试使用 table-driven tests 模式
- 错误处理使用 %w 包装，保留调用链
- Context 作为第一个参数传递，不存储在 struct 中
- 避免 init() 函数副作用，使用显式初始化
