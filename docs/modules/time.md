# Time and measurement

Four functions. What matters is the pairing: `now` for a wall clock, `mark` and
`elapsed` for a stopwatch.

```mire
load kioto::math
load kioto::strings
load kioto::time

pub fn main: () {
    dasu("wall clock: " + strings::from::i64(time::now::ms()) + " ms since the epoch")

    set start = time::mark()
    set acc = 0.0 :f64 mut
    set i = 0 :i64 mut
    while i < 2000000 {
        set acc = acc + 1.5
        set i = i + 1
    }
    dasu("elapsed: " + strings::from::i64(time::elapsed(start)) + " ms")
    dasu("accumulated: " + strings::from::f64(acc))
}
```

| Call | Returns |
| --- | --- |
| `now::ms()` | Wall clock, milliseconds since the Unix epoch |
| `now::ns()` | Wall clock, nanoseconds since the Unix epoch |
| `elapsed(start)` | Milliseconds since the `start` value |
| `mark()` | A reading for `elapsed` to measure against |

`mark` returns the same unit `elapsed` consumes, which is what makes the pair
work; `now` is for timestamps in output and in records, and should not be
mixed into a duration because the wall clock can move underneath a measurement
— a clock adjustment mid-run produces a negative elapsed time.

**The accumulator has to be used.** A loop the compiler can see is dead gets
optimised away, so a benchmark that computes and discards measures nothing.
Binding the result and printing it, or returning it, is what keeps the work
real; that is why the example above prints `acc`.

Two syntax notes from that snippet. The accumulator is declared `:f64 mut` on
its first `set` — a `f64` that is reassigned in a loop needs the annotation,
and the error for a missing one is a misleading "not mutable" rather than
anything about the type. And there is no `float(x)` conversion function:
`float` is the [`float` submodule](math.md#float--float-helpers) namespace, so
calling it as a function is a different thing entirely.

Nanosecond readings are a resolution, not an accuracy: the underlying clock
typically updates far less often than that, so a long series of `now::ns`
differences will show steps, not a smooth ramp. Measuring a block once and
dividing is more honest than timing a loop of tiny operations.

## See also

- [Numbers](math.md) — the arithmetic in a benchmark loop
- [`time` symbol reference](../symbols/time.md)
