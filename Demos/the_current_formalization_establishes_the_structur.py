"""
Single-Peaked Preferences are Flat: Black's Theorem as Vanishing Condorcet Curvature
====================================================================================

Self-contained numerical demonstration of the results formalized in
`Catalog/Bridges/SinglePeakedFlatness.lean` (built on
`Catalog/Bridges/ArrowCurvature/Defs.lean`).

Mathematical objects (all inlined below):
  * StrictRanking   -- a strict order of alternatives, given as a tuple from
                       most-preferred to least-preferred.
  * prefers(r,a,b)  -- voter r prefers a to b.
  * support_count   -- number of voters preferring a to b.
  * majority_beats  -- a beats b by strict majority.
  * condorcet_curvature -- number of directed majority 3-cycles (our discrete
                       curvature scalar).
  * is_single_peaked_at / is_single_peaked -- Black's domain restriction on the
                       fixed axis 0 < 1 < ... < n-1.
  * value_restricted_middle_never_worst -- Sen value restriction (Lemma 4.1).

Headline result (Theorem 5.3, Black geometric form):
  single-peaked profile  ==>  condorcet_curvature == 0  (flatness).

No third-party dependencies; runs on the standard library only.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, List, Sequence, Tuple

# A ranking is a tuple of alternatives ordered from MOST to LEAST preferred.
Ranking = Tuple[int, ...]
# A profile is a list of rankings, one per voter.
Profile = List[Ranking]


# ----------------------------------------------------------------------------
# Core definitions (mirroring the Lean development)
# ----------------------------------------------------------------------------
def rank_of(r: Ranking, a: int) -> int:
    """Position of alternative `a` in ranking `r` (0 = best). Lower is better."""
    return r.index(a)


def prefers(r: Ranking, a: int, b: int) -> bool:
    """Voter with ranking `r` prefers `a` to `b` iff `a` has the lower rank."""
    return rank_of(r, a) < rank_of(r, b)


def support_count(profile: Profile, a: int, b: int) -> int:
    """Number of voters who prefer `a` to `b`."""
    return sum(1 for r in profile if prefers(r, a, b))


def majority_beats(profile: Profile, a: int, b: int) -> bool:
    """`a` beats `b` by strict majority."""
    return support_count(profile, a, b) > support_count(profile, b, a)


def condorcet_curvature(profile: Profile, n: int) -> int:
    """Number of directed majority 3-cycles (Definition 2.6).

    This is the discrete curvature scalar: 0 == flat, > 0 == curved.
    """
    count = 0
    for a, b, c in product(range(n), repeat=3):
        if (majority_beats(profile, a, b)
                and majority_beats(profile, b, c)
                and majority_beats(profile, c, a)):
            count += 1
    return count


# ----------------------------------------------------------------------------
# Single-peakedness on the fixed axis 0 < 1 < ... < n-1
# ----------------------------------------------------------------------------
def is_single_peaked_at(r: Ranking, p: int, n: int) -> bool:
    """Ranking `r` is single-peaked at peak `p` (Definition 4.0):
       (1) peak is top; (2) left-monotone below p; (3) right-monotone above p."""
    # (1) peak is the top choice
    if any(not prefers(r, p, a) for a in range(n) if a != p):
        return False
    # (2) left-monotone: a < b <= p  =>  prefers b a
    for b in range(n):
        for a in range(b):
            if b <= p and not prefers(r, b, a):
                return False
    # (3) right-monotone: p <= a < b  =>  prefers a b
    for a in range(n):
        for b in range(a + 1, n):
            if p <= a and not prefers(r, a, b):
                return False
    return True


def peak_of(r: Ranking) -> int:
    """The peak of a single-peaked ranking is simply its top choice."""
    return r[0]


def is_single_peaked(profile: Profile, n: int) -> bool:
    """Every voter is single-peaked at some axis position."""
    return all(any(is_single_peaked_at(r, p, n) for p in range(n)) for r in profile)


def value_restricted_middle_never_worst(profile: Profile, n: int) -> bool:
    """Sen value restriction (Lemma 4.1): on every axis-sorted triple a<b<c,
       no voter ranks the middle `b` last."""
    for a in range(n):
        for b in range(a + 1, n):
            for c in range(b + 1, n):
                for r in profile:
                    if not (prefers(r, b, a) or prefers(r, b, c)):
                        return False
    return True


def median_peak_winner(profile: Profile, n: int) -> int:
    """Median of the voters' peaks (Algorithm C); on a single-peaked profile with
       odd electorate this is the Condorcet winner."""
    peaks = sorted(peak_of(r) for r in profile)
    return peaks[len(peaks) // 2]


def is_condorcet_winner(profile: Profile, w: int, n: int) -> bool:
    """`w` beats every other alternative by majority."""
    return all(majority_beats(profile, w, b) for b in range(n) if b != w)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_condorcet_paradox() -> None:
    banner("DEMO 1 - The Condorcet paradox: a CURVED opinion space")
    n = 3
    # Classic cyclic profile (NOT single-peaked): voter 3 ranks middle (1) last.
    profile: Profile = [(0, 1, 2), (1, 2, 0), (2, 0, 1)]
    print("Alternatives on axis 0 < 1 < 2; rankings best->worst:")
    for i, r in enumerate(profile):
        print(f"  voter {i}: {r}")
    for a, b in [(0, 1), (1, 2), (2, 0)]:
        print(f"  majority {a} vs {b}: {a} beats {b}? {majority_beats(profile, a, b)}")
    curv = condorcet_curvature(profile, n)
    print(f"  Condorcet curvature = {curv}  ->  {'CURVED (cycle!)' if curv else 'flat'}")
    print(f"  single-peaked? {is_single_peaked(profile, n)}")
    print(f"  value restriction (middle never worst)? "
          f"{value_restricted_middle_never_worst(profile, n)}")


def demo_single_peaked_flat() -> None:
    banner("DEMO 2 - Single-peaked profile: a FLAT opinion space (Black)")
    n = 3
    # Peaks at 0, 1, 2; each voter single-peaked on axis 0 < 1 < 2.
    profile: Profile = [(0, 1, 2), (1, 0, 2), (2, 1, 0)]
    print("Rankings best->worst:")
    for i, r in enumerate(profile):
        sp = is_single_peaked_at(r, peak_of(r), n)
        print(f"  voter {i}: {r}   peak={peak_of(r)}   single-peaked={sp}")
    curv = condorcet_curvature(profile, n)
    print(f"  single-peaked profile? {is_single_peaked(profile, n)}")
    print(f"  value restriction? {value_restricted_middle_never_worst(profile, n)}")
    print(f"  Condorcet curvature = {curv}  ->  "
          f"{'FLAT (Black: curvature 0)' if curv == 0 else 'curved'}")
    w = median_peak_winner(profile, n)
    print(f"  median-peak winner = {w}; is Condorcet winner? "
          f"{is_condorcet_winner(profile, w, n)}")


def demo_exhaustive_black_theorem(n: int = 3, k: int = 3) -> None:
    banner(f"DEMO 3 - Exhaustive verification of Black's theorem (n={n}, k={k})")
    rankings: List[Ranking] = list(permutations(range(n)))
    total = 0
    sp_count = 0
    violations = 0  # single-peaked but curved -> would falsify Black
    for profile in product(rankings, repeat=k):
        prof: Profile = list(profile)
        total += 1
        if is_single_peaked(prof, n):
            sp_count += 1
            if condorcet_curvature(prof, n) != 0:
                violations += 1
    print(f"  profiles examined         : {total}")
    print(f"  single-peaked profiles    : {sp_count}")
    print(f"  single-peaked & curved    : {violations}")
    print(f"  Black's theorem holds?    : {violations == 0}")
    print("  (every single-peaked profile has Condorcet curvature 0)")


def demo_value_restriction_equivalence(n: int = 3, k: int = 3) -> None:
    banner(f"DEMO 4 - Value restriction forces flatness (n={n}, k={k})")
    rankings: List[Ranking] = list(permutations(range(n)))
    vr_curved = 0  # value-restricted but curved -> would falsify Lemma 4.x
    vr_total = 0
    for profile in product(rankings, repeat=k):
        prof: Profile = list(profile)
        if value_restricted_middle_never_worst(prof, n):
            vr_total += 1
            if condorcet_curvature(prof, n) != 0:
                vr_curved += 1
    print(f"  value-restricted profiles : {vr_total}")
    print(f"  ... and yet curved        : {vr_curved}")
    print(f"  value restriction => flat : {vr_curved == 0}")


def demo_parity_free_acyclicity() -> None:
    banner("DEMO 5 - Acyclicity is parity-free (even electorate stays flat)")
    n = 3
    # Single-peaked profile with an EVEN number of voters (k = 4).
    profile: Profile = [(0, 1, 2), (1, 0, 2), (1, 2, 0), (2, 1, 0)]
    print("Even electorate (k=4), all single-peaked:")
    for i, r in enumerate(profile):
        print(f"  voter {i}: {r}  peak={peak_of(r)}")
    print(f"  single-peaked? {is_single_peaked(profile, n)}")
    print(f"  Condorcet curvature = {condorcet_curvature(profile, n)} (still flat)")
    print("  Remark 5.4: oddness is only needed to break ties for a strict order,")
    print("  not for acyclicity/flatness.")


def main() -> None:
    demo_condorcet_paradox()
    demo_single_peaked_flat()
    demo_exhaustive_black_theorem()
    demo_value_restriction_equivalence()
    demo_parity_free_acyclicity()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
