# ftrace-practice

这个仓库是我为了 ftrace 相关课程作业写的一个小工具，名字叫 `litetrace`。

它本质上没什么玄乎的，就是把 `/sys/kernel/debug/tracing` 下面几个常用文件包了一层，省得每次都手敲一堆 `echo` 和 `cat`。

这不是正式版 `trace-cmd`，也不是一个大而全的 tracing 项目。它就是一个作业级的小脚本，目标很简单：

- 能按题目要求完成功能
- 命令别太难记
- README 让人能顺着跑下来

## 这个工具能干什么

现在支持这些命令：

```bash
./litetrace status
./litetrace init
./litetrace on
./litetrace off
./litetrace clear
./litetrace dump
./litetrace filter set vfs_write
./litetrace filter show
./litetrace filter clear
```

对应功能也很直接：

- 看当前状态
- 初始化到 `function` 模式
- 开 / 关 tracing
- 清空旧 trace
- 设置 / 查看 / 清空函数过滤器
- 把 trace 内容打印出来

## 这个作业实际上在操作什么

ftrace 常用目录一般在这里：

```bash
/sys/kernel/debug/tracing
```

这次主要碰到的文件有 4 个：

- `current_tracer`
- `tracing_on`
- `set_ftrace_filter`
- `trace`

平时手动操作大概长这样：

```bash
echo function > current_tracer
echo vfs_write > set_ftrace_filter
echo 1 > tracing_on
cat trace
```

我这个脚本干的事，就是把这些操作换成稍微正常一点的命令。

## 怎么跑

先给脚本执行权限：

```bash
chmod +x litetrace
```

如果你是在真实 Linux 环境里跑，一般要带 `sudo`，因为 tracing 目录通常需要 root 权限。

### 一套最基本的流程

```bash
sudo ./litetrace init
sudo ./litetrace filter set vfs_write
sudo ./litetrace on
# 这里执行你自己的测试操作
sudo ./litetrace off
sudo ./litetrace dump
```

上面这套流程差不多就是这次作业最核心的用法。

## 每个命令是干嘛的

### `./litetrace init`
把环境先整理好。

它会做三件事：

- 把 `current_tracer` 设成 `function`
- 清空旧的 `trace`
- 把 `tracing_on` 设成 `0`

### `./litetrace status`
看当前状态。

示例输出：

```text
current_tracer: function
tracing_on: 1
set_ftrace_filter: vfs_write
```

如果 filter 还没设置，会显示：

```text
set_ftrace_filter: (empty)
```

### `./litetrace on`
打开 tracing。

### `./litetrace off`
关闭 tracing。

### `./litetrace clear`
清空旧的 trace 内容。

### `./litetrace dump`
把 trace 打到终端上。

### `./litetrace filter set <function>`
设置函数过滤器。

比如：

```bash
sudo ./litetrace filter set vfs_write
```

### `./litetrace filter show`
查看当前 filter。

### `./litetrace filter clear`
清空当前 filter。

## 运行前先注意这几点

### 1. 最好在 Linux 上跑
这个脚本默认就是按 Linux 的 ftrace 路径写的。

### 2. tracing 目录得存在
先看一下：

```bash
ls /sys/kernel/debug/tracing
```

如果这里都没有，那后面的命令肯定跑不起来。

常见原因一般是：

- `debugfs` 没挂载
- 当前系统不支持
- 权限不够
- 不是 Linux 环境

### 3. 大多数情况下需要 root
因为要往 tracing 目录里写东西，所以很多命令都得 `sudo`。

## 如果你只是想看效果
这个仓库带了一个 `demo.sh`，不需要真实 tracing 环境也能跑。

```bash
chmod +x demo.sh
./demo.sh
```

它会用一个临时目录假装成 tracing 目录，所以比较适合演示命令流程。

## 测试

我写了一个很简单的测试脚本：

```bash
chmod +x tests/test_litetrace.sh
./tests/test_litetrace.sh
```

如果通过，会看到：

```text
PASS: all tests passed
```

这个测试不是去改你系统里的真实 ftrace，而是拿一个模拟目录来测逻辑，所以比较安全。

## 这份作业和题目要求怎么对应

题目里提到的几个点，这个项目都覆盖了：

| 作业要求 | 对应命令 |
|---------|---------|
| 打开 function 跟踪 | `./litetrace init` + `./litetrace on` |
| function 过滤 | `./litetrace filter set <func>` |
| 动态开关 tracing | `./litetrace on` / `./litetrace off` |
| 查看当前配置状态 | `./litetrace status` |
| 导出跟踪结果 | `./litetrace dump` |

更细一点的说明我放在：

- `docs/SUBMISSION.md`
- `docs/USAGE-EXAMPLE.md`

## 目前没做的东西

这项目就是按作业范围收着写的，所以有些东西我没继续往下做：

- 没做 `function_graph`
- 没做 event 跟踪
- 没做 trigger
- 没做 pid 过滤
- 没做更复杂的输出格式

说白了，这个版本够交作业，也够演示，但还谈不上完整。

## 项目结构

```text
litetrace                 # 主脚本
demo.sh                   # 模拟演示
tests/test_litetrace.sh   # 简单测试
docs/
├─ SUBMISSION.md          # 作业要求对照
└─ USAGE-EXAMPLE.md       # 使用示例
```

## 最后一句

如果只用一句话说这个仓库在干嘛，那就是：

**把 ftrace 作业里最常用的几个操作包成了一个小脚本，省得手敲 sysfs。**
