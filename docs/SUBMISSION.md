# litetrace 提交说明

## 作业要求对照表

| 作业要求 | litetrace 支持方式 | 验证方式 |
|---------|------------------|---------|
| 支持打开 function 跟踪 | `./litetrace init` + `./litetrace on` | 启动后 `tracing_on=1` |
| 支持 function 过滤 | `./litetrace filter set <func>` | filter set 后写入 `set_ftrace_filter` |
| 支持动态开启和关闭跟踪 | `./litetrace on` / `./litetrace off` | 验证 `tracing_on` 数值变化 |
| 支持查看当前配置状态 | `./litetrace status` | 输出 current_tracer / tracing_on / filter |
| 支持导出跟踪结果 | `./litetrace dump` | 输出 `trace` 文件内容 |

## 快速验证步骤

```bash
# 1. 初始化项目
./litetrace init

# 2. 设置要跟踪的函数
./litetrace filter set vfs_write

# 3. 开启跟踪
./litetrace on

# 4. （这里执行你的测试操作）

# 5. 关闭跟踪
./litetrace off

# 6. 查看结果
./litetrace dump

# 7. 查看当前配置
./litetrace status
```

## 商品化 demo 输出（本地模拟验证）

```bash
$ ./demo.sh
== status 之前 ==
current_tracer: nop
tracing_on: 0
set_ftrace_filter: (empty)

== init ==
litetrace 已初始化：current_tracer=function, trace 已清空, tracing_on=0

== 设置 filter ==
filter 已设置：vfs_write

== 打开 tracing ==
tracing 已开启

== 当前状态 ==
current_tracer: function
tracing_on: 1
set_ftrace_filter: vfs_write

== dump ==
<demo>-123 [000] .... 1.234: vfs_write <-ksys_write
<demo>-123 [000] .... 1.235: vfs_write <-ksys_write

== 关闭 tracing ==
tracing 已关闭
```

## 项目文件说明

- `litetrace` - 核心 CLI 工具（Bash）
- `demo.sh` - 模拟演示脚本（无需 root / tracing 目录）
- `tests/test_litetrace.sh` - 功能测试脚本
- `README.md` - 完整使用说明
- `docs/` - 本目录为作业提交说明

## 本地测试方式

```bash
./demo.sh
# 或
./tests/test_litetrace.sh
```

## 依赖要求

- Bash shell（任何现代 Linux 发行版自带）
- `/sys/kernel/debug/tracing` 目录（Linux 内核 ftrace 支持）
- root 权限（写入 tracing 目录）

---

**备注**：本项目是课程作业实现，聚焦于作业要求的 MVP 功能，后续可扩展 `function_graph` / `events` / `trigger` 等高级特性。
