# Inventory

Every public symbol in Kioto 3.0.0, what is deliberately absent, and the rules
that explain both. Counts come from the source, not from this document: the
reference pages under [`symbols/`](symbols/) are generated from the same pass
that found them.

## At a glance

244 public functions across 13 top-level modules, plus 23 namespace groups.

| Module | Symbols | What it is for |
| --- | ---: | --- |
| [`math`](symbols/math.md) | 89 | Pure numbers: float, int, constants, sequences, descriptive statistics, summation, reproducible random |
| [`fs`](symbols/fs.md) | 36 | Whole-file helpers plus capability handles rooted at a directory |
| [`strings`](symbols/strings.md) | 32 | Byte-oriented text operations |
| [`crypto`](symbols/crypto.md) | 30 | Hashing, encoding, checksums, secure random, Ed25519 |
| [`net`](symbols/net.md) | 17 | TCP and UDP sockets |
| [`proc`](symbols/proc.md) | 14 | Running other programs, without a shell |
| [`async`](symbols/async.md) | 10 | Pipes and a thin process layer |
| [`time`](symbols/time.md) | 5 | Wall clock and elapsed time |
| [`env`](symbols/env.md) | 3 | Environment variables and the argument vector |
| [`log`](symbols/log.md) | 3 | Three plain lines on stdout |
| [`mem`](symbols/mem.md) | 3 | Machine memory and process memory |
| [`cli`](symbols/cli.md) | 1 | Argument vector to lookup table |
| [`cpu`](symbols/cpu.md) | 1 | Logical core count |
| **Total** | **255** | |

### math

| Submodule | Symbols |
| --- | ---: |
| root | 14 |
| `float` | 20 |
| `int` | 18 |
| `consts` | 12 |
| `power` | 11 |
| `stats` | 10 |
| `seq` | 6 |
| `random` | 5 |
| `sum` | 4 |

