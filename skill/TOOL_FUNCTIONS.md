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
public static decimal gNum(object val, decimal defVal) { string s = val + string.Empty; s = string.IsNullOrWhiteSpace(s) ? "0" : s; decimal n = defVal; return decimal.TryParse(s, out n) ? n : defVal; }
public static double gNum(object val, double defVal) { string s = val + string.Empty; s = string.IsNullOrWhiteSpace(s) ? "0" : s; double n = defVal; return double.TryParse(s, out n) ? n : defVal; }
public static int gNum(object val, int defVal) { string s = val + string.Empty; s = string.IsNullOrWhiteSpace(s) ? "0" : s; int n = defVal; return int.TryParse(s, out n) ? n : defVal; }
public static bool tTime(object val, out DateTime time) { return DateTime.TryParse(val + string.Empty, out time); }
public static DateTime gTime(object val, DateTime defaultTime) { string s = val + string.Empty; if(string.IsNullOrWhiteSpace(s)) return defaultTime; DateTime t = defaultTime; return DateTime.TryParse(s, out t) ? t : defaultTime; }
public static string g200Str(string str) { return !string.IsNullOrWhiteSpace(str) && str.Length > 200 ? str.Substring(0, 200) : str; }
public static string g2000Str(string str) { return !string.IsNullOrWhiteSpace(str) && str.Length > 2000 ? str.Substring(0, 2000) : str; }
public static decimal gRound(decimal num, int digits) { return System.Math.Round(num, digits, System.MidpointRounding.AwayFromZero); }
```

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
- 工具方法内部使用的氚云类型或平台成员是否逐项完成签名与参数自检。
