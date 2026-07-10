"""
Numerical demonstrations for:

    Minimal Obstructions to Total Rainbow Forests: An Edge-Deletion Analysis

We work with two integer-valued rank functions r1, r2 on a finite ground set E
(the "edges"), and the Edmonds intersection objective

    obj(A) = r1(A) + r2(E \\ A).

The Rainbow Forest Inequality (RFI) at target t asserts  t <= obj(A) for all A.
An obstruction is a graph (rank pair) for which some A has obj(A) < t.

This script demonstrates, purely by brute-force enumeration over all subsets:

  1. Weak duality: every common independent set I satisfies |I| <= obj(A).
  2. Deletion monotonicity: obj of any single-edge deletion never exceeds obj(G).
  3. No edge-minimal obstruction: failure of RFI is closed under deletion.
  4. The lattice of failing / minimizing certificates for a fixed obstruction.

All functions are self-contained and type-hinted.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, Iterable, List, Tuple

RankFn = Callable[[FrozenSet[int]], int]


# --------------------------------------------------------------------------
# Basic combinatorics
# --------------------------------------------------------------------------
def all_subsets(ground: FrozenSet[int]) -> List[FrozenSet[int]]:
    """Return every subset of `ground` as a frozenset."""
    elems = sorted(ground)
    subsets: List[FrozenSet[int]] = []
    for k in range(len(elems) + 1):
        for combo in combinations(elems, k):
            subsets.append(frozenset(combo))
    return subsets


def objective(r1: RankFn, r2: RankFn, ground: FrozenSet[int],
              A: FrozenSet[int]) -> int:
    """Edmonds objective obj(A) = r1(A) + r2(E \\ A)."""
    return r1(A) + r2(ground - A)


def min_objective(r1: RankFn, r2: RankFn,
                  ground: FrozenSet[int]) -> int:
    """min over all A of obj(A) -- equals max total rainbow forest size (Edmonds)."""
    return min(objective(r1, r2, ground, A) for A in all_subsets(ground))


def rfi_holds(r1: RankFn, r2: RankFn, ground: FrozenSet[int], t: int) -> bool:
    """True iff t <= obj(A) for every subset A."""
    return all(t <= objective(r1, r2, ground, A) for A in all_subsets(ground))


# --------------------------------------------------------------------------
# Matroid rank helpers
# --------------------------------------------------------------------------
def uniform_rank(k: int) -> RankFn:
    """Rank function of the uniform matroid U_{k,n}:  r(A) = min(|A|, k)."""
    return lambda A: min(len(A), k)


def partition_rank(color: dict[int, int]) -> RankFn:
    """Rank of the partition matroid: number of distinct colors present in A."""
    return lambda A: len({color[e] for e in A})


def is_monotone(r: RankFn, ground: FrozenSet[int]) -> bool:
    """Check X subseteq Y => r(X) <= r(Y) over all pairs of subsets."""
    subs = all_subsets(ground)
    return all(r(X) <= r(Y) for X in subs for Y in subs if X <= Y)


# --------------------------------------------------------------------------
# 1. Weak duality (Rainbow Forest Inequality)
# --------------------------------------------------------------------------
def common_independent_sets(r1: RankFn, r2: RankFn,
                            ground: FrozenSet[int]) -> List[FrozenSet[int]]:
    """All I with r1(X)=|X| and r2(X)=|X| for every X subseteq I."""
    result: List[FrozenSet[int]] = []
    for I in all_subsets(ground):
        if all(r1(X) == len(X) and r2(X) == len(X) for X in all_subsets(I)):
            result.append(I)
    return result


def check_weak_duality(r1: RankFn, r2: RankFn,
                       ground: FrozenSet[int]) -> bool:
    """Verify |I| <= obj(A) for every common independent set I and subset A."""
    cis = common_independent_sets(r1, r2, ground)
    subs = all_subsets(ground)
    return all(len(I) <= objective(r1, r2, ground, A) for I in cis for A in subs)


# --------------------------------------------------------------------------
# 2 & 3. Deletion monotonicity and no edge-minimal obstruction
# --------------------------------------------------------------------------
def deletion_min_objective(r1: RankFn, r2: RankFn,
                           ground: FrozenSet[int], e: int) -> int:
    """min obj of the deletion G - e (ground set E \\ {e})."""
    g = ground - {e}
    return min(r1(A) + r2(g - A) for A in all_subsets(g))


def check_deletion_monotone(r1: RankFn, r2: RankFn,
                            ground: FrozenSet[int]) -> bool:
    """min obj_{G-e} <= min obj_G for every edge e."""
    base = min_objective(r1, r2, ground)
    return all(deletion_min_objective(r1, r2, ground, e) <= base
               for e in ground)


def no_edge_minimal_obstruction(r1: RankFn, r2: RankFn,
                                ground: FrozenSet[int], t: int) -> bool:
    """
    Confirm there is NO edge-minimal obstruction: it is impossible for RFI to
    fail on G while holding on every deletion G - e.  Returns True when the
    class is empty (i.e. the theorem holds for this instance).
    """
    fails_on_g = not rfi_holds(r1, r2, ground, t)
    holds_on_every_deletion = all(
        deletion_min_objective(r1, r2, ground, e) >= t for e in ground
    )
    # An edge-minimal obstruction would need BOTH to be true.
    return not (fails_on_g and holds_on_every_deletion)


# --------------------------------------------------------------------------
# 4. Lattice of minimizing certificates
# --------------------------------------------------------------------------
def minimizing_certificates(r1: RankFn, r2: RankFn,
                            ground: FrozenSet[int]) -> List[FrozenSet[int]]:
    """All A achieving the minimum objective."""
    m = min_objective(r1, r2, ground)
    return [A for A in all_subsets(ground)
            if objective(r1, r2, ground, A) == m]


def is_sublattice(family: Iterable[FrozenSet[int]]) -> bool:
    """Check closure under union and intersection."""
    fam = list(family)
    fs = set(fam)
    return all((A | B) in fs and (A & B) in fs for A in fam for B in fam)


def least_and_greatest(family: List[FrozenSet[int]]
                       ) -> Tuple[FrozenSet[int], FrozenSet[int]]:
    """Return (intersection of all, union of all) certificates."""
    inter = family[0]
    union = family[0]
    for A in family[1:]:
        inter = inter & A
        union = union | A
    return inter, union


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def demo() -> None:
    print("=" * 70)
    print("DEMO 1: Two free edges (distinct colors) -- an honest obstruction")
    print("=" * 70)
    ground = frozenset({0, 1})
    r1 = uniform_rank(2)                       # free forest matroid on two edges
    r2 = partition_rank({0: 7, 1: 8})          # two distinct colors
    t = 3
    print("monotone r1, r2 :", is_monotone(r1, ground), is_monotone(r2, ground))
    for A in all_subsets(ground):
        print(f"  obj({set(A) or '{}'}) = {objective(r1, r2, ground, A)}")
    print("min obj (= max total rainbow forest) :", min_objective(r1, r2, ground))
    print(f"RFI holds at t={t} ? ", rfi_holds(r1, r2, ground, t), "(False => obstruction)")
    print("weak duality verified :", check_weak_duality(r1, r2, ground))
    print("deletion monotone     :", check_deletion_monotone(r1, r2, ground))
    print("no edge-minimal obstruction (theorem holds):",
          no_edge_minimal_obstruction(r1, r2, ground, t))

    print()
    print("=" * 70)
    print("DEMO 2: Larger instance -- graphic-style uniform matroid + coloring")
    print("=" * 70)
    ground = frozenset({0, 1, 2, 3})
    r1 = uniform_rank(3)                        # forests of size <= 3
    r2 = partition_rank({0: 1, 1: 2, 2: 3, 3: 3})  # colors: {1,2,3,3}
    t = 4
    print("min obj :", min_objective(r1, r2, ground), " target t =", t)
    print("RFI holds ?", rfi_holds(r1, r2, ground, t))
    certs = minimizing_certificates(r1, r2, ground)
    print("number of minimizing certificates :", len(certs))
    print("certificates form a sublattice    :", is_sublattice(certs))
    lo, hi = least_and_greatest(certs)
    print("unique smallest certificate       :", set(lo) or "{}")
    print("unique largest  certificate       :", set(hi))
    print("deletion monotone :", check_deletion_monotone(r1, r2, ground))

    print()
    print("=" * 70)
    print("DEMO 3: Failure is closed under deletion (contagion of obstruction)")
    print("=" * 70)
    ground = frozenset({0, 1, 2})
    r1 = uniform_rank(1)
    r2 = partition_rank({0: 5, 1: 5, 2: 5})    # all one color
    t = 2
    print("RFI on G holds ?", rfi_holds(r1, r2, ground, t), "(obstruction)")
    for e in ground:
        dm = deletion_min_objective(r1, r2, ground, e)
        print(f"  delete edge {e}: min obj_(G-e) = {dm}  ->  still < t ? {dm < t}")
    print("=> every deletion inherits the obstruction, as the theorem predicts.")


if __name__ == "__main__":
    demo()
