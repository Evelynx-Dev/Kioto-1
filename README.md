# kioto — Mire standard library

Version **2.4.4** — [CHANGELOG](CHANGELOG.md)

Kioto is the core library for the Mire language ecosystem.
Load the full library with `load kioto`, or load individual modules
by path (e.g. `load kioto::strings`).

> **Collections live in `mire`** — kioto does not provide `lists`/`dicts`
> modules anymore. Dynamic vectors and string-keyed maps are provided by the
> language's standard library: `load mire::vec` and `load mire::map`.

---

## Module map

| Module | What it provides |
|--------|------------------|
| `strings` | String manipulation and conversion |
| `time` | Host time queries |
| `fs` | Filesystem I/O through PAL v4 handles |
| `env` | Environment access |
| `proc` | Process creation and management |
| `async` | Channels and task/future primitives |
| `mem` | System memory queries |
| `cpu` | CPU count |
| `math` | Arithmetic, statistics, complex, decimal, random |
| `net` | TCP sockets and listeners |
| `log` | Logging with formatted output |
| `cli` | Command-line argument parsing |
| `crypto` | Hashing, encoding, random, Ed25519 signatures |

---

## strings

String manipulation. All functions take `&str` borrows and return owned values.

| Function | Returns | Description |
|----------|---------|-------------|
| `len(s)` | `i64` | Length in bytes |
| `upper(s)` | `str` | To uppercase |
| `lower(s)` | `str` | To lowercase |
| `trim(s)` | `str` | Strip whitespace both sides |
| `strip(s)` | `str` | Strip leading/trailing whitespace |
| `contains(s, sub)` | `bool` | Check if substring exists |
| `index(s, sub)` | `i64` | First index of substring (-1 if not found) |
| `split(s, sep)` | `vec[str]` | Split on separator |
| `join(parts, sep)` | `str` | Join vec with separator |
| `substr(s, start, len)` | `str` | Extract substring |
| `repeat(s, n)` | `str` | Repeat string n times |
| `char_at(s, index)` | `i64` | Code point at index |
| `concat(left, right)` | `str` | Concatenate two strings |
| `copy(s)` | `str` | Copy string |
| `starts::with(s, prefix)` | `bool` | Check prefix |
| `ends::with(s, suffix)` | `bool` | Check suffix |
| `replace::all(s, old, new)` | `str` | Replace all occurrences |
| `replace::first(s, old, new)` | `str` | Replace first occurrence only |
| `pad::left(s, width, pad)` | `str` | Left-pad to width |
| `pad::right(s, width, pad)` | `str` | Right-pad to width |
| `from::i64(v)` | `str` | Convert i64 to string |
| `from::bool(v)` | `str` | Convert bool to `"true"`/`"false"` |
| `from::f64(v)` | `str` | Convert f64 to string |
| `to::i64(s)` | `i64` | Parse string as i64 |
| `is::empty(s)` | `bool` | True if string is empty |

---

## time

Host time queries (monotonic millisecond clock).

| Function | Returns | Description |
|----------|---------|-------------|
| `now::ms()` | `i64` | Current time in milliseconds |
| `now::ns()` | `i64` | Current time in nanoseconds |
| `elapsed(start)` | `i64` | Milliseconds since a mark |
| `mark()` | `i64` | Read a timestamp to pass to `elapsed` |

---

## Collections

Vectors and maps are provided by the **`mire`** standard library, not kioto.
Load them explicitly:

```mire
load mire::vec
load mire::map
```

### mire::vec

| Function | Returns | Description |
|----------|---------|-------------|
| `len(v)` | `i64` | Number of elements |
| `push::i64(v, x)` / `push::str(v, s)` | `vec` | Append (returns the new vec) |
| `pop::i64(v)` | `i64` | Remove and return last element |
| `set::i64(v, index, value)` | — | Set element at index |
| `get::i64(v, index)` | `i64` | Get by index |
| `get::str(v, index)` | `str` | Get str element by index |
| `first::i64(v)` | `i64` | First element |
| `last::i64(v)` | `i64` | Last element |
| `remove(v, index)` | — | Remove at index |
| `clear(v)` | — | Remove all elements |
| `sort(v)` | — | Sort in place |
| `reverse(v)` | `vec[i64]` | Return reversed copy |
| `unique(v)` | `vec[i64]` | Return unique elements |
| `contains::i64(v, x)` | `bool` | Check if value exists |
| `index::i64(v, x)` | `i64` | First index of value (-1 if missing) |
| `slice(v, start, end)` | `vec[i64]` | Return sub-range |
| `flatten(v)` | `vec[i64]` | Flatten nested vectors |
| `concat(v, other)` | — | Append all from other vector |
| `join(v, sep)` | `str` | Join elements as string |

