# 后端 C# 规则

## 硬性限制

- 使用 .NET Framework 4.6.2 兼容语法；不使用 C# 8+ 特性、反射、`HashSet<T>` 或三目运算符。
- 不使用 `Task`、线程、线程池、普通 .NET 定时器或本地文件 I/O。涉及这些场景时先读取 `PLATFORM_CONSTRAINTS.md`。
- 不自行建立数据库连接，不使用 DDL，不直接用 SQL 增删改业务数据；业务数据操作使用 `BizObject`，批量操作使用平台批量接口。
- 避免循环调用 Engine、数据库或服务端接口；大数据量须分页或增加过滤条件。

## 事件与异常

- `OnLoad` 通常调用 `base.OnLoad(response)`。
- `OnSubmit` 无论成功、校验失败或提前返回，都必须调用 `base.OnSubmit(actionName, postValue, response)`。
- 校验方法优先命名为 `CheckData(H3.IEngine engine, H3.DataModel.BizObject thisBo)`，失败时 `throw new Exception("明确的错误说明")`。
- `OnSubmit` 统一捕获业务异常，以 `response.Errors.Add(ex.Message)` 返回。
- 比较时优先常量在前，例如 `"Submit".Equals(actionName)`。

## 自定义类

- 同一应用的后端会共同编译。新增辅助类必须以当前完整表单编码为前缀：`表单编码_类名`。
- 第一次引用辅助类时，在上一行标注：`// 类名类及方法名方法定义于【表单名称】表单设计页后端代码中`。

## 编码注释

- 表单编码旁标注表单名称；字段编码旁标注“表单名称-字段名称”。
- 新增封装方法上方添加一句中文注释说明处理目标。
