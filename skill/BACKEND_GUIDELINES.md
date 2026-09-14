# 后端 C# 规则

## 硬性限制

- 使用 .NET Framework 4.6.2 兼容语法；不使用 C# 8+ 特性、反射、`HashSet<T>` 或三目运算符。
- `if`、`else if`、`else`、`for`、`foreach`、`while`、`do while` 等控制流语句必须使用大括号，即使代码块中只有一条语句也不得省略；大括号采用 Allman 风格，单独占一行。只调整既有代码格式时不得改变业务逻辑。
- 不使用 `Task`、线程、线程池、普通 .NET 定时器或本地文件 I/O。涉及这些场景时先读取 `PLATFORM_CONSTRAINTS.md`。
- 不自行建立数据库连接，不使用 DDL，不直接用 SQL 增删改业务数据；业务数据操作使用 `BizObject`，批量操作使用平台批量接口。
- 在表单 `Post` 请求中，如果需要更新或删除当前业务对象，不能直接操作 `this.Request.BizObject`；必须先使用当前业务对象的 `ObjectId` 调用 `H3.DataModel.BizObject.Load` 加载完整业务对象，再执行赋值、`Update()` 或 `Remove()`。
- 避免循环调用 Engine、数据库或服务端接口；大数据量须分页或增加过滤条件。

## 事件与异常

- `OnLoad` 通常调用 `base.OnLoad(response)`。
- `OnSubmit` 无论成功、校验失败或提前返回，都必须调用 `base.OnSubmit(actionName, postValue, response)`。
- 校验方法优先命名为 `CheckData(H3.IEngine engine, H3.DataModel.BizObject thisBo)`，失败时 `throw new Exception("明确的错误说明")`。
- `OnSubmit` 统一捕获业务异常，以 `response.Errors.Add(ex.Message)` 返回。
- 比较时优先常量在前，例如 `"Submit".Equals(actionName)`。
- 流程表单的 `Submit` 同时可能表示发起提交和审批同意。仅在发起时执行的后端逻辑，必须结合数据状态和当前流程节点判断，不能只判断 `"Submit".Equals(actionName)`。

## 列表删除获取选中数据

- 列表后端处理系统删除按钮时，使用 `postValue.Data["ObjectIds"]` 获取用户选中的业务对象 Id 数组，标准写法为：`string[] selectedIds = (string[]) postValue.Data["ObjectIds"];`。
- 该写法来自官方后端代码示例“列表-删除时获得用户选择的数据”：https://h3yunpro.github.io/docs/cs-example/#%E5%88%97%E8%A1%A8-%E5%88%A0%E9%99%A4%E6%97%B6%E8%8E%B7%E5%BE%97%E7%94%A8%E6%88%B7%E9%80%89%E6%8B%A9%E7%9A%84%E6%95%B0%E6%8D%AE 。不得猜测为 `postValue["seIds"]`、`postValue["ObjectIds"]` 或其他参数名。
- 使用前必须判断数组不为 `null` 且长度大于 0；需要批量查询时，用 `ObjectId` 配合 `ComparisonOperatorType.In` 构造筛选器，并校验查询结果数量与选中 Id 数量一致。
- 列表 `OnSubmit` 处理删除时，无论自定义逻辑成功或异常，都必须保证 `base.OnSubmit(actionName, postValue, response)` 执行；异常应写入 `response.Errors` 后返回。

```csharp
protected override void OnSubmit(string actionName, H3.SmartForm.ListViewPostValue postValue, H3.SmartForm.SubmitListViewResponse response)
{
    try
    {
        if("Remove".Equals(actionName))
        {
            // 列表删除-用户选中的业务对象 Id
            string[] selectedIds = (string[]) postValue.Data["ObjectIds"];
            if(selectedIds != null && selectedIds.Length > 0)
            {
                // 列表表单-按选中业务对象 Id 批量查询
                H3.Data.Filter.Filter filter = new H3.Data.Filter.Filter();
                H3.Data.Filter.And andMatcher = new H3.Data.Filter.And();
                andMatcher.Add(new H3.Data.Filter.ItemMatcher("ObjectId", H3.Data.ComparisonOperatorType.In, selectedIds));
                filter.Matcher = andMatcher;
                filter.FromRowNum = 0;
                filter.ToRowNum = 1000;
                H3.DataModel.BizObject[] boArray = H3.DataModel.BizObject.GetList(
                    this.Engine,
                    H3.Organization.User.SystemUserId,
                    this.Request.Schema,
                    H3.DataModel.GetListScopeType.GlobalAll,
                    filter
                );
            }
        }
    }
    catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
        base.OnSubmit(actionName, postValue, response);
        return;
    }

    base.OnSubmit(actionName, postValue, response);
}
```

