# kioto changelog

## [2.4.0] — 2026-07-21 (F1 rework)

### Changed

- **`core/async` — real channels:** Replaced the file-based IPC (`/tmp` files)
  with a real pthread mutex + condition-variable message queue. `async::channel()`
  returns an opaque packed `i64` handle; `send`/`recv`/`close_channel` operate on
  the handle directly with a blocking `recv` and a non-blocking queue. Channel
  ownership is tracked by handle, not by filename.
- **`core/gpu` — real snapshot:** `pal_gpu_snapshot()` now reads Linux sysfs
  (`/sys/class/drm/`) and returns a parsed dict with vendor, device, driver and
  VRAM info instead of a hardcoded `"available=false"` string.
- **`core/dicts` — `&dict` reference reads:** Read-only operations (`get`, `has`,
  `len`, `keys`, `values`, `entries`) now take `&dict` references instead of moving
  the dict, allowing multiple reads on the same dict. Added `dicts.get_i64` for
  type-safe integer retrieval via the new `rt_dicts_get_i64` C runtime function.

### WASM

- GPU returns an honest `reason: wasm_sandbox` field (not a hardcoded stub).
- The async channel uses a real single-threaded ring buffer on WASM.

## [2.3.2] — 2026-07-18

### Changed

- **`proc` module cleanup:** Removed the self-referential
 `load kioto::proc::spawn`; declared `pal_proc_spawn` and `rt_vec_get_str`
 externs directly. Renamed `build_cmd` → `pub fn join_cmd` and switched
 string-vector indexing from `lists::get` to `rt_vec_get_str` for correct
 element access.
- **`decimal` module:** Added `load kioto::math::basic` and made `pow10`
 `pub` so it can be reused by other modules.
- **`cpu` module:** Dropped a duplicate/blank `load kioto::cpu::elapsed`
 import.

## [2.3.1] — 2026-07-17

### Docs

- **`lists::set` es el workaround correcto del bug de `vec[i64]`**: la
 asignación por índice nativa de Avenys (`set vec at idx = val`) corrumpe
 vectores dinámicos silenciosamente (lecturas posteriores devuelven
 valores erróneos/desplazados). Reproducido en Avenys/Mire v3.15–3.16;
 documentado en `avenys/docs/VEC_INDEXED_ASSIGN_BUG.md`.
 `lists::set(list, idx, val)` enruta a `rt_lists_set_i64` (runtime C)
 y escribe el slot correcto sin corromper. Cualquier código kioto que
 escriba en `vec[]` por índice debe usar `lists::set`, no la sintáxis nativa.

## [2.3.0] — 2026-07-15

Version bump. Built and tested against Avenys / Mire v3.14.x.

Known issue (compiler-side, not kioto): `tests/math_complex.mire` fails to
compile because negative float literals (`-2.0`) are not lexed — tracked in
avenys at `../avenys/benchmarks/NEGATIVE_LITERALS.md`. The rest of the kioto
suite (74 tests) passes at both `-O0` and `-O3`.

## 2.2.0 — 2026-07-09

### New: SHA-512

SHA-512 hash implementation per FIPS 180-4:
- 80 rounds, 128-byte blocks, 64-bit words
- Tested against NIST vectors (empty string, "abc", 128-char length check)
- Uses same internal structure as SHA-256 with 64-bit constants

Implementation note: K constants (80 × 64-bit values) are currently
built via `rt_lists_push_i64()` instead of a list literal. The underlying
compiler bug (negative integer literal lexing in lists, Avenys <3.12.5)
is now fixed — the workaround is retained for backward compatibility
but is no longer required with Avenys ≥3.12.5.

### Fixed

- **Ed25519**: real pid from `proc::run()` passed to `proc::wait()`, error
 checking via `fs::exists+size`, verify uses exit code wrapper instead of
 parsing stdout, `generate_sk/generate_pk` validate output files,
 `cleanup_keys` uses `strings::len` (was bare `len`), `uid()` helper restored
