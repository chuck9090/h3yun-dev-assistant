# 氚云二开编程规范

本文件记录氚云/H3Yun 二次开发中的推荐编程规范和最佳实践。处理氚云 C# 后端、ES5 前端、SQL 或排错任务时，应优先遵守这些约定。

## 现有代码参考原则

- 现有代码只用于理解和延续可验证的业务行为、字段与表单编码、事件入口、调用关系、平台 API 用法及必要兼容约束，不作为新代码的风格模板。
- 生成或修改代码时，不照搬现有代码中的不规范命名、混乱结构、重复逻辑、过深嵌套、不合理异常处理、过时写法或注释缺失。
- 新增代码应符合本文件规范。规范与现有风格冲突时，不修改原有代码来统一风格，并保持用户要求的业务行为不变。
- 用户要求新增逻辑时，原有代码默认保持不变，只能对接入新逻辑所必需的位置做最小修改。不得附带进行重命名、格式化、结构调整、补注释、方法提取、去重或其他清理工作。
- 发现原有代码存在坏风格、潜在缺陷或规范问题时，只做说明，不直接修改。除非问题会阻止新增逻辑正确运行，否则必须等用户明确要求后再处理。
- 原有代码问题会阻止新增逻辑运行时，应先说明原因及最小修复范围；用户未授权修复时，不得自行扩大改动。
- 无法判断某种旧写法属于坏风格还是平台兼容要求时，应先验证，不得盲目复制或删除。

## 后端 C# 硬性规则

氚云后端环境按 .NET Framework 4.6.2 / C# 处理。

线程、普通 .NET Timer、进程内异步任务和本地文件 I/O 等能力受到限制，主要是为了保障云端平台稳定性和资源可控性，避免用户代码使用不当导致线程、CPU、内存、磁盘或 I/O 等资源占用过高。设计方案时应使用氚云平台提供的替代能力，而不是尝试绕过限制。

必须遵守：

- 不使用 .NET Core、.NET 5+、C# 8+ 特性。
- 不使用反射，不引用 `System.Reflection`。
- 不使用 `System.Threading.Tasks.Task`、`Task.Run`、`Task.Delay`、线程池或普通 .NET 定时器实现后台、延时或周期任务；计划和周期任务使用氚云 `H3.SmartForm.Timer`。
- 不使用本地文件 I/O，不引用 `System.IO`，不使用 `File`、`Directory`、文件流、临时目录或服务器本地路径。
- 不使用 `SqlConnection` 等自行建立数据库连接的方式。
- 不使用 DDL：`CREATE`、`DROP`、`ALTER` 等。
- 不用 SQL 直接增删改业务数据，业务数据增删改优先用 `BizObject`。
- 批量创建、更新、删除时使用 `BulkCommit` 或平台批量接口。
- 避免在循环中调用 Engine 接口、数据库查询、服务端接口。
- 避免一次性读取上千条数据，必要时分页或加过滤条件。
- 避免使用标记为 `[Obsolete]` 的类或方法。
- 不使用 `HashSet<T>`，氚云沙箱不支持此类型。去重需求用 `Dictionary<string, object>` 的 Key 替代。
- 生成代码不要使用三目运算符 `?:`，优先使用清晰的 `if` 判断，提升可读性。
- 判断字符串或对象相等时优先常量在前，例如 `"Jack".Equals(userName)`。

## 后端 C# 常用对象操作

```csharp
// 读取控件值
string value = bo["控件编码"] + string.Empty;
if(string.IsNullOrWhiteSpace(value))
{
    // 控件值为空
}

// 设置控件值
bo["控件编码"] = "新值";

// 数字转换
decimal amount = 0;
string numStr = bo["数值控件编码"] + string.Empty;
if(!string.IsNullOrWhiteSpace(numStr))
{
    amount = Convert.ToDecimal(numStr);
}

// 日期转换
DateTime date = Convert.ToDateTime(bo["日期控件编码"]);
```

## 后端 C# 常用事件原则

- `OnLoad`：打开表单时触发，通常需要执行 `base.OnLoad(response)`。
- `OnSubmit`：表单按钮或前端 Post 请求触发，使用 `actionName` 判断按钮或自定义请求。
- `OnWorkflowInstanceStateChanged`：流程状态变化时触发，需要手动添加事件方法。
- 修改当前表单数据时，注意 `base.OnSubmit` 前后的执行时机，避免乐观锁。

`OnSubmit` 基础结构：

```csharp
public override void OnSubmit(string actionName, H3.SmartForm.PostValue postValue, H3.SmartForm.SubmitResponse response)
{
    if (actionName == "Submit")
    {
        // 提交或同意
    }
    else if (actionName == "Save")
    {
        // 暂存
    }
    else if (actionName == "Remove")
    {
        // 删除
    }

    base.OnSubmit(actionName, postValue, response);
}
```

