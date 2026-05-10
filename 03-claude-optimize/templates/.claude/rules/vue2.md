---
globs: ["**/*.vue", "**/*.js", "**/*.jsx"]
---
- 使用 Options API 风格，data/computed/methods/watch 分区清晰
- 状态管理使用 Vuex，module 化组织
- 组件样式使用 scoped CSS
- v-for 必须搭配 :key 使用唯一标识
- 避免直接修改 props，使用 $emit 通信
- mixin 中避免命名冲突，优先使用 scoped slot
