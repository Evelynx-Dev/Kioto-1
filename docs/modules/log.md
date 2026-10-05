# Logging

Three functions that write a line to standard error. The entire module.

```mire
load kioto::log

pub fn main: () {
    log::info("starting")
    log::warn("cache is stale, rebuilding")
    log::error("could not open the lockfile")
}
```

| Call | Level |
| --- | --- |
| `info(msg)` | Informational |
| `warn(msg)` | Something is wrong but the work continues |
| `error(msg)` | Something failed |

The message is borrowed, so a computed string can be passed directly:

```mire
load kioto::log
load kioto::strings
load kioto::fs

pub fn main: () {
    if fs::exists("/srv/app/owl.lock") {
        log::info("lockfile present")
    } else {
        log::warn("no lockfile at /srv/app/owl.lock; " + strings::from::i64(fs::last_error()))
    }
}
```

## Two things to know

**Output goes to standard error, not standard output.** That is deliberate —
it keeps diagnostics out of a program's actual output, so a pipeline reading
stdout is not corrupted by a warning. It also means `2>&1` is how you see log
lines interleaved with output, and it means a program that only reads stdout
shows no sign of the warnings it emitted.

**The level is a label, not a filter.** There is no threshold, no verbosity
setting and no way to silence `debug`-level noise, because there are only
three functions and none of them are suppressed. If you need a level
controlling what appears, gate the call yourself:

```mire
load kioto::env
load kioto::log

pub fn main: () {
    set quiet = env::var("QUIET") != ""
    if !quiet {
        log::info("verbose diagnostics enabled")
    }
}
```

There is no structure, no field, no timestamp and no destination other than
standard error. A structured logger is a thing kioto does not provide.

## See also

- [`log` symbol reference](../symbols/log.md)
- [Errors](../guides/errors.md) — reporting failures to a user rather than a log
