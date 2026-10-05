# Process — symbol reference

Running other programs. There is no shell in this module and no way to get one by accident, which is the entire reason it exists.

## `proc`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `proc::run` | `run()` | The four ways to start a program, and the three questions you ask about one that just ran. The grouping is the point: creating a process and asking what happened to it are different acts, and the answers belong together. |
| `proc::wait` | `wait(p :Process) :i64` | Blocks until the child exits and returns its status. Calling it on a child that was already waited on returns -1 rather than hanging. |
| `proc::kill` | `kill(p :Process) :bool` | Sends a termination signal to the child. True when the signal was delivered, false when the child was already gone or is not ours to signal. |
| `proc::close` | `close(p :Process)` | Releases the handle. Nothing about the child changes; this only gives the descriptor back. Skipping it leaks one descriptor per spawn. |
| `proc::stream` | `stream()` | The three standard streams of a child, as raw channel handles. They are channels rather than strings so the caller decides whether to read them synchronously or hand them to another thread; see async::channel. |

## `proc::run`

### `proc::run::create`

```mire
create(cmd :&str, args :vec[str], flags :i32, stdin_ch :i64, stdout_ch :i64, stderr_ch :i64) :Process
```

The low-level form: raw flags plus three channel handles, one per stream. Pass 0 for a stream to leave it inherited, which is what makes a child's output land on this process's own stdout. A returned handle of 0 or less means the fork failed and there is nothing to close.

### `proc::run::spawn`

```mire
spawn(cmd :&str, args :vec[str]) :i64
```

Runs a command to completion and returns its exit status. Nothing is captured: the child writes to this process's stdout and stderr, so the output shows up in the terminal rather than in a string. Returns -1 when the child could not be forked at all, 127 when exec failed, and otherwise the status of the child.

### `proc::run::output`

```mire
output(cmd :&str, args :vec[str]) :str
```

Captures stdout as an owned string and waits for the child. On every failure path — a bad argument, a failed pipe, a failed fork — the result is the empty string, and so is a command that simply printed nothing. Check proc::run::last_exit() to tell those apart. Read end of the child's stdout, for use with async::channel::recv.

### `proc::run::output_cwd`

```mire
output_cwd(cmd :&str, args :vec[str], cwd :&str, merge_err :bool) :str
```

Captures stdout from a command started in a specific directory. cwd is applied with chdir before exec, and a cwd that cannot be entered makes the child exit 126. merge_err folds stderr into the same pipe, which is the shape to reach for when the only evidence of failure is on stderr. output with the working directory set, and the option to fold the child's stderr into the same capture. A bad working directory exits 126.

### `proc::run::last_exit`

```mire
last_exit() :i64
```

The exit status of the last captured process, thread-local. This is the only reliable success check: output can be empty for a command that succeeded perfectly.

### `proc::run::read_line`

```mire
read_line() :str
```

One line read from the terminal, bypassing the captured-output path so it works while a prompt is waiting. Returns "y" when there is no terminal, which makes an unattended run take the default branch.

## `proc::stream`

### `proc::stream::input`

```mire
input(p :Process) :i64
```

Write end of the child's stdin, as a raw channel handle. Only meaningful when run::create was given a non-zero handle for that stream.

### `proc::stream::output`

```mire
output(p :Process) :i64
```

The three standard streams of a child, as raw channel handles. They are channels rather than strings so the caller decides whether to read them synchronously or hand them to another thread; see async::channel.

### `proc::stream::error`

```mire
error(p :Process) :i64
```

Read end of the child's stderr, for use with async::channel::recv.