## 后端 C# 通用风格

- 氚云表单后端 `OnSubmit` 中，无论是否出现校验异常或需要提前返回，都必须调用 `base.OnSubmit(actionName, postValue, response)`。
- 业务校验方法优先命名为 `CheckData`。
- `CheckData` 应尽量保持独立，优先通过参数接收运行上下文和当前业务对象，不直接依赖控制器成员。
- `CheckData` 推荐签名：`private void CheckData(H3.IEngine engine, H3.DataModel.BizObject thisBo)`。
- `CheckData` 内发现业务异常时，直接 `throw new Exception("异常说明")`。
- `OnSubmit` 中使用 `try catch` 捕获 `CheckData` 抛出的异常，并通过 `response.Errors.Add(ex.Message)` 返回给前端。
- 从 `OnSubmit` 的异常分支提前 `return` 前，必须先调用 `base.OnSubmit(actionName, postValue, response)`。
- 辅助查询方法也应尽量通过参数接收 `H3.IEngine engine`，避免直接使用 `this.Engine`，提升方法独立性。

## OnSubmit 校验推荐结构

```csharp
protected override void OnSubmit(string actionName, H3.SmartForm.SmartFormPostValue postValue, H3.SmartForm.SubmitSmartFormResponse response)
{
    if(actionName == "Submit")
    {
        try
        {
            CheckData(this.Engine, this.Request.BizObject);
        }
        catch(Exception ex)
        {
            response.Errors.Add(ex.Message);
            base.OnSubmit(actionName, postValue, response);
            return;
        }
    }

    base.OnSubmit(actionName, postValue, response);
}
```

## CheckData 推荐结构

```csharp
private void CheckData(H3.IEngine engine, H3.DataModel.BizObject thisBo)
{
    if(thisBo == null)
    {
        throw new Exception("当前业务对象为空。");
    }

    // 在这里编写业务校验逻辑。
    // 校验失败时直接 throw new Exception("具体错误提示")。
}
```

## 异常处理约定

- 业务方法内不要直接操作 `response.Errors`，除非该方法本身就是响应处理方法。
- 独立业务方法应通过 `throw` 抛出异常，由入口方法统一捕获和响应。
- 返回给用户的异常信息应清晰说明字段、数据或业务条件，避免只返回“校验失败”。

## 前端 ES5 硬性规则

氚云前端按 ES5 JavaScript 处理。

必须遵守：

- 使用 `var`，不要使用 `let`、`const`。
- 使用 `function`，不要使用箭头函数。
- 使用字符串拼接，不要使用模板字符串。
- 不使用 `class`、`Promise`、`async/await`、解构赋值、可选链。
- 不直接操作 DOM，不使用 `document.getElementById`、`querySelector`、`appendChild`、`setAttribute` 等。
- 控件操作使用氚云标准 API，例如 `GetValue()`、`SetValue()`、`SetVisible()`、`SetReadonly()`。
- `$.extend($.JForm, {...})` 中只能定义氚云支持的事件入口，例如 `OnLoad`、`OnLoadActions`、`OnValidate`、`BeforeSubmit`、`AfterSubmit`；禁止在其中扩展自定义方法或通过 `this.自定义方法()` 调用，否则可能无法执行。
- 仅供单个事件使用的辅助判断或处理逻辑，直接定义并调用在该事件函数内部；跨事件复用的辅助函数才定义到 `window` 命名空间，并使用表单编码前缀避免冲突。
- 前端不要循环调用服务端接口，尽量一次请求传入批量数据。
- 子表批量添加优先使用批量方法，不要逐行频繁触发联动。

## 表单前端基本结构

```javascript
OnLoad: function() {
    var that = this;
    var value = that.控件编码.GetValue();
    that.控件编码.SetValue(value);
}
```

## 表单按钮校验

流程表单中，`Submit` 同时用于发起提交和审批同意。仅需在发起时执行的前端校验，必须结合 `ResponseContext` 判断，不得仅以 `actionControl.Action == "Submit"` 作为条件，否则每个审批节点都会执行校验。发起提交的判断如下：

```javascript
if( actionControl.Action == "Submit" && (
    $.SmartForm.ResponseContext.IsCreateMode || // 新增
    $.SmartForm.ResponseContext.BizObjectStatus == 0 || // 打开草稿数据
    $.SmartForm.ResponseContext.ActivityCode == "Activity2" // 发起节点
) ) {
    // 仅在发起提交时执行的校验逻辑。
}
```

`Activity2` 是氚云流程默认的发起节点编码，未说明流程节点被调整时直接使用 `Activity2`；仅当用户明确调整过发起节点编码时，才替换为用户提供的实际编码。

