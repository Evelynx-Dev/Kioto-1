# Math — symbol reference

Pure numbers, and the largest surface in the package. The precision contract that governs every assertion here is written down in [the mathematics guide](../modules/math.md).

## `math::consts`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::consts::pi` | `pi() :f64` | Circle constant, half a turn in radians. |
| `math::consts::tau` | `tau() :f64` | Full turn in radians, 2*pi. |
| `math::consts::e` | `e() :f64` | Euler's number, base of the natural logarithm. |
| `math::consts::phi` | `phi() :f64` | Golden ratio, (1 + sqrt(5)) / 2. |
| `math::consts::golden` | `golden() :f64` | Golden ratio conjugate, phi - 1, equal to 1/phi. |
| `math::consts::sqrt2` | `sqrt2() :f64` | Square roots of small integers, handy for normalising a vector without reaching for power::sqrt. |
| `math::consts::sqrt3` | `sqrt3() :f64` | Square root of 3. |
| `math::consts::sqrt5` | `sqrt5() :f64` | Square root of 5. |
| `math::consts::ln2` | `ln2() :f64` | Logarithms and their reciprocals, the natural way to convert bases. |
| `math::consts::ln10` | `ln10() :f64` | Natural log of 10. |
| `math::consts::log2e` | `log2e() :f64` | log2(e), the factor that turns a natural log into a base-2 log. |
| `math::consts::epsilon` | `epsilon() :f64` | The smallest gap between 1.0 and the next representable double. Any difference claimed to be smaller than this is comparing rounding noise. |

## `math::float`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::float::integral_magnitude` | `integral_magnitude(x :f64) :bool` | True when \|x\| is small enough for the power-of-two decomposition to be exact, which is every finite f64 below 2^52. NaN and the infinities fail here, and that is what makes the rounding family hand them back untouched.  Public because it is the gate the rounding family is built on, and a caller implementing its own decomposition needs the same question answered the same way. mod.mr carries a private copy of this predicate: the root tier never calls into a submodule — it is the flat quick tier, self-contained on purpose — so sharing would mean breaking that. The two are meant to agree; change one and change the other. |
| `math::float::abs` | `abs(x :f64) :f64` | Absolute value. NaN compares false against 0 and so comes back unchanged. |
| `math::float::sign` | `sign(x :f64) :f64` | -1.0, 0.0 or 1.0. NaN has no sign, so it reports 0.0. |
| `math::float::min` | `min(a :f64, b :f64) :f64` | Minimum of two values. NaN propagates, matching IEEE minNum's quiet-NaN rule rather than silently picking a side. |
| `math::float::max` | `max(a :f64, b :f64) :f64` | Maximum of two values. NaN propagates. |
| `math::float::copysign` | `copysign(a :f64, b :f64) :f64` | \|a\| carrying the sign of b, so copysign(1.0, -0.0) is -1.0 and not 1.0. |
| `math::float::trunc` | `trunc(x :f64) :f64` | Drop the fractional part, rounding toward zero. |
| `math::float::fract` | `fract(x :f64) :f64` | Fractional part, x - trunc(x). Keeps the sign of x, so fract(-2.5) is -0.5. |
| `math::float::ceil` | `ceil(x :f64) :f64` | Smallest integer not less than x. |
| `math::float::floor` | `floor(x :f64) :f64` | Largest integer not greater than x. |
| `math::float::round` | `round(x :f64) :f64` | Nearest integer, halves away from zero: round(2.5) is 3, round(-2.5) is -3. This is not banker's rounding, and the difference is deliberate and observable at every .5. |
| `math::float::isNan` | `isNan(x :f64) :bool` | Not a number. True for the only value that is not equal to itself, which is why the test is written as x != x and not as a comparison. |
| `math::float::isInf` | `isInf(x :f64) :bool` | Infinite, of either sign. Comparing against 1.0/0.0 works because dividing by zero is the one operation IEEE 754 requires to produce an infinity. |
| `math::float::isFinite` | `isFinite(x :f64) :bool` | Neither NaN nor infinite: the question worth asking before a division. |
| `math::float::isNormal` | `isNormal(x :f64) :bool` | A normal number is finite, non-zero, and not subnormal: its magnitude is at least 2^-1022, so it carries a full 53 bits of precision. |
| `math::float::isSubnormal` | `isSubnormal(x :f64) :bool` | Subnormal: finite, non-zero, and smaller than the smallest normal. The leading bits of the significand are zero, so precision degrades towards zero. |
| `math::float::ulp` | `ulp(x :f64) :f64` | Gap between x and its neighbour, 2^(e - 52) where e is the exponent of x. NaN reports NaN, the infinities report Inf, and 0.0 reports the smallest subnormal, which is the true gap there. |
| `math::float::toBits` | `toBits(x :f64) :i64` | Raw IEEE-754 bit pattern of x, as the i64 that holds it. The inverse of fromBits, and exact for every input including NaN and the infinities, because it reinterprets rather than converts.  This is the escape hatch from the arithmetic above: hashing a float, seeding a PRNG from one, or writing a float to a file byte-for-byte all need the bits, and going through the round trip would lose NaN payloads and turn -0.0 into 0.0. |
| `math::float::fromBits` | `fromBits(b :i64) :f64` | The f64 whose bit pattern is b. Exact inverse of toBits. |
| `math::float::epsilon` | `epsilon() :f64` | The machine epsilon, 2^-52: the smallest gap between 1.0 and the next representable double. Written in scientific notation because that is what the value is; the same number as math::consts::epsilon. |

