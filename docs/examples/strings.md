# Text

The `strings` module is the one most programs lean on. It is also where the
namespace pattern and the ownership rule are most visible, so this page covers
both.

## Three groups, one idea

The address says which operation you mean:

| Form | Reads as |
| --- | --- |
| `strings::upper(s)` | the only upper-caser |
| `strings::starts::with(s p)` | one of two `starts` |
| `strings::replace::all(s a b)` | one of two `replace`s |
| `strings::from::i64(n)` | converting *from* a number |
| `strings::to::i64(s)` | converting *to* a number |

A qualifier appears only when there is more than one of the thing, which is why
`upper` is flat and `replace` is not.

## Case, trimming, padding

```mire
load kioto::strings

pub fn main: () {
    dasu(strings::upper("shout"))
    dasu(strings::lower("QUIET"))
    dasu(strings::trim("  padded  "))
    dasu(strings::pad::left("7" 3 "0"))
    dasu(strings::pad::right("x" 5 "-"))
}
```

`trim` and `strip` are the same function under two names; `trim` is the one
used here because it is shorter and matches what the other languages call.

## Testing and searching

```mire
load kioto::strings

pub fn main: () {
    set name = "/srv/app/main.mir"
    dasu("absolute: " + strings::from::bool(strings::starts::with(name "/")))
    dasu("mir file:  " + strings::from::bool(strings::ends::with(name ".mir")))
    dasu("has app:   " + strings::from::bool(strings::contains(name "app")))
    dasu("dot at:    " + strings::from::i64(strings::index(name ".")))
    dasu("substring: " + strings::substr(name 5 3))
}
```

`index` returns the byte offset of the first occurrence, and `-1` when the
needle is not there — a second thing to check before using the result.

`replace::first` changes one occurrence and `replace::all` changes every one.
`split` returns a `vec[str]`, which is where `mire::vec` starts to matter.

## Converting

```mire
load kioto::strings

pub fn main: () {
    set n = strings::to::i64("42")
    dasu("parsed " + strings::from::i64(n))
    dasu("unparseable: " + strings::from::i64(strings::to::i64("abc")))
    dasu("pi: " + strings::from::f64(3.14159265))
    dasu("flag: " + strings::from::bool(true))
}
```

Two things to know before relying on either direction:

- `strings::to::i64` is `atoll` with no error channel, so **anything that does
  not start with a digit parses as `0`**. Check `strings::starts::with` for a
  digit when the difference matters.
- `strings::from::f64` prints six significant digits, `%g` style — enough to
  show a value, not enough to read one back. Never use it to serialise a
  number you intend to parse again.

`from::bool` takes a `:bool`, not an integer, because that is what a condition
produces.

## Building and splitting

```mire
load kioto::strings
load mire::vec

pub fn main: () {
    set joined = strings::join(["a" "b" "c"] "-")
    dasu(joined)
    set parts = strings::split("a-b-c" "-")
    set i = 0 :i64 mut
    while i < vec::len(parts) {
        dasu("  " + vec::get::str(parts i))
        set i = i + 1
    }
    dasu("count " + strings::from::i64(vec::len(parts)))
}
```

`join` takes the vector **without** `&` — a `vec` argument is reached as a plain
value, and writing `&` is a compile error. `vec::get::str` borrows, so `parts`
survives the loop.

## Ownership

`strings` returns freshly allocated values, so nothing you pass in is spent:

```mire
load kioto::strings

pub fn main: () {
    set name = "ada"
    dasu(strings::upper(name))
    dasu(name)          // still available: upper borrowed it
}
```

This is the opposite of `mire::vec`, where `push` returns a **new** vector and
you must reassign. The distinction is deliberate — the collections own their
elements, the string functions do not touch yours.

When you need to keep both, `vec::clone` is the explicit way to copy a value
you are about to hand to something that consumes it.

## One trap

`+` does not mix a `str` with a `&str`. If one side is a borrowed value, use
`strings::concat`, or make the borrowed side owned first:

```mire
set name = "ada" :str mut
set greeting = "hello, " + name    // fine: both str
```

## See also

- [Text](../modules/strings.md) — the full API
- [Ownership](../guides/ownership.md) — borrowing, moving, and the `&` rule
- [Naming](../guides/naming.md) — why some names are grouped
