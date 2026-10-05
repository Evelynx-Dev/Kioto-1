# Strings — symbol reference

Byte-oriented text. Every function is UTF-8 safe in the sense that it never corrupts a sequence, and none of them is codepoint aware.

## `strings`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `strings::len` | `len(s :&str) :i64` | Length in bytes, not in codepoints. Every other function in this module also works in bytes, so the two never disagree. |
| `strings::upper` | `upper(s :&str) :str` | ASCII uppercase. Bytes above 127 are left alone, because the module has no table for them and a wrong capital is worse than a missing one. |
| `strings::lower` | `lower(s :&str) :str` | ASCII lowercase, with the same limit as strings::upper. |
| `strings::trim` | `trim(s :&str) :str` | Removes whitespace from both ends, where whitespace is every byte at or below a space: spaces, tabs, newlines and carriage returns alike. |
| `strings::strip` | `strip(s :&str) :str` | The same operation as strings::trim, under the other name v2 exposed. New code should pick one; trim is the one this module documents. |
| `strings::contains` | `contains(s :&str, sub :&str) :bool` | Whether sub appears anywhere in s. An empty sub is contained in everything. |
| `strings::index` | `index(s :&str, sub :&str) :i64` | Byte offset of the first occurrence of sub, or -1 when it is not there. An empty sub is found at offset 0. -1 is the only failure signal, so a result of 0 has to be read as "found at the front", not "not found". |
| `strings::split` | `split(s :&str, sep :&str) :vec[str]` | Splits on every occurrence of sep, keeping empty fields: splitting "a,,b" on "," gives three parts. An empty sep does not split at all and returns the whole string as one part. |
| `strings::join` | `join(parts :&vec[str], sep :&str) :str` | The inverse of split, and the way to build a path list or a line out of parts without a loop. |
| `strings::substr` | `substr(s :&str, start :i64, len :i64) :str` | A slice of s, clamped rather than checked: a negative start becomes 0, a length that runs past the end is cut short, and a length of zero or less gives the empty string. Nothing here fails, so nothing here needs a bounds check at the call site. |
| `strings::repeat` | `repeat(s :&str, n :i64) :str` | s repeated n times. A count of zero or less gives the empty string. |
| `strings::char_at` | `char_at(s :&str, index :i64) :i64` | The byte at an index, as 0 to 255, and 0 for an index outside the string. A byte, not a codepoint: for anything beyond ASCII the caller has to walk the leading bytes of a UTF-8 sequence to find the character boundaries. |
| `strings::concat` | `concat(left :&str, right :&str) :str` | The two strings joined, as a new value. This is also the + operator on two strings, spelled as a function so it can be passed around. |
| `strings::copy` | `copy(s :&str) :str` | A second, independent reference to the same bytes. Needed whenever a string is about to be moved by a call that takes it by value but is going to be called again with the original. |
| `strings::starts` | `starts()` | Prefix and suffix tests, kept together because they are the two halves of the same question. |
| `strings::ends` | `ends()` | Suffix tests. The mirror of starts, and the one to reach for when a file name is what you are checking. |
| `strings::replace` | `replace()` | Substitution, all occurrences or just the first. Both leave the string alone when old is not in it, and neither can loop forever: the replacement is not rescanned. |
| `strings::pad` | `pad()` | Pads to a minimum width with the given filler, which may be longer than one character and gets cut to fit. A string already at or over the width comes back unchanged, so the call is safe to make unconditionally. |
| `strings::from` | `from()` | Conversions out of a scalar, and the only way to see one: Mire has no implicit string conversion and no println, so printing means dasu(str). |
| `strings::to` | `to()` | Parsing a string back into a scalar. |
| `strings::is` | `is()` | The shape questions, as opposed to the content ones. |

## `strings::starts`

### `strings::starts::with`

```mire
with(s :&str, prefix :&str) :bool
```

Whether the string ends with this suffix, case-sensitively.

## `strings::ends`

### `strings::ends::with`

```mire
with(s :&str, suffix :&str) :bool
```

Suffix tests. The mirror of starts, and the one to reach for when a file name is what you are checking.

## `strings::replace`

### `strings::replace::all`

```mire
all(s :&str, old :&str, new :&str) :str
```

Substitution, all occurrences or just the first. Both leave the string alone when old is not in it, and neither can loop forever: the replacement is not rescanned.

### `strings::replace::first`

```mire
first(s :&str, old :&str, new :&str) :str
```

Substitution, all occurrences or just the first. Both leave the string alone when old is not in it, and neither can loop forever: the replacement is not rescanned.

## `strings::pad`

### `strings::pad::left`

```mire
left(s :&str, width :i64, pad :&str) :str
```

Pads to a minimum width with the given filler, which may be longer than one character and gets cut to fit. A string already at or over the width comes back unchanged, so the call is safe to make unconditionally.

### `strings::pad::right`

```mire
right(s :&str, width :i64, pad :&str) :str
```

Pads to a minimum width with the given filler, which may be longer than one character and gets cut to fit. A string already at or over the width comes back unchanged, so the call is safe to make unconditionally.

## `strings::from`

### `strings::from::i64`

```mire
i64(value :i64) :str
```

The decimal form of an integer, with a leading minus and nothing else.

### `strings::from::bool`

```mire
bool(value :bool) :str
```

"true" or "false". Takes a :bool because that is the type a condition produces; there is no integer-to-bool conversion to lean on.

### `strings::from::f64`

```mire
f64(value :f64) :str
```

Six significant digits, %g style: 3.14159265 prints as "3.14159". Enough to show a value at a glance, not enough to round-trip one, so never use it to serialise a number you intend to read back exactly.

## `strings::to`

### `strings::to::i64`

```mire
i64(value :&str) :i64
```

The leading integer of the string, and 0 for anything that does not start with one, because the parse is atoll and atoll has no error channel. Check strings::starts::with for a digit if the difference matters.

## `strings::is`

### `strings::is::empty`

```mire
empty(s :&str) :bool
```

Length zero. There is no blank test: a string of spaces is not empty.
