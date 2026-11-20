# 氚云常用工具方法库

来源：氚专开发者扩展文档《工具方法合集》：https://h3yunpro.github.io/docs/tool-function/

## 使用规则

- 本文件中的方法不是氚云内置方法，使用前必须将对应方法代码复制到当前氚云类代码块中。
- 生成代码前先判断是否已有工具方法可以直接复用；能复用时不得重复编写等价方法。
- 只复制本次实际需要的方法及其依赖，避免无关代码膨胀。
- 使用前必须确认当前代码位置、C# 版本、方法可见性、依赖命名空间和参数含义。
- 这些方法均来自外部工具合集，不得把它们当作平台 API；调用时仍需按“生成后自检”逐项核对参数。

## 后端字段与数值处理

适用位置：表单、列表、定时器、自定义接口。

```cs
public static string gStr(object val) { return val + string.Empty; }
public static bool gBool(object val) { string valStr = (val + string.Empty).ToLower(); return valStr == "true" || valStr == "1"; }
public static decimal gDecimalNum(object val) { return gNum(val, 0m); }
public static double gDoubleNum(object val) { return gNum(val, 0.0); }
public static int gIntNum(object val) { return gNum(val, 0); }
public static decimal gDecimalSum(object objArray, string field) { return gSum(objArray, field, 0m); }
public static double gDoubleSum(object objArray, string field) { return gSum(objArray, field, 0.0); }
public static int gIntSum(object objArray, string field) { return gSum(objArray, field, 0); }
// 数字转换：必须先按类型处理，字符串再允许指数形式，否则 double 科学计数法会被解析成 0。
public static decimal gNum(object val, decimal defVal)
{
    if(val == null) return 0m;
    if(val is decimal) return (decimal)val;
    if(val is double) return Convert.ToDecimal((double)val);
    if(val is float) return Convert.ToDecimal((float)val);
    string s = val + string.Empty;
    if(string.IsNullOrWhiteSpace(s)) return 0m;
    decimal n = defVal;
    return decimal.TryParse(s, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out n) ? n : defVal;
}
public static double gNum(object val, double defVal)
{
    if(val == null) return 0.0;
    if(val is double) return (double)val;
    if(val is float) return (float)val;
    if(val is decimal) return (double)(decimal)val;
    string s = val + string.Empty;
    if(string.IsNullOrWhiteSpace(s)) return 0.0;
    double n = defVal;
    return double.TryParse(s, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out n) ? n : defVal;
}
public static int gNum(object val, int defVal)
{
    if(val == null) return 0;
    if(val is int) return (int)val;
    string s = val + string.Empty;
    if(string.IsNullOrWhiteSpace(s)) return 0;
    int n = defVal;
    if(int.TryParse(s, out n)) return n;
    decimal d = 0m;
    return decimal.TryParse(s, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out d) ? (int)d : defVal;
}
public static bool tTime(object val, out DateTime time) { return DateTime.TryParse(val + string.Empty, out time); }
public static DateTime gTime(object val, DateTime defaultTime) { string s = val + string.Empty; if(string.IsNullOrWhiteSpace(s)) return defaultTime; DateTime t = defaultTime; return DateTime.TryParse(s, out t) ? t : defaultTime; }
public static string g200Str(string str) { return !string.IsNullOrWhiteSpace(str) && str.Length > 200 ? str.Substring(0, 200) : str; }
public static string g2000Str(string str) { return !string.IsNullOrWhiteSpace(str) && str.Length > 2000 ? str.Substring(0, 2000) : str; }
public static decimal gRound(decimal num, int digits) { return System.Math.Round(num, digits, System.MidpointRounding.AwayFromZero); }
```

### 数字转换必须兼容科学计数法

氚云数字控件在文档中标注为 `decimal`，但实际运行时表单结构的内部数据类型是 `Double`，取值可能以 `double`/`float` 形式返回。这类值转字符串时，小于 `0.0001` 的数会输出科学计数法，例如 `0.00007 -> "7E-05"`、`0.00003 -> "3E-05"`。而 `decimal.TryParse(s, out n)` 默认使用 `NumberStyles.Number`，不支持指数形式，会解析失败并返回默认值 `0`：数据库里导入的是 `0.00007`，生成 BOM 后用量变成 `0`；若后续还有 `if(用量 <= 0) continue;`，该物料会直接从物料需求明细中消失（真实案例：多级 BOM 导入生成 BOM 时，`0.00007` 的导电炭黑和 `0.00003` 的 CMC 变成 `0`，研发立项物料需求明细中对应物料缺行）。

