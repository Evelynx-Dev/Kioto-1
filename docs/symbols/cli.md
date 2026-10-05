# CLI — symbol reference

Turning a raw argument vector into a lookup table, and nothing else.

## `cli`

### `cli::parse`

```mire
parse(raw :&vec[str]) :map[str str]
```

Turns a raw argument vector into a lookup table: argv[0] lands under "command", and every --flag takes the argument after it as its value. A flag with nothing behind it is stored as "1", which is enough for a boolean switch and keeps the caller free of a second pass.
