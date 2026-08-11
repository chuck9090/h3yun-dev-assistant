# SQL 规则

- SQL 仅用于查询、报表和高级数据源；禁止用 SQL 直接增删改业务数据或执行 DDL。
- 所有用户输入条件使用参数化查询。参数使用三参构造：`new H3.Data.Database.Parameter("@参数名", System.Data.DbType.实际类型, value)`；`DbType` 必须与值类型匹配，例如字符串用 `String`、整数用 `Int32`/`Int64`、小数用 `Decimal`、日期用 `DateTime`、布尔值用 `Boolean`。
- 后端使用 `engine.Query.QueryTable(sql, parameters.ToArray())`；参数集合为空时可传 `null`。
- 空值使用 `IS NULL` 或 `IS NOT NULL`，不使用 `= NULL`。
- 不确定表单编码、控件编码、表名或字段名时，先通过 SQL 排查工具读取项目中的 `cmax.json` 与相关 `fields.md`。
- 业务主表为 `i_表单编码`，子表为 `i_子表控件编码`，关联表单多选中间表为 `i_表单编码_关联表单多选控件编码` 或 `i_子表控件编码_关联表单多选控件编码`。
