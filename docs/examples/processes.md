# Processes

Running other programs, capturing their output, and checking whether they
succeeded.

## Capturing output

`proc::run::output` takes a program and a **vector of arguments**, waits, and
returns what the child printed on stdout.

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set out = proc::run::output("/bin/echo" ["hello from a child"])
    dasu(strings::trim(out))
}
```

No shell is involved. The argument `"hello from a child"` contains spaces and
arrives as **one argument**, because nothing re-parsed the string.

That is the property to keep: an argument containing `;`, `$(...)` or a quote
cannot become a second command, because there is nothing that would interpret
it. There is no shell function in the package to reach for by mistake.

## Telling success from empty output

`output` returns `""` both when the command failed and when it succeeded and
printed nothing. `proc::run::last_exit` separates them.

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set out = proc::run::output("/bin/ls" ["/nonexistent"])
    set code = proc::run::last_exit()
    if code != 0 {
        dasu("ls failed, exit " + strings::from::i64(code))
    } elif out == "" {
        dasu("ls succeeded and printed nothing")
    } else {
        dasu(strings::trim(out))
    }
}
```

Read `last_exit` **immediately** after the call — it reports the most recent
child, so another `proc` call in between replaces it.

## stderr, and a working directory

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set out = proc::run::output_cwd("/usr/bin/mire" ["build" "code/main.mir"] "/srv/app" true)
    if proc::run::last_exit() == 0 {
        dasu("build ok")
    } else {
        dasu(strings::trim(out))
    }
}
```

`output_cwd(cmd, args, cwd, merge_err)` runs the child in `cwd` and, with
`merge_err` true, folds stderr into the captured text — so a build's errors
come back in the same string as its output. With it false, stderr passes
through to your own stderr and only stdout is captured.

## Exit status without the output

`proc::run::spawn` runs the child to completion and returns its **exit
status** — the output is not captured and does not come back.

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set code = proc::run::spawn("/usr/bin/sleep" ["1"])
    if code == 0 {
        dasu("slept, then exited cleanly")
    } else {
        dasu("exited with " + strings::from::i64(code))
    }
}
```

The name is misleading: it is not the counterpart of a shell's `&`, and it does
**not** return a pid. A child you do not wait on comes from `async::spawn`,
and `proc::wait` will not collect it — `proc::wait` takes a `Process`, as
`run::create` returns.

## Talking to a child

`proc::run::create` gives a `Process` with pipes. Its three channel arguments
are stdin, stdout and stderr, and **`0` means "no pipe"** — the child inherits
your own descriptors.

```mire
load kioto::proc
load kioto::strings
load mire::vec

pub fn main: () {
    set p = proc::run::create("/usr/bin/true" [] :vec[str] (1 :i32) 0 0 0)
    set status = proc::wait(p)
    dasu("true exited with " + strings::from::i64(status))
}
```

Three things about that line:

- The flags word is `i32`, so the literal is `(1 :i32)`. `1` is
  `PAL_SPAWN_WAIT`; the module constant is not readable from a consumer, so
  the literal is what you write.
- An empty argument vector is `[] :vec[str]`. A bare `[]` has no element type
  to infer.
- **`create` only accepts an empty argument vector.** `["1"]` inline is
  rejected as `call expects function callback, got Vector`, and a named
  `vec[str]` is rejected as `Unknown function '<name>'` — the second argument
  is misparsed as a call. Use `run::output` or `run::spawn` when the child
  needs arguments.

## A handle is consumed once

`wait`, `kill` and `close` each take the `Process` by value, so exactly one of
the three is possible. `kill` then `wait` does not work: `kill` already took
the handle.

```mire
set p = proc::run::create("/usr/bin/true" [] :vec[str] (1 :i32) 0 0 0)
set status = proc::wait(p)   // p is gone
proc::close(p)               // ownership error
```

## Reading from a child

`async::channel` is the pipe interface. The buffer rule is the same one as
everywhere else: allocate it, size it, and pass the same length.

```mire
load kioto
load kioto::strings

pub fn main: () {
    set ch = async::channel::create()
    set pid = async::spawn("/bin/cat")
    if pid > 0 {
        async::channel::send(&ch "through the pipe\n")
        set buf = strings::repeat("\0" 1024) :str mut
        set n = async::channel::recv(&ch buf 1024)
        dasu("echoed: " + strings::substr(buf 0 n))
        async::wait(pid)
    }
    async::channel::close(&ch)
}
```

`channel::send` and `recv` take `&Channel`, so the handle survives and a loop
can share it. A `recv` returning `0` means there is nothing more to read —
that is the loop condition, not an error.

**`async::spawn` takes a single command string** and splits it itself, so it
cannot express an argument containing whitespace and has no way to say "this
whole string is one argument". For a command built from anything but a literal,
use `proc::run::output` with a vector.

## See also

- [Processes](../modules/proc.md) — the full API
- [Security](../guides/security.md) — why the vector form matters
- [Errors](../guides/errors.md) — exit codes and empty output