### mire::map

| Function | Returns | Description |
|----------|---------|-------------|
| `len(m)` | `i64` | Number of entries |
| `has(m, key)` | `bool` | Check if key exists |
| `is::empty(m)` | `bool` | True if map has no entries |
| `get::str(m, key)` | `str` | Get value by key |
| `get::i64(m, key)` | `i64` | Get i64 value by key |
| `set::str(m, key, value)` | `map` | Set str value (returns the new map) |
| `set::i64(m, key, value)` | `map` | Set i64 value (returns the new map) |
| `remove(m, key)` | — | Remove key |
| `keys(m)` | `vec[str]` | All keys |
| `values::i64(m)` | `vec[i64]` | All i64 values |
| `entries(m)` | `i64` | Number of entries |
| `count(m)` | `i64` | Alias for entries |
| `merge(m, other)` | `map` | Merge from other map |

> `set`/`push`/`merge` return a new collection because the runtime may
> reallocate the backing storage. Read-only functions take `&anything` and are
> safe to call repeatedly.

---

## fs

Filesystem I/O. Path convenience functions return borrowed `&str` values;
handle-based functions use the PAL v4 `Root`/`File`/`Dir` resource handles.

| Function | Returns | Description |
|----------|---------|-------------|
| `read(path)` | `str` | Read entire file (owned copy) |
| `write(path, data)` | — | Write file (create/truncate) |
| `exists(path)` | `bool` | Check if path exists |
| `is_file(path)` | `bool` | Check if path is a regular file |
| `drop(path)` | `bool` | Delete file |
| `remove(path)` | `bool` | Remove a single entry (file, symlink, or empty dir); symlinks are never followed |
| `remove_all(path)` | `bool` | Recursively remove a file/symlink/dir tree; never follows symlinks |
| `last_error()` | `i64` | Last PAL error code (e.g. 11 = `PAL_ERR_NOT_EMPTY`); read after a failure |
| `path::join(a, b)` | `&str` | Join path components |
| `path::dir(path)` | `&str` | Parent directory |
| `path::name(path)` | `&str` | File name from path |
| `path::ext(path)` | `&str` | File extension |
| `root::open(path)` | `Root` | Acquire a filesystem root handle |
| `root::close(root)` | — | Release a root handle |
| `dir::create(path)` | `bool` | Create directory |
| `dir::remove(path)` | `bool` | Remove directory |
| `dir::open(root, path)` | `Dir` | Open a directory under a root |
| `dir::next(dir, entry)` | `bool` | Read next directory entry |
| `dir::close(dir)` | — | Release a directory handle |
| `file::open::read(root, path)` | `File` | Open a file for reading |
| `file::open::write(root, path)` | `File` | Open a file for writing |
| `file::open::create(root, path)` | `File` | Create (read+write) |
| `file::open::truncate(root, path)` | `File` | Create and truncate |
| `file::read(file, buf, max_len)` | `i64` | Read into a caller-owned buffer |
| `file::write(file, data)` | `i64` | Write bytes to a file |
| `file::seek(file, offset, whence)` | `i64` | Seek within a file |
| `file::size(file)` | `i64` | File size in bytes |
| `file::close(file)` | — | Close a file handle |

### Removing files & directories

`fs::remove` unlinks a single entry; `fs::remove_all` removes a whole tree.
**Symlinks are never followed** — a trailing link is unlinked, and a link
inside a tree is deleted without entering its target, so external targets a
symlink points at are always left intact. Removal runs through the PAL
capability primitive `pal_root_remove` (resolve the parent, then `unlinkat`);
no path string is ever rebuilt outside the sandbox.

```mire
load kioto

// Remove one file (or symlink, or empty directory).
set ok = fs::remove("/tmp/cache/stale.txt")
if !ok {
    set code = fs::last_error()   // 11 = PAL_ERR_NOT_EMPTY, etc.
    use dasu("failed: {code}")
}

// Remove a whole tree recursively.
set ok2 = fs::remove_all("/tmp/scratch/build-out")

// A non-empty directory is REFUSED by fs::remove (never recursive):
fs::mkdir("/tmp/data")
fs::write("/tmp/data/keep.txt" "x")
set refused = !fs::remove("/tmp/data")            // false → true
set code = fs::last_error()                       // 11 (NOT_EMPTY)
set cleaned = fs::remove_all("/tmp/data")         // recursive → true
```

