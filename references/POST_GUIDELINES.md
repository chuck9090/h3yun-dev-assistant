# 表单与列表 Post 规则

以下规则同时适用于表单 `$.SmartForm.PostForm` 和列表 `$.ListView.Post`，是不可违反的代码生成要求。

## 命名与委派

- 请求名称必须为 `功能名_Post`。
- 表单：前端 `PostForm` 的第一个参数、后端处理方法名、方法内 `actionName` 判断值必须完全相同。
- 列表：自定义按钮编码为 `功能名`，请求名称、后端处理方法名、方法内判断值必须为对应的 `功能名_Post`。
- `OnSubmit` 只调用对应的 `功能名_Post(actionName, this.Request, response)` 和 `base.OnSubmit(actionName, postValue, response)`；不得在 `OnSubmit` 直接读取参数、处理业务或组装响应。
- 每个 `功能名_Post` 方法开头必须判断不匹配的 `actionName` 并直接返回；方法内负责参数校验、业务处理、成功响应和异常捕获。

## ReturnData

- `response.ReturnData` 的类型固定为 `Dictionary<string, object>`。
- 成功响应必须先写：`response.ReturnData = new Dictionary<string, object>();`。
- 每一项响应数据必须用 `response.ReturnData.Add("键名", 值)` 添加。
- 禁止直接给 `response.ReturnData` 赋 `List`、数组、字符串或其他对象，否则会编译失败。
- 返回集合时，集合必须是字典中的一个值，例如 `response.ReturnData.Add("items", itemList);`。

```csharp
protected override void OnSubmit(string actionName, H3.SmartForm.SmartFormPostValue postValue, H3.SmartForm.SubmitSmartFormResponse response)
{
    QueryOrder_Post(actionName, this.Request, response);
    base.OnSubmit(actionName, postValue, response);
}

// 处理查询订单的前端 Post 请求。
public void QueryOrder_Post(string actionName, H3.SmartForm.SmartFormRequest request, H3.SmartForm.SubmitSmartFormResponse response)
{
    if(!"QueryOrder_Post".Equals(actionName))
    {
        return;
    }

    try
    {
        List<string> orderNos = new List<string>();
        response.ReturnData = new Dictionary<string, object>();
        response.ReturnData.Add("orderNos", orderNos);
    }
    catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
    }
}
```
