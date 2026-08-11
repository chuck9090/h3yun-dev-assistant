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
- 流程表单的 `Submit` 同时可能表示发起提交和审批同意。仅在发起时执行的后端逻辑，必须结合数据状态和当前流程节点判断，不能只判断 `"Submit".Equals(actionName)`。

## 主表与子表控件取值

- 生成后端主表或子表控件的取值、赋值或类型转换代码前，必须先查阅氚专开发文档：https://h3yunpro.github.io/docs/bo-set-get/ 。
- 字符串、人员/部门单选、关联表单、人员/部门多选、关联表单多选、日期、数字、复选框、是/否、地址、位置、附件和图片的值类型及读写方式，必须以该文档为准，不得猜测类型。
- 从业务对象读取子表控件值时，必须转换为 `H3.DataModel.BizObject[]`，例如：`H3.DataModel.BizObject[] detailRows = thisBo["子表控件编码"] as H3.DataModel.BizObject[];`。
- 禁止将子表控件值转换为 `List<H3.DataModel.BizObject>`；平台返回的子表值类型为数组，错误转换会导致读取结果为空或运行异常。
- 使用子表数据前先判断数组是否为 `null` 或长度为 `0`，再用 `foreach` 遍历每一行。

## 自定义类

- 同一应用的后端会共同编译。新增辅助类必须以当前完整表单编码为前缀：`表单编码_类名`。
- 第一次引用辅助类时，在上一行标注：`// 类名类及方法名方法定义于【表单名称】表单设计页后端代码中`。

## 编码注释

- 表单编码旁标注表单名称；字段编码旁标注“表单名称-字段名称”。
- 新增封装方法上方添加一句中文注释说明处理目标。