- **Base64**: `char_value` refactored from 74-line if-chain to 5-line
 `strings::index`, full -1 sentinel validation for all v0-v3 with proper
 pad-aware checking
- **Hex**: `hex_val` returns -1 for invalid chars (was 0), `decode()` validates
 hi/lo for -1 sentinel
- **SHA-256**: uses `rt_lists_push_i64` for integer list operations
 (was routing through `rt_lists_push_ptr` causing segfaults)

### New APIs

- `fs::read_bytes(path)` — binary-safe file read via `rt_read_bytes` C runtime
 function. Returns managed string with correct byte length (no strlen).
- `fs::write_bytes(path, data, len)` — writes exact byte count via
 `pal_fs_write_bytes`
- `rt_hex_to_file(path, hex)` — C function decodes hex string to raw bytes

### Dependencies

Crypto module now has zero external binary conversion dependencies.
Only required system tools: `od` (coreutils, universal) and `openssl`.

### Tests

76/76 tests pass: SHA-256 (5), SHA-512 (3), Base64 (7), Hex (3), Ed25519 (2),
CSPRNG (3), bitwise (6), integration (1).

## 2.1.0 — 2026-07-09

### New: crypto module (73/73 tests)

Complete cryptographic module:

- **crypto::hash::sha256**: Full SHA-256 per FIPS 180-4, tested against NIST vectors (empty, "abc", "hello world", multiblock, 1000-char).
- **crypto::encode::hex**: Hex encode (`vec[i64]` → `str`) and decode (`str` → `vec[i64]`) with round-trip tests.
- **crypto::encode::base64**: Base64 encode/decode per RFC 4648 with full test vector coverage.
- **crypto::random::secure**: CSPRNG via `/dev/urandom` (bytes, seed, i64) using `od` (coreutils).
- **crypto::sign::ed25519**: Ed25519 keygen/sign/verify via openssl CLI, with wrong-signature detection tests.

Infrastructure:
- New `lists::set(list, index, value)` for in-place list mutation (takes `&list`).
- Added `rt_lists_set_i64` to C runtime (lists.c).
- Added `rt_crypto_byte_at` to C runtime (crypto.c) for raw byte access from managed strings.

### Fixed

- **Compiler (Avenys v3.12.3)**: Bitwise operators (`^ & | << >>`) were routing all ops to `MirOp::Add`;
 added proper `MirOp::Shr/Xor/BitAnd/BitOr` variants with LLVM codegen, constant
 folding, and optimizer support.
- **Compiler (Avenys v3.12.4)**: Multi-line expression continuation (binary operators at end of line).
- **lists::push**: Now returns `:list` instead of `:mu` to correctly handle realloc pointer updates.
- **SHA-256**: Uses `rt_lists_push_i64` directly for integer list operations (was routing through `rt_lists_push_ptr` causing segfaults).

### Dependencies

| Tool | Package | Purpose |
|------|---------|---------|
| `od` | coreutils (universal) | CSPRNG + binary→hex |
| `openssl` | openssl | Ed25519 keygen/sign/verify |
| `xxd` | vim-common | Ed25519 verify hex→binary |
| `/dev/urandom` | kernel | CSPRNG entropy |

### Tests (73/73 PASS)

- **bitwise_test.mire**: 6 tests (AND/OR/XOR/SHL/SHR + chained).
- **crypto_test.mire**: 19 tests — SHA-256 (5), Base64 (7), Hex (3), Ed25519 (2), CSPRNG (2).

## 2.0.0 — 2026-07-08

### Breaking: `_` → `::` naming convention

Every function name containing an underscore has been refactored to use Mire's
module path separator (`::`). This aligns all kioto APIs with the language's
namespace resolution system and eliminates inconsistent naming.

**Migration guide:** Replace `_` with `::` in the function path. For example,
`strings::from_i64(x)` becomes `strings::from::i64(x)`.

