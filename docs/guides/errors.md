# Errors

Mire has no exceptions and no error type. A function that can fail returns
something — a `bool`, an empty string, a negative handle, or an integer code —
and deciding what that means is the caller's job. This page is about reading
those signals correctly, because several of them are quiet.

## The five shapes of failure

| Shape | Example | How to notice |
| --- | --- | --- |
| `bool` | `fs::remove(path)` | `false` |
| negative handle | `fs::file::open::read` | `handle < 0` |
| empty string | `env::var(name)`, `proc::run::output` | `== ""` |
| integer code | `fs::last_error()`, `proc::run::last_exit` | non-zero |
| compile error | type and ownership mistakes | the build fails |

The first three are **unreliable on their own**, and that is the substance of
this page.

## `false` from a capability call is not the whole story

```mire
if !fs::exists(path) {
    dasu("cannot read " + path)
    return
}
```

This is right, and it is also the only thing `exists` can tell you. A `false`
means "not there, or not permitted, or not a file" — the three are
indistinguishable. For anything that reads, the reason is usually worth having.

## `last_error` is the exception to the rule

`fs::last_error()` returns the code from the most recent failing **capability**
call, and it is the one place where "why" survives:

```mire
load kioto::fs
load kioto::strings

pub fn main: () {
    if !fs::exists("/etc/shadow") {
        set code = fs::last_error()
        if code != 0 {
            dasu("not readable: error code " + strings::from::i64(code))
        } else {
            dasu("not present")
        }
    }
}
```

The limitation to know: it describes the **last** failure, so it must be read
immediately after the call that failed. Any other capability call in between
overwrites it. And it is not set by the whole-file helpers — `fs::mkdir`
returning `false` leaves `last_error` at `0`, so a `false` from `mkdir` has no
explanation available at all.

## An empty string is two different things

`proc::run::output` returns `""` both when the command failed and when it
succeeded and printed nothing. Those are opposite situations with the same
return value, and `proc::run::last_exit` is what separates them:

```mire
load kioto::proc
load kioto::strings

pub fn main: () {
    set out = proc::run::output("/bin/ls" ["/nonexistent"])
    set code = proc::run::last_exit()
    if out == "" && code != 0 {
        dasu("ls failed with " + strings::from::i64(code))
    } elif out == "" {
        dasu("no output")
    } else {
        dasu(out)
    }
}
```

Check `last_exit` **before** running anything else, for the same
overwrite-by-the-next-call reason.

`env::var` has no such companion: a variable that is unset and a variable set
to `""` are the same value, and there is no way to ask which.

## Compile errors are the good case

The checker catches most of what matters, and when it does the program does not
run at all:

- **Type errors** — `Function 'x' argument 2 expects I32, got I64`
- **Ownership errors** — `Use after move`, `Multiple mutable references`
- **Name resolution** — `Unknown function 'x'`, with a span

A real error carries a file, a line, a column and a caret:

```
error[E0005] ── Type Error
╭─[ /srv/app/main.mir:4:50 ]
│ 4 │   set p = proc::run::create("/bin/true" [] :vec[str] (1 :i32) 0 0 0)
│   │                                                  ^^^ here
╰─ Function 'proc.run.create' argument 3 expects I32, got I64
```

When an error message names a **different** thing than you expected, trust the
span over the prose. The compiler's message can be misleading about *which*
argument is at fault — see the `u16` case in
[Known limitations](../inventory.md#known-limitations), where the message
blames the host string instead of the port.

## Things that fail at runtime, not at compile time

- **Index out of bounds.** A panic with a location. Not a compile error.
- **Division by zero.** Same.
- **A too-small `&mut str` buffer.** A heap overflow, not a caught error. This
  is the one that can corrupt memory rather than stopping cleanly — see
  [Ownership](ownership.md#mut-is-an-out-parameter).
- **`fs::read` on a binary file.** No error at all: it truncates at the first
  NUL and returns a shorter string.

## Reporting

`log::warn` and `log::error` write to standard error, which keeps diagnostics
out of a program's real output. A failure the user must see belongs there; a
failure the caller can handle belongs in a return value.

## See also

- [Ownership](ownership.md) — errors the compiler does catch
- [Logging](../modules/log.md) — where a message goes
- [Known limitations](../inventory.md#known-limitations) — the misleading messages
