"""
Numerical demonstrations for:

    The Lattice of Witnesses to Rainbow Forest Obstructions

An edge-colored graph has a *total rainbow forest* of size t exactly when two
matroids (the graphic matroid and the color-partition matroid) share a common
independent set of size t.  Weak duality (the Rainbow Forest Inequality) says

    |I| <= g(A) = r1(A) + r2(E \ A)   for every common independent set I and
                                       every subset A of the ground set E.

A subset A with g(A) < t is a *witness* that no total rainbow forest of size t
exists.  This module verifies, on concrete instances, the core results:

  * the Rainbow Forest Inequality (weak duality),
  * submodularity of the objective g,
  * closure of g-minimizers under intersection and union (a lattice),
  * existence of a unique least and greatest witness,
  * the two-element counterexample refuting the "unique witness" conjecture.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, FrozenSet, Iterable, List, Tuple

# A rank function maps a frozenset of elements to a natural number.
RankFn = Callable[[FrozenSet[int]], int]


# --------------------------------------------------------------------------- #
# Basic set utilities
# --------------------------------------------------------------------------- #
def powerset(ground: FrozenSet[int]) -> List[FrozenSet[int]]:
    """All subsets of `ground`, as frozensets."""
    elems = sorted(ground)
    return [
        frozenset(c)
        for c in chain.from_iterable(combinations(elems, k) for k in range(len(elems) + 1))
    ]


def g_objective(E: FrozenSet[int], r1: RankFn, r2: RankFn, A: FrozenSet[int]) -> int:
    """The matroid-intersection objective g(A) = r1(A) + r2(E \\ A)."""
    return r1(A) + r2(E - A)


# --------------------------------------------------------------------------- #
# Example rank functions
# --------------------------------------------------------------------------- #
def indicator_rank(A: FrozenSet[int]) -> int:
    """Rank of the uniform matroid U_{1,n}: 0 on the empty set, 1 otherwise."""
    return 0 if len(A) == 0 else 1


def uniform_rank(k: int) -> RankFn:
    """Rank of the uniform matroid U_{k,n}: min(|A|, k)."""
    return lambda A: min(len(A), k)


def partition_rank(blocks: List[FrozenSet[int]]) -> RankFn:
    """Rank of a partition matroid: one representative per block."""

    def r(A: FrozenSet[int]) -> int:
        return sum(1 for b in blocks if len(A & b) >= 1)

    return r


# --------------------------------------------------------------------------- #
# Verification of the matroid rank axioms
# --------------------------------------------------------------------------- #
def check_matroid_axioms(E: FrozenSet[int], r: RankFn) -> bool:
    """Check (R0)-(R3) for r restricted to subsets of E (and their unions)."""
    subs = powerset(E)
    # (R0)
    if r(frozenset()) != 0:
        return False
    for X in subs:
        # (R1) monotonicity and (R2) unit increase
        for Y in subs:
            if X <= Y and r(X) > r(Y):
                return False
        for e in E:
            if r(X | {e}) > r(X) + 1:
                return False
        # (R3) submodularity
        for Y in subs:
            if r(X | Y) + r(X & Y) > r(X) + r(Y):
                return False
    return True


# --------------------------------------------------------------------------- #
# Core theorems, verified numerically
# --------------------------------------------------------------------------- #
def common_independent_sets(
    E: FrozenSet[int], r1: RankFn, r2: RankFn
) -> List[FrozenSet[int]]:
    """All I <= E independent for both matroids: r_i(I) = |I|."""
    return [I for I in powerset(E) if r1(I) == len(I) and r2(I) == len(I)]


def verify_rainbow_forest_inequality(
    E: FrozenSet[int], r1: RankFn, r2: RankFn
) -> bool:
    """|I| <= g(A) for every common independent set I and every A <= E."""
    subs = powerset(E)
    for I in common_independent_sets(E, r1, r2):
        for A in subs:
            if len(I) > g_objective(E, r1, r2, A):
                return False
    return True


def verify_submodularity(E: FrozenSet[int], r1: RankFn, r2: RankFn) -> bool:
    """g(A ∪ B) + g(A ∩ B) <= g(A) + g(B) for all A, B <= E."""
    subs = powerset(E)
    for A in subs:
        for B in subs:
            lhs = g_objective(E, r1, r2, A | B) + g_objective(E, r1, r2, A & B)
            rhs = g_objective(E, r1, r2, A) + g_objective(E, r1, r2, B)
            if lhs > rhs:
                return False
    return True


def minimizers(E: FrozenSet[int], r1: RankFn, r2: RankFn) -> Tuple[int, List[FrozenSet[int]]]:
    """Return (min value m, list of all minimizing subsets)."""
    subs = powerset(E)
    vals = {A: g_objective(E, r1, r2, A) for A in subs}
    m = min(vals.values())
    return m, [A for A in subs if vals[A] == m]


def verify_lattice_and_extremes(
    E: FrozenSet[int], r1: RankFn, r2: RankFn
) -> Tuple[bool, FrozenSet[int], FrozenSet[int]]:
    """Check closure under ∩ and ∪, and return the least and greatest witness."""
    _, mins = minimizers(E, r1, r2)
    mset = set(mins)
    for A in mins:
        for B in mins:
            if (A & B) not in mset or (A | B) not in mset:
                return False, frozenset(), frozenset()
    a_least = frozenset.intersection(*mins) if mins else frozenset()
    a_greatest = frozenset.union(*mins) if mins else frozenset()
    closed = a_least in mset and a_greatest in mset
    return closed, a_least, a_greatest


def fmt(A: Iterable[int]) -> str:
    s = sorted(A)
    return "{" + ", ".join(map(str, s)) + "}" if s else "∅"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_counterexample() -> None:
    print("=" * 68)
    print("DEMO 1  Refuting the uniqueness conjecture (both matroids = U_{1,2})")
    print("=" * 68)
    E = frozenset({0, 1})
    r1 = r2 = indicator_rank
    t = 2
    print(f"Ground set E = {fmt(E)},  target t = {t}")
    print(f"Both rank functions are the indicator (uniform U_1,2) rank.\n")
    header = "A".rjust(10) + " | " + "r1(A)".rjust(5) + " | " + "E\\A".rjust(7) + " | " + "r2(E\\A)".rjust(8) + " | " + "g(A)".rjust(4)
    print(header)
    print("-" * 48)
    for A in powerset(E):
        print(
            f"{fmt(A):>10} | {r1(A):>5} | {fmt(E - A):>7} | {r2(E - A):>8} | "
            f"{g_objective(E, r1, r2, A):>4}"
        )
    m, mins = minimizers(E, r1, r2)
    witnesses = [A for A in powerset(E) if g_objective(E, r1, r2, A) < t]
    print(f"\nMinimum value m = {m}, attained at: {[fmt(A) for A in mins]}")
    print(f"Witnesses (g(A) < t): {[fmt(A) for A in witnesses]}")
    print(f"=> at least two DISTINCT witnesses: uniqueness is FALSE.\n")


def demo_lattice() -> None:
    print("=" * 68)
    print("DEMO 2  The lattice of witnesses: least and greatest cut")
    print("=" * 68)
    # Two partition matroids on a 3-element ground set giving several minimizers.
    E = frozenset({0, 1, 2})
    r1 = uniform_rank(1)  # keep at most one edge (structural bottleneck)
    r2 = uniform_rank(1)  # keep at most one color
    print(f"Ground set E = {fmt(E)}, r1 = r2 = U_1,3 (uniform rank 1)\n")
    assert check_matroid_axioms(E, r1)
    assert check_matroid_axioms(E, r2)
    m, mins = minimizers(E, r1, r2)
    print(f"Minimum value m = {m}")
    print(f"Minimizers: {[fmt(A) for A in mins]}")
    closed, a_least, a_greatest = verify_lattice_and_extremes(E, r1, r2)
    print(f"Closed under ∩ and ∪ ? {closed}")
    print(f"Least witness  A_min = {fmt(a_least)}")
    print(f"Greatest witness A_max = {fmt(a_greatest)}\n")


def demo_rainbow_forest_positive() -> None:
    print("=" * 68)
    print("DEMO 3  A genuine total rainbow forest (no obstruction)")
    print("=" * 68)
    # Path 0-1-2-3 (edges e0,e1,e2 as a graphic uniform proxy) with 3 colors.
    E = frozenset({0, 1, 2})
    r1 = uniform_rank(3)  # all three edges acyclic (a small forest)
    blocks = [frozenset({0}), frozenset({1}), frozenset({2})]  # 3 distinct colors
    r2 = partition_rank(blocks)
    print(f"Ground set E = {fmt(E)}, r1 = U_3,3, r2 = 3 singleton color classes\n")
    assert check_matroid_axioms(E, r1)
    assert check_matroid_axioms(E, r2)
    cis = common_independent_sets(E, r1, r2)
    best = max(cis, key=len)
    m, _ = minimizers(E, r1, r2)
    print(f"Largest total rainbow forest: {fmt(best)}  (size {len(best)})")
    print(f"min_A g(A) = {m}  (weak-duality bound matches the max size)\n")


def demo_verify_all() -> None:
    print("=" * 68)
    print("DEMO 4  Automated verification of all core theorems on many instances")
    print("=" * 68)
    instances = [
        ("U_1,2 / U_1,2 on {0,1}", frozenset({0, 1}), indicator_rank, indicator_rank),
        ("U_1,3 / U_1,3 on {0,1,2}", frozenset({0, 1, 2}), uniform_rank(1), uniform_rank(1)),
        ("U_2,3 / U_1,3 on {0,1,2}", frozenset({0, 1, 2}), uniform_rank(2), uniform_rank(1)),
        (
            "U_3,3 / partition on {0,1,2}",
            frozenset({0, 1, 2}),
            uniform_rank(3),
            partition_rank([frozenset({0, 1}), frozenset({2})]),
        ),
    ]
    for name, E, r1, r2 in instances:
        ax = check_matroid_axioms(E, r1) and check_matroid_axioms(E, r2)
        rfi = verify_rainbow_forest_inequality(E, r1, r2)
        sub = verify_submodularity(E, r1, r2)
        lat, a_least, a_greatest = verify_lattice_and_extremes(E, r1, r2)
        print(f"\n{name}")
        print(f"  matroid axioms (R0-R3) ......... {ax}")
        print(f"  Rainbow Forest Inequality ...... {rfi}")
        print(f"  submodularity of g ............. {sub}")
        print(f"  minimizers form a lattice ...... {lat}")
        print(f"  A_min = {fmt(a_least)}, A_max = {fmt(a_greatest)}")
    print()


if __name__ == "__main__":
    demo_counterexample()
    demo_lattice()
    demo_rainbow_forest_positive()
    demo_verify_all()
    print("All demonstrations complete.")