## `math::int`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::int::abs` | `abs(n :i64) :i64` | Absolute value. i64::MIN has no positive counterpart and so returns itself. |
| `math::int::sign` | `sign(n :i64) :i64` | -1, 0 or 1. |
| `math::int::min` | `min(a :i64, b :i64) :i64` | The smaller of two integers. |
| `math::int::max` | `max(a :i64, b :i64) :i64` | The larger of two integers. |
| `math::int::clamp` | `clamp(x :i64, lo :i64, hi :i64) :i64` | Constrain x to [lo, hi], which is min(max(x, lo), hi). The reversed case is settled first because an empty range has no x inside it: the standard expression folds to hi, and the step-at-a-time version below would otherwise reach the lo test first and hand back lo instead. |
| `math::int::minlist` | `minlist(list :&vec[i64]) :i64` | Smallest element, or 0 for an empty list. |
| `math::int::maxlist` | `maxlist(list :&vec[i64]) :i64` | Largest element, or 0 for an empty list. |
| `math::int::sum` | `sum(list :&vec[i64]) :i64` | Sum of the elements. An empty list sums to 0. |
| `math::int::gcd` | `gcd(a :i64, b :i64) :i64` | Greatest common divisor by Euclid's algorithm. Always non-negative, because both operands are reduced to their magnitudes first. |
| `math::int::lcm` | `lcm(a :i64, b :i64) :i64` | Least common multiple. 0 when either operand is 0, which keeps the identity lcm(0, n) = 0 rather than reporting a number built on a division by zero. |
| `math::int::factorial` | `factorial(n :i64) :i64` | Factorial, n!. Returns 1 for n <= 1. Wraps past 20!. |
| `math::int::comb` | `comb(n :i64, k :i64) :i64` | Binomial coefficient C(n, k), built from the smaller half so it takes k steps rather than n. 0 for k < 0 or k > n. |
| `math::int::perm` | `perm(n :i64, k :i64) :i64` | Permutations P(n, k) = n! / (n-k)!. 0 for k < 0 or k > n. |
| `math::int::isqrt` | `isqrt(n :i64) :i64` | Integer square root, floor(sqrt(n)). -1 marks a negative input, which has no real square root to floor.  Two overflow traps have to be stepped around. The midpoint is lo + (hi - lo) / 2 rather than (lo + hi) / 2, so it cannot leave the range. And the square is tested as mid <= n / mid rather than mid * mid <= n, so the comparison stays exact for every i64 instead of overflowing on the first probe of a large n. mid is never 0, so that division is always defined. |
| `math::int::ipow` | `ipow(base :i64, exp :i64) :i64` | Integer exponentiation by squaring. A negative exponent has no integer result and reports 0. base * base overflows once the base grows past 2^31, so the caller owns the range check: any (base, exp) whose true value exceeds i64 wraps. |
| `math::int::divmod` | `divmod(a :i64, b :i64) :vec[i64]` | Quotient and remainder as the two-element vector [q, r], so the pair survives the return without a tuple type. Division by zero reports [0, 0] rather than trapping, matching lcm's choice to define the degenerate case. |
| `math::int::isPrime` | `isPrime(n :i64) :bool` | Primality by trial division over 6k-1, which is exact for every i64 and needs no 128-bit intermediate.  The walk stops on f <= n / f rather than f * f <= n. The two agree for every f, but the product leaves the range as soon as f passes 3037000499, which the walk does on its way to the end of a large n. Dividing keeps the comparison exact for all of i64. f is never 0, so the division is always defined.  Miller-Rabin would be faster but cannot be made correct here without a double-width product, and the base sets that are deterministic over all of i64 need exactly that. Correctness wins over speed in this tier. |
| `math::int::primeFactors` | `primeFactors(n :i64) :vec[i64]` | Prime factors in ascending order, with multiplicity. An empty vector for n <= 1, which has no prime decomposition. Uses the same 6k-1 walk as isPrime so the two agree on every input, and the same division-based bound check so neither of them overflows on a large input. |

