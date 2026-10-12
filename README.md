# 氚云二次开发助手 (h3yun-dev-assistant)

## 📖 项目简介

这是一个专为氚云平台设计的二次开发助手技能(Skill),用于帮助开发者快速编写符合氚云规范的代码,解答氚云二开相关问题。

## ✨ 主要功能

- **C# 后端代码生成**: 生成符合氚云规范的业务逻辑代码
- **ES5 前端代码生成**: 生成符合氚云规范的前端交互代码
- **API 使用指导**: 提供氚云 API 的正确用法和最佳实践
- **SQL 编写辅助**: 帮助编写符合氚云规范的 SQL 查询
- **错误排查**: 协助诊断和解决氚云二开过程中的常见问题

## 📋 使用场景

当你需要:
- 询问氚云二开相关问题
- 生成符合氚云规范的代码(C# 后端或 ES5 前端)
- 咨询氚云 API 用法
- 编写 SQL 查询语句
- 排查二开错误时

本技能将自动触发并提供专业支持。

## ⚠️ 注意事项

- 本技能仅适用于氚云平台,不适用于其他低代码平台
- 遵循氚云开发规范,禁止使用反射和 DDL 操作
- 优先参考氚专开发文档与氚云平台帮助文档

## 📄 许可证

本项目采用 GNU General Public License v3.0 许可证

## 🚀 快速开始

### 项目结构
`SKILL.md` 位于仓库根目录,规则文档统一放在 `references/` 子目录中,其余文件用于项目说明和打包维护。仓库目录名 `h3yun-dev-assistant` 与 `SKILL.md` 的 `name` 保持一致,符合 Agent Skills 规范。

- `SKILL.md`: 技能主说明文件
- `references/BACKEND_GUIDELINES.md`: 后端 C# 规则
- `references/FRONTEND_GUIDELINES.md`: 前端 ES5 规则
- `references/POST_GUIDELINES.md`: 表单与列表 Post 规则
- `references/SQL_GUIDELINES.md`: SQL 规则
- `references/OPENAPI_GUIDELINES.md`: OpenAPI 规则
- `references/PLATFORM_CONSTRAINTS.md`: 平台限制与长耗时任务规则
- `references/DEV_DOC_ROUTING.md`: 氚专开发文档按需读取路由
- `references/FORM_ACTIONS_GUIDELINES.md`: 表单按钮规则
- `references/TOOL_FUNCTIONS.md`: 氚云常用工具方法本地复用库
- `.github/workflows/release.yml`: GitHub 自动打包与发布工作流

### 代码风格与复用

- 后端 C# 代码使用 Allman 风格,前端 ES5 代码使用 K&R 风格
- 编写代码前优先检查并复用 `references/TOOL_FUNCTIONS.md`

### 发布技能文件

推送以 `v` 开头的版本 Tag 后,GitHub Actions 会校验 `SKILL.md` 与 `references/` 下的规则文档,并生成带版本号的 ZIP。ZIP 顶层固定为同名技能目录 `h3yun-dev-assistant/`,内含 `SKILL.md` 与 `references/`,解压到任意技能目录即可直接使用,无需手工调整目录名。新增规则文件或其他资源文件必须先提交到创建 Tag 的提交中。

例如发布 `v1.0.0`:

```shell
git tag v1.0.0
git push origin v1.0.0
```

工作流将生成 `h3yun-dev-assistant-v1.0.0.zip`,用户可在仓库的 Releases 页面下载并导入 AI 工具。
