# Time — symbol reference

Wall-clock readings and elapsed-time measurement.

## `time`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `time::now` | `now()` | Wall-clock reading, split by unit. Both are the same clock: use ms for measuring and ns when you need to order events inside a millisecond. |
| `time::elapsed` | `elapsed(start :i64) :i64` | Milliseconds between a mark taken earlier and now. The subtraction is in this direction on purpose: pass the earlier value in, get the duration out. |
| `time::mark` | `mark() :i64` | A reading to hand to time::elapsed later. It only exists so the calling code says which of the two ends of the interval it is holding. |

## `time::now`

### `time::now::ms`

```mire
ms() :i64
```

Milliseconds since the Unix epoch.

### `time::now::ns`

```mire
ns() :i64
```

Nanoseconds since the Unix epoch.
