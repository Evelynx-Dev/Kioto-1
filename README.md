# kioto — Mire standard library

Version **2.4.0** — [CHANGELOG](CHANGELOG.md)

Kioto is the core library for the Mire language ecosystem.
Load the full library with `load kioto`, or load individual modules
by path (e.g. `load kioto::strings`).

---

## strings

String manipulation. All functions take `&str` borrows and return owned values.

| Function | Returns | Description |
|----------|---------|-------------|
| `len(s)` | `i64` | Length in bytes |
| `substr(s, start, len)` | `str` | Extract substring |
| `split(s, sep)` | `vec[str]` | Split on separator |
| `join(parts, sep)` | `str` | Join vec with separator |
| `contains(s, sub)` | `bool` | Check if substring exists |
| `index(s, sub)` | `i64` | First index of substring (-1 if not found) |
| `startswith(s, prefix)` | `bool` | Check prefix |
| `endswith(s, suffix)` | `bool` | Check suffix |
| `trim(s)` | `str` | Strip whitespace both sides |
| `ltrim(s)` | `str` | Strip leading whitespace |
| `rtrim(s)` | `str` | Strip trailing whitespace |
| `upper(s)` | `str` | To uppercase |
| `lower(s)` | `str` | To lowercase |
| `replace(s, old, new)` | `str` | Replace all occurrences |
| `repeat(s, n)` | `str` | Repeat string n times |
| `replace::first(s, old, new)` | `str` | Replace first occurrence only |
| `pad::left(s, w, pad)` | `str` | Left-pad to width w |
| `pad::right(s, w, pad)` | `str` | Right-pad to width w |
| `from::i64(v)` | `str` | Convert i64 to string |
| `conv::i64(s)` | `i64` | Parse string as i64 |
| `conv::string(v)` | `str` | Alias for `from::i64` |
| `check::empty(s)` | `bool` | True if string is empty |

---

## lists

Dynamic list operations.

| Function | Returns | Description |
|----------|---------|-------------|
| `len(list)` | `i64` | Number of elements |
| `push(list, value)` | `mu` | Append value |
| `pop(list)` | `i64` | Remove and return last element |
| `get(list, index)` | `i64` | Get by index |
| `get::str(list, index)` | `str` | Get str element by index |
| `first(list)` | `i64` | First element |
| `last(list)` | `i64` | Last element |
| `remove(list, index)` | `mu` | Remove at index |
| `clear(list)` | `mu` | Remove all elements |
| `contains(list, value)` | `bool` | Check if value exists (i64) |
| `index(list, value)` | `i64` | First index of value (-1 if missing) |
| `sort(list)` | `mu` | Sort in place |
| `reverse(list)` | `vec[i64]` | Return reversed copy |
| `unique(list)` | `vec[i64]` | Return unique elements |
| `slice(list, start, end)` | `vec[i64]` | Return sub-range |
| `concat(list, other)` | `mu` | Append all from other list |
| `flatten(list)` | `vec[i64]` | Flatten nested lists |
| `join(list, sep)` | `str` | Join elements as string |
| `check::empty(list)` | `bool` | True if list is empty |

---

## dicts

Dictionary / map operations.

| Function | Returns | Description |
|----------|---------|-------------|
| `len(dict)` | `i64` | Number of entries |
| `count(dict)` | `i64` | Same as len |
| `keys(dict)` | `vec[str]` | All keys |
| `values(dict)` | `vec[i64]` | All values |
| `has(dict, key)` | `bool` | Check if key exists |
| `get(dict, key)` | `str` | Get value by key |
| `set(dict, key, value)` | `mu` | Set key-value |
| `remove(dict, key)` | `mu` | Remove key |
| `merge(dict, other)` | `mu` | Merge from other dict |
| `check::empty(dict)` | `bool` | True if dict has no entries |

---

## fs

Filesystem I/O.

