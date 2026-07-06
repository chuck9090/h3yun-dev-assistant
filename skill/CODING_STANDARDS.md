# 氚云二开编程规范

本文件记录氚云/H3Yun 二次开发中的推荐编程规范和最佳实践。处理氚云 C# 后端、ES5 前端、SQL 或排错任务时，应优先遵守这些约定。

## 后端 C# 硬性规则

氚云后端环境按 .NET Framework 4.6.2 / C# 处理。

必须遵守：

- 不使用 .NET Core、.NET 5+、C# 8+ 特性。
- 不使用反射，不引用 `System.Reflection`。
- 不使用 `SqlConnection` 等自行建立数据库连接的方式。
- 不使用 DDL：`CREATE`、`DROP`、`ALTER` 等。
- 不用 SQL 直接增删改业务数据，业务数据增删改优先用 `BizObject`。
- 批量创建、更新、删除时使用 `BulkCommit` 或平台批量接口。
- 避免在循环中调用 Engine 接口、数据库查询、服务端接口。
- 避免一次性读取上千条数据，必要时分页或加过滤条件。
- 避免使用标记为 `[Obsolete]` 的类或方法。
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

```javascript
$.SmartForm.PostForm("Test_Post", {
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
    Test_Post(actionName, this.Request, response);
    base.OnSubmit(actionName, postValue, response);
}

public void Test_Post(string actionName, H3.SmartForm.SmartFormRequest request, H3.SmartForm.SubmitSmartFormResponse response)
{
    if(actionName != "Test_Post")
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
        response.ReturnData["data"] = "";
    } catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
    }
}
```

## 列表页前后端交互

列表页前后端交互使用 `$.ListView.Post`，不要写成表单页的 `$.SmartForm.PostForm`。列表按钮请求优先在 `$.ListView.ActionPreDo` 中校验选中行、数量上限，再传 `ObjectId` 数组的 JSON 字符串。

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
        $.ListView.Post(actionCode + "_Post", {
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