```javascript
OnValidate: function(actionControl) {
    var that = this;

    if (actionControl.Action == "Submit") {
        // 提交或同意前校验
    }

    if (actionControl.Action == "按钮编码") {
        // return false 可阻止默认提交，常用于自定义 Post
        return false;
    }

    return true;
}
```

## 表单前后端交互

表单前端使用 `$.SmartForm.PostForm` 时，必须遵守以下规则：

- `actionName` 必须采用 `功能名_Post` 格式，前端传入值、后端处理方法名和后端判断值必须完全一致，例如 `QueryOrder_Post`。
- 后端业务必须封装到与 `actionName` 同名的方法中。`OnSubmit` 只负责调用该方法和调用 `base.OnSubmit`，不得直接编写 Post 请求的参数读取、业务处理或响应赋值逻辑。
- 自定义 Post 响应必须先执行 `response.ReturnData = new Dictionary<string, object>();`，再使用 `response.ReturnData.Add("键名", 值)` 添加每项返回值。
- `response.ReturnData` 的类型是 `Dictionary<string, object>`，禁止直接将 `List`、数组、字符串或其他对象赋给它。返回列表时必须作为字典中的一个值，例如 `response.ReturnData.Add("items", itemList);`。

```javascript
$.SmartForm.PostForm("QueryOrder_Post", {
    "orderDate": "2023-01-11"
}, function(data) {
    if (data.Errors && data.Errors.length) {
        $.IShowError("错误", JSON.stringify(data.Errors));
    } else {
        var result = data.ReturnData;
    }
}, function(error) {
    $.IShowError("错误", JSON.stringify(error));
}, false);
```

表单后端接收自定义 Post：

```csharp
protected override void OnSubmit(string actionName, H3.SmartForm.SmartFormPostValue postValue, H3.SmartForm.SubmitSmartFormResponse response)
{
    QueryOrder_Post(actionName, this.Request, response);
    base.OnSubmit(actionName, postValue, response);
}

// 处理查询订单的前端 Post 请求。
public void QueryOrder_Post(string actionName, H3.SmartForm.SmartFormRequest request, H3.SmartForm.SubmitSmartFormResponse response)
{
    if(actionName != "QueryOrder_Post")
    {
        return;
    }

    try
    {
        H3.IEngine engine = request.Engine;
        string currUserId = request.UserContext.UserId;

        string orderDate_Str = request["orderDate"] + string.Empty;
        if(string.IsNullOrWhiteSpace(orderDate_Str))
        {
            throw new Exception("orderDate参数值为空！");
        }
        DateTime orderDate = DateTime.Parse(orderDate_Str);

        response.ReturnData = new Dictionary<string, object>();
        List<string> orderNos = new List<string>();
        response.ReturnData.Add("orderNos", orderNos);
    } catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
    }
}
```

## 列表页前后端交互

列表页前后端交互使用 `$.ListView.Post`，不要写成表单页的 `$.SmartForm.PostForm`。列表按钮请求优先在 `$.ListView.ActionPreDo` 中校验选中行、数量上限，再传 `ObjectId` 数组的 JSON 字符串。

列表前端使用 `$.ListView.Post` 时，必须遵守以下规则：

- 自定义按钮编码为 `功能名` 时，`actionName` 必须为 `功能名_Post`。前端传入值、后端处理方法名和后端判断值必须完全一致，例如按钮 `BatchApprove` 对应 `BatchApprove_Post`。
- 后端业务必须封装到与 `actionName` 同名的方法中。列表后端 `OnSubmit` 只负责调用该方法和调用 `base.OnSubmit`，不得直接编写 Post 请求的参数读取、业务处理或响应赋值逻辑。
- 自定义 Post 响应必须先执行 `response.ReturnData = new Dictionary<string, object>();`，再使用 `response.ReturnData.Add("键名", 值)` 添加每项返回值。
- `response.ReturnData` 的类型是 `Dictionary<string, object>`，禁止直接将 `List`、数组、字符串或其他对象赋给它。返回列表时必须作为字典中的一个值，例如 `response.ReturnData.Add("items", itemList);`。

