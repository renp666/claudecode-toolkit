---
globs: ["**/*.ts", "**/*.tsx"]
---
- strict mode 开启，不关闭 strictNullChecks
- 泛型命名使用 T/K/V 约定，避免 any
- 优先使用 interface 定义对象，type 用于联合/交叉类型
- 使用 export type 明确类型导出
- 善用工具类型：Partial/Required/Pick/Omit/Record
- 避免 as 断言，优先类型守卫（type guard）