Symlink-safety in practice — an outside directory is never walked:

```mire
// target lives OUTSIDE the tree being removed:
fs::mkdir("/tmp/work")            // fs::mkdir does NOT create parents
fs::mkdir("/tmp/work/target")
fs::write("/tmp/work/target/secret.txt" "secret")
fs::mkdir("/tmp/work/tree")
fs::mkdir("/tmp/work/tree/sub")
// /tmp/work/tree/sub/link → /tmp/work/target  (absolute symlink)
proc::run::output("/bin/ln" ["-s" "/tmp/work/target" "/tmp/work/tree/sub/link"] :vec[str])

set ok3 = fs::remove_all("/tmp/work/tree")        // tree gone…
set target_intact = fs::exists("/tmp/work/target/secret.txt") // …target intact
```

`fs::remove` / `fs::remove_all` return `bool`; on `false`, call
`fs::last_error()` immediately for the PAL error code. See
`kioto/tests/fs_remove.mire` for the full adversarial suite.

---

## env

Environment access.

| Function | Returns | Description |
|----------|---------|-------------|
| `args(argc, argv)` | `vec[str]` | Command-line arguments |
| `cwd()` | `&str` | Current working directory |
| `var(name)` | `&str` | Get env var value |

---

## proc

Process management. Handles are PAL v4 `Process` resources.

| Function | Returns | Description |
|----------|---------|-------------|
| `run::create(cmd, args, flags, stdin_ch, stdout_ch, stderr_ch)` | `Process` | Spawn with explicit argv and channel handles |
| `run::spawn(cmd, args)` | `i64` | Spawn, wait, and return the exit code (no shell) |
| `run::output(cmd, args)` | `str` | Capture stdout via argv (no shell) |
| `run::output_cwd(cmd, args, cwd, merge_err)` | `str` | Capture stdout via argv in a working directory, optionally merging stderr |
| `run::last_exit()` | `i64` | Exit code of the last argv capture (0 = success, 126 = bad cwd, 127 = spawn failure) |
| `run::read_line()` | `str` | Read one line from the controlling terminal (no subprocess; returns `"y"` in non-interactive contexts) |
| `wait(process)` | `i64` | Wait for a process handle |
| `kill(process)` | `bool` | Kill a process handle |
| `close(process)` | — | Release a process handle |
| `stream::input(process)` | `i64` | Process stdin channel |
| `stream::output(process)` | `i64` | Process stdout channel |
| `stream::error(process)` | `i64` | Process stderr channel |

---

## async

Channel primitives backed directly by the PAL, plus a task/future pattern.

| Function | Returns | Description |
|----------|---------|-------------|
| `task::ready(value)` | `Task` | Wrap a value as a completed task |
| `task::value(task, fallback)` | `str` | Read a task's value |
| `spawn(cmd)` | `i64` | Spawn a background process |
| `wait(pid)` | `i64` | Wait for a spawned pid |
| `channel::create()` | `Channel` | Acquire a channel handle |
| `channel::send(channel, data)` | `i64` | Send bytes, return the host result |
| `channel::recv(channel, buf)` | `i64` | Receive into a caller-owned buffer |
| `channel::close(channel)` | — | Release a channel handle |

---

## mem

| Function | Returns | Description |
|----------|---------|-------------|
| `total()` | `i64` | Total memory in bytes |
| `available()` | `i64` | Available memory in bytes |
| `process()` | `i64` | Current process memory in bytes |

---

## cpu

| Function | Returns | Description |
|----------|---------|-------------|
| `count()` | `i64` | Number of host CPUs |

---

## math

Mathematical functions.