#### strings
| Old | New |
|-----|-----|
| `strings::from_i64(x)` | `strings::from::i64(x)` |
| `strings::to_i64(s)` | `strings::conv::i64(s)` |
| `strings::index_of(s, sub)` | `strings::index(s, sub)` |
| `strings::is_empty(s)` | `strings::check::empty(s)` |
| `strings::replace_first(s, o, n)` | `strings::replace::first(s, o, n)` |
| `strings::pad_left(s, w, p)` | `strings::pad::left(s, w, p)` |
| `strings::pad_right(s, w, p)` | `strings::pad::right(s, w, p)` |

#### dicts
| Old | New |
|-----|-----|
| `dicts::is_empty(d)` | `dicts::check::empty(d)` |
| `dicts::entries(d)` | `dicts::count(d)` (renamed for accuracy) |

#### fs
| Old | New |
|-----|-----|
| `fs::is_file(p)` | `fs::check::file(p)` |

#### cpu
| Old | New |
|-----|-----|
| `cpu::time_ns()` / `cpu::time_ms()` | `cpu::time::ns()` / `cpu::time::ms()` |
| `cpu::elapsed_ms(m)` / `cpu::elapsed_ns(m)` | `cpu::elapsed::ms(m)` / `cpu::elapsed::ns(m)` |
| `cpu::freq_mhz()` | `cpu::freq::mhz()` |
| `cpu::cycles_est(m)` | `cpu::cycles::est(m)` |

#### time
| Old | New |
|-----|-----|
| `time::unix_ms()` / `time::unix_ns()` | `time::unix::ms()` / `time::unix::ns()` |
| `time::elapsed_ns(s)` | `time::elapsed::ns(s)` |

#### async
| Old | New |
|-----|-----|
| `async::is_done(t)` | `async::check::done(t)` |
| `async::is_error(t)` | `async::check::error(t)` |
| `async::is_pending(t)` | `async::check::pending(t)` |
| `async::error_msg(t)` | `async::error::msg(t)` |
| `async::spawn_thread(f)` | `async::spawn::thread(f)` |
| `async::join_thread(t)` | `async::join::thread(t)` |
| `async::close_channel(c)` | `async::close::channel(c)` |

#### lists
| Old | New |
|-----|-----|
| `lists::index_of(l, v)` | `lists::index(l, v)` |
| `lists::get_str(l, i)` | `lists::get::str(l, i)` |
| `lists::is_empty(l)` | `lists::check::empty(l)` |

#### net::event
| Old | New |
|-----|-----|
| `net::event::accept_one(p)` | `net::event::accept::one(p)` |
| `net::event::has_data(f)` | `net::event::has::data(f)` |

#### net::http
| Old | New |
|-----|-----|
| `http::server_mime(p)` | `http::server::mime(p)` |
| `http::serve_file(f, p)` | `http::serve::file(f, p)` |
| `http::req_method(r)` | `http::req::method(r)` |
| `http::req_path(r)` | `http::req::path(r)` |
| `http::req_header(r, n)` | `http::req::header(r, n)` |
| `http::req_body(r)` | `http::req::body(r)` |
| `http::req_query(r)` | `http::req::query(r)` |
| `http::req_path_only(r)` | `http::req::path_only(r)` |
| `http::resp_200(b, c)` | `http::resp::success(b, c)` |
| `http::resp_404()` | `http::resp::not_found()` |
| `http::resp_302(l)` | `http::resp::redirect(l)` |

#### proc
| Old | New |
|-----|-----|
| `proc::spawn_shell(c)` | `proc::spawn::shell(c)` |

#### math
| Old | New |
|-----|-----|
| `math::min_list(l)` | `math::minlist(l)` |
| `math::max_list(l)` | `math::maxlist(l)` |
| `math::range_between(s, e)` | `math::between(s, e)` |
| `math::range_step(s, e, n)` | `math::step(s, e, n)` |

