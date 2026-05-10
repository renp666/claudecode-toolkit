---
description: 分析并修复 GitHub Issue
argument-hint: issue-number
allowed-tools: Bash(gh:*), Read, Write
---

分析并修复 GitHub Issue: $ARGUMENTS

步骤：
1. 使用 `gh issue view $ARGUMENTS` 获取 Issue 详情
2. 阅读相关代码，定位问题根因
3. 制定修复方案并实现
4. 运行测试验证修复
5. 提交代码，commit message 关联 Issue
