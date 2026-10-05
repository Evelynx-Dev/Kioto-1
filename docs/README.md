# Kioto documentation

Start here, then go as deep as the task needs.

## If you have five minutes

1. [Inventory](inventory.md) — what the package contains, and what it
   deliberately does not.
2. [Getting started](examples/getting-started.md) — a program that compiles,
   with each line explained.
3. [Processes](modules/proc.md) — the module most programs reach for first.

## Reference

[Symbol reference](symbols/) — all 244 public functions, one page per module,
generated from the source comments so it cannot drift from the code.

| | |
| --- | --- |
| [async](symbols/async.md) · [cli](symbols/cli.md) · [cpu](symbols/cpu.md) | [crypto](symbols/crypto.md) · [env](symbols/env.md) · [fs](symbols/fs.md) |
| [log](symbols/log.md) · [math](symbols/math.md) · [mem](symbols/mem.md) | [net](symbols/net.md) · [proc](symbols/proc.md) · [strings](symbols/strings.md) · [time](symbols/time.md) |

## Module guides

One page per module: what it is for, the model behind it, and the mistakes
worth avoiding.

| Module | Guide |
| --- | --- |
| `async` | [Pipes and processes](modules/async.md) |
| `cli` | [Argument parsing](modules/cli.md) |
| `cpu` | [Core count](modules/cpu.md) |
| `crypto` | [Hashing, encoding and signing](modules/crypto.md) |
| `env` | [Environment and arguments](modules/env.md) |
| `fs` | [Files and capabilities](modules/fs.md) |
| `log` | [Logging](modules/log.md) |
| `math` | [Mathematics](modules/math.md) |
| `mem` | [Memory](modules/mem.md) |
| `net` | [Sockets](modules/net.md) |
| `proc` | [Processes](modules/proc.md) |
| `strings` | [Text](modules/strings.md) |
| `time` | [Time](modules/time.md) |

## Examples

Every example is a complete program that compiles. Where a program is shown
inline it is the same code as the file beside it.

| Example | Shows |
| --- | --- |
| [Getting started](examples/getting-started.md) | Loading, printing, the shape of a program |
| [Files and directories](examples/files.md) | Reading, writing, listing, removing |
| [Running programs](examples/processes.md) | Capturing output, exit status, no shell |
| [Hashing and signing](examples/crypto.md) | Digests, hex and base64, Ed25519 |
| [Text processing](examples/strings.md) | Byte-exact text work |
| [Numbers](examples/math.md) | Floats, integers, statistics, sequences, seeded randomness |

## Guides

Rules that hold across modules rather than inside one.

| Guide | Covers |
| --- | --- |
| [Errors](guides/errors.md) | Return conventions, `last_error`, what failures do not tell you |
| [Ownership](guides/ownership.md) | Borrows, moves, handles that must be closed |
| [Naming and loading](guides/naming.md) | How a symbol's name follows from where it is declared |
| [Security](guides/security.md) | The properties the package holds to |

## Reference material

- [Changelog](changelog.md) — release history
- [Inventory](inventory.md) — the complete symbol list and the absences
