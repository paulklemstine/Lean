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
# Usage:  bash check_issues_match_papers.sh [repo_root] [repo_slug]
# Exit 0 if every issue matches its paper (modulo trailing whitespace).

set -uo pipefail

ROOT="${1:-/home/raver1975/lean}"
SLUG="${2:-paulklemstine/Lean}"

declare -A PAPER=(
  [521]=the_baseline_that_was_not.md
  [522]=the_smoothness_wall_is_a_subgroup_wall.md
  [523]=a_square_minus_a_cube_divides_twice.md
  [524]=stange_works_and_its_analysis_does_not.md
  [525]=the_optimal_sampler.md
  [526]=choosing_b_well.md
  [527]=sharper_proved_l_half.md
)

echo "=========================================================================="
echo "ISSUE-DRIFT CHECK — is what GitHub serves still what the repo says?"
echo "  repo: $SLUG"
echo "=========================================================================="

drift=0
for n in $(printf '%s\n' "${!PAPER[@]}" | sort); do
  f="$ROOT/Papers/${PAPER[$n]}"
  if [ ! -f "$f" ]; then
    printf "  #%-4s SKIP — %s not found\n" "$n" "${PAPER[$n]}"
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
  a=$(printf '%s' "$body" | md5sum | cut -c1-10)
  b=$(printf '%s' "$(cat "$f")" | md5sum | cut -c1-10)
  if [ "$a" = "$b" ]; then
    printf "  #%-4s MATCH\n" "$n"
  else
    printf "  #%-4s *** DRIFT — the published issue is STALE ***\n" "$n"
    drift=$((drift + 1))
  fi
done

echo "--------------------------------------------------------------------------"
if [ "$drift" -eq 0 ]; then
  echo "  CLEAN — every published issue serves exactly what the repo holds."
  echo "  A reader arriving through GitHub gets the corrected claim."
  exit 0
fi
echo "  $drift issue(s) DIVERGE from their papers."
echo "  The repo is correct and GitHub is not — so the retraction is invisible"
echo "  to anyone reading the issue. Fix with:"
echo "    gh issue edit <n> --repo $SLUG --body-file <paper>.md"
exit 1