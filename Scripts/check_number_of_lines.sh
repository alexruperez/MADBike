#!/bin/sh

MIN_LINES_WARNING=450
MIN_LINES_ERROR=650
FILE_EXTENSIONS="h|m|mm|c|cpp|swift"
find -E "${SRCROOT}" \( -regex ".*\.($FILE_EXTENSIONS)$" \) -and \( -not -path "${SRCROOT}/Pods/*" \) -and \( -not -path "${SRCROOT}/Carthage/*" \) -print0 | xargs -0 wc -l | awk '
$2 == "total" { next }
$1 > '${MIN_LINES_WARNING}' && $1 < '${MIN_LINES_ERROR}' { print $NF ":1: warning: File more than '${MIN_LINES_WARNING}' lines (" $1 "), consider refactoring." }
$1 > '${MIN_LINES_ERROR}' { print $NF ":1: error: File more than '${MIN_LINES_ERROR}' lines (" $1 "), you MUST refactor." }
'
