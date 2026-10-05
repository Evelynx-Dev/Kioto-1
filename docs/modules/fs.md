# Files and capabilities

`fs` has two layers, and mixing them up is the only real mistake available.

**Whole-file helpers** take a path and do one thing: `fs::read`, `fs::write`,
`fs::list`, `fs::remove`. Convenient, and they operate wherever the process can
reach.

**Capability handles** take a `Root` and a path *relative to it*. Every access
is resolved inside that root, so nothing outside it can be named. This is the
layer to use when the path comes from somewhere you do not control.

```mire
load kioto::fs
load kioto::strings
load mire::vec

pub fn main: () {
    set home = "/home/evelyn/notes"
    if !fs::exists(home) {
        dasu("nothing at " + home)
        return
    }
    set names = fs::list(home)
    dasu(strings::from::i64(vec::len(names)) + " entries")
}
```

## Whole-file helpers

| Call | Does |
| --- | --- |
| `read(path)` | The whole file as a string |
| `write(path, data)` | Replaces the file, creating it if needed |
| `exists(path)` | Whether anything is at that path |
| `is_file(path)` | Whether it is a regular file rather than a directory |
| `list(path)` | The entries in a directory, excluding `.` and `..` |
| `drop(path)` | Removes a file, reporting success |
| `remove(path)` | Removes a file, reporting success |
| `remove_all(path)` | Removes a directory and everything under it |
| `mkdir(path)` | Creates a directory, reporting success |
| `last_error()` | The code from the most recent failing capability call |

`remove` and `drop` are the same operation under two names; `remove` reads
better next to `remove_all`.

### `read` is a text function

`fs::read` returns a string, and it **stops at the first NUL byte**. A binary
file read this way comes back truncated, silently. For binary content use
`file::read` into a buffer you sized, or `hash::sha256_file` when a digest is
all you need.

### `mkdir` leaves no error code

`mkdir` returns a boolean, and the failure does not reach `last_error`. A
`false` here means "did not happen" and nothing more — not whether it was a
permission problem, a full disk or a path that already existed. If you need
the reason, `file::open::create` through a root reports it.

## Paths

`path::join`, `path::dir`, `path::name`, `path::ext` are string operations, not
filesystem calls; they never touch the disk and never fail.

`join` inserts exactly one separator, and an absolute second argument is
appended rather than honoured — so a join cannot silently escape a root.

## Capabilities

A `Root` is a directory you have opened. Everything resolved through it stays
inside it, and `..` is refused rather than followed.

```mire
load kioto::fs
load kioto::strings
load mire::vec

pub fn main: () {
    set root = fs::root::open("/srv/data")
    set f = fs::file::open::read(root "config/app.toml")
    if f.handle < 0 {
        dasu("cannot open config/app.toml inside /srv/data")
    } else {
        set buf = strings::repeat("\0" 4096) :str mut
        set n = fs::file::read(f buf 4096)
        dasu(strings::substr(buf 0 n))
    }
}
```

Note what is **not** there, because both closes are unreachable.

`file::open::read` takes the `Root` **by value** and `file::read` takes the
`File` **by value**. Each consumes its handle, so:

- `fs::file::close(f)` after a read is a use-after-move error, and
- `fs::root::close(root)` after any `file::open::*` or `dir::open` is
  too — the root is spent the moment you use it.

The capability layer therefore transfers every handle exactly once and has no
reachable way to release a descriptor early. That is a limitation of the
current signatures, not a discipline to learn: `root::close` and `file::close`
compile and are the right calls for a handle you never transferred, but a
handle that has been used cannot be closed at all. Long-running code that
opens many files will accumulate descriptors until the process ends.

Three things about that shape are not negotiable:

- **The buffer is allocated before the read.** `file::read` writes into a
  buffer you provide and does not grow it. `strings::repeat("\0" 4096)` is the
  idiom; an empty string overflows the destination.
- **Handles are closed.** `file::close` and `root::close` release the
  descriptor, and `file::close` consumes the handle, so it cannot be closed
  twice.
- **A negative handle is a failure.** `f.handle < 0` is how you notice, and
  `fs::last_error` is where the reason is.

### Opening modes

`file::open::read`, `::write`, `::create` and `::truncate` differ in what they
do when the file is already there: `read` requires it, `write` requires write
permission, `create` makes it if absent, `truncate` makes it if absent and
empties it if present.

### Directories

`dir::open` takes a root, `dir::next` fills a caller-provided buffer with one
entry name and returns whether there was one, and `dir::close` releases it.
The same preallocation rule applies: the buffer needs room for the longest
entry, and `.` and `..` are not returned.

For a whole listing in one call, `fs::list` is easier and is what most code
should use.

## Removal and symlinks

`remove` unlinks one entry. `remove_all` walks a directory and unlinks
everything under it. Neither follows a symlink: the link itself is removed,
and the file or directory it pointed at is left alone, even if that target is
outside the root.

This is the property that makes removal safe to run on a tree you did not
build. A symlink named `data` pointing at `/etc` removes the link, not `/etc`.

`remove_all` is host-side recursion over `dir::open` and `remove`; the
capability primitive underneath is the single-entry `remove`.

## Failure, in one paragraph

`fs::last_error` returns the code from the most recent failing *capability*
call. It does not describe the whole-file helpers, and `mkdir` does not set
it. Treat a `false` return as the signal and `last_error` as the explanation
where one exists.

## See also

- [Files and directories](../examples/files.md) — worked examples
- [Ownership](../guides/ownership.md) — handles, borrows, and what consumes what
- [`fs` symbol reference](../symbols/fs.md)
