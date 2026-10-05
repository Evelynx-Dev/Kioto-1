# Numbers

`math` is the largest module in the package, and most of that is arithmetic
that would otherwise be written by hand. It splits into a root of elementary
helpers plus seven submodules.

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    dasu(strings::from::f64(math::clamp(12.0 0.0 10.0)))
}
```

## Naming

The root helpers are reached as `math::abs`, and the submodule versions as
`math::float::abs` and `math::int::abs`. `load kioto::math` also exposes the
submodules flattened, so `float::abs` and `int::abs` work as well as the fully
qualified `math::float::abs` — but `math::abs` is the root helper, and it is
not the same function.

**A subdirectory is not a module until it is exported.** `modules/math/`
contains `complex/`, `decimal/`, `power/`, `trig/`, `hyperbolic/` and
`special/`, and each is a placeholder. They are deliberately absent from
`[exports]`, so calling one reports that the function is unknown rather than
reaching an empty namespace. See [Planned
modules](#planned-modules).

## The root helpers

`abs`, `sign`, `min`, `max`, `clamp`, `trunc`, `floor`, `ceil` and `round` on
`f64`; plus `sum`, `avg`, `product`, `minlist` and `maxlist` over a
`vec[i64]`.

Two of these deserve a warning. `min` and `max` **propagate NaN**: if either
argument is NaN the result is NaN, which is the IEEE comparison result and the
only defensible choice for a function whose inputs can be `0.0 / 0.0`. And
`minlist`/`maxlist` are named differently from `min`/`max` on purpose — they
take a list, and overloading one name for two arities reads worse at the call
site.

## `consts` — mathematical constants

```mire
load kioto::math
load kioto::strings

pub fn main: () {
    dasu(strings::from::f64(consts::pi()))
    dasu(strings::from::f64(consts::e()))
    dasu(strings::from::f64(consts::phi()))
}
```

`pi`, `tau`, `e`, `phi`, `golden`, `sqrt2`, `sqrt3`, `sqrt5`, `ln2`, `euler`,
`catalan` and `klein` are zero-argument **functions**, not `cons`. A `cons`
is not readable through a package boundary, so constants that consumers need
are functions; a bare identifier would resolve inside the module and vanish
outside it.

## `int` — integers

`abs`, `sign`, `min`, `max`, `clamp`, `minlist`, `maxlist`, `sum`, `gcd`,
`lcm`, `factorial`, `comb`, `perm`, `isqrt`, `ipow` and `divmod`.

`divmod` returns the pair, and `ipow` is integer exponentiation that stays in
`i64` — the result wraps rather than promoting, so it is for small exponents
only. `isqrt` truncates, and `factorial` of anything above 20 overflows.

## `float` — float helpers

`abs`, `sign`, `min`, `max`, `copysign`, `trunc`, `fract`, `ceil`, `floor`,
`round`, `ulp`, `epsilon`, `integral_magnitude`.

`ulp` is the spacing of representable values at the argument, and `epsilon`
the platform's machine epsilon. Both are the tools for a tolerance that is
justified rather than guessed — the difference matters when you are comparing
values that came out of an iterative method.

`fract` is `x - trunc(x)`, so it keeps the sign of the input. `copysign`
applies the sign of one value to the magnitude of another.

## `seq` — sequences

`range`, `between`, `step`, `repeat`, `take` and `drop`, producing `vec[i64]`.

`step` is where the interesting cases are: a step of zero yields an empty
vector rather than looping forever, and a negative step counts down. `take`
and `drop` are the two halves of slicing, with `drop` skipping and `take`
keeping.

## `sum` — reductions on floats

`fsum`, `prod`, `sumprod` and `dist`.

These are for `f64` lists, where the root `sum` takes `vec[i64]`. `fsum`
accumulates with compensated summation, so summing a long list of values near
each other keeps the significant digits a naive loop would lose — the whole
reason it exists. `sumprod` sums the elementwise product of two lists and
`dist` is the Euclidean distance between them.

Two lists of different lengths: the shorter one bounds the result.

## `stats` — descriptive statistics

`mean`, `median`, `variance`, `stddev`, `mode`, `percentile`, `covariance`
and `corr`.

`median` sorts, so it is `O(n log n)`; `mean` is a single pass. `mode` returns
the most frequent value, and when several tie it returns the first encountered
in iteration order. `percentile` takes a fraction in `0.0`–`1.0`.

`corr` and `covariance` walk both lists to the **shorter** length, and compute
means and deviations over that common prefix — so the result describes the
pairs that exist rather than being skewed by the unmatched tail. A
denominator of zero yields `0.0` rather than NaN, which keeps a degenerate
input from propagating.

```mire
load kioto::math
load kioto::strings
load mire::vec

pub fn main: () {
    set xs = [] :vec[i64] mut
    set ys = [] :vec[i64] mut
    set i = 0 :i64 mut
    while i < 5 {
        set xs = vec::push::i64(xs, i)
        set ys = vec::push::i64(ys, i * 2)
        set i = i + 1
    }
    dasu("mean " + strings::from::f64(stats::mean(xs)))
    dasu("corr " + strings::from::f64(stats::corr(xs ys)))
}
```

## `random` — reproducible randomness

`seed`, `next`, `pick`.

This is a **seeded generator**, distinct from `crypto::random::secure`. Seed it
and the same sequence comes back, which is the point: tests, fixtures and
sampling. For tokens, keys and nonces use `crypto::random::secure`, whose
output is unpredictable instead of reproducible.

`pick` chooses from a `vec[i64]` using a value you supply, which is how a
seeded sequence becomes a repeatable sample.

## Precision, if you are testing this module

The functions that iterate — `power`, `trig`, `hyperbolic`, `special` when they
land — are accurate to about `1e-15` relative. Comparing with `==` will fail on
inputs where the answer is right; compare with a relative tolerance, and size
it with `float::ulp` when the question is really about representation.

## Planned modules

`complex`, `decimal`, `hyperbolic`, `power`, `special` and `trig` exist as
placeholders and are **not exported**. Each will join `[exports]` when it has
functions, so until then a call into one is a plain unknown-function error
rather than a silently empty namespace.

The six are tracked in the module directories themselves, each pointing at a
`todo.md` that states what it will contain.

## See also

- [Arithmetic](../examples/math.md) — worked examples
- [`math` symbol reference](../symbols/math.md)
