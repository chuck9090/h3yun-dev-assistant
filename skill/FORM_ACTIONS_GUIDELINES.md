# 氚云表单按钮规则

本文件整理自氚云官方“表单按钮”开发说明，用于在官方旧文档下架后继续指导表单按钮开发。

## 适用范围

- 表单后端 `OnLoad` 中删除、替换、动态增加按钮。
- 表单后端 `OnSubmit` 中按按钮编码处理业务。
- 根据当前业务对象字段值决定按钮是否显示。

## 关键对象

- `response.Actions`：表单加载响应中的按钮字典，键为按钮编码，值为 `H3.SmartForm.ViewAction`。
- `H3.SmartForm.ViewAction`：按钮定义，构造参数为按钮编码、显示名称和说明文本。
- `actionName`：表单后端 `OnSubmit` 的按钮编码。
- `this.Request.BizObject`：当前表单业务对象，可读取字段值决定是否动态添加按钮。

## 基本规则

- `OnLoad` 必须先调用 `base.OnLoad(response)`。
- 操作 `response.Actions` 前先判断其不为 `null`。
- 删除按钮前先使用 `response.Actions.ContainsKey("按钮编码")` 判断。
- 新增按钮前同样判断编码不存在，避免重复添加异常。
- 动态添加的按钮编码必须与 `OnSubmit` 中判断的 `actionName` 完全一致。
- 自定义按钮编码只使用英文字母和数字，避免中文、空格及特殊字符。
- 不通过前端 DOM 操作新增或隐藏表单头部按钮，应由后端 `response.Actions` 决定。

## 删除与新增按钮

```csharp
protected override void OnLoad(H3.SmartForm.LoadSmartFormResponse response)
{
    base.OnLoad(response);

    if(response.Actions == null)
    {
        return;
    }

    if(response.Actions.ContainsKey("Save"))
    {
        response.Actions.Remove("Save");
    }

    if(!response.Actions.ContainsKey("TestAction"))
    {
        response.Actions.Add(
            "TestAction",
            new H3.SmartForm.ViewAction("TestAction", "测试按钮", "")
        );
    }
}
```

## 按字段状态动态添加按钮

```csharp
protected override void OnLoad(H3.SmartForm.LoadSmartFormResponse response)
{
    base.OnLoad(response);

    if(response.Actions == null)
    {
        return;
    }

    // 示例表单-处理状态：F0000001
    string processStatus = this.Request.BizObject["F0000001"] + string.Empty;
    if("待处理".Equals(processStatus) && !response.Actions.ContainsKey("TestAction"))
    {
        response.Actions.Add(
            "TestAction",
            new H3.SmartForm.ViewAction("TestAction", "测试按钮", "")
        );
    }
}
```

## OnSubmit 处理动态按钮

```csharp
protected override void OnSubmit(
    string actionName,
    H3.SmartForm.SmartFormPostValue postValue,
    H3.SmartForm.SubmitSmartFormResponse response)
{
    try
    {
        if("TestAction".Equals(actionName))
        {
            // 处理测试按钮业务。
        }
    }
    catch(Exception ex)
    {
        response.Errors.Add(ex.Message);
    }

    base.OnSubmit(actionName, postValue, response);
}
```

## 系统按钮编码

| 名称 | 编码 |
| --- | --- |
| 暂存 | `Save` |
| 提交/同意 | `Submit` |
| 删除 | `Remove` |
| 撤回 | `RetrieveInstance` |
| 不同意 | `Reject` |
| 作废 | `CancelInstance` |
| 打印 | `Print` |
| 关闭 | `Close` |

`Submit` 同时可能表示发起提交和流程审批同意。需要区分时，必须结合表单数据状态或流程节点编码判断。
