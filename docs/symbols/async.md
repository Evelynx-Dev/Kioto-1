# Async — symbol reference

Pipes between places, plus a thin process layer. The rule worth memorising: a receive buffer has to be big enough *before* the read, because the read does not resize it.

## `async`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `async::task` | `task()` | ── task ──────────────────────────────────────────────────────── Values in flight, for the case where a result is produced now and read later. |
| `async::channel` | `channel()` | ── channel ───────────────────────────────────────────────────── The pipe itself, plus the one rule that catches everyone: a receive buffer must already have room for the bytes you expect, or the write lands past the end of it. strings::repeat("\0" n) is how you make room. |
| `async::spawn` | `spawn(cmd :&str) :i64` | ── process ───────────────────────────────────────────────────── Starts a program and returns its process id, without waiting. The command is the program path and nothing else: it is not split on spaces, so "ls -l" looks for a file with that exact name and the child exits 127. Use proc::run::spawn when there are arguments to pass. |
| `async::wait` | `wait(pid :i64) :i64` | Waits for a process id from async::spawn and returns its status. |

## `async::task`

### `async::task::ready`

```mire
ready(value :str) :Task
```

Wraps a value as a finished task. Nothing is scheduled and nothing can fail, which is the point: the caller can stop branching on whether the work is done.

### `async::task::value`

```mire
value(t :Task, fallback :str) :str
```

The value inside a task, or fallback when there is none. Taking a fallback rather than returning Maybe keeps the call site free of a match, at the cost of having to invent a default.

## `async::channel`

### `async::channel::create`

```mire
create() :Channel
```

An open channel. Nothing flows until a process or a thread is attached to one of the ends.

### `async::channel::send`

```mire
send(ch :&Channel, data :&str) :i64
```

Writes data to the channel, returning the byte count or -1. The data is copied, so the caller's string is unaffected.

### `async::channel::recv`

```mire
recv(ch :&Channel, buf :&mut str, cap :i64) :i64
```

Reads up to cap bytes into buf and returns how many arrived, 0 at end of stream. buf must have cap bytes of room.

### `async::channel::close`

```mire
close(ch :&Channel)
```

Closes the channel. Both ends have to be closed for a reader to see the end of the stream.
