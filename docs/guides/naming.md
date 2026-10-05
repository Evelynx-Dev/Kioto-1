# Naming

Most of kioto's names were settled before there was a convention to follow, so
this page records what the package actually does — including the places where
it contradicts itself.

## The rule that matters most

**A function is spelled `module::name` and its sub-functions are spelled
`module::group::name`.** A group is a function with no parameters and no return
value, written as a block:

```mire
pub fn strings {
    pub fn upper: (s :&str) :str { ... }
    pub fn starts {
        pub fn with: (s :&str, prefix :&str) :bool { ... }
    }
}
```

A group is a namespace, not a value. `strings::starts::with` is the whole
address; `strings::starts` is not something you call.

## Grouping is by role, not by type

The package groups where the *operation* comes from, and the grouping is not
uniform:

- `strings::starts::with`, `strings::ends::with`, `strings::replace::all` —
  grouped by the operation, with a qualifier where two exist.
- `strings::upper`, `strings::lower` — flat, because there is only one.
- `strings::from::i64`, `strings::to::i64` — conversion in, conversion out.
- `math::float::abs` and `math::int::abs` — a **module** boundary, not a group,
  because they take different types.
- `math::float::isNan` — camelCase, the only names in the package that are.

So a rule of thumb rather than a rule: if a qualifier would be redundant
because there is exactly one of the thing, it is left off. That is why
`replace::all` has a qualifier and `upper` does not.

## Underscores, not camelCase

Every name is `lower_snake_case`: `strip`, `substring_index`, `is_empty`.
Acronyms are not capitalised, so `sha256`, `ed25519` and `b64` are lowercase
as written.

## A module reached by its own name, except when it is not

This is the inconsistency that catches people, and it has one cause.

A module in a **named subdirectory** is reached by that name:
`fs::`, `strings::`, `math::`, `crypto::`, `net::`.

A module whose own file is `mod.mr` contributes **no namespace of its own**.
Those are `net`, `async`, `env`, `mem`, `cpu`, `log`, `time`, `cli`, and the
package name is the outermost segment instead:

```mire
net::socket::connect::tcp("host" port)     // yes
socket::connect::tcp("host" port)          // Unknown function
```

`fs`, `strings` and `math` have subdirectories (`fs/mod.mr`,
`strings/mod.mr`, `math/mod.mr` under a directory named after them), so their
names are real. `net` and `async` are the same shape on disk and still behave
differently. The rule to remember is the mechanical one: **if the module
resolves without a prefix under `load kioto`, keep the prefix; if it does not,
add `net::` or `async::` and try again.**

A file that is *not* `mod.mr` adds its own stem as a namespace. That is why
`crypto/sign/ed25519.mr` is reached as `ed25519::secret::new` and not
`sign::ed25519::secret::new`, and why `math/consts/mod.mr` is `consts::pi()`
rather than `pi()`.

## Constants are functions

A `cons` is not readable across a package boundary, so anything a consumer
needs is a zero-argument function: `consts::pi()`, `net::PAL_SOCKET_TCP()`,
`float::is_nan(x)`. Calling one as a bare value reports `Unknown function`.

The same applies to protocol and flag words. `proc::run::create` takes its
flags as an `i32`, and `PAL_SPAWN_WAIT` is the value `1` — a consumer has to
write the literal, which is why it appears as `(1 :i32)` in
[the process guide](../modules/proc.md#asynchronous-execution).

## Namespaces in the standard library

`mire::vec` and `mire::map` are separate from kioto's `strings`, and the
distinction is one of ownership: the collections own their elements, so
`vec::push` returns a **new** vector and you reassign.

```mire
set names = vec::push::str(names "new")
```

`strings` returns freshly allocated strings, so `strings::upper(s)` hands you a
value and leaves `s` alone. The two rules are different on purpose, and mixing
them up is the usual source of a "why did my vector change" question.

## Two spellings that break the compiler, and both work aroundable

### Never parenthesise a call argument

A parenthesised expression in the **second or later** position of a call is
misparsed, and the error points at the wrong argument.

A parenthesised expression in the **second or later** position of a call is
misparsed, and the error points at the wrong argument:

```mire
dasu(strings::repeat("ab" i + 1))      // fine
dasu(strings::repeat("ab" (i + 1)))    // call expects function callback, got Str
```

The message blames the first argument, which sends you looking at the string
rather than the arithmetic. The same shape appears in
`net::socket::connect::tcp("host" (80 :u16))`, where a parenthesised `u16` is
rejected and `(1 :i32)` in the same position elsewhere is accepted — so the
rule cannot be applied by reading the code.

Leave the parens off, or bind the value to a variable first. Neither costs
anything, and neither can be got wrong.

### Never write `&` on a `vec` or `map` argument

This one is easy to get wrong in the opposite direction, because the
declaration says `&` and the call does not. It is not about the declared
parameter type — **no vector or map argument ever takes `&`**, whether it is
declared `&vec[i64]` or the generic `&anything`:

```mire
dasu(strings::join(words ", "))    // words :vec[str]   — no &
dasu(strings::from::f64(stats::mean(xs)))   // xs :vec[i64]   — no &
dasu(strings::from::i64(vec::len(words)))   // &anything      — no &
```

Writing `&` is `Multiple mutable references not allowed`, and the fix is always
to delete it.

`&` **is** required for a reference to a non-collection struct — a `Socket`, a
`Channel`, a `File`, a `Process`:

```mire
net::socket::send(&sock msg)      // &Socket — required
async::channel::recv(&ch buf 1024) // &Channel — required
```

Getting the direction backwards is the common error: a collection is reached as
a plain value, a struct handle is reached by reference. See
[Ownership](ownership.md#when-to-write--at-the-call-site).

## Historical spellings kept for compatibility

Three pairs exist because the shorter name was added later and the original was
not removed:

- `fs::remove` and `fs::drop` — the same operation.
- `strings::trim` and `strings::strip` — the same operation.
- `hash::sha256` and `hash::sha256::hash` — the first returns hex, the second
  does not.

Prefer the longer or clearer name where there is a choice, and be consistent
within a file rather than across the package.

## See also

- [`strings`](../modules/strings.md) and [`math`](../modules/math.md) — the
  grouping in practice
- [Known limitations](../inventory.md#known-limitations) — the rules that
  contradict each other
