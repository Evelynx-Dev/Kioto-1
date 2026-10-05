# Text

Every function here works on **bytes**. That is the whole design, and it is
the thing to internalise before reading the tables: a `str` in Mire is a byte
sequence, `strings::len` counts bytes, and `strings::char_at` returns a byte
value even though its name suggests a character.

The consequence is that text is never corrupted — a multi-byte UTF-8 sequence
cannot be split by a truncation that was asked for — but the module is not
codepoint aware, and nothing here knows what a "character" is.

```mire
load kioto::strings

pub fn main: () {
    dasu(strings::upper("hello"))
    dasu(strings::pad::right("7" 3 "0"))
    dasu(strings::replace::all("a-b-c" "-" "_"))
    dasu(strings::from::i64(42))
    dasu(strings::from::bool(true))
}
```

## Inspection

| Call | Returns |
| --- | --- |
| `len(s)` | Byte count |
| `is::empty(s)` | Whether there are zero bytes |
| `contains(s, sub)` | Whether the substring appears |
| `index(s, sub)` | Byte offset of the first occurrence, or `-1` |
| `starts::with(s, prefix)` | Case-sensitive prefix test |
| `ends::with(s, suffix)` | Case-sensitive suffix test |

`index` returning `-1` rather than "not found" is worth knowing: it is a
number, so it can be compared, and adding one to it accidentally is easy.

## Slicing

`substr(s, start, len)` takes a byte offset and a byte count. Both ends are
clamped rather than checked, so an out-of-range request returns the shorter
string instead of failing — including a negative start, which clamps to zero.

`char_at(s, index)` returns the **byte** at an index, as an `i64`. On ASCII
that is the character; on anything else it is one byte of a multi-byte
sequence, and the useful values are the continuation bytes of `0x80`–`0xBF`.
There is no `char_at` that walks codepoints.

`repeat(s, n)` builds a string of `n` copies, and is the way to make room
before a PAL write: `strings::repeat("\0" 256)`.

## Building

`concat(left, right)` joins two strings, and `join(parts, sep)` joins a vector
with a separator. The `+` operator does the same as `concat` for two `str`
values, and is the shorter spelling.

`copy(s)` produces an owned copy of a borrowed string. Reach for it when a
value has to outlive the borrow it came from.

`from::i64`, `from::bool` and `from::f64` render values. The float form uses
`%g`, which is six significant digits — enough for display, and **not**
round-trip safe. A `f64` that must come back exactly needs the explicit
form the caller chooses, not this one.

`to::i64` parses with `atoll`, and returns `0` for anything that is not a
number. There is no "did it parse" answer, so a field that may be empty will
read as zero.

## Editing

`replace::all` and `replace::first` substitute a substring. `trim` and `strip`
are the same function under two names; both remove whitespace from both ends,
which is a behaviour worth checking if you expected only one end.

`pad::left` and `pad::right` pad to a width with a given string. A pad wider
than one character repeats it.

## A worked slice

```mire
load kioto::strings
load mire::vec

pub fn main: () {
    set line = "  name: kioto  "
    set parts = strings::split(strings::trim(line) ":")
    dasu("key is [" + vec::get::str(parts 0) + "]")
    dasu("value is [" + strings::trim(vec::get::str(parts 1)) + "]")
}
```

## What is not here

No regular expressions, no Unicode normalisation, no case folding beyond ASCII
`upper`/`lower`, no locale. `upper` and `lower` are ASCII operations; a `ñ`
passes through unchanged. This is a deliberate line: the module is byte-exact
and predictable, and anything smarter belongs in a layer that can choose its
own trade-off.

## See also

- [Text processing](../examples/strings.md) — worked examples
- [Encoding and hashing](crypto.md) — bytes to base64 and hex
- [`strings` symbol reference](../symbols/strings.md)
