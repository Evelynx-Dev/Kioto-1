# Crypto — symbol reference

Hashing, encoding, checksums, secure randomness and Ed25519 signing. The only module where a mistake is a security mistake, so read the ownership notes before closing a key.

## `crypto::checksum`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::checksum::file` | `file(path :&str) :str` | A content hash of a file's bytes, hex. |
| `crypto::checksum::text` | `text(s :&str) :str` | A content hash of a string, hex. For comparing two things, not for proving authorship: use crypto::sign for that. |
| `crypto::checksum::store_get` | `store_get(store_path :&str, key :&str) :str` | Looks a key up in a checksum store file and returns its recorded value, or the empty string when the store or the key is missing. |
| `crypto::checksum::store_put` | `store_put(store_path :&str, key :&str, value :&str) :bool` | Records a value for a key in a checksum store, creating the file if needed. |
| `crypto::checksum::verify` | `verify(store_path :&str, key :&str, expected :&str) :bool` | Whether the store records exactly this value for this key, which is the question a lockfile or a manifest actually asks. |

## `crypto::encode::base64`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::encode::base64::encode` | `encode(bytes :vec[i64]) :str` | Bytes to base64, with the padding a decoder expects. |
| `crypto::encode::base64::decode` | `decode(s :&str) :vec[i64]` | Base64 back to bytes, as a vector of 0 to 255. |
| `crypto::encode::base64::encode_file` | `encode_file(path :&str) :str` | The whole file base64-encoded, for handing binary over a text channel. |

## `crypto::encode::hex`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::encode::hex::encode` | `encode(bytes :vec[i64]) :str` | Bytes to hex, lowercase, two characters per byte. |
| `crypto::encode::hex::decode` | `decode(s :&str) :vec[i64]` | Hex back to bytes, as a vector of 0 to 255. Anything that is not a pair of hex digits ends the conversion. |

## `crypto::hash`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::hash::sha256` | `sha256(msg :&str) :str` | SHA-256 of a message, lowercase hex. |
| `crypto::hash::sha512` | `sha512(msg :&str) :str` | SHA-512 of a message, lowercase hex. |
| `crypto::hash::sha256_file` | `sha256_file(path :&str) :str` | File variants read the whole file binary-safely (embedded NULs preserved), so they hash tarballs and other opaque payloads correctly. |
| `crypto::hash::sha512_file` | `sha512_file(path :&str) :str` | SHA-512 of a file's bytes, lowercase hex. Reads the whole file, so the cost is the file size. |

## `crypto::hash::sha256`

### `crypto::hash::sha256::hash`

```mire
hash(msg :&str) :str
```

SHA-256, lowercase hex. The namespace the parent forwards to.

## `crypto::hash::sha512`

### `crypto::hash::sha512::hash`

```mire
hash(msg :&str) :str
```

SHA-512, lowercase hex. The namespace the parent forwards to.

## `crypto::random::secure`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::random::secure::bytes` | `bytes(n :i64) :vec[i64]` | n cryptographically secure random bytes, as a vector of 0 to 255. This is the one random source to reach for when the output has to be unpredictable: math::random is seeded and reproducible by design. |
| `crypto::random::secure::seed` | `seed(size :i64) :str` | size random bytes rendered as a hex string, which is the shape a seed or a key file usually wants. |
| `crypto::random::secure::i64` | `i64() :i64` | A random 64-bit integer. Note the asymmetry with math::random::nextInt, which is bounded and reproducible. |

## `crypto::sign::ed25519`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `crypto::sign::ed25519::secret` | `secret()` | The private half, and the only asymmetric signing this module offers. |
| `crypto::sign::ed25519::public` | `public()` | The public half, for the side that only checks. |

## `crypto::sign::ed25519::secret`

### `crypto::sign::ed25519::secret::new`

```mire
new() :SecretKey
```

A fresh key pair from the system entropy source.

### `crypto::sign::ed25519::secret::public`

```mire
public(secret :SecretKey) :PublicKey
```

The public key that matches a secret key.

### `crypto::sign::ed25519::secret::sign`

```mire
sign(secret :SecretKey, msg :&str) :str
```

Signs a message, returning the signature as the raw 64 bytes the algorithm produces, or an empty string if signing failed.

Raw, not base64, so that it pairs with `verify`, which reads a raw signature. About one signature in five contains a NUL byte, so a raw signature is not safe to store in a string, write to a file as text, or print. The base64 forms are separate functions.

### `crypto::sign::ed25519::secret::close`

```mire
close(secret :SecretKey)
```

Releases the secret key. After this the signature it produced is the only copy of anything that can reproduce it. Releases the public key handle.

## `crypto::sign::ed25519::public`

### `crypto::sign::ed25519::public::verify`

```mire
verify(pubkey :PublicKey, msg :&str, sig :&str) :bool
```

Whether a signature is this key's signature over this message. The signature is the raw 64 bytes `sign` produces, not base64; the base64 forms live in `verify_b64` and `verify_file`.

### `crypto::sign::ed25519::public::verify_b64`

```mire
verify_b64(pubkey_b64 :&str, data_file :&str, sig_b64 :&str) :bool
```

The same check, reading the message from a file and the public key as base64 rather than as a handle. This is the shape a registry or a lockfile check uses, where nothing is loaded into memory first.

### `crypto::sign::ed25519::public::verify_file`

```mire
verify_file(pubkey_b64 :&str, data_file :&str, sig_file :&str) :bool
```

As verify_b64, with the signature in a file too.

### `crypto::sign::ed25519::public::raw_b64_from_pem`

```mire
raw_b64_from_pem(pem_path :&str) :str
```

The raw key bytes of a PEM file, base64 encoded, which is the form verify_b64 expects.

### `crypto::sign::ed25519::public::close`

```mire
close(pubkey :PublicKey)
```

The public half, for the side that only checks.
