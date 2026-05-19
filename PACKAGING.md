# 打包说明 / Packaging Instructions

## 📦 打包方式

### 方式一:自动打包(推荐)
每次执行 `git commit` 后,会自动触发 post-commit hook,生成最新的 zip 包。

**优点**: 
- ✅ 无需手动操作
- ✅ 保证打包的是最新提交的版本
- ✅ 自动化流程

### 方式二:手动打包
如果需要手动打包,运行以下命令:

```cmd
package-skill.cmd
```

或者直接双击运行 `package-skill.cmd` 文件。

**适用场景**:
- 在 commit 之前需要预览打包结果
- 测试打包功能是否正常
- 需要多次打包而不提交

## 📂 生成的文件

打包完成后,会在项目根目录生成:
- `h3yun-dev-assistant.zip` - 包含 SKILL.md 和 README.md 的压缩包

## 📥 同事使用方式

1. 从 Git 仓库下载最新的 `h3yun-dev-assistant.zip`
2. 解压到本地文件夹
3. 在 AI 工具中导入该文件夹作为 Skill

## ⚙️ 自定义配置

如果需要打包更多文件,可以修改:

### package-skill.cmd (Windows)
在第 24-25 行之后添加:
```cmd
copy 你的文件 dist\你的文件 >nul
```

### .git/hooks/post-commit (Git Hook)
在第 26-27 行之后添加:
```bash
cp 你的文件 dist/你的文件
```

## 🔧 禁用自动打包

如果不想在每次 commit 时自动打包,可以:

1. 删除或重命名 `.git/hooks/post-commit` 文件
2. 或者在文件中第一行添加 `exit 0` 来禁用

```bash
#!/bin/bash
exit 0  # 禁用自动打包
```

## ❓ 常见问题

**Q: 为什么 commit 后没有生成 zip 文件?**
A: 检查 `.git/hooks/post-commit` 文件是否存在且有执行权限

**Q: 打包的文件不完整?**
A: 检查项目中是否有所有需要打包的文件(SKILL.md, README.md 等)

**Q: 如何查看 zip 文件内容?**
A: 直接双击打开,或使用解压软件查看
