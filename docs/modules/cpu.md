# CPU

One function: how many logical cores the machine has.

```mire
load kioto::cpu
load kioto::strings
load mire::vec

pub fn main: () {
    set n = cpu::count()
    dasu(strings::from::i64(n) + " logical cores")
    if n > 1 {
        dasu("worker count capped at 4: " + strings::from::i64(4))
    } else {
        dasu("single core, running inline")
    }
}
```

`count()` returns **logical** cores, so a machine with SMT reports twice the
physical ones. Use it to size a worker pool against what the scheduler can
actually run in parallel, not against what a single socket contains.

It is a static property of the machine — it does not reflect cgroup limits,
container quotas, CPU affinity, or how much of the machine is busy right now.
A process confined to two of a sixteen-core host still reads 16 here, which is
the case where a worker count derived from it will oversubscribe. When that
matters, cap the pool independently.

Never returns less than 1, and never fails.

## See also

- [Memory](mem.md) — the other resource question before starting work
- [`cpu` symbol reference](../symbols/cpu.md)
