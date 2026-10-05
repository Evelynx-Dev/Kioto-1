# Hashing, encoding and signing

This is the one module where a mistake is a security mistake rather than a
correctness one, so it is written to make the safe choice the easy one.

Five groups, and the distinction between the first two is the one that matters
most:

| Group | Answers |
| --- | --- |
| [`hash`](#digests) | Has this content changed? |
| [`checksum`](#checksum-stores) | Has this file changed since the store said? |
| [`encode`](#encoding) | How do I write these bytes down? |
| [`random::secure`](#randomness) | Where does unpredictable data come from? |
| [`sign::ed25519`](#signing) | Who wrote this? |

`hash` compares content. Only `sign` establishes authorship. A digest proves
that two things are the same, which is not the same as proving where either
came from — anyone can hash a file they just modified.

## Digests

```mire
load kioto::crypto

pub fn main: () {
    dasu(hash::sha256("hello"))
    dasu(hash::sha512("hello"))
    dasu(hash::sha256_file("/etc/hostname"))
}
```

`sha256` and `sha512` return lowercase hex. The `_file` variants read the file
**binary-safely**, so embedded NULs survive and a tarball hashes correctly —
which is exactly the case `fs::read` cannot handle. The cost is that the whole
file is read; there is no streaming variant.

`sha256::hash` and `sha512::hash`, one level deeper, are the same operations
before hex encoding. Prefer the `hash::` spelling; the deeper names exist
because the hex wrapper is the one you want.

## Checksum stores

A checksum store is a `key = value` text file. The point is answering "does
this file still match what the manifest recorded?" without shelling out.

```mire
load kioto::crypto

pub fn main: () {
    set digest = checksum::file("/srv/app/bin/tool")
    checksum::store_put("/srv/app/owl.lock" "tool" digest)
    if checksum::verify("/srv/app/owl.lock" "tool" digest) {
        dasu("unchanged")
    } else {
        dasu("the binary does not match the lockfile")
    }
}
```

`store_put` rewrites one key and preserves the rest. `store_get` returns `""`
for a missing store or a missing key, and `verify` returns `false` if either
the stored value or the expected value is empty — an absent entry is never a
match.

## Encoding

Bytes go in as `vec[i64]`, and text comes out.

```mire
load kioto::crypto
load kioto::strings
load mire::vec

pub fn main: () {
    set bytes = [] :vec[i64] mut
    set i = 0 :i64 mut
    while i < strings::len("hi") {
        set bytes = vec::push::i64(bytes, strings::char_at("hi" i))
        set i = i + 1
    }
    set copy = vec::clone(bytes)
    dasu(hex::encode(bytes))
    dasu(base64::encode(copy))
}
```

`hex::encode` takes its `vec[i64]` **by value**, which consumes it, so a
second encode of the same vector is a use-after-move error. `vec::clone` makes
the copy that lets both run; a borrow-taking signature would have been the
other answer.

`base64::encode_file` reads and encodes a whole file in one call; there is no
`hex::encode_file`, because hex is for text and `hash::sha256_file` covers the
binary case. Both `decode` functions return a `vec[i64]` of byte values, and
neither reports a malformed input — a bad character is skipped or produces a
shorter result, so do not treat a decode as validation.

## Randomness

There are two random sources in the package and they are not
interchangeable.

- **`crypto::random::secure`** draws from the operating system's entropy
  source. Unpredictable, not reproducible, the right choice for keys, tokens
  and nonces.
- **`math::random`** is seeded and reproducible by design. It is for sampling,
  jitter and test fixtures, where being able to replay a sequence is the point.

```mire
load kioto::crypto

pub fn main: () {
    set token = random::secure::seed(32)     // 32 random bytes, as hex
    set n = random::secure::i64()
    dasu("token: " + token)
}
```

`secure::bytes(n)` returns the raw bytes when you want them as a vector;
`seed(size)` is the same thing rendered as hex, which is the shape a key file
usually wants. A failure returns an empty vector or `""` rather than raising.

## Signing

Ed25519, and the names nest one level deeper than you would guess: after
`load kioto::crypto` the namespace is `ed25519`, because the file is called
`ed25519.mr`.

```mire
load kioto::crypto

pub fn main: () {
    set secret = ed25519::secret::new()
    set sig = ed25519::secret::sign(secret "the message")
    dasu("signature: " + sig)
}
```

> **Limitation — a secret key is consumed by its first use.** Both
> `secret::public` and `secret::sign` take the `SecretKey` **by value**, so
> whichever runs first takes the handle and the other is a use-after-move
> error:
>
> ```mire
> set secret = ed25519::secret::new()
> set pubkey = ed25519::secret::public(secret)   // secret is gone here
> set sig = ed25519::secret::sign(secret "msg")  // ownership error
> ```
>
> There is no signing entry point that takes a public key, so **a sign and a
> verify cannot be done in one program**: the only way to obtain a `PublicKey`
> is to spend the secret on it, and once spent the secret cannot sign. A
> program that publishes a key and a program that signs have to be separate
> steps, with the key material passed between them. This is a design gap in
> the module rather than a rule to remember — a signing key that can be used
> once is not a usable signing key.

Deriving a public key on its own is fine:

```mire
load kioto::crypto

pub fn main: () {
    set secret = ed25519::secret::new()
    set pubkey = ed25519::secret::public(secret)
    ed25519::public::close(pubkey)
    dasu("derived and released a public key")
}
```

For checking a signature without holding keys in memory, the file-oriented
pair is the one to reach for:

```mire
load kioto::crypto

pub fn main: () {
    set key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA"
    if ed25519::public::verify_file(key "/srv/app/owl.lock" "/srv/app/owl.lock.sig") {
        dasu("lockfile is signed by the expected key")
    } else {
        dasu("signature check failed")
    }
}
```

`verify_b64` is the same with the signature inline as base64 rather than in a
file, and `raw_b64_from_pem` converts a PEM file to the base64 form those two
expect. A failure anywhere in that chain is a `false`, never an exception.

## What this module will not do

There is no symmetric encryption, no key derivation, no certificate handling
and no key storage. A secret key exists in memory until you close it, and
kioto has nowhere to put one safely — that is a job for the system keyring,
which a library should not be writing to behind your back.

## See also

- [Hashing and signing](../examples/crypto.md) — worked examples
- [Security](../guides/security.md) — the properties the package holds to
- [`crypto` symbol reference](../symbols/crypto.md)
