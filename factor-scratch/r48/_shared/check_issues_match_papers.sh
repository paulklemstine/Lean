#!/usr/bin/env bash
# Verify every PUBLISHED issue body still matches the paper file it came from.
#
# WHY THIS EXISTS, SEPARATELY FROM check_consistency.py. That script reads the
# repo. This one asks GITHUB what the world actually sees -- and the two have
# drifted apart twice, fatally:
#
#   FATAL-1: #523's ABSTRACT kept, in bold, the claim its own body withdrew.
#            The repo file was correct; the ISSUE was not.
#   FATAL-3: #522 withdrew "structurally excluded / impossible" and then used
#            it six more times, INCLUDING THE TITLE. Same shape.
#
# In both cases the repo was clean and a reader arriving through the issue got
# the retracted claim FIRST. A repo-local check cannot catch that, because the
# defect lives outside the repo entirely.
#
# DISCOVERY IS NOT HARDCODED. It was, and adding paper #528 left this script
# reporting CLEAN over seven issues while an eighth existed unchecked -- the
# identical fixed-scope failure I had just fixed in check_consistency.py.
# The list is now DISCOVERED from the census, the one artifact that must name
# every paper. Discovery runs in python because a bash associative array built
# from a sed pipeline mispaired its tokens twice.
#
# If discovery finds nothing this script FAILS LOUDLY. A checker that cannot
# see its scope must say so rather than report CLEAN.
#
# Usage:  bash check_issues_match_papers.sh [repo_root] [repo_slug]
# Exit 0 if every discovered issue matches its paper (modulo trailing whitespace).

set -uo pipefail

ROOT="${1:-/home/raver1975/lean}"
SLUG="${2:-paulklemstine/Lean}"
CENSUS="$ROOT/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md"

PAIRS=$(python3 - "$CENSUS" <<'PYEOF'
import re, sys, pathlib
p = pathlib.Path(sys.argv[1])
if not p.exists():
    sys.exit(1)
txt = p.read_text(errors="replace")
# Rows read: | 4b | `Papers/x.md` | **#528** | ...
found = re.findall(r'`(Papers/[^`]*\.md)`.*?\*\*#(\d+)\*\*', txt)
if not found:
    sys.exit(1)
for path, num in sorted(set(found)):
    print(f"{num}\t{path}")
PYEOF
)
rc=$?

if [ $rc -ne 0 ] || [ -z "$PAIRS" ]; then
  echo "=========================================================================="
  echo "ISSUE-DRIFT CHECK -- ** CANNOT RUN **"
  echo "  Discovered 0 papers from: $CENSUS"
  echo "  A checker that cannot see its scope reports CLEAN meaninglessly."
  echo "=========================================================================="
  exit 1
fi

echo "=========================================================================="
echo "ISSUE-DRIFT CHECK -- is what GitHub serves still what the repo says?"
echo "  repo: $SLUG"
echo "  discovered $(printf '%s\n' "$PAIRS" | wc -l) papers from the census"
echo "=========================================================================="

drift=0
while IFS=$'\t' read -r n pfile; do
  [ -z "$n" ] && continue
  f="$ROOT/$pfile"
  if [ ! -f "$f" ]; then
    printf "  #%-4s SKIP -- %s not found on disk\n" "$n" "$pfile"
    continue
  fi
  body=$(gh issue view "$n" --repo "$SLUG" --json body -q .body 2>/dev/null)
  if [ -z "$body" ]; then
    printf "  #%-4s *** COULD NOT FETCH ISSUE ***\n" "$n"
    drift=$((drift + 1))
    continue
  fi
  # Normalise: command substitution strips trailing newlines on both sides, so
  # compare the stripped forms. An earlier version compared raw bytes and
  # flagged all seven as differing by exactly one byte -- gh appends a newline.
  # A check that reports drift on a correct record gets ignored, which is worse
  # than no check at all.
  a=$(printf '%s' "$body" | md5sum | cut -c1-10)
  b=$(printf '%s' "$(cat "$f")" | md5sum | cut -c1-10)
  if [ "$a" = "$b" ]; then
    printf "  #%-4s MATCH   %s\n" "$n" "$pfile"
  else
    printf "  #%-4s *** DRIFT -- the published issue is STALE ***  %s\n" "$n" "$pfile"
    drift=$((drift + 1))
  fi
done <<< "$PAIRS"

echo "--------------------------------------------------------------------------"
if [ "$drift" -eq 0 ]; then
  echo "  CLEAN -- every published issue serves exactly what the repo holds."
  echo "  A reader arriving through GitHub gets the corrected claim."
  exit 0
fi
echo "  $drift issue(s) DIVERGE from their papers."
echo "  The repo is correct and GitHub is not -- so the retraction is invisible"
echo "  to anyone reading the issue. Fix with:"
echo "    gh issue edit <n> --repo $SLUG --body-file <paper>.md"
exit 1