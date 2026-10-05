# Net — symbol reference

TCP and UDP through the PAL. Thin bindings: the semantics are the sockets exactly as the kernel implements them.

## `net`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `net::PAL_SOCKET_TCP` | `PAL_SOCKET_TCP() :i32` | The two socket types, as functions rather than constants because a cons in this module would be the only one in the package. Call them; the value is not meant to be reasoned about. Socket type constants |
| `net::PAL_SOCKET_UDP` | `PAL_SOCKET_UDP() :i32` | The protocol selectors, as functions rather than constants because a bare number in source would be a magic value with nothing to explain it. Pass the result to connect, bind or listen. |
| `net::socket` | `socket()` | ── socket ────────────────────────────────────────────────────── One end of a connection. connect for the client side, listener for the server side. |
| `net::listener` | `listener()` | ── listener ──────────────────────────────────────────────────── The server side: bind a port, then accept or, for UDP, send and receive on the listener itself. |

## `net::socket`

### `net::socket::connect`

```mire
connect()
```

── socket ────────────────────────────────────────────────────── One end of a connection. connect for the client side, listener for the server side.

### `net::socket::send`

```mire
send(sock :&Socket, data :&str) :i64
```

Sends the whole string and returns the byte count written.

### `net::socket::recv`

```mire
recv(sock :&Socket, buf :&mut str, max_len :i64) :i64
```

Reads up to max_len bytes into buf and returns how many arrived. buf must have that much room: strings::repeat("\0" n).

### `net::socket::close`

```mire
close(sock :&Socket)
```

Closes the socket.

## `net::socket::connect`

### `net::socket::connect::tcp`

```mire
tcp(host :&str, port :u16) :Socket
```

Connects over TCP. port is a :u16, so a bare integer literal will not do: write 8080 :u16.

### `net::socket::connect::udp`

```mire
udp(host :&str, port :u16) :Socket
```

Opens an unconnected UDP socket aimed at host and port. There is no handshake, so a bad address is not reported until the first send.

## `net::listener`

### `net::listener::bind`

```mire
bind()
```

── listener ──────────────────────────────────────────────────── The server side: bind a port, then accept or, for UDP, send and receive on the listener itself.

### `net::listener::accept`

```mire
accept(listener :&Listener) :Socket
```

Blocks until a peer connects and returns the socket for that one connection. The listener stays open, so this can be called in a loop.

### `net::listener::send`

```mire
send(listener :&Listener, data :&str) :i64
```

Sends on a UDP listener, because a UDP socket has no connection to send through.

### `net::listener::recv`

```mire
recv(listener :&Listener, buf :&mut str, max_len :i64) :i64
```

Receives on a UDP listener, same reason.

### `net::listener::close`

```mire
close(listener :Listener)
```

Closes the listener.

## `net::listener::bind`

### `net::listener::bind::tcp`

```mire
tcp(port :u16) :Listener
```

Binds a TCP port. A handle of 0 or less means the bind failed, most often because the port is already in use.

### `net::listener::bind::udp`

```mire
udp(port :u16) :Listener
```

Binds a UDP port.
