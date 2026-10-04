#!/usr/bin/env python3
"""
CONSISTENCY CHECK across the round-48/49 papers and the census.

WHY THIS EXISTS. During round 49 the same defect produced, in order:
  - FATAL-1: #523's ABSTRACT kept, in bold, the claim its own body withdrew
  - FATAL-3: #522 withdrew "structurally excluded / impossible" and then
              used it six more times, INCLUDING THE TITLE
  - a census sweep: two live wrong numbers, the 8.46x Dickman figure and a
    threshold that had missed the sqrt2 correction entirely

All three are the same failure: **a number was corrected in one place and not
in its other copies.** Each was found by a separate audit, at a cost of one
FATAL each. This script makes the check cheap enough to run after every edit.

WHAT IT DOES. For each key figure, it asserts that no WITHDRAWN value appears
anywhere outside an explicitly-marked correction notice. That is the only
question that matters: a wrong number that has been marked as wrong is
provenance; a wrong number that has not is a live error.

Usage:  python3 check_consistency.py [repo_root]
Exit 0 if clean, 1 if a live (unmarked) stale figure is found.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# (label, stale_pattern, required_context) -- a hit is LIVE unless the line
# also matches one of the correction markers.
STALE_FIGURES = [
    ("#523 valuation law: k-independence / k>=2",
     r"for every odd prime.*k\s*.?≥\s*2.*\bindependent of\b", None),
    ("#522: factor-2 slip, N<5400",
     r"N\s*<\s*5400|4√\(L ln L\)|2√\(L ln L\)", "wrong by|twice|corrected"),
    ("#522: sqrt2-convention slip, N<1.8e29 as a live claim",
     r"16 ln L < L", "corrected|twice|√2"),
    ("Dickman 8.46x as a live claim",
     r"8\.46", "wrong|corrected|superseded|old"),
    ("Dickman 13.9x (never valid)",
     r"13\.9", None),
    ("#526: 186x as a live claim",
     r"186×", "fails its own table|published as|corrected"),
    ("#523: 18.8x enrichment",
     r"18\.8", None),
    ("#523: 25-38% as a measured end-to-end payoff",
     r"25[–-]38%", "WITHDRAWN|withdrawn|naive|never measured"),
    ("2026-04/05: 'now also a THEOREM' on partial info",
     r"now also a THEOREM", "STRUCK|struck|my error"),
]

CORRECTION_MARKERS = re.compile(
    r"correct|withdraw|struck|supersed|wrong|error|WITHDRAW|STRUCK|old |"
    r"formerly|previously|no longer|not a theorem|my error|naive|fails its own",
    re.I,
)

TARGETS = [
    "Papers/the_baseline_that_was_not.md",
    "Papers/the_smoothness_wall_is_a_subgroup_wall.md",
    "Papers/a_square_minus_a_cube_divides_twice.md",
    "Papers/stange_works_and_its_analysis_does_not.md",
    "Papers/the_optimal_sampler.md",
    "Papers/choosing_b_well.md",
    "Papers/sharper_proved_l_half.md",
    "Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md",
]


# A second class the first version MISSED entirely: superseded STATUS words.
# check_consistency.py caught stale FIGURES, but "the mechanism remains
# unexplained" is not a figure -- it is a claim about the state of knowledge,
# and it stayed live in the census after the note that closed it. Tracking only
# numbers gives false assurance, which is worse than not checking.
SUPERSEDED_STATUS = [
    ("20/27 mechanism called unexplained after it was derived",
     r"20/27.{0,80}unexplained|unexplained.{0,80}20/27", "superseded|now derived|derived"),
    ("'measured and confirmed, not derived' after derivation",
     r"not derived", "superseded|now|derived|was"),
    ("axis called NOT closed after closure",
     r"axis NOT closed|axis not closed", None),
    ("'undiscovered in the literature' style unverified novelty",
     r"apparently-unpublished|apparently unpublished", None),
    ("census claims a row is LIVE after closure",
     r"genuinely live lead", "closed|was"),
]


def check_status(root: Path) -> list[str]:
    """Second pass: superseded status words, not stale figures."""
    out: list[str] = []
    for rel in TARGETS:
        path = root / rel
        if not path.exists():
            continue
        lines = path.read_text(encoding="utf-8", errors="replace").split("\n")
        WINDOW = 4
        for label, pattern, required in SUPERSEDED_STATUS:
            for i, line in enumerate(lines, 1):
                if not re.search(pattern, line, re.I | re.S):
                    continue
                lo = max(0, i - 1 - WINDOW)
                hi = min(len(lines), i + WINDOW)
                ctx = "\n".join(lines[lo:hi])
                if required and re.search(required, ctx, re.I):
                    continue
                if CORRECTION_MARKERS.search(ctx):
                    continue
                out.append(f"{rel}:{i}  [{label}]\n      {line.strip()[:150]}")
    return out


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "/home/raver1975/lean")
    live: list[str] = []
    seen_targets = 0

    for rel in TARGETS:
        path = root / rel
        if not path.exists():
            print(f"  [skip] {rel} (not found)")
            continue
        seen_targets += 1
        text = path.read_text(encoding="utf-8", errors="replace")
        lines = text.split("\n")
        # A stale figure is LIVE unless a correction marker appears within a
        # WINDOW around it. Line-local testing produced seven false positives
        # on first run -- every hit sat inside a correction notice whose marker
        # was on an adjacent line. A blockquote of a withdrawn claim is still
        # inside the withdrawal.
        WINDOW = 4
        for label, pattern, required in STALE_FIGURES:
            for i, line in enumerate(lines, 1):
                if not re.search(pattern, line, re.I):
                    continue
                lo = max(0, i - 1 - WINDOW)
                hi = min(len(lines), i + WINDOW)
                context = "\n".join(lines[lo:hi])
                if required and re.search(required, context, re.I):
                    continue
                if CORRECTION_MARKERS.search(context):
                    continue
                live.append(f"{rel}:{i}  [{label}]\n      {line.strip()[:150]}")

    status_live = check_status(root)

    print("=" * 72)
    print("CONSISTENCY CHECK — stale figures AND superseded status words, OUTSIDE a correction notice")
    print("=" * 72)
    print(f"  scanned {seen_targets}/{len(TARGETS)} files, "
          f"{len(STALE_FIGURES)} tracked figures")
    live.extend(status_live)
    if not live:
        print("\n  CLEAN — every retired figure and every superseded status word appears\n"
              "  only inside a correction notice.\n")
        return 0
    print(f"\n  {len(live)} LIVE stale figure(s):\n")
    for item in live:
        print("   " + item)
    print("\n  Each of these is a number a reader will take as current.")
    print("  Fix at the site, or mark it as withdrawn where it stands.\n")
    return 1


if __name__ == "__main__":
    sys.exit(main())