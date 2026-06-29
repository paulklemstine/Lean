"""
demo.py — Arrow's Theorem as Curvature of Preference Space
==========================================================

Self-contained numerical demonstrations of the central results in the
"Arrow-Curvature" development.  Everything is computed from first principles
in plain Python (standard library only): no third-party dependencies.

Key objects modeled here
------------------------
* StrictRanking      : a strict total order over n alternatives, stored as a
                       tuple `rank` where rank[a] is the position of alternative
                       a (smaller = more preferred).
* PreferenceProfile  : a list of k StrictRankings (one per voter).
* supportCount(a,b)  : number of voters who prefer a to b.
* majorityMargin     : supportCount(a,b) - supportCount(b,a).
* CondorcetCurvature : number of directed 3-cycles a > b > c > a in the
                       strict-majority relation.  This is the discrete
                       "curvature" of the preference space.

Theorems demonstrated
---------------------
1. unanimous_curvature_zero          : a unanimous profile is always flat.
2. exists_positive_curvature_profile : the Condorcet paradox realizes
                                       positive curvature.
3. unrestricted_domain_impossible    : no profile space has positive curvature
                                       on EVERY profile (the unanimous profile
                                       is a counterexample), which is why the
                                       "Arrow-curvature conjecture" is vacuous.
4. curvature_zero_iff_transitive     : zero curvature <=> transitive majority
                                       tournament <=> a global integer potential
                                       (Copeland score) reproduces the majority
                                       order  (cohomological "coboundary" reading).
5. Kendall distance properties       : symmetry and self-distance zero.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core data types
# ----------------------------------------------------------------------------

# A StrictRanking over n alternatives {0,...,n-1} is a tuple `rank` of length n
# where rank[a] is the position of alternative a (0 = most preferred).
StrictRanking = Tuple[int, ...]
# A PreferenceProfile is a list of k rankings.
PreferenceProfile = List[StrictRanking]


def prefers(r: StrictRanking, a: int, b: int) -> bool:
    """Voter with ranking r prefers a to b iff a has the lower (better) rank."""
    return r[a] < r[b]


def all_rankings(n: int) -> List[StrictRanking]:
    """Enumerate all n! strict rankings of n alternatives."""
    # A permutation p of (0..n-1) lists alternatives best-first; convert to a
    # rank vector rank[alt] = position.
    out: List[StrictRanking] = []
    for p in permutations(range(n)):
        rank = [0] * n
        for position, alt in enumerate(p):
            rank[alt] = position
        out.append(tuple(rank))
    return out


# ----------------------------------------------------------------------------
# Majority machinery
# ----------------------------------------------------------------------------

def support_count(profile: PreferenceProfile, a: int, b: int) -> int:
    """Number of voters who prefer a to b."""
    return sum(1 for r in profile if prefers(r, a, b))


def majority_margin(profile: PreferenceProfile, a: int, b: int) -> int:
    """Excess support for a over b: supportCount(a,b) - supportCount(b,a)."""
    return support_count(profile, a, b) - support_count(profile, b, a)


def majority_beats(profile: PreferenceProfile, a: int, b: int) -> bool:
    """a beats b by strict majority."""
    return support_count(profile, a, b) > support_count(profile, b, a)


def condorcet_curvature(profile: PreferenceProfile, n: int) -> int:
    """Count directed 3-cycles a>b>c>a in the strict-majority relation.

    This is the discrete curvature of the preference space.
    """
    count = 0
    for a, b, c in product(range(n), repeat=3):
        if (majority_beats(profile, a, b)
                and majority_beats(profile, b, c)
                and majority_beats(profile, c, a)):
            count += 1
    return count


def majority_is_transitive(profile: PreferenceProfile, n: int) -> bool:
    """Check transitivity of the strict-majority relation directly."""
    for a, b, c in product(range(n), repeat=3):
        if (majority_beats(profile, a, b)
                and majority_beats(profile, b, c)
                and not majority_beats(profile, a, c)):
            return False
    return True


# ----------------------------------------------------------------------------
# Cohomological reading: the Copeland potential
# ----------------------------------------------------------------------------

def copeland_score(profile: PreferenceProfile, n: int) -> Dict[int, int]:
    """Copeland score: (# alternatives a beats) - (# alternatives that beat a).

    When the majority tournament is transitive, this integer-valued score is a
    'potential' f: the majority order is exactly the strict order of f, i.e. the
    margin 1-cochain is a coboundary  beats(a,b) <=> f(a) > f(b).
    """
    score: Dict[int, int] = {}
    for a in range(n):
        wins = sum(1 for b in range(n) if b != a and majority_beats(profile, a, b))
        losses = sum(1 for b in range(n) if b != a and majority_beats(profile, b, a))
        score[a] = wins - losses
    return score


def potential_reproduces_majority(profile: PreferenceProfile, n: int) -> bool:
    """Check whether the Copeland potential f reproduces the majority order:
    for all a != b, beats(a,b) <=> f(a) > f(b)."""
    f = copeland_score(profile, n)
    for a, b in product(range(n), repeat=2):
        if a == b:
            continue
        if majority_beats(profile, a, b) != (f[a] > f[b]):
            return False
    return True


# ----------------------------------------------------------------------------
# Kendall tau distance between rankings
# ----------------------------------------------------------------------------

def kendall_distance(r1: StrictRanking, r2: StrictRanking, n: int) -> int:
    """Number of ordered pairs (a,b) with a preferred to b in r1 but b to a in r2."""
    return sum(
        1
        for a, b in product(range(n), repeat=2)
        if prefers(r1, a, b) and prefers(r2, b, a)
    )


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def ranking_from_order(order: Sequence[int]) -> StrictRanking:
    """Build a StrictRanking from a best-first list of alternatives."""
    n = len(order)
    rank = [0] * n
    for position, alt in enumerate(order):
        rank[alt] = position
    return tuple(rank)


def demo_condorcet_paradox() -> None:
    """The canonical Condorcet paradox: three voters, three alternatives,
    cyclic majority preference (positive curvature)."""
    print("=" * 70)
    print("DEMO 1: The Condorcet paradox realizes POSITIVE curvature")
    print("=" * 70)
    # Voter 1: A>B>C, Voter 2: B>C>A, Voter 3: C>A>B  (0=A,1=B,2=C)
    profile: PreferenceProfile = [
        ranking_from_order([0, 1, 2]),
        ranking_from_order([1, 2, 0]),
        ranking_from_order([2, 0, 1]),
    ]
    n = 3
    print("Voter 1: A>B>C")
    print("Voter 2: B>C>A")
    print("Voter 3: C>A>B")
    print(f"  A beats B? {majority_beats(profile, 0, 1)}  (margin {majority_margin(profile,0,1)})")
    print(f"  B beats C? {majority_beats(profile, 1, 2)}  (margin {majority_margin(profile,1,2)})")
    print(f"  C beats A? {majority_beats(profile, 2, 0)}  (margin {majority_margin(profile,2,0)})")
    print(f"  CondorcetCurvature = {condorcet_curvature(profile, n)}  (> 0: CURVED)")
    print(f"  Majority transitive? {majority_is_transitive(profile, n)}")
    print()


def demo_unanimous_flat() -> None:
    """A unanimous profile is always flat (curvature 0)."""
    print("=" * 70)
    print("DEMO 2: Unanimity implies ZERO curvature (the flat limit)")
    print("=" * 70)
    n, k = 4, 5
    common = ranking_from_order([0, 1, 2, 3])
    profile: PreferenceProfile = [common for _ in range(k)]
    print(f"All {k} voters share the ranking A>B>C>D over {n} alternatives.")
    print(f"  CondorcetCurvature = {condorcet_curvature(profile, n)}  (= 0: FLAT)")
    print(f"  Copeland potential reproduces majority order? "
          f"{potential_reproduces_majority(profile, n)}")
    print()


def demo_unrestricted_impossible() -> None:
    """No profile space has positive curvature on EVERY profile."""
    print("=" * 70)
    print("DEMO 3: 'Positive curvature everywhere' is UNSATISFIABLE")
    print("=" * 70)
    n, k = 3, 3
    common = ranking_from_order([0, 1, 2])
    unanimous: PreferenceProfile = [common for _ in range(k)]
    print(f"For n={n}, k={k}: the unanimous profile is always reachable, and")
    print(f"  CondorcetCurvature(unanimous) = {condorcet_curvature(unanimous, n)}")
    print("So no SWF domain can satisfy 'for all P, curvature(P) > 0'.")
    print("=> the Arrow-curvature conjecture's global premise is vacuous.")
    print()


def demo_curvature_zero_iff_potential() -> None:
    """Across all 3-alternative profiles with 3 voters, verify:
    zero curvature  <=>  transitive majority  <=>  Copeland potential works."""
    print("=" * 70)
    print("DEMO 4: curvature = 0  <=>  transitive  <=>  has integer potential")
    print("=" * 70)
    n, k = 3, 3
    rankings = all_rankings(n)
    flat = curved = 0
    consistent = True
    for profile in product(rankings, repeat=k):
        prof = list(profile)
        curv = condorcet_curvature(prof, n)
        trans = majority_is_transitive(prof, n)
        pot = potential_reproduces_majority(prof, n)
        if (curv == 0) != trans:
            consistent = False
        if (curv == 0) != pot:
            consistent = False
        if curv == 0:
            flat += 1
        else:
            curved += 1
    total = flat + curved
    print(f"Enumerated all {total} = ({n}!)^{k} profiles for n={n}, k={k}.")
    print(f"  Flat   (curvature 0): {flat}  ({100*flat/total:.2f}%)")
    print(f"  Curved (curvature>0): {curved}  ({100*curved/total:.2f}%)")
    print(f"  Equivalence  curv=0 <=> transitive <=> potential  holds: {consistent}")
    print()


def demo_kendall() -> None:
    """Kendall tau distance: symmetry and self-distance zero."""
    print("=" * 70)
    print("DEMO 5: Kendall tau distance (geodesics on preference space)")
    print("=" * 70)
    n = 4
    r1 = ranking_from_order([0, 1, 2, 3])
    r2 = ranking_from_order([3, 2, 1, 0])  # the reversal
    r3 = ranking_from_order([0, 2, 1, 3])
    print(f"  d(A>B>C>D , A>B>C>D) = {kendall_distance(r1, r1, n)}  (self = 0)")
    print(f"  d(A>B>C>D , D>C>B>A) = {kendall_distance(r1, r2, n)}  (max disagreement)")
    print(f"  symmetric?  d(r1,r3)={kendall_distance(r1,r3,n)}  "
          f"d(r3,r1)={kendall_distance(r3,r1,n)}")
    print()


def demo_flat_fraction_table() -> None:
    """Enumerate the fraction of flat profiles for small (n,k):
    a curvature-flavored version of the classic 'probability of a cycle'."""
    print("=" * 70)
    print("DEMO 6: Fraction of FLAT profiles (curvature statistics)")
    print("=" * 70)
    print(f"{'n':>3} {'k':>3} {'#profiles':>12} {'#flat':>10} {'%flat':>8}")
    for n in (3,):
        for k in (1, 3, 5):
            rankings = all_rankings(n)
            flat = 0
            total = 0
            for profile in product(rankings, repeat=k):
                total += 1
                if condorcet_curvature(list(profile), n) == 0:
                    flat += 1
            print(f"{n:>3} {k:>3} {total:>12} {flat:>10} {100*flat/total:>7.2f}%")
    print()


def main() -> None:
    demo_condorcet_paradox()
    demo_unanimous_flat()
    demo_unrestricted_impossible()
    demo_curvature_zero_iff_potential()
    demo_kendall()
    demo_flat_fraction_table()


if __name__ == "__main__":
    main()
