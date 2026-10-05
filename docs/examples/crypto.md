# Hashes and signatures

Two different jobs: proving two things are the same, and proving where one of
them came from. Only one of those is cryptography.

## Digests

```mire
load kioto::crypto
load kioto::strings

pub fn main: () {
    set a = hash::sha256("hello")
    set b = hash::sha256("hello")
    set c = hash::sha256("hellp")
    dasu("a == b: " + strings::from::bool(a == b))
    dasu("a == c: " + strings::from::bool(a == c))
    dasu("sha256(hello) = " + a)
    dasu("64 hex chars: " + strings::from::i64(strings::len(a)))
}
```

The output is lowercase hex, always 64 characters for SHA-256 and 128 for
SHA-512. `hash::sha256::hash` is the same digest without the hex wrapper, so
the two are interchangeable only if you convert.

**A digest is not a signature.** Anyone can hash a file they just modified.
If the source matters, sign it — see below.

## Digesting a file

```mire
load kioto::crypto
load kioto::strings

pub fn main: () {
    set path = "/tmp/kioto-demo.bin"
    fs::write(path "abc")
    dasu("sha256: " + hash::sha256_file(path))
    dasu("sha512: " + hash::sha512_file(path))
}
```

The `_file` variants read the file without stopping at NUL, so a tarball
digests correctly. `fs::read` cannot do that — it truncates at the first NUL
and reports no error.

## Base64 and hex

```mire
load kioto::crypto
load kioto::strings
load mire::vec

pub fn main: () {
    set raw = hex::decode("48656c6c6f")
    dasu("decoded " + strings::from::i64(vec::len(raw)) + " bytes")
    dasu("re-encoded: " + hex::encode(raw))
}
```

There is no bytes-to-`str` function, and there cannot be one: the bytes are
arbitrary, and a `str` in this runtime is length-prefixed with an embedded
NUL in the middle truncates. Printing decoded bytes is what
`vec::get::i64` and `strings::from::i64` per byte are for.

Both encoders **consume** the vector. Calling `hex::encode` twice on the same
variable is a use-after-move error, so clone it first if you need it twice:

```mire
set copy = vec::clone(raw)
dasu(hex::encode(raw))
dasu(base64::encode(copy))
```

## Randomness

```mire
load kioto::crypto
load kioto::strings

pub fn main: () {
    set token = random::secure::bytes(16)
    set again = random::secure::bytes(16)
    set same = vec::len(token) == vec::len(again) && token == again
    dasu("token: " + hex::encode(token))
    dasu("two draws identical: " + strings::from::bool(same))
}
```

`crypto::random::secure` draws from the operating system's entropy source.
`math::random` is seeded and reproducible on purpose — right for sampling and
test fixtures, wrong for a token, a nonce or anything an attacker benefits from
predicting. Nothing about the output distinguishes the two, so the choice has
to be deliberate.

## Signing

`sign::ed25519` produces a real signature. A signature can be verified by
anyone holding the public key, which is what makes it useful and what a digest
cannot do.

The limitation is in the key's ownership, and it shapes the API:

**a `SecretKey` is consumed by its first use.** Deriving the public key with
`public()` spends it, and so does `sign()`. Deriving and signing is
consequently two programs, or a `vec::clone` of the key.

Deriving the public key:

```mire
load kioto::crypto
load kioto::strings

pub fn main: () {
    set sk = ed25519::secret::new()
    set h = sk.handle
    set pk = ed25519::secret::public(sk)
    dasu("secret handle " + strings::from::i64(h))
    dasu("public handle " + strings::from::i64(pk.handle))
}
```

Reading `sk.handle` has to come first, for the reason in the section above: the
derivation spent the key.

`SecretKey` and `PublicKey` are **opaque handles**, not byte strings — they
wrap a `pal_secret` handle and nothing else. There is no `to_bytes`, and
`base64::encode` will not accept one, because it takes a `vec[i64]` and these
are structs. The one route to a string form is
`ed25519::public::raw_b64_from_pem(path)`, which reads a PEM file, so
publishing a key means writing the PEM out first.

Signing with a key that was cloned for the purpose:

```mire
set sk = ed25519::secret::new()
set sk2 = vec::clone(sk)
set pk = ed25519::secret::public(sk2)
set sig = ed25519::secret::sign(sk "the document")
dasu("public key: " + base64::encode(pk))
dasu("signature:  " + sig)
```

Two details worth knowing: `sign` returns the signature as the **raw 64
bytes** the algorithm produces, not base64, which is what
`ed25519::public::verify(pk, msg, sig) :bool` checks in memory. A signature is
arbitrary binary and roughly one in five contains a NUL byte, so never write
that string to a file as text — for a signature on disk use
`public::verify_file(pubkey_b64, data, sig)`, which takes the signature as a
raw 64-byte file, or `verify_b64` when it arrives inline as base64. The public
key comes from the **secret** group, `ed25519::secret::public(sk)`, not
`public::from_secret`.

What Ed25519 does not give you here: there is no encryption, no key derivation
and nowhere safe to keep a key. `secret::close` is the only explicit release,
and it is unreachable once the key has been used. Key material that matters
belongs in the system keyring.

## What is missing

No TLS, no symmetric cipher, no password hashing. `net` gives plain sockets and
`crypto` gives digests, randomness and signatures — so anything crossing a
network has to be protected by something else.

## See also

- [Signing and encoding](../modules/crypto.md) — the full API
- [Security](../guides/security.md) — digests versus signatures, and the rest
- [`fs::read` and binary files](files.md#reading-bytes-with-a-sized-buffer)
