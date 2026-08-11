# 前端 ES5 规则

## 硬性规则

- 使用 `var` 和 `function`；禁止 `let`、`const`、箭头函数、`class`、`Promise`、`async/await`、解构、模板字符串和可选链。
- 不直接操作 DOM；控件仅使用氚云 API，例如 `GetValue()`、`SetValue()`、`SetVisible()`、`SetReadonly()`。
- `$.extend($.JForm, {...})` 只定义平台支持的事件入口。单一事件的辅助逻辑放在事件内部；跨事件复用时定义到带表单编码前缀的 `window` 方法。
- 不循环调用服务端接口；子表新增优先批量操作。

## 表单按钮

- 点击顺序：`OnValidate` -> `BeforeSubmit` -> 后端 `OnSubmit` -> `AfterSubmit`。
- 流程表单的 `Submit` 同时表示发起和同意。仅发起时执行的校验，必须结合 `ResponseContext` 判断新增、草稿或发起节点，不能只判断 `Submit`。
- 自定义 Post 按钮在 `OnValidate` 中完成必要校验后返回 `false`，阻止平台默认提交。

## 列表按钮

- 列表按钮前置校验使用 `$.ListView.ActionPreDo`。
- 批量操作先校验选中行与数量上限，再传递选中 `ObjectId` 的 JSON 字符串。