## `math`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::abs` | `abs(x :f64) :f64` | Absolute value. NaN compares false against 0 and so is returned unchanged. |
| `math::sign` | `sign(x :f64) :f64` | -1.0, 0.0 or 1.0. NaN has no sign, so it reports 0.0. |
| `math::min` | `min(a :f64, b :f64) :f64` | The smaller of two floats, NaN-propagating: if either argument is NaN the answer is NaN rather than the other number, so a NaN cannot be silently dropped by a min over a list. |
| `math::max` | `max(a :f64, b :f64) :f64` | The larger of two floats, NaN-propagating in the same way as math::min. |
| `math::clamp` | `clamp(x :f64, lo :f64, hi :f64) :f64` | Constrain x to [lo, hi]. A reversed range collapses to hi, matching the behaviour of clamping against an inverted pair. |
| `math::trunc` | `trunc(x :f64) :f64` | Drop the fractional part, rounding toward zero. |
| `math::floor` | `floor(x :f64) :f64` | Largest integer not greater than x. |
| `math::ceil` | `ceil(x :f64) :f64` | Smallest integer not less than x. |
| `math::round` | `round(x :f64) :f64` | Nearest integer, halves away from zero (round(2.5) = 3, round(-2.5) = -3). |
| `math::sum` | `sum(list :&vec[i64]) :f64` | Sum of the elements, accumulated in f64. |
| `math::avg` | `avg(list :&vec[i64]) :f64` | Arithmetic mean. An empty list has no mean, so it reports 0.0. |
| `math::product` | `product(list :&vec[i64]) :f64` | Product of the elements. An empty list is the multiplicative identity. |
| `math::minlist` | `minlist(list :&vec[i64]) :i64` | Smallest element, or 0 for an empty list. |
| `math::maxlist` | `maxlist(list :&vec[i64]) :i64` | Largest element, or 0 for an empty list. |

