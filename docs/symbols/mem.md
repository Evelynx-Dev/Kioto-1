# Memory — symbol reference

How much memory the machine has, and how much of it this process is using.

## `mem`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `mem::total` | `total() :i64` | Physical memory installed on the machine, in bytes. |
| `mem::available` | `available() :i64` | Memory the kernel will hand out without swapping, in bytes. |
| `mem::process` | `process() :i64` | Resident set size of this process, in bytes. Not a cap: the allocation that grows this number is whatever your code asked for. |