因此：

- `gNum`、`gDecimalNum`、`gDoubleNum`、`gIntNum`，以及项目内自定义的 `GetDecimal`/`ToDecimal` 等所有通用数字转换方法，都必须先按类型处理（`decimal` 直接返回，`double`/`float` 用 `Convert.ToDecimal` 等直接转换），仅对字符串使用 `decimal.TryParse(s, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out n)`。
- 禁止写成 `decimal.TryParse(s, out n)` 并把解析失败的结果留成默认值 `0`；也不得只依赖 `gStr` 转字符串后再集中解析。
- 涉及用量、金额、系数等可能为极小值的字段时，转换后必须验证非零值未被吞掉。

### 子表汇总依赖

`gDecimalSum`、`gDoubleSum`、`gIntSum` 依赖以下重载。`objArray` 必须是 `H3.DataModel.BizObject[]`，`field` 必须是子表内控件编码。

```cs
public static decimal gSum(object objArray, string field, decimal defVal) {
    if(objArray == null || string.IsNullOrWhiteSpace(field)) return defVal;
    H3.DataModel.BizObject[] list = (H3.DataModel.BizObject[])objArray;
    if(list == null || list.Length == 0) return defVal;
    decimal sum = defVal;
    foreach(H3.DataModel.BizObject bo in list) sum += gNum(bo[field], defVal);
    return sum;
}
public static double gSum(object objArray, string field, double defVal) { return Convert.ToDouble(gSum(objArray, field, 0m)); }
public static int gSum(object objArray, string field, int defVal) { return Convert.ToInt32(gSum(objArray, field, 0m)); }
```

## 后端计算公式

仅在需要触发已有控件计算公式时复用。主表传主表业务对象，子表传当前子表业务对象；子表控件参数只能传子表内控件编码，不能传“子表编码.控件编码”。

```cs
public static void CalcPropertyComputationRule(H3.DataModel.BizObject bo, string propertyCode)
{
    if(bo == null || !bo.Schema.PropertyExist(propertyCode)) return;
    H3.DataModel.PropertySchema schema = bo.Schema.GetProperty(propertyCode);
    if(string.IsNullOrWhiteSpace(schema.ComputationRule)) return;
    string rule = schema.ComputationRule.Replace(bo.Schema.SchemaCode + ".", "");
    bo[propertyCode] = bo.CalcExpression(rule);
}
```

## 前端值与日期处理

以下代码为 ES5，可放在表单默认代码之前；日期控件赋值只能使用 `yyyy-MM-dd` 或 `yyyy-MM-dd HH:mm:ss` 格式。

```js
function convertToNumber(v) {
    if(typeof v === "string" && v.length) { try { return parseFloat(v); } catch(e) { return 0; } }
    if(typeof v === "number") return v;
    return 0;
}
function convertToString(v) {
    if(typeof v === "string") return v;
    if(typeof v === "number") return v + "";
    return "";
}
function MyDateFormat(d, fmt) {
    var o = { "M+": d.getMonth() + 1, "d+": d.getDate(), "H+": d.getHours(), "m+": d.getMinutes(), "s+": d.getSeconds(), "q+": Math.floor((d.getMonth() + 3) / 3), "S": d.getMilliseconds() };
    if(/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (d.getFullYear() + "").substr(4 - RegExp.$1.length));
    for(var k in o) if(new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
    return fmt;
}
```

## 复用检查清单

- 是否存在可直接复用的工具方法及其依赖。
- 是否只复制必要方法，避免重复定义同名方法。
- 每个方法的参数、返回值、适用位置和平台上下文是否已确认。
- 数字转换方法是否已按类型处理并使用 `NumberStyles.Float`，确保 `double` 科学计数法（如 `7E-05`）不会被解析成 `0`。
- 工具方法内部使用的氚云类型或平台成员是否逐项完成签名与参数自检。
