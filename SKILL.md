---
name: h3yun-dev-assistant
description: 氚云二次开发助手。当用户询问氚云二开相关问题、请求生成符合氚云规范的代码（C# 后端或 ES5 前端）、咨询氚云 API 用法、SQL 编写或排查二开错误时触发。不适用于其他低代码平台或通用编程问题。
---

# 氚云二开助手 (H3Yun Dev Assistant)

本技能旨在辅助开发者在氚云（H3Yun）低代码平台上进行高效、规范的二次开发。

## 1. 核心原则

- **规范优先**：所有生成的代码必须严格遵循氚云的技术栈约束和编码规范。
- **文档为据**：当本地规则未覆盖时，按以下优先级参考：
  1. 优先参考 [氚云开发文档](https://h3yunpro.github.io/llms.txt) 和本技能内置的官方文档链接
  2. 如果文档中也没有相关内容，则要求用户提供参考信息或指定文档链接
- **安全第一**：SQL 操作必须使用参数化查询，避免注入风险；批量操作需使用 `BulkCommit`。
- **版本兼容**：
  - 后端：.NET Framework 4.6.2 / C#
  - 前端：ECMAScript 5 (ES5) / JavaScript

## 2. 技术栈约束

### 2.1 后端开发 (.NET Framework 4.6.2)
- **语言**：C#
- **禁止**：使用 .NET Core 或 .NET 5+ 特有 API。
- **规范**：
  - 业务表名规则：`i_表单编码`（小写 `i`）。
  - SQL 语句需保持在一行，避免编辑器报错。
  - 优先使用 `BizObject` 标准方法（Load, Create, Update, Remove, GetList）。
  - 大量数据操作必须使用 `BulkCommit`。

### 2.2 前端开发 (ES5)
- **语言**：JavaScript (ES5)
- **禁止**：
  - `let` / `const`（使用 `var`）
  - 箭头函数 `=>`（使用 `function`）
  - 模板字符串 `` ` ${} ` ``（使用字符串拼接 `+`）
  - `class`、`Promise`、`async/await`、解构赋值等现代特性。
- **规范**：
  - 加载事件中先转存 `this`：`var that = this;`
  - 控件操作：`that.控件编码.GetValue()` / `SetValue()`
  - 表单页前后端交互：`$.SmartForm.PostForm`
  - 列表页前后端交互：`$.ListView.Post`

## 3. 常用 API 参考

本章节提供氚云二开常用操作的分类索引，具体 API 用法、参数说明及完整示例请参考官方文档。

### 3.1 后端开发 API

#### 业务对象操作（BizObject）
- **加载单个对象**：使用 `BizObject.Load()` 方法  
  📖 [业务对象文档](https://h3yunpro.github.io/docs/biz-object/)
- **批量查询列表**：使用 `BizObject.GetList()` 配合 Filter  
  📖 [业务对象文档](https://h3yunpro.github.io/docs/biz-object/)
- **创建数据**：使用 `BizObject.Create()` 或 `Create(commit)` 批量提交  
  📖 [业务对象文档](https://h3yunpro.github.io/docs/biz-object/)
- **更新数据**：使用 `BizObject.Update()` 或 `Update(commit)` 批量提交  
  📖 [业务对象文档](https://h3yunpro.github.io/docs/biz-object/)
- **删除数据**：使用 `BizObject.Remove()`  
  📖 [业务对象文档](https://h3yunpro.github.io/docs/biz-object/)
- **控件取值与赋值**：通过 `bo["控件编码"]` 访问  
  📖 [控件取值&赋值](https://h3yunpro.github.io/docs/bo-set-get/)

#### 后端代码示例与实例
- **标准代码示例**：包含 Load、Create、Update、GetList 等完整用法  
  📖 [后端代码示例](https://h3yunpro.github.io/docs/cs-example/)
- **常用实例场景**：如权限判断、日期处理、字符串操作等  
  📖 [后端常用实例](https://h3yunpro.github.io/docs/cs-instance/)
- **JSON 序列化与反序列化**：处理前后端数据交互  
  📖 [后端 Json 序列化](https://h3yunpro.github.io/docs/cs-json/)

#### 数据库操作
- **执行 SQL 查询**：使用 `engine.QueryEngine` 执行参数化 SQL  
  📖 [后端执行 SQL](https://h3yunpro.github.io/docs/exec-sql/)
- **数据库表结构**：了解业务表（`i_表单编码`）及系统表结构  
  📖 [数据库表结构详解](https://h3yunpro.github.io/docs/database/)
- **SQL 高级数据源**：构建复杂查询与报表  
  📖 [SQL 高级数据源](https://h3yunpro.github.io/docs/sql-dashboard/)
- **SQL 报表开发**：自定义报表实现  
  📖 [SQL 报表](https://h3yunpro.github.io/docs/sql-report/)
- **数据库操作示例**：常见 SQL 操作场景  
  📖 [数据库操作示例](https://h3yunpro.github.io/docs/sql-example/)

#### 组织与人员管理
- **部门、人员、角色操作**：查询用户信息、组织架构等  
  📖 [部门&人员&角色管理](https://h3yunpro.github.io/docs/organization/)

#### 工作流操作
- **流程实例管理**：启动流程、审批、撤回等操作  
  📖 [流程操作](https://h3yunpro.github.io/docs/workflow/)

#### 消息通知
- **发送消息与提醒**：站内消息、钉钉通知等  
  📖 [消息通知&提醒](https://h3yunpro.github.io/docs/notification/)
- **发送钉钉消息**：支持发送钉钉文本消息到指定用户  
  📖 [发送通知消息](https://help.h3yun.com/contents/889/1006.html)
- **发送邮件**：支持发送邮件到指定邮箱地址  
  📖 [发送邮件](https://help.h3yun.com/contents/889/1006.html)
- **发送短信**：支持发送短信到指定手机号（统一前缀为"氚云"）  
  📖 [发送短信](https://help.h3yun.com/contents/1330/2568.html)
- **创建定时提醒任务**：支持创建一次性或周期性提醒任务，系统自动在指定时间发送消息  
  📖 [创建提醒任务](https://help.h3yun.com/contents/889/1006.html)

#### 定时器任务
- **定时任务配置与开发**：周期性执行后台任务  
  📖 [定时器](https://h3yunpro.github.io/docs/timer/)

#### 工具方法
- **常用工具函数合集**：类型转换、日期处理、字符串截取、四舍五入等  
  📖 [工具方法合集](https://h3yunpro.github.io/docs/tool-function/)

---

### 3.2 前端开发 API

#### 表单前端 API
- **控件取值与赋值**：使用 `GetValue()` / `SetValue()`  
  📖 [表单前端 GetValue&SetValue](https://h3yunpro.github.io/docs/form-js-set-get/)
- **控件显示/隐藏、只读/可写**：使用 `SetVisible()` / `SetReadonly()`  
  📖 [表单前端 API](https://h3yunpro.github.io/docs/form-js-api/)
- **子表操作**：添加行、删除行、清空子表等  
  📖 [表单前端 API](https://h3yunpro.github.io/docs/form-js-api/)
- **表单事件**：OnLoad、OnValidate、AfterSubmit 等  
  📖 [表单事件](https://h3yunpro.github.io/docs/form-events/)
- **子表联动计算**：通过 BindChange 监听子表字段变化，使用 GetCellManager 获取单元格值，UpdateRow 更新其他列  
  📖 [子表联动计算](https://help.h3yun.com/contents/241/799.html#section8)
- **控件单击事件绑定**：使用 BindClickEvent 为单行文本或数值控件绑定单击事件（仅支持这两种控件类型）  
  📖 [控件单击事件](https://help.h3yun.com/contents/241/799.html#section9)
- **子表单元格单击事件**：遍历子表行，通过 GetCellManager 获取单元格管理器并绑定单击事件（仅支持单行文本和数值控件）  
  📖 [子表单元格单击事件](https://help.h3yun.com/contents/241/799.html#section10)

#### 列表前端 API
- **列表页操作**：获取选中行、刷新列表等  
  📖 [列表前端 API](https://h3yunpro.github.io/docs/list-js-api/)
- **列表事件**：列表加载、行点击等事件处理  
  📖 [列表事件](https://h3yunpro.github.io/docs/list-events/)

#### 前端代码示例与实例
- **标准前端代码示例**：包含控件操作、子表处理、前后端交互等  
  📖 [前端代码示例](https://h3yunpro.github.io/docs/js-example/)
- **常用前端实例场景**：如动态显隐、联动校验、数据格式化等  
  📖 [前端常用实例](https://h3yunpro.github.io/docs/js-instance/)

---

### 3.3 前后端交互

- **前后端交互示例**：使用 `$.SmartForm.PostForm` 进行 AJAX 调用  
  📖 [前后端交互示例](https://h3yunpro.github.io/docs/interactive-example/)
- **纯净代码示例**：无框架依赖的基础交互模式  
  📖 [纯净代码示例](https://h3yunpro.github.io/docs/pure-example/)

---

### 3.4 外部接口调用

#### 氚云 OpenApi
- **第三方系统调用氚云**：通过 OpenApi 接口创建、查询、更新数据  
  📖 [第三方调用氚云 OpenApi](https://h3yunpro.github.io/docs/open-api/)

#### 调用外部服务
- **氚云调用 WebAPI**：在后端代码中调用外部 REST API  
  📖 [氚云调用 WebAPI](https://h3yunpro.github.io/docs/req-api/)
- **氚云调用 WebService**：调用 SOAP 服务  
  📖 [氚云调用 WebService](https://h3yunpro.github.io/docs/req-ws/)

---

### 3.5 开发规范与工具

#### 编程规范
- **编码规范总览**：命名规范、注释规范、性能优化建议等  
  📖 [编程规范](https://h3yunpro.github.io/docs/standard/)
- **前端代码合规说明**：氚云前端不支持 DOM 操作，需使用标准 API  
  📖 [前端代码合规说明](https://help.h3yun.com/contents/241/2507.html)
  - **禁止的 DOM 操作**：document.getElementById/getElementsByName/getElementsByClassName/getElementsByTagName、element.getAttribute/setAttribute、document.createElement/createTextNode/createAttribute、element.appendChild/insertBefore/removeChild 等
  - **原因**：DOM 操作依赖的元素会随产品升级而变化，导致功能失效；通用需求应向氚云提需求，通过产品能力实现
  - **解决方案**：使用氚云提供的标准前端 API（GetValue/SetValue/SetVisible/SetReadonly 等）
- **自定义代码开发指导规范**：后端开发最佳实践与注意事项  
  📖 [自定义代码开发指导规范](https://help.h3yun.com/contents/191/2628.html)
  - **禁止使用过时 API**：不能使用标记为 [Obsolete] 的类或方法，避免新版本兼容性问题
  - **避免空引用异常**：Object.Equals 方法应使用常量或有值对象调用，如 `"Jack".Equals(user)` 而非 `user.Equals("Jack")`
  - **禁止循环调用 Engine 接口**：跨进程接口调用耗时长，应改用批量接口（如 BulkCommit）
  - **SQL 参数化查询**：必须使用参数化查询防止 SQL 注入，禁止字符串拼接 SQL
  - **批量操作优化**：大量数据创建/更新时使用 BulkCommit 提升性能
  - **BizObject 标准方法**：优先使用 Load/Create/Update/Remove/GetList 等标准方法
  - **禁止反射操作**：不允许使用反射（Reflection）机制，GetType() 等方法只能单线程执行，性能比普通代码慢约10倍
  - **禁止特定引用和方法**：禁止使用 Finalize、MemberwiseClone、GetType、Clone、GetHashCode 等核心方法，以及 System.Reflection、System.Threading.Monitor、数据库连接类（SqlConnection 等）、动态编译类
  - **禁止 DDL 操作**：禁止对数据库执行 DDL（数据定义语言）操作，如 CREATE/DROP/ALTER TABLE 等
  - **禁止大数据量操作**：禁止一次性读取上千条数据的大数据量操作
  - **禁止循环调用数据库**：不允许在循环中执行数据库操作
  - **禁止 SQL 直接操作业务数据**：不要通过 SQL 直接对业务数据进行增删改，需通过 BizObject 接口操作
  - **前端禁止循环调用服务端**：前端代码禁用循环调用服务端接口，应构造一次性调用返回
  - **前端子表批量添加**：前端子表行添加时，尽量采用 BatchAddRows 等批量添加方法
  - **建议赋值完整对象**：对人员、部门、关联数据的赋值，尽量赋值完整对象而非仅 ObjectId
  - **乐观锁机制注意事项**：出现 "UpdateFailed"、"ItemExists" 或 "Optimistic lock failed" 错误时为乐观锁报错；避免在 base.OnSubmit 前调用 Update、激活流程、更新当前数据或操作子表；如需多次更新应在每次更新前重新 Load 数据

#### 开发工具
- **辅助开发工具**：代码生成器、调试工具等  
  📖 [开发工具](https://h3yunpro.github.io/docs/dev-tools/)

#### 常见问题
- **FAQ 常见问题解答**：常见错误排查与解决方案  
  📖 [常见问题解答](https://h3yunpro.github.io/docs/faq/)

#### 名词解释
- **氚云常见名词**：表单、应用、控件、流程等概念说明  
  📖 [常见名词](https://h3yunpro.github.io/docs/noun/)

#### 代码查看
- **查看应用、表单、控件编码**：快速获取编码标识  
  📖 [应用、表单、控件编码查看](https://h3yunpro.github.io/docs/check-code/)

#### 自动化与代码混用
- **代码与自动化规则混用注意事项**  
  📖 [代码跟自动化混用](https://h3yunpro.github.io/docs/automation/)

## 4. 数据库规范

### 4.1 业务表与系统表

- **业务主表**：`i_表单编码`
- **业务子表**：`i_子表控件编码`
- **关联多选中间表**：
  - 控件在主表：`i_表单编码_关联表单多选控件编码`
  - 控件在子表：`i_子表控件编码_关联表单多选控件编码`
  - 表结构说明：
    - `ObjectId`：主表数据Id / 子表数据Id（对应控件所在的主表或子表的 ObjectId）
    - `ValueIndex`：本选项是第几个，从 0 开始
    - `PropertyValue`：描述表单多选控件的其中 1 个选项值（若此关联表单控件有多个值，会在此表有多行数据），对应所关联的表单数据的 ObjectId 字段
- **常用系统表**：
  - `H_User`：用户表
  - `H_Organizationunit`：部门表
  - `H_Company`：公司表
  - `H_WorkflowInstance`：流程实例表
  - `H_WorkItem`：流程工作项表
  - `H_Token`：流程步骤表
  - `H_Comment`：审批意见记录表
  - `H_BizObjectFile`：附件/图片记录表
  - `H_OrgRole`：角色表
  - `H_Orgpost`：角色与用户关系表
  - `H_FunctionAcl`：角色与表单关系表

📖 [数据库表结构详解](https://h3yunpro.github.io/docs/database/)

### 4.2 SQL 查询规范

- **参数化查询**：务必使用参数化查询，避免 SQL 注入风险。
- **NULL 值处理**：查询 NULL 值使用 `IS NULL`，而非 `= NULL`。
- **批量操作**：大量数据操作必须使用 `BulkCommit` 提升性能。
- **关联多选查询示例**：
  ```csharp
  // 查询某个主表数据关联的所有多选值
  string sql = "SELECT PropertyValue FROM i_表单编码_关联表单多选控件编码 WHERE ObjectId = @ObjectId ORDER BY ValueIndex";
  var values = engine.QueryEngine.ExecuteSql(sql, new { ObjectId = objectId });
  ```

## 5. 事件处理

📖 [表单事件完整文档](https://h3yunpro.github.io/docs/form-events/)

### 5.1 表单后端事件

- **OnLoad**：打开表单页时最先触发，在触发完后才会到达前端的 OnLoad 事件；需执行 `base.OnLoad(response)` 将业务对象转换到 response 上响应给前端渲染
- **OnSubmit**：按钮点击或 Post 请求时触发；`actionName` 参数标识触发来源（按钮编码或自定义请求名称）；不同 actionName 有不同的默认处理效果（Save/Submit 保存数据、Submit 触发生效规则、Remove 触发作废规则等）
- **OnWorkflowInstanceStateChanged**：流程状态发生改变时触发；有 oldState 和 newState 两个参数，可判断是结束还是重新激活；需手动添加到表单类中

### 5.2 表单前端事件

- **OnLoad**：后端 OnLoad 执行完并渲染表单后触发；用于表单加载完成后的初始化操作
- **OnLoadActions**：前端 OnLoad 执行完后，渲染表单头部按钮时，每个按钮触发一次；针对每个按钮的加载后处理
- **OnValidate**：用户点击表单按钮时触发；用于校验数据和给控件赋值；`actionControl.Action` 的值即按钮编码
- **BeforeSubmit**：前端 OnValidate 执行完成后触发；提交前的最后处理
- **AfterSubmit**：后端 OnSubmit 执行完成后，前端收到响应数据时触发；提交完成后的后续处理

### 5.3 事件触发顺序

**表单页加载顺序**：
后端 OnLoad → 前端 OnLoad → 前端 OnLoadActions（每个按钮触发一次）

**表单按钮点击顺序**：
前端 OnValidate → 前端 BeforeSubmit → 后端 OnSubmit → 前端 AfterSubmit

### 5.4 列表事件

📖 [列表事件完整文档](https://h3yunpro.github.io/docs/list-events/)

**列表前端事件**：
- **ActionPreDo**：点击列表按钮时触发；接收 actionCode 参数（按钮编码）；用于拦截和处理平台默认按钮（Create、Import、Export、Remove、PrintQrCode）及自定义按钮；统计分析按钮点击不经过该事件

**列表后端事件**：
- **OnInit**：列表页初始打开时触发，比 OnLoad 更早；用于设置列表初始状态（按钮显隐、筛选条件、排序字段、分页配置等）；需在 `base.OnInit(response)` 之后编写自定义代码
- **OnLoad**：每次加载列表数据时触发（初始打开、筛选变化、切换分页、排序等）；用于自定义数据查询逻辑或对查询结果进行二次处理；必须执行 `base.OnLoad(response)` 以保持默认查询功能
- **OnSubmit**：按钮点击或 Post 请求时触发；`actionName` 为按钮编码或自定义请求名称；处理删除操作（Remove 时自动删除选中数据）及自定义按钮逻辑；必须执行 `base.OnSubmit(actionName, postValue, response)` 以保持默认删除等功能

## 6. 表单按钮编码

在 OnSubmit 等后端事件中，通过 `actionName` 参数判断用户执行的按钮操作。

📖 [表单按钮编码说明](https://help.h3yun.com/contents/242/278.html#section1)

### 6.1 常用按钮编码

| 按钮名称 | ActionName 编码 | 说明 |
|---------|----------------|------|
| 暂存 | `Save` | 保存草稿 |
| 提交 | `Submit` | 提交表单 |
| 删除 | `Remove` | 删除数据 |
| 同意 | `Submit` | 流程审批同意（与提交共用） |
| 不同意 | `Reject` | 流程审批拒绝 |
| 撤回 | `RetrieveInstance` | 撤回流程实例 |
| 作废 | `CancelInstance` | 作废数据 |
| 编辑 | `Edit` | 编辑数据 |
| 关闭 | `Close` | 关闭表单 |
| 打印 | `Print` | 打印表单 |
| 转交 | `Forward` | 转交流程 |
| 已阅 | `Read` | 标记为已阅 |
| 二维码 | `ViewQrCode` | 查看二维码 |
| 全屏 | `FullScreen` | 全屏显示 |


### 6.2 使用示例

**后端 OnSubmit 事件判断操作类型：**
```csharp
public override void OnSubmit(string actionName, H3.SmartForm.PostValue postValue, H3.SmartForm.SubmitResponse response)
{
    if (actionName == "Submit")
    {
        // 提交或同意操作
    }
    else if (actionName == "Save")
    {
        // 暂存操作
    }
    else if (actionName == "Remove")
    {
        // 删除操作
    }
    
    base.OnSubmit(actionName, postValue, response);
}
```

**注意事项**：
- 后端 OnSubmit 事件中，"提交"和"同意"都使用 `Submit` 编码，需结合流程状态区分  
  📖 [表单后端常用状态判断组合](https://h3yunpro.github.io/docs/form-events/#%E8%A1%A8%E5%8D%95%E5%90%8E%E7%AB%AF%E5%B8%B8%E7%94%A8%E7%8A%B6%E6%80%81%E5%88%A4%E6%96%AD%E7%BB%84%E5%90%88)
- 在 base.OnSubmit 之前可以进行数据校验和处理
- 不同操作可能需要不同的权限控制

**前端 OnValidate 事件判断点击按钮：**
``` js
// 提交校验
OnValidate: function( actionControl ) {

    var that = this;
    if( actionControl.Action == "Submit") {
        // 提交或同意操作
    }

    if( actionControl.Action == "按钮编码") {
        // 点击了自定义的按钮，或者是按钮控件
        
        //这里写 return false，可阻止按钮的默认请求后端，此方式搭配Post请求后端
        return false;
    }

    return true;
},
```


## 7. 工作流

1. **识别意图**：判断用户是请求代码生成、API 查询、规范检查还是错误调试。
2. **检索信息**：从本技能内置规范或官方文档中查找对应 API 和示例。
3. **生成方案**：
   - 提供符合 ES5/.NET 4.6.2 规范的代码片段。
   - 标注关键注意事项（如批量操作、参数化 SQL）。
   - 若涉及复杂逻辑，建议封装工具方法。
4. **引导补充**：若上下文缺失（如缺少表单编码、控件编码），主动询问用户。

## 8. 边缘情况与异常

- **权限问题**：提醒用户检查当前用户的操作权限。
- **性能问题**：大数据量操作务必使用 `BulkCommit` 或分页查询。
- **版本差异**：若用户提及旧版氚云，需确认 API 兼容性。
