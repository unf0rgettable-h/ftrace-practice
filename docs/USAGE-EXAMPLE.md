# litetrace 使用示例

## 典型使用流程

### 1. 初始化（只需执行一次）

```bash
sudo ./litetrace init
# 输出示例：
# litetrace 已初始化：current_tracer=function, trace 已清空, tracing_on=0
```

### 2. 设置要跟踪的函数（可选）

```bash
sudo ./litetrace filter set vfs_write
# 输出示例：
# filter 已设置：vfs_write
```

### 3. 开启跟踪

```bash
sudo ./litetrace on
# 输出示例：
# tracing 已开启
```

### 4. 执行你的测试操作

比如：

```bash
# 在另一个终端执行
echo "hello" > /tmp/test.txt
# 这个操作会触发 vfs_write
```

### 5. 关闭跟踪

```bash
sudo ./litetrace off
# 输出示例：
# tracing 已关闭
```

### 6. 查看跟踪结果

```bash
sudo ./litetrace dump
# 输出示例：
# <demo>-123 [000] .... 1.234: vfs_write <-ksys_write
# <demo>-123 [000] .... 1.235: vfs_write <-ksys_write
```

### 7. 查看当前配置

```bash
sudo ./litetrace status
# 输出示例：
# current_tracer: function
# tracing_on: 0
# set_ftrace_filter: vfs_write
```

## 所有命令一览

| 命令 | 说明 |
|------|------|
| `./litetrace status` | 查看当前 tracing 配置 |
| `./litetrace init` | 初始化：设为 function 模式，清空 trace，关闭 tracing |
| `./litetrace on` | 开启 tracing |
| `./litetrace off` | 关闭 tracing |
| `./litetrace clear` | 清空旧的 trace 内容 |
| `./litetrace dump` | 打印 trace 内容到终端 |
| `./litetrace filter set <func>` | 设置函数过滤器 |
| `./litetrace filter show` | 查看当前过滤器 |
| `./litetrace filter clear` | 清空过滤器 |

## 环境要求

- Linux 系统（推荐 Ubuntu 20.04+ 或 CentOS 7+）
- `/sys/kernel/debug/tracing` 目录存在
- root 权限（或加入 `fuse` 组等足够权限）

## 常见报错

### `tracing 目录不存在`

```bash
ls /sys/kernel/debug/tracing
# 如果报错，说明 debugfs 未挂载

# 临时挂载：
sudo mount -t debugfs debugfs /sys/kernel/debug
```

### `缺少文件：xxx`

说明 `/sys/kernel/debug/tracing/xxx` 这个文件不存在，通常是：

- 当前内核配置没启用 ftrace
- 或者路径被改了（比如某些发行版挂载到别的地方）

### `Permission denied`

```bash
sudo ./litetrace <cmd>
# 或
sudo chmod -R 755 /sys/kernel/debug/tracing
```

## 本地模拟演示（无需真实 tracing）

如果只是想看看效果，但手头又没有真正的 `tracing` 目录：

```bash
./demo.sh
```

它会用一个临时模拟目录，行为和真实 ftrace 几乎一样。
