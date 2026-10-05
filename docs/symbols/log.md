# Log — symbol reference

Three lines on stdout. No level filter, no timestamping, on purpose.

## `log`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `log::info` | `info(msg :&str)` | Writes msg to stdout behind an [INFO] prefix. There is no level filter and no timestamp: a log line is a line, and the prefix is the whole protocol. |
| `log::warn` | `warn(msg :&str)` | Writes msg to stdout behind a [WARN] prefix. See log::info. |
| `log::error` | `error(msg :&str)` | Writes msg to stdout behind an [ERROR] prefix. Note that it goes to stdout, not stderr, so it stays in order with the lines around it. |