#### stats (via `math::stats`)
| Old | New |
|-----|-----|
| `stats::min_list(l)` | `stats::minlist(l)` |
| `stats::max_list(l)` | `stats::maxlist(l)` |
| `stats::range_between(s, e)` | `stats::between(s, e)` |
| `stats::range_step(s, e, n)` | `stats::step(s, e, n)` |

#### Decimal
| Old | New |
|-----|-----|
| `decimal::from_int(v)` | `decimal::int(v)` |
| `decimal::from_str(s)` | `decimal::parse(s)` |
| `decimal::to_float(d)` | `decimal::float(d)` |
| `decimal::to_str(d)` | `decimal::text(d)` |
| `decimal::div_prec(a, b, p)` | `decimal::prec(a, b, p)` |

#### Complex
| Old | New |
|-----|-----|
| `complex::from_polar(r, a)` | `complex::polar(r, a)` |
| `complex::to_str(z)` | `complex::text(z)` |

#### iter
| Old | New |
|-----|-----|
| `iter::is_empty(l)` | `iter::empty(l)` |
| `iter::index_of(l, v)` | `iter::index(l, v)` |

### Removed
- **`strings::to_string`**: Use `strings::from::i64()` instead (identical behavior).
- **`dicts::delete`**: Use `dicts::remove()` instead (identical behavior).
- **`dicts::entries`**: Use `dicts::count()` instead (returns count, not key-value pairs).

## 1.1.6 — 2026-07-07

> **Re-versioned (2026-07-03):** Old 3.x tags mapped to semver:
> - 3.11.12 → 1.0.0 (base)
> - 3.11.13 → 1.1.0 (SDL3 module)

## 1.1.6 — 2026-07-07

### Changed
- **`thread::spawn` / `thread::join`**: `core/async/mod.mire` now uses the new
 namespace syntax (`thread::spawn` / `thread::join`) instead of legacy flat
 builtins (`thread_spawn` / `thread_join`). This aligns with builtin
 modularization in Avenys 3.11.44+.

## 1.1.5 — 2026-07-06

### New features

- **fs::walk**: Recursive directory traversal. Returns all file paths under a
 directory, recursively including subdirectories. Skips `.` and `..` entries.

## 1.1.4 — 2026-07-06

### Naming cleanup

- **Removed duplicate functions**: `lists::append` (alias for `push`),
 `lists::delete` (alias for `remove`), `strings::strip` (alias for `trim`).
- **Removed broken extern**: `proc::err` no longer declares non-existent
 `pal_proc_err`. Function now returns empty string with `@[deprecated]`.

### 1.1.3 — 2026-07-06

### Core cleanup

- **Removed stubs**: `gpu::available()` (hardcoded false), `lists::map/filter/fold`
 (returning dummies), `proc::on()` (empty body).
- **Namespace separators**: Fixed `basic.` → `basic::` and `strings.` → `strings::`
 in `math/complex.mire` and `core/term/mod.mire`.

### Tests

- **Extended test suite**: Tests split into modular files (`maybe.mire`, `result.mire`,
 `iter.mire`, `json.mire`, `async.mire`, `fs.mire`, `env.mire`, `proc.mire`,
 `math.mire`, `math_complex.mire`, `cli.mire`) for easier navigation.

## 1.1.2 — 2026-07-05

### Fixed

- **strings::substr:** All calls now compute length into a variable before
 passing to `substr`, avoiding a Mire runtime bug where inline
 `strings::len()` as a function argument corrupts concatenated strings.
 Fix applied across `ext/maybe`, `ext/result`, `ext/json`, `ext/ws`,
 `core/async`, `core/cli`, `core/net/http` (12+ functions affected).
- **async::channel:** Replaced undefined `proc_run("date +%s")` with
 `time::unix_ms()` — the `proc_run` function never existed in kioto's scope.
- **async::value, async::error_msg:** Fixed inline `strings::len()` bug
 in the same pattern.

### Added