## 表单按钮增删

- 在表单后端 `OnLoad` 中，先调用 `base.OnLoad(response)`，再通过 `response.Actions` 调整按钮。
- 删除已有按钮前先用 `response.Actions.ContainsKey("按钮编码")` 判断，避免不存在时异常。
- 动态新增按钮使用 `response.Actions.Add("按钮编码", new H3.SmartForm.ViewAction("按钮编码", "按钮名称", ""))`。
- 需要按业务状态显示按钮时，读取 `this.Request.BizObject["字段编码"]` 后再决定是否添加；不要依赖前端直接操作 DOM。
- 动态按钮的编码必须与 `OnSubmit` 的 `actionName` 判断完全一致。

```csharp
protected override void OnLoad(H3.SmartForm.LoadSmartFormResponse response)
{
    base.OnLoad(response);

    if(response.Actions != null && response.Actions.ContainsKey("Save"))
    {
        response.Actions.Remove("Save");
    }

    // 示例表单-执行状态：F0000004
    string executeStatus = this.Request.BizObject["F0000004"] + string.Empty;
    if("暂停".Equals(executeStatus) && !response.Actions.ContainsKey("ContinueRecognition"))
    {
        response.Actions.Add(
            "ContinueRecognition",
            new H3.SmartForm.ViewAction("ContinueRecognition", "继续执行", "")
        );
    }
}
```

## 主表与子表控件取值

- 生成后端主表或子表控件的取值、赋值或类型转换代码前，必须先查阅氚专开发文档：https://h3yunpro.github.io/docs/bo-set-get/ 。
- 字符串、人员/部门单选、关联表单、人员/部门多选、关联表单多选、日期、数字、复选框、是/否、地址、位置、附件和图片的值类型及读写方式，必须以该文档为准，不得猜测类型。
- 从业务对象读取子表控件值时，必须转换为 `H3.DataModel.BizObject[]`，例如：`H3.DataModel.BizObject[] detailRows = thisBo["子表控件编码"] as H3.DataModel.BizObject[];`。
- 禁止将子表控件值转换为 `List<H3.DataModel.BizObject>`；平台返回的子表值类型为数组，错误转换会导致读取结果为空或运行异常。
- 使用子表数据前先判断数组是否为 `null` 或长度为 `0`，再用 `foreach` 遍历每一行。

## 自定义类

- 同一应用的后端会共同编译。新增辅助类必须以当前完整表单编码为前缀：`表单编码_类名`。
- 第一次引用辅助类时，在上一行标注：`// 类名类及方法名方法定义于【表单名称】表单设计页后端代码中`。
- 类内只定义字段，禁止使用 `{ get; set; }` 自动属性；氚云后端编译器不支持自动属性。
- 每个字段定义时必须同时给出默认值；对象类型字段可默认为 null。例如：`public string name = "";`、`public decimal qty = 0;`、`public List<string> ids = null;`。

## 方法复用

- 封装方法内部需要使用 `H3.IEngine` 时，必须将 `H3.IEngine engine` 作为方法入参传入，不直接使用 `this.Engine`，以提高方法复用性。
- 封装方法内部需要使用 `H3.DataModel.BizObject` 时，必须将业务对象作为方法入参传入，不直接使用 `this.Request.BizObject`，以提高方法复用性。

## 编码注释

- 表单编码旁标注表单名称；字段编码旁标注“表单名称-字段名称”。
- 新增封装方法上方添加一句中文注释说明处理目标。
