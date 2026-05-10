---
globs: ["**/*.vue", "**/*.ts", "**/*.tsx"]
---
- 使用 Composition API + <script setup> 语法
- 状态管理使用 Pinia，按功能域拆分 store
- 可复用逻辑抽取为 composables（useXxx 命名）
- 类型完整定义，使用 defineProps<T>() 泛型语法
- 大列表使用 v-memo 优化渲染
- 避免在 watch/watchEffect 中修改触发源数据