- **Test suite:** 35 tests across `tests/test_smoke.mire` and
 `tests/test_ext.mire`. Run with `mire test` in the kioto directory.

## 1.1.1 — 2026-07-04

### Fixed

- **net::event:** `accept_one` bounded to 50 retries instead of infinite loop,
 returns -1 when exhausted.
- **net::http:** Removed unnecessary variable aliases in `get`, `post`,
 `build_get_request`, `build_post_request` — leftover use-after-move workarounds
 no longer needed.
- **net::http:** Fixed `if/if` patterns to `if/else` in `http_send` and `http_close`.

## 1.1.0 — 2026-07-03

### New modules

#### sdl3 — SDL3 video + rendering (`SDL_CreateWindow` + Wayland fix)
```mire
load kioto::sdl3

if sdl3::init_video() {
 set win = sdl3::create_window("My App" 640 480)
 set rend = sdl3::create_renderer(win)
 sdl3::fill_screen(rend 100 150 200) # present first buffer → window appears
 sdl3::delay(3000)
 sdl3::destroy_renderer(rend)
 sdl3::destroy_window(win)
 sdl3::quit()
}
```
Full SDL3 FFI: `SDL_Init`, `SDL_CreateWindow`, `SDL_CreateRenderer`,
`SDL_SetRenderDrawColor`, `SDL_RenderClear`, `SDL_RenderPresent`, `SDL_Delay`.
Wrapper functions handle the Wayland requirement of committing a buffer before the
window is mapped by the compositor (Hyprland, GNOME, etc.).

### Changes

- **sdl3:** New `ext/sdl3` module with correct `:bool` return types for SDL3 C `_Bool`
 functions (`SDL_Init`, `SDL_SetRenderDrawColor`, `SDL_RenderClear`, `SDL_RenderPresent`).
- **sdl3:** Fixed `create_window` parameter type to `:str` (not `:&str`).
- **sdl3:** Window test requires renderer + `fill_screen` for Wayland buffer commit.
- **sdl2:** Fixed `create_window` parameter type from `:&str` to `:str`.
- **Compiler:** Removed debug `eprintln!` lines from `typeck.rs`.

### Design notes

- **SDL3 `:bool` vs SDL2 `:i64`:** SDL3 C API returns `_Bool` for success/failure
 functions; SDL2 returns `int` (0 = success). Module return types must match exactly
 for correct x86_64 ABI (`al` register vs full `rax`).
- **Wayland needs a buffer:** `SDL_CreateWindow` creates the surface but Wayland
 compositors only map it after the first `wl_surface.commit()` with a valid buffer
 attached. Always call `SDL_CreateRenderer` + `SDL_RenderPresent` before waiting.
- **`SDL_Delay` pumps Wayland events** but does not attach a buffer.

## 1.0.0 — 2025-06-25

### New modules

#### json — Full JSON parser, navigator, and builder (`e1a7d5a`)
```mire
set data = json::get(response, "user.name")
set age = json::get(response, "user.age") # "30"
set ok = json::is_valid("{...}")
set t = json::type_of(data, "items") # "object" | "array" | "string" | ...
set keys = json::keys(obj, "") # newline-separated key names
set n = json::len("[1,2,3]", "") # 3
set out = json::object(pairs_vec) # {"k":"v",...}
set out = json::array(items_vec) # [a,b,c]
set safe = json::quoted("hello \"world\"") # escaped + quoted
```
Supports dot-path navigation (`user.tags.0.name`), array indexing, nested objects,
all JSON types (string, number, bool, null, object, array), and string escape/unescape.

#### maybe — Option type (`071d7d3`)
```mire
set m = maybe::some("hello")
if maybe::is_some(m) { use dasu(maybe::unwrap(m)) }
set v = maybe::unwrap_or(maybe::none(), "fallback")
set m2 = maybe::map(m, "mapped")
set m3 = maybe::and_then(m, next_maybe)
```
Tagged-string encoding (`"some:value"` / `"none"`).