```javascript
$.ListView.ActionPreDo = function(actionCode) {
    if (actionCode == "TestBtn") {
        var maxSelectedCount = 10;
        var seDatas = $.ListView.GetSelected();
        if (!seDatas || !seDatas.length) {
            $.IShowWarn("警告", "没有选中任何行");
            return false;
        }
        if (seDatas.length > maxSelectedCount) {
            $.IShowWarn("警告", "一次批量处理最多" + maxSelectedCount + "条！");
            return false;
        }

        var seIds = [];
        for (var i = 0; i < seDatas.length; i++) {
            seIds.push(seDatas[i]["ObjectId"]);
        }

        $.IShowSuccess("成功", "系统处理中，请稍候...");
        $.ListView.Post("TestBtn_Post", {
            "seIds": JSON.stringify(seIds)
        }, function(data) {
            if (data.Errors && data.Errors.length) {
                $.IShowError("错误", JSON.stringify(data.Errors));
            } else {
                $.IShowSuccess("成功", "系统处理完成！");
                $.ListView.RefreshView();
            }
        }, function(error) {
            $.IShowError("错误", JSON.stringify(error));
        }, false);

        return false;
    }
};
```

列表后端接收自定义 Post：

```csharp
protected override void OnSubmit(string actionName, H3.SmartForm.ListViewPostValue postValue, H3.SmartForm.SubmitListViewResponse response)
{
    TestBtn_Post(actionName, this.Request, response);
    base.OnSubmit(actionName, postValue, response);
}

// 处理批量测试按钮的前端 Post 请求。
public void TestBtn_Post(string actionName, H3.SmartForm.ListViewRequest request, H3.SmartForm.SubmitListViewResponse response)
{
    if(actionName != "TestBtn_Post")
    {
        return;
    }

    try
    {
        string seIdsStr = request["seIds"] + string.Empty;
        if(string.IsNullOrWhiteSpace(seIdsStr))
        {
            throw new Exception("没有选中任何行。");
        }

        string[] seIds = this.Deserialize<string[]>(seIdsStr);
        if(seIds == null || seIds.Length == 0)
        {
            throw new Exception("没有选中任何行。");
        }

        List<string> processedIds = new List<string>();
        response.ReturnData = new Dictionary<string, object>();
        response.ReturnData.Add("processedIds", processedIds);
    }
    catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
    }
}
```

## SQL 规则

SQL 主要用于查询、报表、高级数据源，不要用 SQL 直接增删改业务数据。

必须遵守：

- 查询条件使用参数化，禁止拼接用户输入。
- 后端执行 SQL 使用 `engine.Query.QueryTable(sql, parameters)`，不要写成 `engine.QueryEngine.ExecuteSql`。
- 参数对象必须使用三参构造：`new H3.Data.Database.Parameter("@参数名", System.Data.DbType.String, value)`，不能省略第二个 `System.Data.DbType.*` 参数。
- `System.Data.DbType.String` 只是字符串示例，不是固定写法；必须根据参数值类型选择对应 `DbType`。
- 参数名要和 SQL 中的 `@参数名` 一致。
- 判断空值使用 `IS NULL` / `IS NOT NULL`，不要写 `= NULL`。
- 可直接粘贴到氚云编辑器的 C# SQL 字符串尽量保持单行。
- 表名、字段名不确定时向用户确认，不要臆造控件编码。

表名规则：

- 业务主表：`i_表单编码`
- 业务子表：`i_子表控件编码`
- 关联表单多选中间表：`i_表单编码_关联表单多选控件编码` 或 `i_子表控件编码_关联表单多选控件编码`

关联表单多选中间表常见字段：

- `ObjectId`：主表或子表数据 ObjectId。
- `ValueIndex`：选项序号，从 0 开始。
- `PropertyValue`：关联数据 ObjectId。

常见系统表：

- `H_User`：用户。
- `H_Organizationunit`：部门。
- `H_Company`：公司。
- `H_WorkflowInstance`：流程实例。
- `H_WorkItem`：流程工作项。
- `H_Token`：流程步骤。
- `H_Comment`：审批意见。
- `H_BizObjectFile`：附件/图片。
- `H_OrgRole`：角色。
- `H_Orgpost`：角色与用户关系。
- `H_FunctionAcl`：角色与表单关系。

参数化查询示例：

```csharp
string sql = "SELECT ObjectId FROM H_User WHERE Name = @name; ";

List<H3.Data.Database.Parameter> parameters = new List<H3.Data.Database.Parameter>();
H3.Data.Database.Parameter param = new H3.Data.Database.Parameter(
    "@name",
    System.Data.DbType.String,
    "张三"
);
parameters.Add(param);

System.Data.DataTable dt = engine.Query.QueryTable(sql, parameters.ToArray());
if(dt == null || dt.Rows.Count == 0)
{
    // 未查询到数据
} else {
    foreach(System.Data.DataRow row in dt.Rows)
    {
        string objectId = row["ObjectId"] + string.Empty;
    }
}
```

常用 `System.Data.DbType` 映射：`string` 用 `String`，`int` 用 `Int32`，`long` 用 `Int64`，`double` 用 `Double`，`decimal` 用 `Decimal`，`DateTime` 用 `DateTime`，`bool` 用 `Boolean`。
