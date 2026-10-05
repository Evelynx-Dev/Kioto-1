# Files and directories

Reading, writing, listing and removing — and the two rules that are the same
rule in `fs`, `async` and `net`: **allocate the buffer first**, and **a value
moves when you pass it**.

## Reading a file

```mire
load kioto::fs
load kioto::strings

pub fn main: () {
    set path = "/etc/hostname"
    if !fs::exists(path) {
        dasu("no such file: " + path)
        return
    }
    set text = fs::read(path)
    dasu("hostname is " + strings::trim(text))
}
```

`fs::read` takes the path by reference, so `path` is still usable on the next
line. Without the `&` in the signature, passing it would have moved it.

## Writing, and not clobbering

```mire
load kioto::fs
load kioto::strings

pub fn main: () {
    set out = "/tmp/kioto-demo.txt"
    if fs::exists(out) {
        dasu("refusing to overwrite " + out)
        return
    }
    fs::write(out "written by kioto\n")
    set size = strings::len(fs::read(out))
    dasu("wrote " + strings::from::i64(size) + " bytes")
}
```

`fs::write` takes both arguments by reference. The existence check above is not
something the API does for you: `write` replaces whatever is there, including
nothing.

## Listing a directory

```mire
load kioto::fs
load kioto::strings
load mire::vec

pub fn main: () {
    set names = fs::list("/etc")
    set n = vec::len(names)
    set i = 0 :i64 mut
    while i < n {
        dasu("  " + vec::get::str(names i))
        set i = i + 1
    }
    dasu(strings::from::i64(n) + " entries")
}
```

`fs::list` excludes `.` and `..`, so the count is entries, not entries plus
two. `vec::get::str` borrows, which is why `names` survives the loop.

The entries come back in whatever order the filesystem reports, which is not
sorted. If order matters, sort the vector.

## Removal

```mire
load kioto::fs
load kioto::strings

pub fn main: () {
    set work = "/tmp/kioto-demo"
    fs::mkdir(work)
    fs::write(work + "/a.txt" "one")
    fs::write(work + "/b.txt" "two")

    if fs::remove_all(work) {
        dasu("removed " + work)
    } else {
        dasu("could not remove " + work + "; code " + strings::from::i64(fs::last_error()))
    }
    dasu("still there? " + strings::from::bool(fs::exists(work)))
}
```

`remove_all` recurses, and neither `remove` nor `remove_all` ever follows a
symlink — a link inside `work` would be unlinked and its target left alone.
That is what makes this safe on a directory you did not create.

`fs::mkdir` does not create parents, so `/tmp/a/b` needs `/tmp/a` to exist
first. It also does not set `last_error`, so a `false` from it has no
explanation available.

## Capabilities

For a path that came from outside the program, open a root and resolve inside
it. `..` is refused, so nothing outside can be named.

```mire
load kioto::fs
load kioto::strings
load mire::vec

pub fn main: () {
    set root = fs::root::open("/srv/data")
    set names = fs::list("/srv/data")
    set i = 0 :i64 mut
    while i < vec::len(names) {
        set entry = vec::get::str(names i)
        dasu("data: " + entry)
        set i = i + 1
    }
    dasu("root handle " + strings::from::i64(root.handle))
}
```

**The root is spent by its first use.** `fs::file::open::*` and `fs::dir::open`
take the `Root` by value, so `fs::root::close(root)` after opening anything
through it is a use-after-move error. The same applies to a `File`: reading it
consumes the handle, so `file::close` afterwards is unreachable. Handles are
released when the process ends, not by a close you can still reach.

## Reading bytes with a sized buffer

For binary content, `fs::read` is the wrong tool — it stops at the first NUL
and returns a shorter string with no error.

```mire
load kioto::fs
load kioto::crypto
load kioto::strings

pub fn main: () {
    set path = "/tmp/kioto-demo.bin"
    fs::write(path "abc")
    set digest = crypto::hash::sha256_file(path)
    dasu("sha256 " + digest)
}
```

`hash::sha256_file` reads the file without stopping at NUL, so it is the
right way to digest binary content. To get the bytes themselves through a
capability, `fs::file::read` writes into a buffer you sized:

```mire
set buf = strings::repeat("\0" 4096) :str mut
set n = fs::file::read(f buf 4096)
```

The allocation and the length must agree, or it is a heap overflow rather than
a caught error.

## See also

- [Files and capabilities](../modules/fs.md) — the full API
- [Ownership](../guides/ownership.md) — why `root::close` is unreachable
- [Security](../guides/security.md) — symlink safety in detail
