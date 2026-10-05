# Kioto

The standard library for [Mire](https://github.com/mire-lang/Avenys-rust):
text, collections, filesystem, processes, networking, crypto, logging, time and
mathematics — 244 public functions across 13 modules.

> **3.0.0 is in development.** The 2.x `core/` tree is being replaced by
> `modules/`, and the math surface is being rebuilt in Mire itself, with no
> `rt_math_*` externs behind it. This package documents what has actually
> landed; [the inventory](docs/inventory.md) records what has not.

## Install

The package is a directory of Mire modules under `modules/`, with a `mod.mr` at
the root that makes the whole library visible:

```mire
load kioto            // everything
load kioto::math      // one module
load kioto::fs::path  // one submodule
```

Collections are **not** part of this package. `vec` and `map` live in the
compiler's own standard library, `mire::vec` and `mire::map`.

## A first program

```mire
load kioto
load kioto::strings
load mire::vec

pub fn main: () {
    set args = env_args()
    if vec::len(args) < 2 {
        dasu("usage: greet <name>")
        return
    }
    set name = vec::get::str(args 1)
    dasu("hello, " + strings::upper(name) + "!")
}
```

`dasu` is the print builtin — Mire has no `println` — and it takes a `str`, so
anything computed becomes one first with `strings::from::*`.

## Documentation

**[Start here →](docs/README.md)**

| | |
| --- | --- |
| [Inventory](docs/inventory.md) | Every module, every public symbol, and the deliberate absences |
| [Getting started](docs/examples/getting-started.md) | A program that compiles, with each construct explained |
| [Symbol reference](docs/symbols/) | All 244 functions, one page per module, generated from the source comments |
| [Module guides](docs/README.md#module-guides) | One page per module: the model, and the mistakes worth avoiding |
| [Examples](docs/README.md#examples) | Six complete programs: files, processes, crypto, text, numbers |
| [Guides](docs/README.md#guides) | Errors, ownership, naming and security — the rules that cross module lines |
| [Changelog](docs/changelog.md) | Release history |

## Three things to know before you start

**1. A function that fails returns a value, and there is no exception.** A
`bool`, an empty string, a negative handle, or a code from `fs::last_error()`.
Some of these are ambiguous on their own — an empty string from
`proc::run::output` means either "failed" or "printed nothing", and
`last_exit` is what tells them apart. See [Errors](docs/guides/errors.md).

**2. Passing a value without `&` moves it.** Using it again is a compile error,
not a crash. Vectors and maps are the exception: never write `&` on them.
`&` is for struct handles — a `Socket`, a `Channel`, a `File`. See
[Ownership](docs/guides/ownership.md).

**3. `fs::remove` and `fs::remove_all` never follow a symlink.** They unlink
the link and leave the target alone, and `..` is refused during path
resolution. Processes take a program and a `vec[str]` of arguments, with no
shell anywhere in the path. See [Security](docs/guides/security.md).

## Modules

| Module | What it does |
| --- | --- |
| [`async`](docs/modules/async.md) | Pipes and processes that outlive a single call |
| [`cli`](docs/modules/cli.md) | Argument parsing into flags and values |
| [`cpu`](docs/modules/cpu.md) | Core count |
| [`crypto`](docs/modules/crypto.md) | Digests, hex and base64, secure randomness, Ed25519 |
| [`env`](docs/modules/env.md) | Environment variables |
| [`fs`](docs/modules/fs.md) | Files, directories and root capabilities |
| [`log`](docs/modules/log.md) | Diagnostics on stderr, keeping them out of real output |
| [`math`](docs/modules/math.md) | Scalars, integers, statistics, sequences, seeded randomness |
| [`mem`](docs/modules/mem.md) | Memory in use, and the system and process ceilings |
| [`net`](docs/modules/net.md) | TCP and UDP sockets |
| [`proc`](docs/modules/proc.md) | Running programs, capturing output, exit status |
| [`strings`](docs/modules/strings.md) | Byte-exact text work |
| [`time`](docs/modules/time.md) | Clocks and elapsed measurement |

## Not in this package

- **Collections.** `vec` and `map` are `mire::vec` and `mire::map`.
- **TLS or any transport security.** `net` is plain sockets.
- **Encryption or key storage.** `crypto` does digests, randomness and
  signatures, and nothing that keeps a secret safe.
- **Floating-point `sqrt`, `log` or `pow`.** `int::ipow` is the only
  exponentiation, and it is on `i64`.
- **`async`, `trig`, `complex`, `decimal`, `hyperbolic`, `power`, `special`**
  math submodules — six placeholders that export nothing.

The full list, with the reasoning, is in
[the inventory](docs/inventory.md#what-is-deliberately-absent).

## Licence

MIT.
