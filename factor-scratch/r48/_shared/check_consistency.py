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
    "Papers/the_order_finding_constant.md",
    "Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md",
]

# ⚠️ THIS LIST IS A FIXED SCOPE, and it just bit me: adding paper #528 left the
# checker reporting CLEAN, because #528 was not in TARGETS and therefore not
# scanned or orphan-checked. A hardcoded file list cannot notice that a file was
# added. The census cross-check below is the mitigation -- it asks whether the
# SET of published papers has changed, rather than trusting the list above.


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


# Third class. The first two track what a file SAYS; this tracks what it
# OMITS. A paper that exists, is published, and carries the round's most
# useful general principle can still be invisible if the index never names it.
# That is not a stale figure and not a superseded status word -- it is an
# absence, which no amount of re-reading an existing line will surface.
# Found on first run: paper #522 had ZERO references in the census, and the
# "localisable" strengthening of the NFS result had been dropped, leaving
# only the retraction.
CENSUS = "Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md"


def check_orphans(root: Path) -> list[str]:
    """Every published paper must be named by the census, and its headline
    finding must appear there."""
    out: list[str] = []
    census = root / CENSUS
    if not census.exists():
        return [f"{CENSUS}: MISSING -- no index to audit against"]
    text = census.read_text(encoding="utf-8", errors="replace")

    for rel in TARGETS:
        if not rel.startswith("Papers/"):
            continue
        name = Path(rel).name
        if name not in text:
            out.append(f"{CENSUS}: ORPHAN PAPER -- {name} is never referenced")

    # The mitigation for the fixed-scope problem above. Discovering papers by
    # SIZE alone was a false-positive generator: Papers/ holds hundreds of
    # files from the parallel Aether loop and earlier rounds. The right
    # discriminator is "what did THIS campaign add" -- recent mtime. A paper
    # modified in the last day that is neither scanned nor referenced is the
    # case worth catching.
    import time
    papers_dir = root / "Papers"
    if papers_dir.is_dir():
        cutoff = time.time() - 24 * 3600
        recent = [md for md in sorted(papers_dir.glob("*.md"))
                  if md.stat().st_mtime > cutoff and md.stat().st_size > 3000]
        if len(recent) > 12:
            out.append(
                f"{CENSUS}: {len(recent)} papers touched in the last 24h -- this campaign "
                f"authored about 8, so other work (a parallel loop?) is also landing here. "
                f"Confirm the census covers this campaign's papers, and that foreign work "
                f"is left untouched."
            )
        for md in recent:
            if md.name not in text and md.name not in TARGETS:
                out.append(
                    f"{CENSUS}: RECENT PAPER NOT IN CENSUS -- {md.name} was modified in "
                    f"the last 24h, is not in TARGETS, and is never referenced."
                )

    # Headline findings that must survive into the index.
    REQUIRED_FINDINGS = [
        ("NFS excess is LOCALISABLE (stronger than the withdrawn figure)",
         r"localisab", None),
        ("the subgroup-wall reframe (general principle, #522)",
         r"subgroup wall|subgroup.*wall", None),
        ("sampler proved OPTIMAL (#525)", r"cost-optimal|proved.{0,20}optimal", None),
        ("2sqrt2 -> 2, unconditional (#527)", r"2√2|2 sqrt2", None),
        ("gap is in the GUARANTEE, not the method",
         r"GUARANTEE|guarantee, not the method", None),
    ]
    for label, pattern, _ in REQUIRED_FINDINGS:
        if not re.search(pattern, text, re.I):
            out.append(f"{CENSUS}: MISSING FINDING -- {label}")
    return out


# Fourth class -- and the one that motivated the other three. It is also the
# WEAKEST of the four: it can only test for phrasing, never for meaning, and
# it produced two false positives on its first run for exactly that reason.
# A checker that cannot tell "absent" from "said differently" is a checker
# you will eventually stop reading. The first three
# track specific patterns in the BODY of each file. This one asks whether the
# file's own SUMMARY is still true of its body. The census headline kept
# asserting "181/240 = 75%" as evidence the construction works, and "Two
# papers, two issues", long after both had been corrected -- while every
# targeted pattern below reported CLEAN.
#
# Because the defect was in the framing rather than in any figure, no amount of
# grepping for retired numbers would find it. The general form: an index that
# has been appended to for a day will describe its own contents in the past
# tense unless something forces it to be rewritten.
SUMMARY_BLOCK = "Round 48 — Summary and Census"


def check_summary_current(root: Path) -> list[str]:
    """The census's own headline must describe what the body now says.

    NOTE ON LOGIC, after getting it backwards once: these are REQUIRED
    patterns. Report when one is ABSENT. An earlier version reported when
    one was PRESENT -- so it flagged the very fix it was written to verify,
    and the manual check against a known-true headline is what caught it.
    """
    out: list[str] = []
    path = root / CENSUS
    if not path.exists():
        return out
    text = path.read_text(encoding="utf-8", errors="replace")
    head = text.split("## ■ DELIVERED")[0]

    # ABSENT-when-stale: the headline asserts a retired framing.
    STALE_IF_PRESENT = [
        ("headline asserts a bare 75% with no attribution caveat",
         r"\*\*181/240\s*=\s*75%\*\*"),
        ("headline still says 'Two papers, two issues'", r"Two papers, two issues"),
        ("headline counts only ONE positive result",
         r"one \*\*positive\*\* measurement"),
    ]
    for label, pattern in STALE_IF_PRESENT:
        if re.search(pattern, head, re.I):
            out.append(f"{CENSUS}: STALE HEADLINE -- {label}")

    # REQUIRED: the headline must carry these, or it under-sells the round.
    REQUIRED = [
        ("the 20/27 attribution caveat (it is the ORDER constant, not the construction's)",
         r"20/27"),
        ("both proved positives (#525 and #527)", r"#525.*#527|#527.*#525"),
        # NOTE: this is the weakest of the four passes. It tests PHRASING,
        # not meaning -- the first version flagged a headline that already
        # carried the distinction in the words "the ratio diverges; they never
        # meet". Accept any phrasing that asserts the substance.
        ("the guarantee-vs-method distinction (cost walls the method, not the guarantee)",
         r"GUARANTEE|guarantee, not the method|ratio diverges|never meet"),
        ("the derivation status of b_needed", r"argmin"),
    ]
    for label, pattern in REQUIRED:
        if not re.search(pattern, head, re.I | re.S):
            out.append(f"{CENSUS}: HEADLINE MISSING -- {label}")
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
    orphan_live = check_orphans(root)
    summary_live = check_summary_current(root)

    print("=" * 72)
    print("CONSISTENCY CHECK — figures, status words, orphaned claims, AND a stale headline")
    print("=" * 72)
    print(f"  scanned {seen_targets}/{len(TARGETS)} files, "
          f"{len(STALE_FIGURES)} tracked figures")
    live.extend(status_live)
    live.extend(orphan_live)
    live.extend(summary_live)
    if not live:
        print("\n  CLEAN — no stale figure, no superseded status word, no orphaned\n"
              "  claim, and the index's own headline still describes its contents.\n")
        return 0
    print(f"\n  {len(live)} LIVE stale figure(s):\n")
    for item in live:
        print("   " + item)
    print("\n  Each of these is a number a reader will take as current.")
    print("  Fix at the site, or mark it as withdrawn where it stands.\n")
    return 1


if __name__ == "__main__":
    sys.exit(main())