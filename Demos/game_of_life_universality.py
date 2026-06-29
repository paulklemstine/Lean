"""Numerical demonstrations for *Union-Closed Families as Positive-Correlation
Systems*.

Each function exercises one of the formally proved theorems on concrete
families of finite sets. Sets are modeled as Python ``frozenset`` objects over
a ground set ``alpha`` (a tuple of hashable elements). A *family* ``F`` is a
list of such frozensets (treated as a set of members).

Run ``python demo.py`` to print a full verification report.
"""

from __future__ import annotations

from itertools import combinations
from typing import Sequence, Hashable, FrozenSet, List, Tuple


Element = Hashable
Subset = FrozenSet[Element]
Family = List[Subset]


# --------------------------------------------------------------------------- #
# Observables (Definitions 3-5)
# --------------------------------------------------------------------------- #
def member_count(a: Element, F: Family) -> int:
    """mc(a) = number of members of F containing a."""
    return sum(1 for s in F if a in s)


def joint_count(a: Element, b: Element, F: Family) -> int:
    """jc(a, b) = number of members of F containing both a and b."""
    return sum(1 for s in F if a in s and b in s)


def union_count(a: Element, b: Element, F: Family) -> int:
    """uc(a, b) = number of members of F containing a or b."""
    return sum(1 for s in F if a in s or b in s)


def total_occupancy(F: Family) -> int:
    """sum over members s of |s|."""
    return sum(len(s) for s in F)


# --------------------------------------------------------------------------- #
# Structural predicates (Definitions 1-2)
# --------------------------------------------------------------------------- #
def is_union_closed(F: Family) -> bool:
    """Definition 1: closed under pairwise union."""
    members = set(F)
    return all((s | t) in members for s in members for t in members)


def is_upper_set(F: Family, alpha: Sequence[Element]) -> bool:
    """Definition 2: closed upward under inclusion within 2^alpha."""
    members = set(F)
    for s in members:
        for t in powerset(alpha):
            if s <= t and t not in members:
                return False
    return True


def powerset(alpha: Sequence[Element]) -> List[Subset]:
    """Return 2^alpha as a list of frozensets."""
    return [
        frozenset(c)
        for r in range(len(alpha) + 1)
        for c in combinations(alpha, r)
    ]


# --------------------------------------------------------------------------- #
# Union closure (Definition 6) via the fixed-point algorithm
# --------------------------------------------------------------------------- #
def union_closure(F: Family) -> Family:
    """Least union-closed family containing F (Lemmas 5-6)."""
    members = set(F)
    changed = True
    while changed:
        changed = False
        for s in list(members):
            for t in list(members):
                u = s | t
                if u not in members:
                    members.add(u)
                    changed = True
    return list(members)


# --------------------------------------------------------------------------- #
# Theorem checks
# --------------------------------------------------------------------------- #
def check_double_counting(F: Family, alpha: Sequence[Element]) -> bool:
    """Theorem 1: sum_a mc(a) = sum_{s in F} |s|."""
    lhs = sum(member_count(a, F) for a in alpha)
    rhs = total_occupancy(F)
    return lhs == rhs


def check_majority_from_average(
    F: Family, alpha: Sequence[Element]
) -> Tuple[bool, object]:
    """Theorem 2: if 2*sum|s| >= |F|*|alpha| then some a has 2*mc(a) >= |F|.

    Returns (hypothesis_holds, witness_or_None).
    """
    hyp = 2 * total_occupancy(F) >= len(F) * len(alpha)
    if not hyp:
        return False, None
    for a in alpha:
        if 2 * member_count(a, F) >= len(F):
            return True, a
    return True, None  # would contradict the theorem (should never happen)


def check_inclusion_exclusion(
    a: Element, b: Element, F: Family
) -> bool:
    """Theorem 4: uc(a,b) = mc(a) + mc(b) - jc(a,b)."""
    return union_count(a, b, F) == (
        member_count(a, F) + member_count(b, F) - joint_count(a, b, F)
    )


def check_closure_monotone(F: Family) -> Tuple[int, int, bool]:
    """Theorem 7: total occupancy does not decrease under union closure."""
    before = total_occupancy(F)
    after = total_occupancy(union_closure(F))
    return before, after, before <= after


def check_powerset_correlation(alpha: Sequence[Element]) -> bool:
    """Theorem 8: |2^a| * jc(a,b) >= mc(a)*mc(b) on the full powerset."""
    P = powerset(alpha)
    card = len(P)
    for a in alpha:
        for b in alpha:
            if card * joint_count(a, b, P) < member_count(a, P) * member_count(b, P):
                return False
    return True


# --------------------------------------------------------------------------- #
# Report
# --------------------------------------------------------------------------- #
def main() -> None:
    alpha = ("x", "y", "z", "w")

    # A handcrafted union-closed family that is large on average.
    F: Family = [
        frozenset({"x", "y"}),
        frozenset({"y", "z"}),
        frozenset({"x", "y", "z"}),
        frozenset({"x", "y", "z", "w"}),
        frozenset({"y", "z", "w"}),
    ]
    # Close it so it genuinely satisfies Definition 1.
    F = union_closure(F)

    print("Ground set alpha =", alpha, " |alpha| =", len(alpha))
    print("Family F has", len(F), "members; union-closed:", is_union_closed(F))
    print()

    print("--- Definition observables ---")
    for a in alpha:
        print(f"  mc({a}) = {member_count(a, F)}")
    print("  total occupancy sum|s| =", total_occupancy(F))
    print()

    print("--- Theorem 1 (double counting) ---")
    print("  sum_a mc(a) == sum_s |s| :", check_double_counting(F, alpha))
    print()

    print("--- Theorem 2 (majority from average) ---")
    hyp, w = check_majority_from_average(F, alpha)
    print("  averaged hypothesis holds:", hyp, " witness element:", w)
    if w is not None:
        print(f"  check: 2*mc({w}) = {2*member_count(w, F)} >= |F| = {len(F)}")
    print()

    print("--- Theorem 4 (inclusion-exclusion), all pairs ---")
    ok = all(check_inclusion_exclusion(a, b, F) for a in alpha for b in alpha)
    print("  uc = mc + mc - jc for every pair:", ok)
    print(f"  sample x,z: uc={union_count('x','z',F)} "
          f"mc(x)={member_count('x',F)} mc(z)={member_count('z',F)} "
          f"jc={joint_count('x','z',F)}")
    print()

    print("--- Theorem 7 (closure monotonicity) ---")
    G: Family = [frozenset({"x"}), frozenset({"y"}), frozenset({"z"})]
    before, after, mono = check_closure_monotone(G)
    print(f"  start family of singletons: occupancy {before} -> {after} "
          f"(non-decreasing: {mono})")
    print("  closed family size:", len(union_closure(G)))
    print()

    print("--- Theorem 8 (FKG base case on the full powerset) ---")
    for n in range(1, 6):
        a = tuple(range(n))
        print(f"  |alpha|={n}: |2^a|*jc >= mc*mc holds:",
              check_powerset_correlation(a))
    # Show the saturating equality for distinct sites.
    P = powerset(("a", "b", "c"))
    print("  n=3 distinct a,b:",
          f"|2^a|*jc = {len(P)*joint_count('a','b',P)}",
          f"== mc*mc = {member_count('a',P)*member_count('b',P)}")


if __name__ == "__main__":
    main()
