# 项目开发指南

> 此文件由 `/init` 命令交互生成，或手动按此模板创建。
> Codex CLI 启动时会自动读取项目根目录的 `AGENTS.md` 加载项目上下文。

---

## 项目概述

- **项目名称**：[项目名称]
- **项目类型**：Web 应用 / API 服务 / CLI 工具 / 移动端 / 其他
- **核心语言**：[TypeScript / Python / Go / Rust / ...]
- **主要框架**：[React / Vue / Express / FastAPI / Gin / ...]

## 技术栈

- **前端**：[React 19 + TypeScript + Tailwind CSS]
- **后端**：[Node.js + Express + PostgreSQL]
- **基础设施**：[Docker / K8s / Nginx / Redis]
- **测试**：[Vitest / Playwright / pytest]
- **CI/CD**：[GitHub Actions / GitLab CI]

## 目录结构

```
[项目名]/
├── src/
│   ├── components/     # UI 组件
│   ├── services/       # 业务逻辑
│   ├── utils/          # 工具函数
│   └── types/          # 类型定义
├── tests/              # 测试文件
├── docs/               # 项目文档
└── scripts/            # 辅助脚本
```

## 编码规范

- **命名**：[严格 camelCase / PascalCase for classes / UPPER_SNAKE for constants]
- **文件组织**：[每个模块一个文件，导出单一职责]
- **API 设计**：[RESTful / GraphQL / gRPC]
- **错误处理**：[统一 { error: string, code: number } 格式]
- **提交规范**：[Conventional Commits]

## 架构决策记录（ADR）

<!-- 如果有重大架构决策，在此记录 -->
- 2026-06：选择 PostgreSQL 作为主数据库（原因：事务支持 + 成熟生态）

## 常用命令

```bash
# 开发
npm run dev          # 启动开发服务器
npm run build        # 生产构建

# 测试
npm run test         # 运行单元测试
npm run test:e2e     # 运行 E2E 测试

# 代码质量
npm run lint         # ESLint 代码检查
npm run typecheck    # TypeScript 类型检查

# 部署
npm run deploy:staging  # 部署到预发布环境
npm run deploy:prod     # 部署到生产环境
```

## 环境变量

```bash
# 数据库
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# API Keys（通过环境变量或 .env 文件注入）
# ⚠️ 不要在本文档中写入真实 Key
```

## 特殊说明

<!-- 任何 AI 编程助手需要特别了解的项目约定或背景信息 -->
- 本项目使用 monorepo 结构，`pnpm workspaces` 管理多包
- 所有 API 端点需要 JWT 认证，token 过期时间 24 小时
- 国际化支持中文和英文，文本统一放在 `locales/` 目录
