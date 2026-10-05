# Environment

Reading the process environment and the command line. Three functions, one of
which is a trap.

```mire
load kioto::env
load kioto::strings

pub fn main: () {
    set home = env::var("HOME")
    if home == "" {
        dasu("HOME is not set")
    } else {
        dasu(strings::concat("home: " home))
    }
    dasu(strings::concat("cwd: " env::cwd()))
}
```

`var` and `cwd` return `:&str`, and `+` does not mix a `str` with a `&str`.
`strings::concat` takes both, which is why it is the spelling used throughout
these examples.

| Call | Returns |
| --- | --- |
| `var(name)` | The variable's value, or `""` if unset |
| `cwd()` | The working directory |
| `args(argc, argv)` | The command line as a `vec[str]` — see below |

All three return **borrowed** strings pointing into the process's own
environment block, and a `var` result stays valid for the life of the process.
That is fine to print and fine to pass to something taking `:&str`; it is not
something to store, mutate or free. If a value has to outlive the call, use
`strings::copy`.

`var` returning `""` for unset is indistinguishable from a variable that is
set to the empty string. There is no "is it set" query, so a variable whose
empty value is meaningful has to be treated as present if you care.

## The command line

The way to read arguments is the **`env_args()` builtin**, which takes no
parameters and returns a `vec[str]` with the program name first:

```mire
load kioto::env
load kioto::strings
load mire::vec

pub fn main: () {
    set a = env_args()
    dasu(strings::from::i64(vec::len(a)) + " arguments, including argv[0]")
    if vec::len(a) > 1 {
        dasu(strings::concat("first argument: " vec::get::str(a 1)))
    }
}
```

`env::args(argc, argv)` also exists and is the underlying runtime call, but it
takes the raw C pair that `main` receives, and **Mire's `main` takes no
parameters** — there is no way to name those values in source. Use
`env_args()`; `env::args` is only reachable from a C-side caller.

Nothing splits a string into words, and nothing expands a glob, resolves a
`~` or interprets a shell metacharacter: a `--path=/etc/*` argument arrives as
one element exactly as the caller wrote it. That is the correct behaviour, and
it is the reason arguments are a vector rather than a string.

Parsing what you find in that vector is [`cli::parse`](cli.md)'s job.

## See also

- [Command-line parsing](cli.md)
- [Security](../guides/security.md) — why `~` expansion is deliberately absent
- [`env` symbol reference](../symbols/env.md)
