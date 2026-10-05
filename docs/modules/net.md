# Sockets

TCP and UDP, with the same shape for both: connect or bind, then send and
recv, then close. The differences are real but small, and the buffer rule is
identical to every other PAL read in the package.

## Connecting out

The port is a `u16`, and a `u16` **variable** is how it has to be passed —
see the limitation below.

```mire
load kioto::net
load kioto::strings

pub fn main: () {
    set port = 80 :u16
    set sock = net::socket::connect::tcp("example.com" port)
    if sock.handle < 0 {
        dasu("no connection")
    } else {
        net::socket::send(&sock "GET / HTTP/1.0\r\n\r\n")
        set buf = strings::repeat("\0" 4096) :str mut
        set n = net::socket::recv(&sock buf 4096)
        dasu("got " + strings::from::i64(n) + " bytes")
        net::socket::close(&sock)
    }
}
```

A negative `handle` is the failure signal, and it is the only one — the call
does not raise. `socket::close` takes a reference, so a socket can be closed
from any branch that can see the handle.

## Serving

```mire
load kioto::net
load kioto::strings

pub fn main: () {
    set port = 8080 :u16
    set srv = net::listener::bind::tcp(port)
    if srv.handle < 0 {
        dasu("port 8080 is not available")
    } else {
        set client = net::listener::accept(&srv)
        if client.handle >= 0 {
            set buf = strings::repeat("\0" 1024) :str mut
            set n = net::listener::recv(&srv buf 1024)
            dasu("request was " + strings::substr(buf 0 n))
            net::socket::close(&client)
        }
        net::listener::close(srv)
    }
}
```

`listener::close` takes the listener **by value** while `accept`, `send` and
`recv` take a reference. The asymmetry is real: the handle is consumed by
close, so it cannot be closed twice.

`listener` also has `send` and `recv` of its own, which act on the bound
socket itself. They exist for the UDP case below, where there is no
connection to mediate.

## UDP

`bind::udp` and `connect::udp` give a datagram socket. A datagram is a
message rather than a stream, so the useful pairing is the listener's own
`send`/`recv` with a connected peer:

```mire
load kioto::net
load kioto::strings

pub fn main: () {
    set port = 9000 :u16
    set srv = net::listener::bind::udp(port)
    set peer = net::socket::connect::udp("127.0.0.1" port)
    if srv.handle >= 0 && peer.handle >= 0 {
        net::socket::send(&peer "ping")
        set buf = strings::repeat("\0" 512) :str mut
        set n = net::listener::recv(&srv buf 512)
        dasu("datagram: " + strings::substr(buf 0 n))
    }
    net::listener::close(srv)
    net::socket::close(&peer)
}
```

The buffer rule applies to datagrams too, and a UDP datagram larger than the
buffer is **discarded** rather than truncated — unlike a stream, where a short
buffer just means a short read and the rest arrives on the next call. Size the
buffer for the largest datagram you intend to accept.

## Limitations

**Bind the port to a variable first.** A `u16` argument passed inline — as
`(80 :u16)` or as a bare literal — is misparsed whenever it is the second or
later argument of a call, and the compiler reports `call expects function
callback, got Str` or `Unknown function '<name>'` pointing at the *host*
argument, not the port. Binding the port to a `u16` variable before the call
works in every case shown above:

```mire
set port = 80 :u16
set sock = net::socket::connect::tcp("example.com" port)
```

A `u16` as the only argument (`net::listener::bind::tcp((9000 :u16))`) is
fine, so the rule to carry around is narrow: **when a call has more than one
argument, bind the port to a variable.**

**`load kioto::net` is not enough to reach the functions.** The module
resolves as `net::socket::connect::tcp`, with the package name as the outermost
segment. The flattened form `socket::connect::tcp` does not resolve, because
`net`'s own file is `mod.mr` and contributes no namespace of its own.

**`accept` blocks.** There is no timeout and no non-blocking mode, so a
server waits on the next connection indefinitely.

## The protocol constants

`PAL_SOCKET_TCP()` and `PAL_SOCKET_UDP()` return the protocol word the backend
expects. The `connect::` and `bind::` functions already pass the right one, so
calling them is only necessary when driving a raw socket yourself.

## What is not here

No TLS, no name resolution beyond what the host provides, no IPv6 selection, no
timeouts, and no `select`. A connection is a plain socket, which means
encrypted transport has to be layered above this by something else.

## See also

- [Security](../guides/security.md) — what an unauthenticated socket does and does not give you
- [`net` symbol reference](../symbols/net.md)