## `math::power`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::power::sqrt` | `sqrt(x :f64) :f64` | The square root, to the Binary64 floor.  Newton on x^2, g <- (g + a/g)/2, which doubles the correct digits per pass, so six passes from a 1e-2 seed is enough to stop moving. A negative argument has no real square root and returns NaN. |
| `math::power::cbrt` | `cbrt(x :f64) :f64` | The real cube root, including for a negative argument.  The scale is by eight rather than by four, and that is arithmetic rather than taste: undoing a scale of 4^e means taking 4^(e/3), which is 2^(2e/3) and not an integer power of two, so it cannot be applied exactly. Undoing 8^e means taking 8^(e/3), which is exactly 2^e. The refinement is Halley on g^3 = a, g <- g*(g^3 + 2a)/(2g^3 + a), which triples the correct digits per pass instead of doubling them. The mantissa stays in [1,8), so g^3 cannot overflow. |
| `math::power::exp` | `exp(x :f64) :f64` | e raised to x.  The argument is reduced as x = k*ln2 + r with r below ln2/2, so the series never sees more than 0.3466. The k*ln2 product is the entire error budget, and ln2 is split high/low so both products are exact and both subtractions land on the small remainder; folding them into x - (k*ln2Hi + k*ln2Lo) instead would round the bracket at the magnitude of ln2 and hand back an error of 1e-13 that grows with k. Past the overflow point the result is an infinity, and past the underflow point a signed zero, because those are the answers a real exp gives. |
| `math::power::exp2` | `exp2(x :f64) :f64` | Two raised to x.  The reduction is by two rather than by ln2, so x = k + r with r in [0,1). The gain over exp is exactness at the integers: for a whole-number x the remainder is zero, the series sums to exactly 1.0, and the answer is 2^k with no error at all. A program that raises two to a loop counter gets an exact answer every time. |
| `math::power::expm1` | `expm1(x :f64) :f64` | e raised to x, minus one.  This is a function rather than a subtraction because the subtraction loses. At x = 1e-10 the exact answer is 1.00000000005e-10 while exp(x) is 1.0000000001 to within half an ulp, so exp(x) - 1 cancels away every significant digit and returns 6 correct digits out of 16. Below 0.5 the series is summed directly, where no term is larger than the whole and no cancellation is possible. Above 0.5 there is nothing to protect. The sign of a zero argument is preserved, so expm1(-0.0) is -0.0. |
| `math::power::log` | `log(x :f64) :f64` | The natural logarithm.  x is split as 2^k * m with m in [sqrt(0.5), sqrt(2)), so t = (m-1)/(m+1) is at most 0.1716 and the atanh series converges on it quickly. The k*ln2 part is Cody-Waite split, so a logarithm of a very large or very small number does not pay for the magnitude of k in the rounding of one product. Zero and the negatives return -infinity and NaN. |
| `math::power::log2` | `log2(x :f64) :f64` | The base-2 logarithm.  The same split as log, and it earns its keep a second time: for a power of two the mantissa is exactly 0.5, t is exactly zero, the series returns exactly zero, and the answer is exactly the integer k. log2(1024.0) is 10.0 with no tolerance involved. The reciprocal in the series is only ever applied to a quantity below 0.35, so its own 1e-16 relative error stays an absolute 3.5e-17 and does not grow with the magnitude of the result. |
| `math::power::log10` | `log10(x :f64) :f64` | The base-10 logarithm.  The same construction as log, with the constant that belongs to the base. The reduction is still written in base two, so the constant is log10(2) and not ln10: log10(x) is k*log10(2) plus a small correction, never k*ln10 plus one. It is split high/low for the same reason ln2 is, and without that split the base-10 logarithm of 1e300 would be wrong in the fourteenth digit for no reason other than the rounding of a single large product. |
| `math::power::log1p` | `log1p(x :f64) :f64` | The natural logarithm of one plus x, for x above minus one.  The same cancellation that motivates expm1 applies here: log(1 + 1e-10) written the obvious way loses every digit, because 1 + 1e-10 is exactly 1.0 in Binary64. The identity log(1+x) = 2*atanh(x/(2+x)) removes the special case, because its argument is x/2 for small x and so never sits near one. Past \|x\| = 0.29 the argument approaches one and the series slows down, so that end defers to log(1+x), where the cancellation is mild. A subnormal argument returns itself. At x = -1 the answer is -infinity. |
| `math::power::pow` | `pow(x :f64, y :f64) :f64` | x raised to y.  For a positive x the answer is 2^(y*log2(x)), and both halves are this module's own: log2 is exact at the powers of two and exp2 is exact at the integers, so pow(2, 10) and pow(10, 2) are both exact. Three cases do better than the general path and are worth the branches: a whole-number y goes through repeated squaring, which is exact for every integer result below 2^53; a negative x has no real answer for a fractional y, which returns NaN, while the whole-number case carries the sign of an odd y; and y equal to 0.5 is routed to sqrt rather than recomputed. pow(-0.5, -0.0) is +infinity and pow(-0.0, -0.0) is 1.0, which is C99 7.12.22.  This is the one entry point here that does not hold 1e-15, and the reason is conditioning rather than the implementation: y*log2(x) is a single product already carrying about 1e-16 of rounding, and raising it to a large exponent multiplies that by n, so the relative error grows like n. At pow(0.001, 64) the floor is genuinely near 2e-15. Across a 591 case sweep the other ten entry points all stayed under 1e-15, worst case 6.2e-16. |
| `math::power::hypot` | `hypot(a :f64, b :f64) :f64` | The square root of a squared plus b squared.  Written naively, hypot(1e200, 1e200) overflows the square to an infinity and hypot(1e-200, 1e-200) underflows it to a zero, and both answers are wrong by an infinite factor. So the larger argument is factored out first, the squares are taken of numbers inside [0,1], and the factor is restored by an exact scaling. The final rescaling is exact only when the ratio is: hypot(3, 4) is exactly 5.0 because 3/4 is representable, but hypot(5, 12) returns 13.000000000000002, one ulp out, because 5/12 is not representable and the rounded ratio is already wrong before it is squared. A correctly rounded hypot would need a final correction step; this one reports the formulation's own error rather than hiding it. |

