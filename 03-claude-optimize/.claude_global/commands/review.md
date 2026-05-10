---
description: 审查当前分支的代码变更
allowed-tools: Read, Bash(git:*)
---

审查当前分支的代码变更：

1. 读取 `git diff` 了解变更范围
2. 检查：代码质量、潜在 bug、边界情况、性能问题
3. 检查：安全漏洞、错误处理、文档是否充分
4. 按严重程度分类输出：Critical / High / Medium / Low
