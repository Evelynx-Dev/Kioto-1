# Processes

Running another program is the thing programs do most, and it is the easiest
thing to do dangerously. This module is built around one decision: **there is
no shell, and there is no way to get one by accident.**

Every entry point takes a program and an argument vector. Nothing is parsed,
nothing is word-split, nothing is interpreted. `sh -c` is not reachable from
here, so a filename that happens to contain a space, a semicolon or a `$` is
just a filename.

```mire
load kioto::proc

pub fn main: () {
    set out = proc::run::output("/usr/bin/git" ["--version"])
    if proc::run::last_exit() == 0 {
        dasu("git says: " + out)
    } else {
        dasu("git is not usable here")
    }
}
```

## The three ways to run something

| Call | Blocks | Returns | Use when |
| --- | --- | --- | --- |
| `run::output` | yes | captured stdout | you want the text and nothing else |
| `run::spawn` | yes | exit status | you want to know whether it worked |
| `run::create` | no | a `Process` | you need pipes, or must not block |

`spawn` and `output` are both synchronous: they return after the child exits.
Neither gives you a handle. If you need one, you want `create`.

## Capturing output

`output` returns the child's standard output as a string, and standard error is
discarded. The string is owned by the caller.

The important caveat is that **`""` is ambiguous**. A command that printed
nothing, a command that failed before printing, and a command that could not be
started at all all return the same empty string. `last_exit` is what tells them
apart:

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set out = proc::run::output("/usr/bin/git" ["rev-parse" "HEAD"])
    set status = proc::run::last_exit()
    if status == 0 {
        dasu(out)
    } elif status == 127 {
        dasu("git is not installed")
    } else {
        dasu("git failed with status " + strings::from::i64(status))
    }
}
```

The statuses worth special-casing:

| Status | Meaning |
| --- | --- |
| `0` | Success. The only status that means the command did what you asked. |
| `126` | Found, but could not be executed — not a program, or not executable. |
| `127` | Not found on the `PATH`, or the name was not a single executable. |
| other | The command's own exit code. Its meaning is the command's business. |

`last_exit` is thread-local and reflects the most recent captured process. It
is also reset to `-1` when a capture never got as far as running anything, so
`status >= 0` is a cheap sanity check before you compare it against `0`.

## Working directory and stderr

`output_cwd` adds two things: where the child starts, and whether its standard
error joins the capture.

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    // Runs in the project directory, with errors folded into the same capture
    set out = proc::run::output_cwd("/usr/bin/mire" ["build"] "/srv/app" true)
    if proc::run::last_exit() == 0 {
        dasu("build ok")
    } else {
        dasu(out)
    }
}
```

A working directory that does not exist is not an error the call reports; the
child exits `126` instead, which is what you will see in `last_exit`. With
`merge_err` set to `false` the child's diagnostics disappear entirely, so
prefer `true` when you are going to print the output on failure.

## Asynchronous execution

`create` is the one that does not block. It takes the program, the argument
vector, a flags word, and three channel handles.

```mire
load kioto::proc
load kioto::strings
load mire::vec

pub fn main: () {
    // 1 is PAL_SPAWN_WAIT; the module constant is not readable from here, so
    // the literal carries the meaning. The three zeros are null channels.
    set p = proc::run::create("/usr/bin/true" [] :vec[str] (1 :i32) 0 0 0)
    set status = proc::wait(p)
    dasu("true exited with " + strings::from::i64(status))
}
```

> **Limitation.** `create` currently only accepts an **empty** argument
> vector, `[] :vec[str]`. Passing a literal such as `["1"]`, or a variable
> holding one, is rejected: the compiler reports `call expects function
> callback, got Vector` for the literal, and `Unknown function 'a'` for a named
> variable. `run::output` and `run::output_cwd` do accept both forms. Until
> this is fixed, use `run::spawn` or `run::output` when the child needs
> arguments, and `create` only when it does not.

The three channel arguments are `stdin`, `stdout` and `stderr`. **Pass `0` for
each one you do not want to wire up** — zero is the null channel, and the child
inherits the parent's own file descriptors. That is what makes a child's
output appear on your terminal, and it is also the easy mistake: a handle that
is not `0` has to be a real channel, and one that is invalid makes the call
fail.

The flags word is `i32`, not `i64`, so the literal needs its type:
`(1 :i32)`. `PAL_SPAWN_WAIT` is the only flag defined, and it means the child
is waited for by `proc::wait` rather than left as a zombie. The constant is
declared in the module but is not readable from outside it, which is why the
literal appears here.

An empty argument vector is `[] :vec[str]` — an untyped `[]` is rejected,
because the compiler has nothing to infer the element type from.

## The handle is consumed exactly once

`wait`, `kill` and `close` each take the `Process` by value, which means each
one **consumes** it. Calling a second one is a use-after-move error at compile
time, not a crash:

```mire
set p = proc::run::create("/usr/bin/true" [] :vec[str] (1 :i32) 0 0 0)
set status = proc::wait(p)   // p is gone from here
proc::close(p)               // ownership error
```

So the shape is: `wait` if you want the status, `kill` if you want it to stop,
`close` if you are abandoning it. `kill` does not reap, and you cannot
`wait` afterwards, because `kill` already took the handle — a process you have
signalled is released rather than collected.

## Reading a line interactively

`read_line` reads one line from the terminal, bypassing the capture path so it
works while a prompt is waiting:

```mire
load kioto::proc

pub fn main: () {
    dasu("continue? [Y/n] ")
    set answer = proc::run::read_line()
    if answer == "n" { dasu("stopping") } else { dasu("continuing") }
}
```

When there is no terminal — a pipe, a test, CI — it returns `"y"`, so the
default branch is taken. An unattended run never blocks on this call, which is
the point: a prompt that cannot be answered should proceed, not hang.

## Signalling

`wait` returns the exit status and reaps the child; the handle is consumed and
there is nothing left to call.

`kill` sends `SIGKILL` to the child and reports whether the signal was
delivered. It consumes the handle too, so it replaces `wait` rather than
preceding it.

## The rule

If you find yourself wanting to build a command line as one string and pass it
to something, the answer is an argument vector:

```mire
// Wrong, and impossible: there is no function that takes this.
set cmd = "grep -rn 'TODO' src/"

// Right.
set hits = proc::run::output("/usr/bin/grep" ["-rn" "TODO" "src/"])
```

The second form cannot be confused by a filename with a space in it, cannot be
broken by a quote in the data, and cannot be redirected by a semicolon. There
is no third option to get wrong, because [the inventory](../inventory.md#no-shell)
records that no shell surface exists.

## See also

- [`async`](async.md) — pipes between processes and channels
- [Running programs](../examples/processes.md) — worked examples
- [Errors](../guides/errors.md) — what a failure does and does not tell you
- [`proc` symbol reference](../symbols/proc.md)
