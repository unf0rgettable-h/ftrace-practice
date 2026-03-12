# ftrace-practice

这是一个很朴素的课程作业项目：

我把 Linux 里和 `ftrace` 相关的几个常用文件，封装成了一个简单命令行工具 `litetrace`。

它不是完整版 `trace-cmd`，也不是很花哨的工程项目，目标很直接：**把作业要求做出来，并且让人一眼能看懂。**

---

## 这个小工具能做什么

`litetrace` 目前支持这些操作：

- 查看当前 tracing 状态
- 打开 tracing
- 关闭 tracing
- 清空旧的 trace 内容
- 设置函数过滤器
- 查看函数过滤器
- 清空函数过滤器
- 导出 trace 内容
- 初始化为作业里最常用的 `function` 模式

对应命令：

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

---

## 这个作业到底在操作什么

Linux 的 ftrace 常见工作目录一般是：

```bash
/sys/kernel/debug/tracing
```

这次作业主要用到了下面几个文件：

- `current_tracer`：当前使用的 tracer 类型
- `tracing_on`：当前 tracing 开关，`1` 表示开，`0` 表示关
- `set_ftrace_filter`：函数过滤器，只跟踪指定函数
- `trace`：跟踪结果输出

这个脚本本质上就是把平时手工写的：

```bash
echo function > current_tracer
echo 1 > tracing_on
cat trace
```

变成了比较好记的命令。

---

## 运行前提

### 1）系统环境
建议在 Linux 环境运行。

### 2）需要有 tracing 目录
一般要先确认这个目录存在：

```bash
ls /sys/kernel/debug/tracing
```

如果这个目录不存在，通常是下面几种情况：

- `debugfs` 没挂载
- 当前环境不支持
- 不是 Linux
- 权限不够

### 3）通常需要 root 权限
因为这个工具要往 `/sys/kernel/debug/tracing` 下面写文件，所以很多时候需要：

```bash
sudo ./litetrace status
```

或者：

```bash
sudo ./litetrace on
```

---

## 快速开始

### 第一步：给脚本执行权限

```bash
chmod +x litetrace
```

### 第二步：初始化

```bash
sudo ./litetrace init
```

这一步会做三件事：

- 把 `current_tracer` 设成 `function`
- 清空旧的 trace
- 把 `tracing_on` 设成 `0`

### 第三步：设置要跟踪的函数（可选）

```bash
sudo ./litetrace filter set vfs_write
```

### 第四步：开启 tracing

```bash
sudo ./litetrace on
```

### 第五步：执行你的目标操作
比如跑一下会触发该函数的程序。

### 第六步：关闭 tracing

```bash
sudo ./litetrace off
```

### 第七步：查看结果

```bash
sudo ./litetrace dump
```

---

## 命令说明

### `status`
查看当前状态。

```bash
./litetrace status
```

示例输出：

```text
current_tracer: function
tracing_on: 1
set_ftrace_filter: vfs_write
```

如果过滤器是空的，会显示：

```text
set_ftrace_filter: (empty)
```

### `init`
初始化成比较适合这次作业的状态。

```bash
./litetrace init
```

### `on`
打开 tracing。

```bash
./litetrace on
```

### `off`
关闭 tracing。

```bash
./litetrace off
```

### `clear`
清空 trace 文件里的旧内容。

```bash
./litetrace clear
```

### `dump`
打印 trace 内容。

```bash
./litetrace dump
```

### `filter set <function>`
设置函数过滤器。

```bash
./litetrace filter set vfs_write
```

### `filter show`
查看当前过滤器。

```bash
./litetrace filter show
```

### `filter clear`
清空当前过滤器。

```bash
./litetrace filter clear
```

---

## 一个最简单的使用流程

```bash
sudo ./litetrace init
sudo ./litetrace filter set vfs_write
sudo ./litetrace on
# 这里执行你的测试操作
sudo ./litetrace off
sudo ./litetrace dump
```

---

## 测试

这个项目带了一个简单的脚本测试，主要是针对“假 tracing 目录”做功能验证，不会真的改系统里的 ftrace。

运行方法：

```bash
chmod +x tests/test_litetrace.sh
./tests/test_litetrace.sh
```

如果测试通过，会看到：

```text
PASS: all tests passed
```

---

## demo

如果你只是想看看脚本怎么工作，但手头环境又没有真的 `/sys/kernel/debug/tracing`，可以跑：

```bash
chmod +x demo.sh
./demo.sh
```

它会用一个临时目录模拟 tracing 文件，方便看效果。

---

## 已知限制

这个项目是课程作业风格的小工具，所以有一些明显限制：

- 只做了 `function` tracer 这一条主线
- 没做 `function_graph`
- 没做 events / trigger / pid 过滤
- 没做复杂输出格式化
- 更偏向“把题目要求做出来”，不是完整生产工具

---

## 后面如果还想继续加

如果以后还要继续扩，可以考虑：

- 支持 `function_graph`
- 支持输出到文件
- 支持检查某个函数是否存在于 `available_filter_functions`
- 支持更完整的错误提示

---

## 一句话总结

`litetrace` 就是一个**把 ftrace 课程作业里几个常用 sysfs 操作包起来的小脚本**。能看状态，能开关 tracing，能设 filter，也能把 trace 打出来。