## `math::random`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::random::seed` | `seed(s :i64)` | Restart the generator from s. The same seed always replays the same sequence, which is the property tests and simulations depend on.  A zero seed is remapped to 1: xorshift128 is a linear generator over GF(2) and the all-zero state is its single fixed point, so seeding with 0 would emit nothing but zeroes for the rest of the process. |
| `math::random::next` | `next() :i64` | Next 31-bit word, in [0, 2^31). |
| `math::random::nextInt` | `nextInt(bound :i64) :i64` | Uniform value in [0, bound). 0 when bound <= 0, so the degenerate bound does not trap in a loop that cannot terminate.  Unbiased: neither 2^31 nor 2^62 is a multiple of an arbitrary bound, so taking a plain remainder would over-represent the low end. Instead the largest multiple of bound that fits in the domain is computed and any draw at or above it is thrown away and redrawn, which leaves every residue equally likely.  One word covers a bound up to 2^31. Above that the domain is widened to 2^62 from two words, so a bound in (2^31, 2^62] is served exactly. A bound past 2^62 has no representable domain to reject within and reports 0. |
| `math::random::nextFloat` | `nextFloat() :f64` | Uniform value in [0, 1), built from two words so the low 31 bits of the result are filled in rather than left as zeros. That keeps the mantissa full width instead of handing back a float that only has 31 bits of entropy. |
| `math::random::pick` | `pick(v :&vec[i64]) :i64` | Uniform choice of one element of v, by value. An empty list has no element to pick and reports 0, which is the same degenerate answer nextInt gives for a bound of 0. |

## `math::seq`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::seq::range` | `range(end :i64) :vec[i64]` | [0, end) counting up. range(0) and any negative end are empty. |
| `math::seq::between` | `between(start :i64, end :i64) :vec[i64]` | [start, end) counting up when start <= end, and [start, end) counting down when start > end. So between(2 6) is [2 3 4 5] and between(6 2) is [6 5 4 3] — the start is always included and the end always excluded, only the direction depends on which bound is larger. |
| `math::seq::step` | `step(start :i64, end :i64, n :i64) :vec[i64]` | start, start + n, start + 2n, ... up to but not including end when n is positive, and down to but not including end when it is negative. A zero stride is empty. step(0 10 3) is [0 3 6 9] and step(10 0 0 -1) is [10 9 8 7 6 5 4 3 2 1]. |
| `math::seq::repeat` | `repeat(value :i64, count :i64) :vec[i64]` | A vector of `count` copies of `value`. New in 3.0 — v2 had no counterpart — and the generalisation the three above could have been written in terms of. |
| `math::seq::take` | `take(list :&vec[i64], n :i64) :vec[i64]` | The first n elements. New in 3.0. n is clamped into range rather than rejected, matching what rt_list_slice already does underneath: a negative n gives an empty vector and an n past the end gives the whole list, which is what a caller trimming an optional prefix actually wants. |
| `math::seq::drop` | `drop(list :&vec[i64], n :i64) :vec[i64]` | Everything after the first n elements, clamped the same way as take, so drop 0 is a copy of the list and drop of at least the length is empty. New in 3.0. |

