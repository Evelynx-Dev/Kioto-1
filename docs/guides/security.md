# Security

What this package guarantees, what it deliberately does not, and where the
sharp edges are. The summary is short: kioto's crypto is real, its process API
is argv-safe, and its removal API never follows a symlink. The sharp edges are
all in how handles are passed and in what the language cannot express.

## What is actually enforced

### Removal never follows a symlink

`fs::remove` and `fs::remove_all` unlink the **link**, never the target. A
symlink named `data` pointing at `/etc` loses the link; `/etc` is untouched,
even though the link sits inside a root that was opened with `..` refused.

This is the property that makes removal safe on a tree you did not build, and
it holds for `remove_all` too — the recursion is host-side and goes through
the same single-entry primitive.

`..` is refused during path resolution as well, so a path cannot climb out of a
`Root` by construction rather than by a check that could be missed.

### Processes are argv-safe

`proc::run::output` and `proc::run::output_cwd` take a program path and a
`vec[str]` of arguments. Nothing is re-parsed and no shell is involved, so an
argument containing a space, a quote, `;` or `$(...)` arrives as **one
argument** and cannot become a second command.

There is no shell function in the package, and the legacy shell surface in the
underlying PAL layer is compiled out by default. There is no way to run a
command line through `/bin/sh` from Mire.

**One exception, and it is a real one:** `async::spawn(cmd)` takes a single
string and splits it itself. It is fine for a command you wrote and wrong for
anything assembled from parts, because it has no way to express an argument
containing whitespace. Use `proc::run::output` with a vector whenever the
command is not entirely literal.

### Randomness has two sources, and they are labelled

`crypto::random::secure` draws from the operating system's entropy source and
is unpredictable. `math::random` is seeded and reproducible by design.

Choosing the wrong one is the failure mode: a token, a nonce or a key made
with `math::random` is guessable, and nothing about the result looks different
from a secure one. `math::random` exists for sampling and test fixtures, where
replay is the point.

### Digests are hex, and file variants are binary-safe

`hash::sha256` and `hash::sha512` return lowercase hex. The `_file` variants
read the file without stopping at NUL, so a tarball hashes correctly — which
`fs::read` cannot do.

## What is not enforced

**A digest is not a signature.** `hash::sha256` proves two things are the same,
not where either came from. Anyone can hash a file they just modified. Only
`sign::ed25519` establishes authorship, and note its current limitation: a
`SecretKey` is consumed by its first use, so publishing a key and signing with
it are separate steps by necessity.

**No encryption, no key storage.** There is no symmetric cipher, no key
derivation and nowhere safe to put a key. A `SecretKey` lives in memory until
the process ends, and `secret::close` — the only explicit release — is
unreachable once the key has been used. Key material that matters belongs in
the system keyring, not in a kioto program.

**No transport security.** `net` gives plain TCP and UDP. There is no TLS, so
a socket carrying anything sensitive is readable on the path. `accept` also
has no timeout, which is a liveness problem rather than a confidentiality one.

**`cli::parse` does no validation.** It splits flags and nothing more. A value
that arrives from the command line and is about to be used as a path or a port
has to be checked by the caller — `strings::to::i64` returns `0` for anything
unparseable, which is not a safe default for a count.

## Sharp edges

### The `&mut str` buffer

Every PAL read — `fs::file::read`, `async::channel::recv`,
`net::socket::recv`, `net::listener::recv` — writes into a buffer the caller
allocated, up to the length the caller claimed, and **does not grow it**. An
empty or short destination is a heap overflow, not a caught error.

```mire
set buf = strings::repeat("\0" 4096) :str mut
set n = fs::file::read(f buf 4096)
```

The allocation and the length passed must agree. This is the one place where a
mistake corrupts memory instead of stopping cleanly, and it is why the
preallocation idiom appears in every example in this documentation.

### Descriptors are never released

`fs::file::read` consumes the `File` and `file::open::*` consumes the `Root`,
so neither `file::close` nor `root::close` is reachable after a handle has been
used. A long-running program that opens files in a loop will accumulate
descriptors until the process ends. Same story for a `SecretKey`.

### UDP discards what does not fit

A datagram larger than the receive buffer is **dropped**, not truncated. A
stream short read means the rest arrives next call; for UDP the message is
gone. Size the buffer for the largest datagram you intend to accept.

### `fs::read` truncates at NUL

Reading a binary file with `fs::read` returns a shorter string and no error.
Use `hash::*_file` for a digest, or a sized `file::read` for the bytes.

## Checklist for a program that touches untrusted input

- Paths from outside the program: resolve them through a `Root`, never whole.
- Commands: `proc::run::output` with a vector, never `async::spawn` with a
  built string.
- Random values: `crypto::random::secure`, never `math::random`.
- Integrity from an untrusted source: a signature, not a digest.
- Every PAL read: buffer allocated with `strings::repeat`, length matching.
- Removal on a tree you did not build: `remove_all` is symlink-safe, so it is
  the right call.

## See also

- [Ownership](ownership.md) — handle consumption in detail
- [Errors](errors.md) — which failures are loud and which are quiet
- [Signing](../modules/crypto.md#signing) and
  [Files and capabilities](../modules/fs.md#removal-and-symlinks)
- [Known limitations](../inventory.md#known-limitations)
