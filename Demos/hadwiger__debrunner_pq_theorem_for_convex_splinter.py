"""
demo.py — Numerical demonstrations for the Hadwiger–Debrunner (p,q) theory
for convex splinters.

This self-contained script illustrates the *combinatorial core* of the
transversal theory that was formally verified in Phase A:

  * HasPQProperty            — the (p,q)-property of a finite family of sets,
  * IsTransversal            — a piercing set hitting every member,
  * strengthen_p / weaken_q  — monotonicity of the (p,q)-property,
  * exists_transversal_of_nonempty       — the trivial transversal (|T| <= |s|),
  * exists_transversal_of_pqProperty_full — the one-shot bound (|T| <= |s|-q+1).

Sets are modelled as finite Python `frozenset`s of integer "points"; their
intersections are honest set intersections, so every claim below is checked
concretely. Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, Hashable, Iterable, List, Optional, Set, Tuple

# A "set" in the family is a frozenset of integer points. A family is a dict
# mapping an index (Hashable) to such a set.
Point = int
Member = frozenset
Family = Dict[Hashable, "frozenset[Point]"]


# --------------------------------------------------------------------------
# Core predicates (mirroring the Lean definitions)
# --------------------------------------------------------------------------
def common_intersection(family: Family, indices: Iterable[Hashable]) -> "frozenset[Point]":
    """Intersection of the members indexed by `indices` (empty index -> {})."""
    indices = list(indices)
    if not indices:
        return frozenset()
    result = family[indices[0]]
    for i in indices[1:]:
        result = result & family[i]
    return result


def has_pq_property(family: Family, p: int, q: int) -> bool:
    """HasPQProperty: among every p members, some q share a common point."""
    s = list(family.keys())
    for A in combinations(s, p):
        if not any(common_intersection(family, B) for B in combinations(A, q)):
            return False
    return True


def is_transversal(transversal: "Set[Point]", family: Family) -> bool:
    """IsTransversal: every member contains a point of `transversal`."""
    return all(member & transversal for member in family.values())


# --------------------------------------------------------------------------
# Constructive transversal builders (mirroring the Lean existence proofs)
# --------------------------------------------------------------------------
def trivial_transversal(family: Family) -> "Set[Point]":
    """exists_transversal_of_nonempty: pick one point from each member.

    Returns a transversal of size at most |family|.
    """
    transversal: Set[Point] = set()
    for member in family.values():
        if member:  # nonempty
            transversal.add(next(iter(sorted(member))))
    return transversal


def one_shot_transversal(family: Family, q: int) -> Optional["Set[Point]"]:
    """exists_transversal_of_pqProperty_full.

    If the *full* (|s|, q)-property holds, find a q-subset with a common point,
    pierce all of it with one point, and pierce the rest individually.
    Returns a transversal of size at most |s| - q + 1, or None if no q-subset
    shares a point.
    """
    s = list(family.keys())
    for B in combinations(s, q):
        shared = common_intersection(family, B)
        if shared:
            t0 = next(iter(sorted(shared)))
            rest = {i: family[i] for i in s if i not in B}
            return {t0} | trivial_transversal(rest)
    return None


def min_transversal_size(family: Family) -> int:
    """Brute-force exact transversal number (for verification on small inputs)."""
    universe = sorted(set().union(*family.values())) if family else []
    for k in range(len(universe) + 1):
        for T in combinations(universe, k):
            if is_transversal(set(T), family):
                return k
    return len(universe)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_monotonicity() -> None:
    print("=" * 70)
    print("DEMO 1 — Monotonicity: strengthen_p and weaken_q")
    print("=" * 70)
    # Three sets that pairwise intersect but have no common point
    # (a 1-D "splinter"-style Helly violation): every PAIR meets, the TRIPLE
    # does not. Hence the (2,2)-property holds but the (3,3)-property fails.
    family: Family = {
        "A": frozenset({0, 1}),  # meets B at 1, C at 0
        "B": frozenset({1, 2}),  # meets A at 1, C at 2
        "C": frozenset({0, 2}),  # meets A at 0, B at 2
    }
    p, q = 2, 2
    print(f"Family of {len(family)} intervals; checking ({p},{q})-property:",
          has_pq_property(family, p, q))
    # strengthen_p: (2,2) => (3,2)
    print(f"  strengthen_p  ({p},{q}) => ({p+1},{q}):",
          has_pq_property(family, p + 1, q))
    # weaken_q: (3,2) => (3,1)
    print(f"  weaken_q      ({p+1},{q}) => ({p+1},{q-1}):",
          has_pq_property(family, p + 1, q - 1))
    print()


def demo_trivial_transversal() -> None:
    print("=" * 70)
    print("DEMO 2 — Trivial transversal: |T| <= |s|")
    print("=" * 70)
    family: Family = {
        i: frozenset({i, i + 100}) for i in range(5)  # disjoint pairs
    }
    T = trivial_transversal(family)
    print(f"|s| = {len(family)}, |T| = {len(T)} (<= |s|):", len(T) <= len(family))
    print("Is a valid transversal:", is_transversal(T, family))
    print()


def demo_one_shot_bound() -> None:
    print("=" * 70)
    print("DEMO 3 — One-shot bound: |T| <= |s| - q + 1")
    print("=" * 70)
    # q = 4 members all share the point 0; two extra members are off on their own.
    family: Family = {
        "S1": frozenset({0, 1}),
        "S2": frozenset({0, 2}),
        "S3": frozenset({0, 3}),
        "S4": frozenset({0, 4}),
        "X":  frozenset({50}),
        "Y":  frozenset({60}),
    }
    q = 4
    n = len(family)
    T = one_shot_transversal(family, q)
    bound = n - q + 1
    print(f"|s| = {n}, q = {q}, bound |s|-q+1 = {bound}")
    print(f"Constructed transversal {sorted(T)}  size = {len(T)}")
    print(f"  size <= bound:", len(T) <= bound)
    print(f"  valid transversal:", is_transversal(T, family))
    print(f"  exact optimum (brute force): {min_transversal_size(family)}")
    print()


def demo_helly_threshold() -> None:
    print("=" * 70)
    print("DEMO 4 — Helly number as the single geometric scalar")
    print("=" * 70)
    print("Convex sets in R^d : Helly number h = d + 1")
    print("Convex splinters   : Helly number h = 2d + 1")
    for d in range(1, 5):
        print(f"  d = {d}:  convex threshold q >= {d+1},"
              f"  splinter threshold q >= {2*d+1}")
    print("\nThe combinatorial core (Demos 1-3) is identical for both classes;")
    print("only the scalar h changes at the Helly bridge.")
    print()


def main() -> None:
    demo_monotonicity()
    demo_trivial_transversal()
    demo_one_shot_bound()
    demo_helly_threshold()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
