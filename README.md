# file.lazycmd

本地文件浏览插件。

## 功能

- 进入 `/file` 后直接从文件系统根目录 `/` 开始浏览
- 列表区域目录显示为蓝色，文件显示为白色
- 目录项通过 entry metatable 提供局部 `keymap`，支持用右键/回车进入
- 文件项不会继续被当作目录进入，右键/回车只会刷新预览
- 预览区域：
  - 目录：展示子文件列表
  - 常见代码文件：使用 `lc.style.highlight` 语法高亮
  - 其他文本文件：纯文本展示

## 配置

在 `~/.config/lazycmd/init.lua` 中加入：

```lua
{
  dir = 'plugins/file.lazycmd',
  config = function()
    require('file').setup()
  end,
},
```

可选配置：

```lua
require('file').setup {
  preview_max_chars = 60000,
  keymap = {
    open = '<right>',
    enter = '<enter>',
  },
}
```

## 结构

- `file/init.lua`: 列表构建、路径处理、插件入口
- `file/config.lua`: 配置读取与默认键位
- `file/metas.lua`: 通过 metatable 注入 entry 级 `keymap` 和 `preview`
- `file/preview.lua`: 目录/文件预览渲染