Five further submodules — `complex`, `decimal`, `hyperbolic`, `special` and
`trig` — exist as two-line placeholders. They are not exported, not loaded and
not reachable; see [Not implemented](#not-implemented).

### crypto

| Submodule | Symbols |
| --- | ---: |
| `sign::ed25519` | 11 |
| `checksum` | 5 |
| `hash` | 4 |
| `encode::base64` | 3 |
| `random::secure` | 3 |
| `encode::hex` | 2 |
| `hash::sha256` | 1 |
| `hash::sha512` | 1 |

## How a symbol is named

A submodule directory contributes a namespace level; a file that is not called
`mod.mr` contributes one more, named after the file. Nesting `pub fn` inside a
`pub fn` adds further levels. So the function declared as `pub fn encode` in
`crypto/encode/base64.mr` is reached as `base64::encode`, and the one in
`crypto/hash/sha256.mr` as `sha256::hash`.

`mod.mr` files contribute nothing: they exist to load and re-export, and the
`module` line inside them is what names the directory.

After `load kioto` the namespaces are available flattened, so both
`float::abs` and `math::float::abs` resolve, as do `hash::sha256` and
`crypto::hash::sha256`. Loading a submodule directly — `load kioto::crypto` —
is the narrower and more explicit habit, and it is what the examples use.

## The nine public structs

The 244 functions above are the callable surface. Nine structs are public as
well, and they are what the handles in that table actually are: an opaque
wrapper around a PAL handle, with no field a caller should read.

| Struct | Module | Created by | Note |
| --- | --- | --- | --- |
| `Process` | `proc` | `proc::run::create` | Consumed by `wait`, `kill` or `close` — exactly one |
| `Channel` | `async` | `async::channel::create` | Passed to send/recv/close by `&` |
| `Task` | `async` | `async::task::ready` | |
| `Socket` | `net` | `net::socket::connect::*` | Passed to send/recv/close by `&` |
| `Listener` | `net` | `net::listener::bind` | Consumed by `close`; `accept` borrows it |
| `Root` | `fs` | `fs::root::open` | Consumed by the first `file::open`/`dir::open` |
| `File` | `fs` | `fs::file::open::*` | Consumed by `file::read` |
| `Dir` | `fs` | `fs::dir::open` | |
| `SecretKey`, `PublicKey` | `crypto` | `ed25519::secret::new` | Opaque; a `SecretKey` is consumed by its first use |

There are no public enums and no public constants — a `cons` is not readable
across a package boundary, which is why every constant a consumer needs is
exposed as a zero-argument function (`consts::pi()`, `PAL_SOCKET_TCP()`).

## What is not here

### No collection management

There is no `collections` module, and no public function anywhere in the package
pushes to, pops from, sorts, inserts into or clears a vector or map. Kioto has
no API for managing a collection after it exists.

Collections do appear at the edges, deliberately and in three shapes:

- **Produced by something else.** `fs::list` returns a directory listing,
  `cli::parse` returns the argument vector as a table, `secure::bytes` returns
  random bytes, `base64::decode` and `hex::decode` return byte vectors. These
  are results, not containers you then own.
- **Consumed as input.** `stats::mean`, `int::sum`, `math::random::pick` and
  `strings::join` read a vector and return a number or a string. They do not
  modify it.
- **Constructed for you.** `seq::range`, `seq::between`, `seq::step` and
  `seq::repeat` build a fresh `vec[i64]` from arithmetic. Each call returns a
  new value and holds no state between calls.

Mutation is what `mire::vec` and `mire::map` are for. Kioto depends on `mire`
and does not wrap it.

### No macros

Kioto defines no macros. `owl.toml` lists five names — `assert`, `assert_eq`,
`assert_ne`, `dbg`, `trace_i64` — under `[security] macros`, but all five are
defined in `mire/core/macros/`. The list is an allowlist of what project code
may invoke, not a declaration of what Kioto provides.

### No stubs in the exported surface

Every one of the 244 symbols resolves and has a body. Six files under
`modules/math/` are two-line placeholders and are the only unfinished code in
the package.

### No shell

`proc` cannot reach a shell. There is no `system`, no `popen`, no
`sh -c`. Every entry point takes a program and an argument vector. A string
that happens to contain a space is a filename with a space in it, never a
command line — the property the [process guide](modules/proc.md) is built on.

## Not implemented

| File | Status |
| --- | --- |
| `modules/math/complex/mod.mr` | Placeholder, not exported |
| `modules/math/decimal/mod.mr` | Placeholder, not exported |
| `modules/math/hyperbolic/mod.mr` | Placeholder, not exported |
| `modules/math/special/mod.mr` | Placeholder, not exported |
| `modules/math/trig/mod.mr` | Placeholder, not exported |

None is listed in `modules/math/owl.toml`, none is `load`ed by
`modules/math/mod.mr`, and none resolves. They are absent from the reference
pages because absent is the accurate description.

## Known limitations

These are behaviours of the current code, not gaps in the documentation. Each
one is also recorded at the symbol it affects.

- **`fs::mkdir` leaves no error code.** It returns `bool`, and `fs::last_error`
  does not see the failure, so a failed `mkdir` cannot be told apart from a
  permission problem by inspection. Check the boolean, and do not reach for
  `last_error` to explain it.
- **`fs::read` truncates at the first NUL byte.** It is a text function. For
  binary content use `fs::file::read` into a buffer you sized yourself, or
  `hash::sha256_file` when all you need is a digest.
- **`async::spawn` does not split a command string.** `"ls -l"` is looked up as
  a single executable name and fails to start. Pass a vector via
  `proc::run::spawn`, or build the argv explicitly.
- **`proc::run::output` returns `""` on failure and on empty output.** The two
  are indistinguishable from the return value; `proc::run::last_exit` is what
  separates them.
- **`proc::run::create` only accepts an empty argument vector.** Passing
  `["1"]` inline fails with `call expects function callback, got Vector`, and
  a named `vec[str]` variable fails with `Unknown function '<name>'` — the
  second argument is misparsed as a call. `run::output` and `run::output_cwd`
  accept both forms, so they are the way to run a program with arguments until
  this is fixed. See [the process guide](modules/proc.md#asynchronous-execution).
- **A `u16` argument must be a variable when it is not the only argument.**
  `net::socket::connect::tcp("host" (80 :u16))` is misparsed and reports
  `call expects function callback, got Str` — pointing at the *host*, not the
  port. Binding the port first works everywhere:
  `set port = 80 :u16` then `connect::tcp("host" port)`.
- **Handles are consumed by their first use, and most have no reachable
  close.** `proc::wait`, `proc::kill`, `proc::close`, `fs::file::read`,
  `fs::file::open::*` and `fs::dir::open` all take their handle **by value**,
  so a second use is a use-after-move error. In `fs` the effect is that
  `root::close` can never be reached: opening a file or directory from a root
  spends it. See [Ownership](guides/ownership.md).
- **An Ed25519 `SecretKey` is usable exactly once.** Both
  `ed25519::secret::public` and `ed25519::secret::sign` take the key by value,
  and there is no signing entry point that takes a public key — so a program
  cannot both derive a public key and sign with it. See
  [Signing](modules/crypto.md#signing).
- **`env::args(argc, argv)` is not reachable from Mire.** It needs the raw C
  `argc`/`argv` pair that `main` receives, and Mire's `main` takes no
  parameters. Use the `env_args()` builtin, which reads them itself.
- **A `cons` is invisible across a package boundary.** Constants a consumer
  needs are exposed as zero-argument functions instead — `consts::pi()`,
  `crypto::random::secure::seed`, `net::PAL_SOCKET_TCP()`. Reading one as a
  bare value reports `Unknown function`.
- **Namespace parents that are also files.** A module reached through a
  package resolves with the package name outermost — `net::socket::connect::tcp`,
  `async::channel::create`. The flattened `socket::connect::tcp` does not
  resolve, because those modules' own file is `mod.mr` and contributes no
  namespace. Modules in named subdirectories (`fs`, `strings`, `math`) are
  reached by their own name.

## Related

- [Module guides](modules/) — one page per module, with the mental model
- [Examples](examples/) — programs that compile, start to finish
- [Guides](guides/) — cross-cutting rules: errors, ownership, naming
- [Changelog](changelog.md) — what changed in each release
