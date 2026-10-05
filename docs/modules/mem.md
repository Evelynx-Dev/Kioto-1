# Memory

Three numbers about the machine, in bytes. They come from the operating
system's view, not from the allocator's.

```mire
load kioto::mem
load kioto::strings

pub fn main: () {
    set mb = (1024 :i64) * 1024
    dasu("system: " + strings::from::i64(mem::total() / mb) + " MiB")
    dasu("free:   " + strings::from::i64(mem::available() / mb) + " MiB")
    dasu("this process: " + strings::from::i64(mem::process() / mb) + " MiB")
}
```

| Call | Returns |
| --- | --- |
| `total()` | Physical memory installed |
| `available()` | Memory that can be handed out without swapping |
| `process()` | This process's resident set |

`available()` is not `total() - used()`. It is what the kernel estimates it can
satisfy right now **without** swapping, so it drops under memory pressure in a
way a subtraction would not show. That is the number to check before deciding
whether to start a large job.

`process()` is the resident set: pages this process actually has, which grows
in steps as memory is touched. It does not shrink the moment memory is freed,
because the allocator keeps it — so a rising-then-flat resident size after a
big allocation is freed is expected, not a leak.

The parentheses in `(1024 :i64) * 1024` are load-bearing. A type ascription
binds tighter than `*`, so `1024 :i64 * 1024` reads as `1024 : (i64 * 1024)`
and the compiler complains about dereferencing a non-reference type.

The readings are snapshots from separate calls, so calling all three in a row
is not a consistent view of one instant. Take one reading, use it, and treat
the others as approximate context.

## What this is not

There is no allocator control here, no trim, no memory limit, and no way to
ask for a specific arena. Memory is the operating system's decision, and this
module only reports it.

## See also

- [Time and measurement](time.md) — the same "measure before concluding" idea
- [`mem` symbol reference](../symbols/mem.md)