| Function | Returns | Description |
|----------|---------|-------------|
| `pi()` | `f64` | π constant |
| `e()` | `f64` | e constant |
| `tau()` | `f64` | τ constant |
| `abs(n)` | `i64` | Absolute value |
| `min(a, b)` | `i64` | Minimum of two values |
| `max(a, b)` | `i64` | Maximum of two values |
| `clamp(n, min, max)` | `i64` | Clamp value to range |
| `sum(list)` | `i64` | Sum of list |
| `mean(list)` | `f64` | Arithmetic mean |
| `avg(list)` | `f64` | Alias for mean |
| `variance(list)` | `f64` | Population variance |
| `stddev(list)` | `f64` | Standard deviation |
| `median(list)` | `f64` | Median value |
| `minlist(list)` | `i64` | Minimum value in list |
| `maxlist(list)` | `i64` | Maximum value in list |
| `range(end)` | `vec[i64]` | Range `[0, end)` |
| `between(start, end)` | `vec[i64]` | Range `[start, end)` |
| `step(start, end, n)` | `vec[i64]` | Range with step |
| `sin(x)` | `f64` | Sine |
| `cos(x)` | `f64` | Cosine |
| `tan(x)` | `f64` | Tangent |
| `asin(x)` | `f64` | Arc sine |
| `acos(x)` | `f64` | Arc cosine |
| `atan2(y, x)` | `f64` | Arc tangent (2-arg) |
| `sqrt(x)` | `f64` | Square root |
| `pow(base, exp)` | `f64` | Power |
| `log(x)` | `f64` | Natural log |
| `log10(x)` | `f64` | Base-10 log |
| `exp(x)` | `f64` | Exponential |
| `round(x)` | `i64` | Round to nearest integer |
| `floor(x)` | `i64` | Floor |
| `ceil(x)` | `i64` | Ceiling |
| `hypot(x, y)` | `f64` | Euclidean distance |

### math::basic

