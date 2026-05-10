---
globs: ["**/*.tsx", "**/*.jsx"]
---
- 函数组件 + Hooks，不使用 Class 组件
- 服务端状态使用 React Query / SWR 管理
- Context 仅用于全局配置和主题，避免过度使用
- 使用 React.memo + useMemo/useCallback 优化重渲染
- 自定义 Hook 抽取复用逻辑（useXxx 命名）
- 错误边界包裹关键组件树
