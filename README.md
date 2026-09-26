# Kioto

The standard library for [Mire](https://github.com/mire-lang/Avenys-rust):
strings, collections, filesystem, processes, networking, crypto, and math.

> **3.0.0 is in development.** The 2.x `core/` tree is being replaced by
> `modules/`, and the math surface is being rebuilt in Mire itself, without the
> `rt_math_*` externs. This file is being filled in module by module, so it
> documents only what has actually landed. See [CHANGELOG.md](CHANGELOG.md) for
> the full history and the known gaps.

## Loading

```mire
load kioto            // the whole library
load kioto::math      // one module
```

A bare `load kioto` resolves to `src/mod.mr`, which is the file that makes the
library visible. Each module is a directory with its own `owl.toml` and
`mod.mr`.

## math

The math module is written in Mire. There is no `rt_math_*` extern and no
`math.c` in the link, so a program that only needs math still builds and runs
without pulling in a math library.

### Scalars

```mire
math::abs(0.0 - 2.5)      // 2.5
math::sign(0.0 - 3.0)     // -1.0
math::min(1.5 2.5)        // 1.5
math::max(1.5 2.5)        // 2.5
math::clamp(5.0 0.0 1.0)  // 1.0, and 0.0 when the value is below the range
```

### Rounding

Four distinct directions, which only disagree with each other on fractions and
exact halves — that is where they are worth testing.

```mire
math::trunc(3.75)         //  3.0, toward zero
math::trunc(0.0 - 3.75)   // -3.0, not -4.0
math::floor(0.0 - 3.75)   // -4.0
math::ceil(0.0 - 3.75)    // -3.0
math::round(2.5)          //  3.0, ties away from zero
math::round(0.0 - 2.5)    // -3.0
```

NaN and both infinities are returned untouched by all four.

### Lists

The reductions take `vec[i64]` and return `f64`.

```mire
set v = [] :vec[i64] mut
set v = vec::push::i64(v 10)
set v = vec::push::i64(v 20)
set v = vec::push::i64(v 33)

math::sum(v)        // 63.0
math::avg(v)        // 21.0
math::product(v)    // 6600.0
math::minlist(v)    // 10
math::maxlist(v)    // 33
```

`sum`, `avg` and `product` return `f64`; `minlist` and `maxlist` return `i64`,
matching the element type they reduce.

An empty list is not a special case to guard against: `sum` and `avg` are `0.0`,
`product` is `1.0`, and `minlist` and `maxlist` are `0`.

> **Why `vec[i64]` and not `vec[f64]`?** The standard library has no f64
> element support: `vec::get` exists only for `i64` and `str`, so a `vec[f64]`
> signature would not compile. This matches 2.x, where `sum_i64`, `mean`,
> `minlist` and `maxlist` were i64-based and only `fsum` and `prod` were
> genuinely f64. Teaching `mire::vec` about f64 is the prerequisite for
> changing this.

### Constants

```mire
math::consts::pi()        // 3.141592653589793
math::consts::e()         // 2.718281828459045
math::consts::sqrt2()     // 1.4142135623730951
math::consts::phi()       // 1.618033988749895
math::consts::golden()    // 0.618033988749895, the conjugate
math::consts::ln2()       // 0.6931471805599453
math::consts::log2e()     // 1.4426950408889634
math::consts::tau()       // 6.283185307179586
math::consts::epsilon()   // the smallest gap above 1.0
```

The full set is `pi tau e phi golden sqrt2 sqrt3 sqrt5 ln2 ln10 log2e epsilon`.

Every value is the correctly-rounded double nearest the real constant, written
as the shortest decimal that round-trips to those exact bits. A double cannot
hold more than about 17 significant digits, so a longer decimal would only add
noise.

`epsilon` is worth reaching for instead of a hardcoded tolerance when comparing
floats:

```mire
set tol = math::consts::epsilon() * 4.0
if math::abs(measured - expected) > tol { return false }
```

Products of these constants are **not** exact in floating point — `phi * golden`
lands one epsilon above `1.0` — so identity checks need a tolerance rather than
`==`.

### Sequences

```mire
math::seq::range(5)              // [0 1 2 3 4]
math::seq::between(2 6)          // [2 3 4 5]
math::seq::step(0 10 3)          // [0 3 6 9]
math::seq::repeat(7 3)           // [7 7 7]
math::seq::take(v 2)             // the first two elements
math::seq::drop(v 2)             // everything after the first two
```

Every range is half-open: the start is included, the end is excluded. The
direction follows from the arguments rather than from a separate flag, so
`between` counts down when the start is the larger bound:

```mire
math::seq::between(6 2)          // [6 5 4 3], not empty
math::seq::step(10 0 0 - 1)      // [10 9 8 7 6 5 4 3 2 1]
```

A negative stride is therefore a supported walk, not a rejected input — the loop
bound flips to "greater than", so it terminates. Only a zero stride is empty,
because the loop would never advance. A degenerate range always returns an empty
vector rather than raising: these exist to drive loops, and a caller whose
bounds came from arithmetic should not have to guard every call to turn a
miscomputed count into a panic three frames deeper.

`take` and `drop` clamp instead of rejecting, so a negative count gives an empty
vector and a count past the end gives the whole list or nothing, whichever is
being taken or dropped.

## Testing

Kioto's tests are run with the compiler's own runner:

```sh
mire test tests --lib-dir ~/.owl/libs
```

`owl test` works too and gives the same result. It did not for a while: this is
a library declaring `artifact = "shared"`, so the test build produced a shared
object with no test entry point and every file came back `ok` having run no
assertion. Both owl and the compiler now force a test build to be an executable,
so the artifact a package publishes no longer has any say in it. The regression
that pinned this down was a deliberately false assertion with the caches
cleared, which `owl test` reported as `Ok: 16 - Passed: 16`.

One caveat on the count, which is deliberately conservative: a file with several
`@[test]` functions reports all of them as failed when any one fails. A red
suite is never understated, but `Failed: 11` does not mean eleven broken tests.