Sub-module with the same mathematical constants and basic functions.
- `pi`, `e`, `tau`, `abs`, `min`, `max`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan2`, `sqrt`, `pow`, `log`, `log10`, `exp`, `round`, `floor`, `ceil`, `hypot`

### math::stats

Statistics sub-module: `sum`, `mean`, `avg`, `variance`, `stddev`, `minlist`,
`maxlist`, `median`, `range`, `between`, `step`.

### math::decimal

Fixed-point decimal arithmetic.

| Function | Returns | Description |
|----------|---------|-------------|
| `new(mantissa, scale)` | `Decimal` | Create decimal |
| `zero()` | `Decimal` | Zero value |
| `int(v)` | `Decimal` | From i64 |
| `parse(text)` | `Decimal` | From string |
| `float(d)` | `f64` | Convert to f64 |
| `text(d)` | `str` | Convert to string |
| `abs(d)` | `Decimal` | Absolute value |
| `neg(d)` | `Decimal` | Negate |
| `add(a, b)` | `Decimal` | Add |
| `sub(a, b)` | `Decimal` | Subtract |
| `mul(a, b)` | `Decimal` | Multiply |
| `div(a, b)` | `Decimal` | Divide (12-digit precision) |
| `prec(a, b, p)` | `Decimal` | Divide with custom precision |
| `round(d)` | `i64` | Round to integer |
| `mantissa(d)` | `i64` | Get mantissa |
| `scale(d)` | `i64` | Get scale |
| `normalize(d)` | `Decimal` | Normalize scale |

```mire
set d = decimal::int(42)           # 42
set d = decimal::parse("3.14")     # 3.14
set f = decimal::float(d)          # 3.14 as f64
set s = decimal::text(d)           # "3.14"
set r = decimal::prec(a, b, 6)     # division with 6 decimal places
```

### math::complex

Complex number arithmetic.

| Function | Returns | Description |
|----------|---------|-------------|
| `new(re, im)` | `Complex` | Create complex number |
| `zero()` | `Complex` | (0 + 0i) |
| `one()` | `Complex` | (1 + 0i) |
| `i()` | `Complex` | (0 + 1i) |
| `real(z)` | `f64` | Real part |
| `imag(z)` | `f64` | Imaginary part |
| `conj(z)` | `Complex` | Conjugate |
| `abs(z)` | `f64` | Magnitude |
| `arg(z)` | `f64` | Argument (angle) |
| `polar(r, a)` | `Complex` | From polar coordinates |
| `text(z)` | `str` | String representation |
| `add(a, b)` | `Complex` | Add |
| `sub(a, b)` | `Complex` | Subtract |
| `mul(a, b)` | `Complex` | Multiply |
| `div(a, b)` | `Complex` | Divide |
| `scale(z, f)` | `Complex` | Scale by f64 |
| `exp(z)` | `Complex` | Complex exponential |
| `log(z)` | `Complex` | Complex natural log |
| `sqrt(z)` | `Complex` | Complex square root |
| `pow(z, exp)` | `Complex` | Complex power |

### math::random

Random number generation (deterministic seeded PRNG).

| Function | Returns | Description |
|----------|---------|-------------|
| `seed(seed)` | — | Seed the generator |
| `u64()` | `i64` | Random unsigned 64-bit integer |
| `i64()` | `i64` | Random signed 64-bit integer |
| `f64()` | `f64` | Random float in [0, 1) |
| `bool()` | `bool` | Random boolean |
| `range(min, max)` | `i64` | Random integer in [min, max) |

---

## net

Low-level TCP resources backed by PAL v4 handles.

| Function | Returns | Description |
|----------|---------|-------------|
| `socket::connect(host, port)` | `Socket` | Open a TCP socket handle |
| `socket::send(socket, data)` | `i64` | Send bytes |
| `socket::recv(socket, buffer, max_len)` | `i64` | Receive bytes into a caller-owned buffer |
| `socket::close(socket)` | — | Release a socket handle |
| `listener::bind(port)` | `Listener` | Open a listening handle |
| `listener::accept(listener)` | `Socket` | Accept one connection |
| `listener::close(listener)` | — | Release a listener handle |

---

## cli

Command-line argument parsing.

| Function | Returns | Description |
|----------|---------|-------------|
| `parse(raw)` | `map[str,str]` | Parse raw CLI args into a key-value map |

The first argument becomes `"command"`; `--flag value` pairs are collected.

---

## crypto

Cryptographic primitives.

### crypto::hash

SHA-256 and SHA-512 hashing per FIPS 180-4.

| Function | Returns | Description |
|----------|---------|-------------|
| `sha256(msg)` | `str` | SHA-256 hex digest (64 lowercase hex chars) |
| `sha512(msg)` | `str` | SHA-512 hex digest (128 lowercase hex chars) |

```mire
set h = crypto::hash::sha256("abc")
# h == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
```

### crypto::encode

Hex and Base64 encoding.

| Function | Returns | Description |
|----------|---------|-------------|
| `hex::encode(bytes)` | `str` | Encode `vec[i64]` bytes to hex string |
| `hex::decode(hex)` | `vec[i64]` | Decode hex string to bytes |
| `base64::encode(bytes)` | `str` | Encode bytes to Base64 string |
| `base64::decode(s)` | `vec[i64]` | Decode Base64 string to bytes |

### crypto::random::secure

CSPRNG via `/dev/urandom`.

| Function | Returns | Description |
|----------|---------|-------------|
| `bytes(n)` | `vec[i64]` | Read `n` random bytes |
| `seed(size)` | `str` | Random hex seed (2*size chars) |
| `i64()` | `i64` | Random 64-bit signed integer |

```mire
set rand_bytes = crypto::random::secure::bytes(32)
set rand_seed = crypto::random::secure::seed(32)
set rand_i64 = crypto::random::secure::i64()
```

### crypto::sign::ed25519

Ed25519 digital signatures via PAL (EdDSA, Curve25519, RFC 8032).

| Function | Returns | Description |
|----------|---------|-------------|
| `secret::new()` | `SecretKey` | Generate a secret key handle |
| `secret::public(secret)` | `PublicKey` | Derive the public key |
| `secret::sign(secret, msg)` | `str` | Sign a message (64-byte signature) |
| `public::verify(pubkey, msg, sig)` | `bool` | Verify a signature |
| `secret::close(secret)` | — | Release a secret key handle |
| `public::close(pubkey)` | — | Release a public key handle |

```mire
set secret = crypto::sign::ed25519::secret::new()
set pubkey = crypto::sign::ed25519::secret::public(secret)
set sig = crypto::sign::ed25519::secret::sign(secret "message")
set ok = crypto::sign::ed25519::public::verify(pubkey "message" sig)
crypto::sign::ed25519::secret::close(secret)
crypto::sign::ed25519::public::close(pubkey)
```

---

## log

Logging with formatted output.

| Function | Description |
|----------|-------------|
| `info(msg)` | Print `[INFO] msg` |
| `warn(msg)` | Print `[WARN] msg` |
| `error(msg)` | Print `[ERROR] msg` |

---

## Quick start

```mire
load kioto
load mire::vec

pub fn main: () {
    // File I/O
    fs::write("output.txt", "hello from kioto")

    // String conversion
    set msg = strings::from::i64(42)
    log::info("The answer is " + msg)

    // Collections from mire
    set parts = strings::split("a,b,c" ",")
    set n = vec::len(parts)
    set first = vec::get::str(parts 0)
}
```

## Version

**2.4.8** — See [CHANGELOG.md](CHANGELOG.md) for the migration guide.

## Verification

Run the complete kioto verification from the checkout:

```sh
./scripts/verify.sh
```

The script checks every core module, checks the exported entrypoint, and runs
the PAL v4 integration smoke tests in `tests/`. Set `MIRE_BIN` or
`AVENYS_ROOT` when the compiler is outside the sibling `avenys/` directory.
