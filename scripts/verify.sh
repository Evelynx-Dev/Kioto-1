#!/bin/sh
# Kioto 3.0.0 — verification driver.
#
# Checks every `modules/**/*.mr` compiles, checks the entry point, then runs the
# test suite file by file. Set MIRE_BIN to use a specific compiler build.
set -eu

kioto_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
avenys_root=${AVENYS_ROOT:-"$kioto_root/../avenys"}
mire_bin=${MIRE_BIN:-"$avenys_root/target/release/mire"}

if [ ! -x "$mire_bin" ]; then
    echo "mire compiler not found: $mire_bin" >&2
    exit 1
fi

lib_dir=${KIOTO_LIB_DIR:-"$HOME/.owl/libs"}

# 1. Every module source must typecheck.
for source in $(find "$kioto_root/modules" -name '*.mr' -type f | sort); do
    echo "check ${source#"$kioto_root"/}"
    "$mire_bin" check "$source" --lib-dir "$lib_dir"
done

# 2. The entry point must typecheck.
echo "check src/mod.mr"
"$mire_bin" check "$kioto_root/src/mod.mr" --lib-dir "$lib_dir"

# 3. Every test file must pass.
cd "$kioto_root"
for test_source in $(find tests -name '*.mr' -type f | sort); do
    [ -f "$test_source" ] || continue
    echo "test $test_source"
    "$mire_bin" test "$test_source" --lib-dir "$lib_dir" --verbose
done