| Function | Returns | Description |
|----------|---------|-------------|
| `read(path)` | `str` | Read entire file |
| `write(path, data)` | `mu` | Write file (overwrite) |
| `append(path, data)` | `mu` | Append to file |
| `exists(path)` | `bool` | Check if path exists |
| `size(path)` | `i64` | File size in bytes |
| `copy(src, dst)` | `mu` | Copy file |
| `move(src, dst)` | `mu` | Move / rename |
| `drop(path)` | `mu` | Delete file |
| `list(path)` | `vec[str]` | List directory contents |
| `walk(path)` | `vec[str]` | Recursive directory traversal |
| `mkdir(path)` | `mu` | Create directory |
| `rmdir(path)` | `mu` | Remove directory |
| `join(a, b)` | `str` | Join path components |
| `dir(path)` | `str` | Parent directory |
| `name(path)` | `str` | File name from path |
| `ext(path)` | `str` | File extension |
| `check::file(path)` | `bool` | True if path is a regular file |
| `read_bytes(path)` | `vec[i64]` | Read file as byte array |
| `write_bytes(path, data)` | `mu` | Write byte array to file |

---

## net

TCP networking.

| Function | Returns | Description |
|----------|---------|-------------|
| `connect(host, port)` | `i64` | Open TCP connection (returns fd) |
| `send(fd, data)` | `mu` | Send data |
| `recv(fd, max)` | `str` | Receive up to max bytes |
| `close(fd)` | `mu` | Close connection |
| `resolve(host)` | `str` | DNS resolution |

### net::http

HTTP client + server.

| Function | Returns | Description |
|----------|---------|-------------|
| `get(url)` | `str` | HTTP GET (supports HTTPS) |
| `post(url, body, content_type)` | `str` | HTTP POST |
| `req::method(raw)` | `str` | Parse HTTP method from request |
| `req::path(raw)` | `str` | Parse path from request |
| `req::header(raw, name)` | `str` | Parse specific header |
| `req::body(raw)` | `str` | Parse request body |
| `req::query(raw)` | `str` | Parse query string |
| `req::path_only(raw)` | `str` | Path without query string |
| `resp::success(body, content_type)` | `str` | Build HTTP 200 response |
| `resp::not_found()` | `str` | Build HTTP 404 response |
| `resp::redirect(location)` | `str` | Build HTTP 302 response |
| `server::mime(path)` | `str` | Guess MIME type from extension |
| `serve::file(fd, path)` | `mu` | Serve a file over HTTP |

### net::event

Non-blocking I/O primitives.

| Function | Returns | Description |
|----------|---------|-------------|
| `accept::one(port)` | `i64` | Bind and accept one connection |
| `has::data(fd)` | `bool` | Check if fd has data ready |
| `wait(fd, timeout_ms)` | `bool` | Wait for data with timeout |

---

## proc

Process management.

| Function | Returns | Description |
|----------|---------|-------------|
| `run(cmd, args)` | `i64` | Spawn process (returns pid) |
| `spawn(cmd, args)` | `i64` | Alias for `run` |
| `capture(cmd, args)` | `str` | Run and capture stdout |
| `shell(cmd)` | `str` | Run shell command, capture output |
| `pipe(commands)` | `str` | Pipe commands together |
| `read()` | `str` | Read line from stdin |
| `write(data)` | `mu` | Print to stdout |
| `eprint(msg)` | `mu` | Print to stderr |
| `exit(code)` | `mu` | Exit process |
| `kill(pid)` | `mu` | Kill process |
| `wait(pid)` | `i64` | Wait for process to finish |
| `exists(pid)` | `bool` | Check if process is running |

---

## env

Environment access.

| Function | Returns | Description |
|----------|---------|-------------|
| `get(key)` | `str` | Get env var value |
| `set(key, value)` | `mu` | Set env var |
| `all()` | `map[str,str]` | All env vars |
| `cwd()` | `str` | Current working directory |
| `chdir(path)` | `mu` | Change directory |

