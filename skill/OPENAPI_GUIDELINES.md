# OpenAPI 规则

- 仅当外部系统调用氚云时使用 OpenAPI；不要与表单后端 `BizObject` 代码混用。
- 调用使用 HTTPS、POST、UTF-8、`application/json`，频率控制在每秒 1 至 2 次，超时不超过 60 秒。
- 必须确认 `EngineCode`、`AppCode`、`SchemaCode` 和控件编码；`EngineSecret` 为敏感信息，禁止写入前端、示例明文或公开仓库。
- 表单数据通常传 JSON 字符串。查询返回的 `xxxObject` 补充字段不可回传用于创建或更新。
- 创建、更新、删除会触发自动化和业务规则；批量或长耗时调用由调用方分批，不使用线程或后台任务。
- 接口请求体或签名不确定时，先从 https://h3yun-pro-doc-openapi.apifox.cn/llms.txt 定位并查阅对应接口文档。
