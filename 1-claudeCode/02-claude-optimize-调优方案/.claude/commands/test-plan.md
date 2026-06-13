---
description: 生成测试计划并执行测试
argument-hint: test-scope
allowed-tools: Read, Bash(npm:*), Write
---

为 $ARGUMENTS 生成测试计划并执行：

1. 分析目标模块的代码结构和依赖
2. 识别需要测试的场景（正常/边界/异常）
3. 生成测试用例代码
4. 运行测试并报告结果
5. 如有失败，分析原因并修复
