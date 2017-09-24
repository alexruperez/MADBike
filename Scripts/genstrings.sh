#!/usr/bin/env bash
set -eu

find ../BiciMAD/Source/ ../Pods \( -name "*.m" -o -name "*.swift" \) -print0 | xargs -0 genstrings -deleteUnusedEntries -o ../BiciMAD/Resources/Languages/Base.lproj