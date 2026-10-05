# Filesystem — symbol reference

Two layers: whole-file helpers that take a path, and capability handles that resolve every path inside a root. Removal never follows a symlink, and never leaves the root.

## `fs`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `fs::exists` | `exists(path :&str) :bool` | Whether anything exists at path, of any kind. False for a path whose parent does not exist, and false for a dangling symlink. |
| `fs::is_file` | `is_file(path :&str) :bool` | Whether path is a regular file. Directories and symlinks are false; use fs::exists for the any-kind question. |
| `fs::read` | `read(path :&str) :str` | The whole file as a string, or the empty string when it cannot be read. The result is NUL-terminated like every other Mire string, so a file that contains a NUL byte reads back truncated at that byte: this is a text reader, and binary data belongs in crypto or a file::read loop. |
| `fs::write` | `write(path :&str, data :&str)` | Writes data to path, creating it and truncating whatever was there. The value is borrowed, not moved, so the caller keeps its string. There is no append variant at this level; open a file and seek to the end for that. |
| `fs::drop` | `drop(path :&str) :bool` | Unlinks a single file. For anything recursive, or to remove a directory at all, use fs::remove and fs::remove_all, which report a proper error code. |
| `fs::remove` | `remove(path :&str) :bool` | Remove a single entry (file, symlink, or empty directory). A symlink is unlinked — never followed — even when it points outside the path's parent. Returns false and leaves fs::last_error() set to the PAL error code (PAL_ERR_NOT_EMPTY for a non-empty directory). |
| `fs::remove_all` | `remove_all(path :&str) :bool` | Recursively remove a file, symlink, or directory tree. Intermediate and trailing symlinks are never followed (the sandbox rejects them); a symlink inside the tree is deleted without entering its target. |
| `fs::last_error` | `last_error() :i64` | Last PAL error code from a failed fs operation (see PAL_ERR_* above). Read immediately after a failed call; 0 (PAL_ERR_OK) means no error. |
| `fs::list` | `list(path :&str) :vec[str]` | The names of the entries in a directory, excluding "." and "..". Names come back in whatever order the filesystem reports, so sort them if order matters. An unreadable directory yields an empty vector rather than an error; check fs::exists first if the difference matters. |
| `fs::mkdir` | `mkdir(path :&str) :bool` | Creates exactly one directory, which means false for two different reasons: the parent does not exist, or the directory already does. There is no -p and no already-exists tolerance, because a silent recursive mkdir hides the mistake that caused the missing parent. Note also that a false result leaves fs::last_error() at PAL_ERR_OK, so there is no code telling the two apart. Write a test before relying on either. |
| `fs::path` | `path()` | ── path ──────────────────────────────────────────────────────── |
| `fs::dir` | `dir()` | ── dir ───────────────────────────────────────────────────────── |
| `fs::root` | `root()` | ── root ──────────────────────────────────────────────────────── |
| `fs::permission` | `permission(path :str mode :str) :bool` | ── permissions ─────────────────────────────────────────────────── Changes a path's mode, chmod style: mode is a string such as "755". |
| `fs::file` | `file()` | ── file ──────────────────────────────────────────────────────── The four ways to open a file, kept as one group so the flag combinations read together instead of being four bare functions with a shared comment. |

## `fs::path`

### `fs::path::join`

```mire
join(a :&str, b :&str) :&str
```

Joins two path fragments with a single separator, adding one only when the first part does not already end in one. An absolute second part is appended, not honoured, so join never escapes the root on its own.

### `fs::path::dir`

```mire
dir(path :&str) :&str
```

The directory part of a path, or "." when there is no separator. The separator itself is not included.

### `fs::path::name`

```mire
name(path :&str) :&str
```

The last component of a path, separators not included.

### `fs::path::ext`

```mire
ext(path :&str) :&str
```

The extension of the last component, dot included, or the empty string when there is none. A leading dot is not an extension: ".gitignore" has none.

## `fs::dir`

### `fs::dir::create`

```mire
create(path :&str) :bool
```

One directory, same rules and same silence as fs::mkdir. fs::dir::create exists so that the family of operations on a directory reads together.

### `fs::dir::remove`

```mire
remove(path :&str) :bool
```

Removes an empty directory. A directory with entries in it fails.

### `fs::dir::open`

```mire
open(root :Root, path :&str) :Dir
```

Opens a directory under a root, for iteration with fs::dir::next.

### `fs::dir::next`

```mire
next(d :Dir, entry :&mut str) :bool
```

Advances the iterator and writes the next entry name into entry, which must already hold room for 256 bytes: strings::repeat("\0" 256) is the shape to use. False once the directory is exhausted.

### `fs::dir::close`

```mire
close(d :Dir)
```

Releases the directory handle. Exhausting the iterator does not do it.

## `fs::root`

### `fs::root::open`

```mire
open(path :&str) :Root
```

Opens a directory as a capability root. Every later path is resolved inside it, which is what keeps a path built from user input inside the sandbox.

### `fs::root::close`

```mire
close(root :Root)
```

Releases the root handle.

## `fs::file`

### `fs::file::open`

```mire
open()
```

── file ──────────────────────────────────────────────────────── The four ways to open a file, kept as one group so the flag combinations read together instead of being four bare functions with a shared comment.

### `fs::file::read`

```mire
read(file :File, buf :&mut str, max_len :i64) :i64
```

Reads up to max_len bytes into buf and returns how many arrived. buf must have that much room, for the same reason as fs::dir::next.

### `fs::file::write`

```mire
write(file :File, data :&str) :i64
```

Writes the whole string and returns the byte count written.

### `fs::file::seek`

```mire
seek(file :File, offset :i64, whence :i32) :i64
```

Moves the position and returns the new absolute offset. whence is one of the PAL_SEEK_* constants.

### `fs::file::size`

```mire
size(file :File) :i64
```

Current size in bytes. For a file open for writing this is the size now, which is not the size after the last write is flushed.

### `fs::file::close`

```mire
close(file :File)
```

Closes the file and releases the descriptor.

## `fs::file::open`

### `fs::file::open::read`

```mire
read(root :Root, path :&str) :File
```

Opens for reading, positioned at the start. The flags are the PAL_OPEN_* constants, combined with + when more than one applies.

### `fs::file::open::write`

```mire
write(root :Root, path :&str) :File
```

Opens for writing without truncating, so an existing longer file keeps its tail and whatever you write past the old end.

### `fs::file::open::create`

```mire
create(root :Root, path :&str) :File
```

Opens for writing, creating the file if it is missing and leaving it alone if it is not.

### `fs::file::open::truncate`

```mire
truncate(root :Root, path :&str) :File
```

Opens for writing and empties the file first.
