# Numbers

`math` is split into submodules that mostly take different types, so the
address is what tells you which one you want.

## Layout

| Submodule | Works on | Reached as |
| --- | --- | --- |
| `math` | `f64` | `math::abs` |
| `math::float` | `f64`, plus predicates | `math::float::abs` |
| `math::int` | `i64` | `math::int::abs` |
| `math::stats` | `vec[i64]` → `f64` | `math::stats::mean` |
| `math::consts` | — | `math::consts::pi()` |
| `math::seq` | `i64` ranges | `math::seq::between` |
| `math::sum` | `vec[f64]` | `math::sum::fsum` |
| `math::random` | seeded | `math::random::next` |

`math::abs` and `math::float::abs` are both there, taking the same type, and
`math::abs` is the one to reach for. The `float` submodule is where the
predicates and the bit-level functions live.

## Constants are functions

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    dasu("pi    " + strings::from::f64(consts::pi()))
    dasu("tau   " + strings::from::f64(consts::tau()))
    dasu("phi   " + strings::from::f64(consts::phi()))
    dasu("eps   " + strings::from::f64(float::epsilon()))
}
```

`consts::pi()` — with the call parentheses — not `consts::pi`. A `cons` is not
readable across a package boundary, so anything a consumer needs is exposed as
a zero-argument function. The module's own functions use the constants the same
way.

## Floating point

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    dasu("abs(-2.5)   " + strings::from::f64(math::abs(0.0 - 2.5)))
    dasu("clamp       " + strings::from::f64(math::clamp(11.0 0.0 10.0)))
    dasu("floor(-1.5) " + strings::from::f64(float::floor(0.0 - 1.5)))
    dasu("ceil(-1.5)  " + strings::from::f64(float::ceil(0.0 - 1.5)))
    dasu("fract(2.75) " + strings::from::f64(float::fract(2.75)))
    dasu("copysign    " + strings::from::f64(float::copysign(3.0 0.0 - 1.0)))
}
```

Note `0.0 - 2.5` rather than `-2.5`: the lexer reads a leading `-` as part of a
number, and a negative literal in an argument position is not reliable. Bind a
negative value to a variable if you need one.

The predicate names are camelCase, unlike everything else in the package:
`float::isNan`, `float::isInf`, `float::isFinite`, `float::isNormal`,
`float::isSubnormal`.

## Integers

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    dasu("gcd(84, 36)   " + strings::from::i64(int::gcd(84 36)))
    dasu("lcm(4, 6)     " + strings::from::i64(int::lcm(4 6)))
    dasu("isqrt(999999) " + strings::from::i64(int::isqrt(999999)))
    dasu("isPrime(97)   " + strings::from::bool(int::isPrime(97)))
    dasu("comb(10, 3)   " + strings::from::i64(int::comb(10 3)))
    dasu("ipow(2, 10)   " + strings::from::i64(int::ipow(2 10)))
}
```

`divmod(a, b)` returns a `vec[i64]` of quotient and remainder, and
`primeFactors(n)` returns a `vec[i64]` too — so both hand back a collection
that is yours.

**There is no integer overflow check.** `int::factorial(21)` is past
`i64` and wraps silently. If a value can be attacker-supplied, bound it before
you compute.

## Statistics

```mire
load kioto::math
load kioto::strings
load mire::vec

pub fn main: () {
    set xs = [2 4 4 4 5 5 7 9] :vec[i64]
    set ys = [1 2 2 3 4 4 5 8] :vec[i64]
    dasu("mean       " + strings::from::f64(stats::mean(xs)))
    dasu("median     " + strings::from::f64(stats::median(xs)))
    dasu("stddev     " + strings::from::f64(stats::stddev(xs)))
    dasu("mode       " + strings::from::i64(stats::mode(xs)))
    dasu("percentile " + strings::from::f64(stats::percentile(xs 0.9)))
    dasu("dist       " + strings::from::f64(sum::dist(xs ys)))
}
```

`stddev` is the **population** standard deviation — it divides by `n`, not by
`n - 1`. If you need the sample form, the arithmetic is two lines.

`corr` and `covariance` are the two to treat carefully: they iterate the
**shorter** of the two lists, so passing mismatched lengths silently gives you
an answer about only part of the data. Make the lengths equal yourself first.

## Sequences

```mire
load kioto::math
load kioto::strings
load mire::vec

pub fn main: () {
    set r = seq::between(0 5)
    dasu("between  " + strings::from::i64(vec::len(r)))
    set stepped = seq::step(0 1 5)
    dasu("step     " + strings::from::i64(vec::len(stepped)))
    set rep = seq::repeat(7 3)
    dasu("repeat   " + strings::from::i64(vec::len(rep)))
    set head = seq::take(r 2)
    dasu("take     " + strings::from::i64(vec::len(head)))
}
```

## Reproducible randomness

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    random::seed(42)
    set a = random::nextInt(100)
    random::seed(42)
    set b = random::nextInt(100)
    dasu("same seed, same draw: " + strings::from::bool(a == b))
}
```

`math::random` is seeded and reproducible, which is what makes it useful for
fixtures and sampling. For a token, a nonce or a key use
`crypto::random::secure` — see [Security](../guides/security.md).

## What is not here

Six submodules exist as placeholders and export nothing: `complex`, `decimal`,
`hyperbolic`, `power`, `special` and `trig`. There is no `sqrt`, no `log` and
no `pow` for floats — `int::ipow` is the only exponentiation, and it is on
`i64`.

## See also

- [Numbers](../modules/math.md) — the full API
- [Security](../guides/security.md) — seeded versus secure randomness
- [Getting started](getting-started.md) — vectors, which everything here takes
