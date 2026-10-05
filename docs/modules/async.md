# Channels and background work

`async` is two things that happen to share a file: a `Channel` is a pair of
pipes between a parent and a child process, and `spawn` starts a child and
gives you its process id.

## Channels

```mire
load kioto

pub fn main: () {
    set ch = async::channel::create()
    set pid = async::spawn("/bin/cat")
    if pid > 0 {
        async::channel::send(&ch "through the pipe\n")
        set buf = strings::repeat("\0" 1024) :str mut
        set n = async::channel::recv(&ch buf 1024)
        dasu("child echoed: " + strings::substr(buf 0 n))
        async::wait(pid)
    } else {
        dasu("could not start the child")
    }
    async::channel::close(&ch)
}
```

The module resolves with the package name as the outermost segment:
`async::channel::create`, not `channel::create`. `async`'s own file is
`mod.mr` and contributes no namespace of its own, so the flattened spelling
does not resolve — unlike `fs::` or `strings::`, which come from named
subdirectories.

The buffer rule from the filesystem layer applies here without exception, and
it is the one thing in this module that can corrupt memory:

**`channel::recv` writes into a buffer you allocated, and does not grow it.**
`strings::repeat("\0" 1024)` is the idiom. An empty string as the destination
is a heap overflow — the callee writes the full message plus a terminator into
a zero-length allocation.

`channel::send` and `channel::recv` take `&Channel` precisely so the handle is
not consumed by the call, which is what lets a loop share one channel between
many messages. `channel::close` takes a reference too, and closes the pair
once; the `&` is required at the call site.

A `recv` returning `0` means there is nothing more to read. That is the loop
condition, not an error: a child that exits closes its end, and every
subsequent `recv` returns `0` rather than blocking forever.

## Tasks

`task::ready(value)` wraps an already-computed value, and `task::value` reads
it back, falling back to a default if the task is not ready. It is a small
convenience for code that has a "started/finished" shape to express without
threads, and it is honest about being a value rather than a computation.

## Processes

`spawn(cmd)` takes a **command string**, runs it through the process layer, and
returns a pid, or `0` if it could not start. `wait(pid)` collects the child.

This is the one place in the package where a string is interpreted as a
command line, and the difference from `proc::run::output` matters:

- `proc::run::output(cmd, args)` takes a program and a **vector** of arguments.
  Nothing is re-parsed, so an argument containing a space, a quote or a `;` is
  passed as one argument and cannot become a second command.
- `async::spawn(cmd)` takes a single string and splits it itself. It cannot
  express an argument containing whitespace, and it has no way to say "this
  whole string is one argument".

So `async::spawn` is fine for a command you wrote, and wrong for a command
line that came from anywhere else. Reach for `proc::run::output` with an
argument vector as soon as any part of the command is untrusted.

## What is not here

No promises, no futures, no executor, no thread pool. `async` is pipes and a
process id; if you need concurrency inside one process, Mire does not have it
yet, and the honest shape today is multiple processes and a channel between
them.

## See also

- [Processes](proc.md) — the module with the safer command interface
- [Ownership](../guides/ownership.md) — borrows and handles
- [`async` symbol reference](../symbols/async.md)
