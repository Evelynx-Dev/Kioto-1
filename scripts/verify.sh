#!/bin/sh
set -eu

kioto_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
avenys_root=${AVENYS_ROOT:-"$kioto_root/../avenys"}
mire_bin=${MIRE_BIN:-"$avenys_root/target/debug/mire"}

if [ ! -x "$mire_bin" ]; then
    echo "mire compiler not found: $mire_bin" >&2
    exit 1
fi

for source in $(find "$kioto_root/core" -name '*.mire' -type f | sort); do
    "$mire_bin" check "$source" --lib-dir "$kioto_root"
done

"$mire_bin" check "$kioto_root/code/mod.mire" --lib-dir "$kioto_root"

cd "$kioto_root"
for test_source in tests/*.mire; do
    [ -f "$test_source" ] || continue
    "$mire_bin" test "$test_source" --verbose
done
