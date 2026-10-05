# Environment — symbol reference

The process environment and the command line. Everything returned here is borrowed from the process and stays valid for as long as the process runs.

## `env`

| Symbol | Signature | Notes |
| --- | --- | --- |
| `env::args` | `args(argc :i32, argv :ptr) :vec[str]` | The command line as the runtime received it, argv[0] first. Takes the raw argc/argv pair because Mire's main takes no parameters; a program that wants arguments stores them in a local on the first line of main. |
| `env::cwd` | `cwd() :&str` | Working directory. Borrowed: the string belongs to the process environment and stays valid for the life of the process. Do not free it. |
| `env::var` | `var(name :&str) :&str` | Value of an environment variable, or the empty string when it is not set. Also borrowed, and also process-owned. |