---

## time

Wall-clock and monotonic time.

| Function | Returns | Description |
|----------|---------|-------------|
| `unix::ms()` | `i64` | Unix timestamp in milliseconds |
| `unix::ns()` | `i64` | Unix timestamp in nanoseconds |
| `elapsed::ns(start)` | `i64` | Nanoseconds elapsed since mark |
| `elapsed(start)` | `i64` | Milliseconds elapsed (alias) |
| `mark()` | `i64` | Take a timestamp mark |

---

## cpu

CPU and performance counters.

| Function | Returns | Description |
|----------|---------|-------------|
| `time::ns()` | `i64` | High-resolution CPU timestamp (ns) |
| `time::ms()` | `i64` | CPU timestamp (ms) |
| `mark()` | `i64` | Take a performance mark |
| `elapsed::ms(mark)` | `i64` | Milliseconds since mark |
| `elapsed::ns(mark)` | `i64` | Nanoseconds since mark |
| `count()` | `i64` | Number of CPU cores |
| `freq::mhz()` | `i64` | CPU frequency in MHz |
| `cycles::est(mark)` | `i64` | Estimated CPU cycles since mark |
| `loadavg()` | `vec[f64]` | System load average |
| `snapshot()` | `map[str,i64]` | Full CPU snapshot |

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
| `minlist(list)` | `i64` | Minimum value in list |
| `maxlist(list)` | `i64` | Maximum value in list |
| `sum(list)` | `i64` | Sum of list |
| `mean(list)` | `f64` | Arithmetic mean |
| `avg(list)` | `f64` | Alias for mean |
| `variance(list)` | `f64` | Population variance |
| `stddev(list)` | `f64` | Standard deviation |
| `median(list)` | `f64` | Median value |
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
- `pi`, `e`, `tau`, `abs`, `min`, `max`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan2`, `sqrt`

### math::stats

Statistics sub-module.

| Function | Returns | Description |
|----------|---------|-------------|
| `sum(list)` | `i64` | Sum of list |
| `mean(list)` | `f64` | Arithmetic mean |
| `avg(list)` | `f64` | Alias for mean |
| `variance(list)` | `f64` | Population variance |
| `stddev(list)` | `f64` | Standard deviation |
| `minlist(list)` | `i64` | Minimum in list |
| `maxlist(list)` | `i64` | Maximum in list |
| `median(list)` | `f64` | Median |
| `range(end)` | `vec[i64]` | Range `[0, end)` |
| `between(s, e)` | `vec[i64]` | Range `[start, end)` |
| `step(s, e, n)` | `vec[i64]` | Range with step |

### math::decimal

Fixed-point decimal arithmetic.

```mire
set d = decimal::int(42)           # 42
set d = decimal::parse("3.14")     # 3.14
set f = decimal::float(d)          # 3.14 as f64
set s = decimal::text(d)           # "3.14"
set r = decimal::prec(a, b, 6)     # division with 6 decimal places
```

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

Random number generation.

| Function | Returns | Description |
|----------|---------|-------------|
| `seed(size)` | `str` | Random hex seed |
| `u64()` | `i64` | Random unsigned 64-bit integer |
| `i64()` | `i64` | Random signed 64-bit integer |
| `f64()` | `f64` | Random float in [0, 1) |
| `bool()` | `bool` | Random boolean |
| `range(min, max)` | `i64` | Random integer in [min, max) |

---

## async

Async / concurrency primitives.

| Function | Returns | Description |
|----------|---------|-------------|
| `sleep(ms)` | `mu` | Sleep for milliseconds |
| `spawn(cmd)` | `i64` | Spawn process (returns pid) |
| `wait(pid)` | `i64` | Wait for process |
| `ready(value)` | `str` | Mark task as done (returns `"done:..."`) |
| `failed(msg)` | `str` | Mark task as failed (returns `"error:..."`) |
| `pending()` | `str` | Create pending token |
| `value(task, fallback)` | `str` | Extract value from done task |
| `error::msg(task)` | `str` | Extract error message |
| `check::done(task)` | `bool` | True if task completed |
| `check::error(task)` | `bool` | True if task errored |
| `check::pending(task)` | `bool` | True if task pending |
| `spawn::thread(task)` | `i64` | Spawn OS thread with function |
| `join::thread(tid)` | `i64` | Join thread |
| `channel()` | `str` | Create IPC channel path |
| `send(ch, msg)` | `mu` | Send message through channel |
| `recv(ch)` | `str` | Receive message from channel |
| `close::channel(ch)` | `mu` | Close and remove channel |

---

## cli

Command-line argument parsing.

| Function | Returns | Description |
|----------|---------|-------------|
| `parse(raw)` | `map[str,str]` | Parse raw CLI args into key-value map |

---

## crypto

Cryptographic primitives implemented in pure Mire.

### crypto::hash

SHA-256 and SHA-512 hashing per FIPS 180-4.

| Function | Returns | Description |
|----------|---------|-------------|
| `sha256(msg)` | `str` | SHA-256 hex digest (64 lowercase hex chars) |
| `sha512(msg)` | `str` | SHA-512 hex digest (128 lowercase hex chars) |

Both are complete pure-Mire implementations. Tested against NIST vectors
for empty string, "abc", "hello world", and multiblock messages.

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

### crypto::sign::ed25519

Ed25519 digital signatures via openssl (EdDSA, Curve25519, RFC 8032).

| Function | Returns | Description |
|----------|---------|-------------|
| `generate_sk()` | `str` | Generate secret key (PEM file path) |
| `generate_pk(sk_path)` | `str` | Extract public key from secret key |
| `sign(sk_path, msg)` | `str` | Sign message (returns hex signature) |
| `verify(pk_path, msg, sig)` | `bool` | Verify signature against message |
| `read_pem(path)` | `str` | Read PEM file contents |
| `cleanup_keys(sk, pk)` | — | Delete temp key files |

Keys are stored as PEM files. Signatures are hex-encoded strings.

```mire
set sk_path = crypto::sign::ed25519::generate_sk()
set pk_path = crypto::sign::ed25519::generate_pk(sk_path)
set sig = crypto::sign::ed25519::sign(sk_path, "message")
set ok = crypto::sign::ed25519::verify(pk_path, "message", sig)
crypto::sign::ed25519::cleanup_keys(sk_path, pk_path)
```

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

---

## iter

Iterator utilities operating on `vec[str]`.

| Function | Returns | Description |
|----------|---------|-------------|
| `range(start, end)` | `str` | Newline-separated range string |
| `count(items)` | `i64` | Number of elements |
| `nth(items, idx)` | `str` | Element at index |
| `first(items)` | `str` | First element |
| `last(items)` | `str` | Last element |
| `contains(items, needle)` | `bool` | Check if element exists |
| `index(items, needle)` | `i64` | Index of element (-1 if missing) |
| `empty(items)` | `bool` | True if no elements |

---

## json

JSON parser, navigator, and builder.

| Function | Returns | Description |
|----------|---------|-------------|
| `get(data, path)` | `str` | Navigate dot-path (e.g. `"user.name"`) |
| `exists(data, path)` | `bool` | Check path exists |
| `type_of(data, path)` | `str` | JSON type at path |
| `keys(data, path)` | `str` | Object keys (newline-separated) |
| `len(data, path)` | `i64` | Array length or object key count |
| `is_valid(data)` | `bool` | Validate JSON syntax |
| `quoted(s)` | `str` | Escape and quote string |
| `number(v)` | `str` | JSON number value |
| `bool_val(v)` | `str` | JSON bool value |
| `null_val()` | `str` | JSON null value |
| `object(pairs)` | `str` | Build JSON object from vec |
| `array(items)` | `str` | Build JSON array from vec |
| `escape(s)` | `str` | Escape string |
| `unescape(s)` | `str` | Unescape JSON string |

---

## maybe

Option type using tagged strings (`"some:..."` / `"none"`).

| Function | Returns | Description |
|----------|---------|-------------|
| `some(value)` | `str` | Wrap value |
| `none()` | `str` | No value |
| `is_some(m)` | `bool` | Check if some |
| `is_none(m)` | `bool` | Check if none |
| `unwrap(m)` | `str` | Unwrap (panics if none) |
| `unwrap_or(m, fallback)` | `str` | Unwrap with fallback |
| `map(m, f)` | `str` | Transform value |
| `and_then(m, f)` | `str` | Chain maybe-returning function |

---

## result

Result type using tagged strings (`"ok:..."` / `"err:..."`).

| Function | Returns | Description |
|----------|---------|-------------|
| `ok(value)` | `str` | Success value |
| `err(msg)` | `str` | Error message |
| `is_ok(r)` | `bool` | Check if ok |
| `is_err(r)` | `bool` | Check if err |
| `unwrap(r)` | `str` | Unwrap (panics if err) |
| `unwrap_or(r, fallback)` | `str` | Unwrap with fallback |
| `unwrap_err(r)` | `str` | Extract error |
| `map(r, f)` | `str` | Transform ok value |
| `map_err(r, f)` | `str` | Transform error message |

---

## websocket (ws)

WebSocket client and server (RFC 6455).

| Function | Returns | Description |
|----------|---------|-------------|
| `connect(url)` | `i64` | Connect to WebSocket server |
| `send::text(fd, msg)` | `mu` | Send text frame |
| `recv::all(fd)` | `str` | Receive all data |
| `close(fd)` | `mu` | Close connection |
| `server::accept(fd)` | `mu` | Accept WebSocket handshake |
| `server::send_text(fd, msg)` | `mu` | Server send text |
| `server::recv(fd, max)` | `str` | Server receive |
| `server::close(fd)` | `mu` | Server close |

---

## log

Logging with formatted output.

| Function | Description |
|----------|-------------|
| `info(msg)` | Print `[INFO] msg` |
| `warn(msg)` | Print `[WARN] msg` |
| `error(msg)` | Print `[ERROR] msg` |

---

## mem

Memory operations.

| Function | Returns | Description |
|----------|---------|-------------|
| `used()` | `i64` | Used memory in bytes |
| `total()` | `i64` | Total memory in bytes |
| `free()` | `i64` | Free memory in bytes |
| `available()` | `i64` | Available memory in bytes |
| `percent()` | `f64` | Memory usage percentage |
| `process()` | `i64` | Current process memory in bytes |
| `snapshot()` | `map[str,i64]` | Full memory snapshot |
| `format(bytes)` | `str` | Human-readable memory size |

---

## gpu

GPU detection.

| Function | Returns | Description |
|----------|---------|-------------|
| `snapshot()` | `map[str,i64]` | GPU information snapshot |

---

## term

Terminal styling and output.

| Function | Returns | Description |
|----------|---------|-------------|
| `style(text, style_code)` | `str` | Apply ANSI style to text |
| `hr(ch, len)` | `str` | Horizontal rule |
| `clear()` | `mu` | Clear terminal |
| `bar(name, elapsed_ms, phase_ms, total_ms)` | `str` | Progress bar |

---

## Quick start

```mire
load kioto

pub fn main: () {
    // File I/O
    fs::write("output.txt", "hello from kioto")

    // String conversion
    set msg = strings::from::i64(42)
    log::info("The answer is " + msg)

    // Lists
    set parts = strings::split("a,b,c" ",")
    set n = lists::len(parts)
    set first = lists::get::str(parts 0)

    // Result handling
    set r = result::ok("done")
    use dasu(result::unwrap(r))
}
```

## Version

**2.4.0** — See [CHANGELOG.md](CHANGELOG.md) for migration guide.
