# Ownership

Mire has an ownership checker, and in a language with manual memory it is the
difference between a bug you find and a bug that finds you. This page is about
what actually moves, because that is where the surprises are.

## Two annotations, two meanings

`:T` takes a value; `:&T` and `:&mut T` borrow one.

A **borrow** is a promise that the value outlives the call and is not
invalidated while borrowed. Almost every read-only function in the package
takes `:&T` for exactly this reason:

```mire
load kioto::strings
load mire::vec

pub fn main: () {
    set names = [] :vec[str] mut
    set names = vec::push::str(names "alpha")
    set n = vec::len(names)           // borrow: names is still usable
    dasu(strings::from::i64(n))
    dasu(vec::get::str(names 0))      // borrowed again
    dasu(strings::upper("literal"))
}
```

`vec::len`, `strings::upper`, `map::get::str` and `net::socket::send` are all
borrow-taking, so calling them in a loop does not consume the value. That is
what makes the read-only half of the package comfortable to use.

## When to write `&` at the call site

This trips people up, and the rule is not "borrows need `&`" — it depends on
what the parameter is declared as.

| Declared parameter | Call site | Example |
| --- | --- | --- |
| `&anything` (vec, map) | **no `&`** | `vec::len(v)`, `vec::get::str(v 0)`, `map::has(m k)` |
| `&SomeStruct` | **`&` required** | `net::socket::send(&sock msg)`, `async::channel::recv(&ch buf n)` |
| `&str`, `&mut str` | either works | `strings::upper(s)` or `strings::upper(&s)` |

Writing `&` on a `vec` or `map` argument is a compile error —
`Multiple mutable references not allowed` — even though the signature says
`&`. A vector is reached as a plain value and the reference is implied.

## `&mut` is an out-parameter

`&mut str` is how a callee writes into a buffer you own, and it is what every
PAL read uses:

```mire
set buf = strings::repeat("\0" 1024) :str mut
set n = net::socket::recv(&sock buf 1024)
dasu(strings::substr(buf 0 n))
```

`buf` is declared `mut` **and** sized before the call. The callee writes up to
`max_len` bytes and does not grow anything, so an empty or short buffer is a
heap overflow rather than a caught error. This is the one ownership rule with
a memory-safety consequence, and it appears in `fs`, `async` and `net`
alike.

## A value moves when it is passed by value

`:T` **consumes** the argument. Using it again is a compile-time
use-after-move error, not a crash:

```mire
load kioto::strings

pub fn main: () {
    set s = strings::upper("hello")
    dasu(s)
    dasu(s)              // does not compile: s was moved
}
```

So the rule to carry is simple: **if you will need a value again, pass a
borrow.** Reach for the `:&T` overload when one exists, and treat a missing
borrow as a gap in the API rather than a reason to give up on the value.

## Handles are the exception that proves the rule

The `fs`, `proc`, `net` and `async` handle types — `Root`, `File`, `Dir`,
`Process`, `Socket`, `Listener`, `Channel`, `SecretKey`, `PublicKey` — are
**consumed by their first use**, and this is where the package's ownership
model is genuinely inconsistent.

```mire
set secret = ed25519::secret::new()
set pubkey = ed25519::secret::public(secret)   // consumed
set sig = ed25519::secret::sign(secret "msg")  // ownership error
```

Consequences worth knowing before you write the code:

- **`proc`**: `wait`, `kill` and `close` each consume the `Process`, so
  exactly one of the three is possible. `kill` then `wait` does not work —
  `kill` already took the handle.
- **`fs`**: `file::open::*` and `dir::open` consume the `Root`, so
  **`root::close` is unreachable** once you have opened anything through it.
  `file::read` consumes the `File`, so `file::close` after a read is too.
  Descriptors accumulate until the process ends.
- **`ed25519`**: a `SecretKey` is usable once, and since `public()` is the
  only way to get a `PublicKey`, a single program cannot both publish a key
  and sign with it.
- **`net`**: `socket::send`/`recv`/`close` borrow the socket and behave well.
  `listener::close` consumes the listener, and `listener::accept` borrows it.

The borrow-taking calls are the ones that behave as you would expect, and they
are the majority of the network API. The by-value ones are the exception.

## Why a struct passed by value is a move

A struct is not `Copy`, and neither is a `vec` or a `map`. Passing one to a
`:T` parameter transfers it, even when the callee only reads a field:

```mire
load kioto::crypto
load mire::vec

pub fn main: () {
    set bytes = [] :vec[i64] mut
    set bytes = vec::push::i64(bytes 65)
    set copy = vec::clone(bytes)      // the way to keep using it
    dasu(hex::encode(bytes))          // consumes bytes
    dasu(base64::encode(copy))        // clone is the one that survives
}
```

`vec::clone` is the tool for this, and the ownership error is the tool for
finding every place you needed it.

## Strings: borrowed, and owned

A `str` returned by value is yours: it was allocated for you, and releasing it
is the runtime's job. A `str` returned as `:&str` is **not** — it points into
something that already exists, such as the process environment, and freeing it
would be a bug.

`env::var` and `env::cwd` both return `:&str`, and the reason is that the
value belongs to the process. If a result has to outlive the call, take a copy:

```mire
set borrowed = env::var("HOME")
set owned = strings::copy(borrowed)   // safe to keep
```

Every whole-file helper in `fs` (`read`, `exists`, `list`) takes `:&str` for
its path, and the pattern for building a path is the same: compose it once,
then pass it as a borrow.

## What the checker will not catch

- **Index and arithmetic bounds are not part of this.** An out-of-range index
  is a panic at runtime with a location, not a compile error.
- **A borrow that outlives its owner** is a compile error, which is the one
  place this checker earns its keep — but it cannot see through a raw `ptr`
  parameter, and `env::args` takes one.
- **Double free of a string** is prevented by reference counting in the
  runtime, so a `str` freed twice is counted rather than corrupting the heap.
  That is a runtime safety net, not a compile-time guarantee.

## See also

- [Errors](errors.md) — what a failure looks like when there is no exception
- [Files and capabilities](../modules/fs.md) — the `Root` lifetime in context
- [Signing](../modules/crypto.md#signing) — the `SecretKey` single-use rule
