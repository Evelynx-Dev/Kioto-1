# Getting started

A first program, then the three things worth knowing before writing more.

## Hello

```mire
load kioto::strings

pub fn main: () {
    dasu(strings::upper("hello, world"))
}
```

`main` takes no parameters and returns nothing. `dasu` is the print builtin —
Mire has no `println`. It appends a newline, and it takes a `str`, so anything
computed has to become one first with `strings::from::*`.

Build and run it:

```
mire build main.mir --debug -O0
./bin/debug/main
```

## Reading arguments

`env_args()` returns the command line as a `vec[str]`, program name first.
`cli::parse` turns flags into a map.

```mire
load kioto
load kioto::strings
load mire::map
load mire::vec

pub fn main: () {
    set opts = cli::parse(env_args())
    set target = map::get::str(opts "out")
    if target == "" {
        dasu("nothing to do; pass --out <path>")
        return
    }
    if map::has(opts "verbose") {
        dasu("writing to " + target)
    }
    dasu("would write to " + target)
}
```

Two details: `map::get::str` returns `""` for a missing key, and `&` is **not**
written on a `map` argument — `map::get::str(opts "out")`, not
`map::get::str(&opts "out")`. See [Naming](../guides/naming.md).

## Working with a list

`mire::vec` owns its elements, so `push` returns a **new** vector and you
reassign. A variable reassigned later is declared `mut` on its first `set`.

```mire
load kioto::strings
load mire::vec

pub fn main: () {
    set words = [] :vec[str] mut
    set i = 0 :i64 mut
    while i < 3 {
        set words = vec::push::str(words strings::repeat("ab" i + 1))
        set i = i + 1
    }
    dasu(strings::join(words ", "))
    dasu(strings::from::i64(vec::len(words)) + " words")
}
```

`vec` and `map` arguments are written **without** `&` — the reference is
implied, and adding it is a compile error. `&` is for concrete struct handles
like a `Socket` or a `Channel`. The full rule is in
[Ownership](../guides/ownership.md#when-to-write--at-the-call-site).

## Three things before you go further

**1. There is no `else if`.** The keyword is `elif`:

```mire
if a { dasu("a") } elif b { dasu("b") } else { dasu("c") }
```

**2. A call's arguments go on one line.** A multi-line argument list is a parse
error, not a formatting choice. Bind to a variable first:

```mire
set key = "a-very-long-key-name-goes-here"
if ed25519::public::verify_file(key sig_path data_path) { dasu("ok") }
```

**3. A value moves when passed without `&`.** Using it again is a compile
error, not a crash. If you need it twice, borrow it — or `vec::clone` it.

**4. Do not parenthesise a call argument.** `strings::repeat("ab" i + 1)`
compiles; `strings::repeat("ab" (i + 1))` does not, and the error names the
*first* argument. Some parenthesised forms happen to work, so it is not a rule
you can check by reading — leave the parens off, or bind to a variable.

## What to read next

- [Ownership](../guides/ownership.md) — moves, borrows, and the `&` rule
- [Errors](../guides/errors.md) — how failure is reported
- [Text](../modules/strings.md) — the module you will use most
- [`inventory`](../inventory.md) — every module and what it does not have

## See also

- [Files and directories](files.md) — reading and writing
- [Processes](processes.md) — running other programs