#### result — Result type (`071d7d3`)
```mire
set r = result::ok("success")
set e = result::err("fail")
if result::is_ok(r) { use dasu(result::unwrap(r)) }
set v2 = result::unwrap_or(e, "default")
set em = result::unwrap_err(e)
set r2 = result::map(r, "mapped")
set r3 = result::map_err(e, "better error")
```
Tagged-string encoding (`"ok:value"` / `"err:message"`).

#### iter — Iterator utilities (`071d7d3`)
```mire
set parts = strings::split("a\nb\nc", "\n")
set n = iter::count(parts) # 3
set f = iter::first(parts) # "a"
set l = iter::last(parts) # "c"
set el = iter::nth(parts, 1) # "b"
if iter::contains(parts, "b") { ... }
set idx = iter::index_of(parts, "b")
set rng = iter::range(0, 5) # "0\n1\n2\n3\n4"
```
Operates on `vec[str]` (the standard Mire vector type).

#### ws — WebSocket client + server (`392067b`)
```mire
# Client (ws:// and wss:// with auto TLS)
set fd = ws::connect("ws://echo.example.com/")
ws::send::text(fd, "hello")
set msg = ws::recv::all(fd)
ws::close(fd)

# Server
ws::server::accept(client_fd)
set msg = ws::server::recv(client_fd, 65536)
ws::server::send_text(client_fd, "echo: " + msg)
ws::server::close(client_fd)
```
Client frames automatically masked per RFC 6455. Server frames unmasked.
Server PAL per RFC 6455 SS5.2–5.3 (handshake, frame encode/decode, XOR masking,
base64 encoding).

#### net::http server — Request parser + response builder (`757abc2`)
```mire
set method = net::http::req_method(raw) # "GET" / "POST"
set path = net::http::req_path(raw) # "/api/data"
set qs = net::http::req_query(raw) # "a=1&b=2"
set host = net::http::req_header(raw, "Host")
set body = net::http::req_body(raw) # after \r\n\r\n
set ct = net::http::server_mime("style.css") # MIME type
set resp = net::http::resp_200(body, "text/html")
set notf = net::http::resp_404()
set rd = net::http::resp_302("/new-location")
net::http::serve_file(fd, "index.html")
```

### Changes

- **ws:** Server-side PAL functions added (`pal_ws_server_accept/send_text/recv/close`)
 with corresponding LLVM IR declarations. Client PAL rewired to use existing
 `pal_net_*` / `pal_tls_*` functions. (`418f48f` in mire)
- **ws:** Fixed `owl.toml` to export `server` submodule. (`d5cde03`)
- **maybe/result/iter:** Replaced dict-based stubs with tagged-string implementations
 that avoid LLVM codegen edge cases.
- **json:** Moved from planned `core/json` to `ext/json` to match export path.
 All helpers use `&str` borrows to avoid Mire ownership conflicts.
- **http server:** Flattened into `net::http` module to avoid 3-level module
 nesting (`kioto::net::http::server`). Functions prefixed (`server_mime`,
 `req_method`, `resp_200`, etc.) to avoid conflicts with existing client API.

### Design notes

- **Module nesting > 2 levels** requires `owl.toml` in every intermediate directory.
 When possible, flatten to 2 levels or use prefixed function names.
- **`&str` everywhere:** Mire's borrow checker is conservative — passing owned `str`
 to helper functions that consume it prevents further use of the value in the caller.
- **`str mut` building:** Long inline string concatenation can trigger codegen issues.
 Using intermediate variables or delegating to builder functions is more reliable.
- **No binary data in Mire strings:** Mire `str` is UTF-8/C-string. WebSocket frame
 construction requires C PAL functions for binary headers and XOR masking.
- **`rt_vec_get_str` spacing:** `rt_vec_get_str(v(i+1))` is parsed as function call.
 Use `rt_vec_get_str(v, i+1)` or `rt_vec_get_str(v(i+1))` (no space before `(`).