## `math::stats`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::stats::mean` | `mean(list :&vec[i64]) :f64` | The arithmetic mean, the total over the count. An empty list has no mean, and returns 0.0. |
| `math::stats::median` | `median(list :&vec[i64]) :f64` | The middle observation. An even count has two middles, and they are averaged, so the median of a list of two is their midpoint rather than either of them.  The list is sorted first, on a copy. Sorting in place would reorder the caller's data to answer a question about it, and the surprise would land in whatever code ran next rather than here. |
| `math::stats::variance` | `variance(list :&vec[i64]) :f64` | The population variance: the mean squared deviation from the mean, over n.  This divides by n, not by n-1. The n-1 form is the unbiased estimator for a sample, and it is a different statistic, not a better one. Choosing it here would make the number disagree with the definition it is named after, and with the root tier's helpers it sits beside. A caller who wants the sample estimate scales by n/(n-1) themselves, which keeps the decision visible in their code. |
| `math::stats::stddev` | `stddev(list :&vec[i64]) :f64` | The population standard deviation, the square root of the variance.  The square root is taken once, at the end, rather than on every term. The variance already carries the only rounding that matters; rooting each deviation separately and squaring it back would add error and buy nothing. |
| `math::stats::mode` | `mode(list :&vec[i64]) :i64` | The most frequent value. Ties go to the smallest of the tied values, so the answer is a function of the data and not of the order the counts happened to accumulate in.  The counting is the obvious nested loop, one pass per candidate. That is quadratic, and it is left that way on purpose: a hash map keyed on the observations would be faster and would make the tie rule depend on a hash order that is not part of any contract. The lists this runs on are the ones people read and eyeball. |
| `math::stats::minVal` | `minVal(list :&vec[i64]) :i64` | The smallest observation, or 0 for an empty list. |
| `math::stats::maxVal` | `maxVal(list :&vec[i64]) :i64` | The largest observation, or 0 for an empty list. |
| `math::stats::percentile` | `percentile(list :&vec[i64], p :f64) :f64` | The value below which p percent of the observations fall, with p in [0, 100].  The order statistics are interpolated rather than snapped, so p = 50 on a two element list is the midpoint of the two, which is what median returns and what every table of percentiles in common use reports. p outside [0, 100] is clamped to the ends instead of rejected: a percentile of 0 is the minimum, and a caller computing one from a ratio should not have to range check first. |
| `math::stats::covariance` | `covariance(x :&vec[i64], y :&vec[i64]) :f64` | How far the two lists move together: the mean of the products of their deviations, over the shorter of the two.  A positive result means the lists rise and fall together, zero that they do not track, and negative that one rises as the other falls. The scale is whatever the data is measured in, which is why the correlation below exists. |
| `math::stats::corr` | `corr(x :&vec[i64], y :&vec[i64]) :f64` | The Pearson correlation of the two lists: covariance divided by the product of their standard deviations, which lands in [-1, 1] and says how tightly the two move together without carrying their units.  A list that never varies has no spread to divide by, and the coefficient is undefined rather than infinite. That case returns 0.0, meaning "no measurable relationship" — the same answer as two unrelated lists, which is as close as this signature can say. |

## `math::sum`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `math::sum::fsum` | `fsum(list :&vec[f64]) :f64` | The compensated sum: exact to the last bit, for any input order. |
| `math::sum::prod` | `prod(list :&vec[f64], start :f64) :f64` | start multiplied by every element, left to right. |
| `math::sum::sumprod` | `sumprod(p :&vec[f64], q :&vec[f64]) :f64` | The dot product, over the shorter of the two lists. |
| `math::sum::dist` | `dist(p :&vec[f64], q :&vec[f64]) :f64` | The Euclidean distance, over the shorter of the two lists. |
