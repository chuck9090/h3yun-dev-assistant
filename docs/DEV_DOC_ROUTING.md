# 氚专开发文档按需读取路由

处理氚云需求时，先读取本表；仅在需求命中对应主题、用户要求按氚专开发文档实现，或现有规则无法确认 API 签名、参数、返回值、事件时机或控件类型时，再读取对应开发文档。不要为简单需求加载全部文档。

| 需求意图或关键词 | 必读开发文档 |
| --- | --- |
| 按钮编码、自定义按钮、`actionName`、动态增删表单按钮、`response.Actions` | 读取技能内置 `docs/FORM_ACTIONS_GUIDELINES.md`；动态按钮不再依赖旧版官方网页 |
| 自动化、业务规则与代码的执行顺序或副作用 | [代码跟自动化混用](https://h3yunpro.github.io/docs/automation/) |
| 创建、加载、查询、提交、删除 `BizObject` | [业务对象](https://h3yunpro.github.io/docs/biz-object/) |
| 后端读取或设置主表、子表控件值 | [业务对象之控件的取值与赋值](https://h3yunpro.github.io/docs/bo-set-get/) |
| 获取应用、表单、子表、控件编码 | [应用、表单、控件编码查看](https://h3yunpro.github.io/docs/check-code/) |
| 后端 API 用法、`Engine`、常用 C# 示例 | [后端常用实例](https://h3yunpro.github.io/docs/cs-instance/)；必要时参考 [后端代码示例](https://h3yunpro.github.io/docs/cs-example/) |
| JSON 序列化或反序列化 | [后端 JSON 序列化与反序列化](https://h3yunpro.github.io/docs/cs-json/) |
| 数据库系统表、字段、附件表、流程表 | [数据库表结构详解](https://h3yunpro.github.io/docs/database/) |
| 开发环境、编辑器、调试工具 | [开发工具](https://h3yunpro.github.io/docs/dev-tools/) |
| 后端 SQL 查询、参数化 SQL | [后端执行 SQL](https://h3yunpro.github.io/docs/exec-sql/) |
| 平台报错、现象或 FAQ 类问题 | [常见问题解答](https://h3yunpro.github.io/docs/faq/) |
| 表单后端或前端事件、提交时机 | [表单事件](https://h3yunpro.github.io/docs/form-events/) |
| 表单前端 API、控件操作 | [表单前端 API](https://h3yunpro.github.io/docs/form-js-api/)；控件取值和赋值另读 [表单前端 GetValue 与 SetValue](https://h3yunpro.github.io/docs/form-js-set-get/) |
| 表单或列表前后端请求、`PostForm`、`ListView.Post` | [前后端交互示例](https://h3yunpro.github.io/docs/interactive-example/)；必要时参考 [纯净代码示例](https://h3yunpro.github.io/docs/pure-example/) |
| 表单前端完整示例、事件代码示例 | [前端代码示例](https://h3yunpro.github.io/docs/js-example/)；常见组合场景参考 [前端常用实例](https://h3yunpro.github.io/docs/js-instance/) |
| .NET/C#、JavaScript、浏览器兼容性 | [技术栈](https://h3yunpro.github.io/docs/language/) |
| 列表前端或后端事件 | [列表事件](https://h3yunpro.github.io/docs/list-events/)；列表删除获取选中数据时，另读 [后端代码示例-列表删除时获得用户选择的数据](https://h3yunpro.github.io/docs/cs-example/#%E5%88%97%E8%A1%A8-%E5%88%A0%E9%99%A4%E6%97%B6%E8%8E%B7%E5%BE%97%E7%94%A8%E6%88%B7%E9%80%89%E6%8B%A9%E7%9A%84%E6%95%B0%E6%8D%AE) |
| 列表前端 API、选中行、刷新、列表按钮 | [列表前端 API](https://h3yunpro.github.io/docs/list-js-api/) |
| 短信、通知、提醒 | [消息通知与提醒](https://h3yunpro.github.io/docs/notification/) |
| 平台术语、状态或对象含义 | [常见名词](https://h3yunpro.github.io/docs/noun/) |
| 外部系统调用氚云 | [第三方调用氚云 OpenAPI](https://h3yunpro.github.io/docs/open-api/) |
| 人员、部门、角色、组织关系 | [部门、人员与角色管理](https://h3yunpro.github.io/docs/organization/) |
| 氚云后端调用第三方 HTTP 接口 | [氚云调用 WebAPI](https://h3yunpro.github.io/docs/req-api/) |
| 氚云后端调用第三方 WebService | [氚云调用 WebService](https://h3yunpro.github.io/docs/req-ws/) |
| SQL 高级数据源 | [SQL 高级数据源](https://h3yunpro.github.io/docs/sql-dashboard/) |
| SQL 报表 | [SQL 报表](https://h3yunpro.github.io/docs/sql-report/) |
| SQL 查询范例 | [数据库操作示例](https://h3yunpro.github.io/docs/sql-example/) |
| 平台编程规范或代码风格 | [编程规范](https://h3yunpro.github.io/docs/standard/) |
| 计划、周期、延时执行 | [定时器](https://h3yunpro.github.io/docs/timer/) |
| 流程实例、节点、发起、审批、撤回、作废 | [流程操作](https://h3yunpro.github.io/docs/workflow/) |
| 常用工具函数 | [工具方法合集](https://h3yunpro.github.io/docs/tool-function/) |

无法归类或开发文档目录新增主题时，读取总索引：https://h3yunpro.github.io/llms.txt 。
