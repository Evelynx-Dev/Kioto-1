# Kioto tests

These tests cover only the public surface exported by the current Kioto
manifest. They are intentionally small integration tests: each function marked
`@[test]` returns `bool`, and the compiler test runner reports the result.

The suite does not test removed modules such as HTTP, TLS, terminal, GPU,
`result`, `maybe`, `iter`, or JSON. Those features are not part of the current
PAL-backed Kioto surface and must not remain as compatibility tests.

Run the suite from the Avenys repository with the freshly built compiler:

```sh
cd ../kioto
../avenys/target/debug/mire test tests/pal_v4_smoke.mire --verbose
```

For a compile-only check:

```sh
cd ../kioto
../avenys/target/debug/mire test tests/pal_v4_smoke.mire --no-run
```

The test suite intentionally avoids external network services and process
spawning. Those APIs require an explicit host fixture before they can be
tested without making the result backend-dependent.
