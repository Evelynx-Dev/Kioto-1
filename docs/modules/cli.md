# Command-line parsing

`cli::parse` turns a `vec[str]` of arguments into a `map[str str]`. It handles
the two shapes a flag normally takes and nothing else.

```mire
load kioto::cli
load kioto::strings
load mire::map
load mire::vec

pub fn main: () {
    set opts = cli::parse(env_args())
    set verbose = map::has(opts "verbose")
    set out = map::get::str(opts "out")
    if verbose {
        dasu("verbose mode, writing to [" + out + "]")
    } else {
        dasu("writing to [" + out + "]")
    }
}
```

| Form in the vector | Becomes |
| --- | --- |
| `--name value` | `name` → `value` |
| `--name=value` | `name` → `value` |
| `--name` with no value | `name` → `""` |
| a bare word | a key, with `""` as its value |

A flag is a flag when it starts with `--`; everything else is a key. A bare
word as a key is what makes `map::has(opts "verbose")` work for a switch that
was written with no value, and it is also why a positional argument ends up
in the same map as an option — **there is no separate list of positionals.**
If a program takes one, the convention is to name it (`input`, `output`) and
read it back with `map::get::str`.

A missing key is a `false` from `map::has`, and an absent value is `""` from
`map::get::str`; the two together are the whole interface. Neither call fails,
so there is no error to check.

## Limits

This is a flag splitter, not a parser. There are no short aliases (`-v` is a
key named `v`, not `verbose`), no `--flag` boolean semantics beyond "present",
no repeated flags (the last one wins), no `--` terminator, and no defaults. For
any of those, read the vector yourself.

The type is `map[str str]` because flags are text. A number arrives as text and
becomes a number when you convert it with `strings::to::i64` — and that
conversion returns `0` for anything unparseable, so a value that came from the
command line and is about to be used as a count or a port is worth validating
rather than trusting.

## See also

- [Environment](env.md) — where the argument vector comes from
- [Errors](../guides/errors.md) — validating values the parser accepted
- [`cli` symbol reference](../symbols/cli.md)
