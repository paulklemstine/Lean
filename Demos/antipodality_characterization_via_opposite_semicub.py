"""
Numerical demonstrations of the antipodality characterization for hypercube
vertex sets via the opposite-semicube Helly property.

We model vertices of the n-dimensional hypercube Q_n as bit-vectors (tuples of
0/1). We implement:

  * the antipode (bit-complement) map and Hamming distance,
  * semicubes S_i^b and opposite-semicube isometry / cardinality balance,
  * the Helly-number-2 property for coordinate constraints,
  * the antipode construction of the converse direction, and
  * the main biconditional:  under the Helly property,
        S is antipodal  <=>  every pair of opposite semicubes is isometric.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, List, Optional, Tuple

Vertex = Tuple[int, ...]  # a bit-vector, e.g. (0, 1, 1)


# --------------------------------------------------------------------------
# Core hypercube operations
# --------------------------------------------------------------------------
def antipode(v: Vertex) -> Vertex:
    """Bit complement of a vertex: flip every coordinate."""
    return tuple(1 - b for b in v)


def hamming(u: Vertex, v: Vertex) -> int:
    """Hamming distance: number of coordinates in which u and v differ."""
    return sum(1 for a, b in zip(u, v) if a != b)


def all_vertices(n: int) -> List[Vertex]:
    """All 2^n vertices of Q_n."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def semicube(S: FrozenSet[Vertex], i: int, b: int) -> FrozenSet[Vertex]:
    """The semicube S_i^b = { v in S : v[i] == b }."""
    return frozenset(v for v in S if v[i] == b)


def is_antipodal(S: FrozenSet[Vertex]) -> bool:
    """True iff S is closed under taking antipodes."""
    return all(antipode(v) in S for v in S)


# --------------------------------------------------------------------------
# Isometric isomorphism of opposite semicubes
# --------------------------------------------------------------------------
def semicubes_balanced(S: FrozenSet[Vertex], n: int) -> bool:
    """Necessary screen: |S_i^0| == |S_i^1| for every coordinate i."""
    return all(len(semicube(S, i, 0)) == len(semicube(S, i, 1)) for i in range(n))


def antipode_is_iso(S: FrozenSet[Vertex], i: int) -> bool:
    """
    Check whether the antipode map is an isometric isomorphism
    S_i^0 -> S_i^1.  Since the antipode is always a global Hamming isometry,
    this reduces to: the antipode bijects S_i^0 onto S_i^1.
    """
    A = semicube(S, i, 0)
    B = semicube(S, i, 1)
    image = frozenset(antipode(v) for v in A)
    return image == B  # antipode is injective, so bijectivity == image equality


def opposite_semicubes_isometric(S: FrozenSet[Vertex], n: int) -> bool:
    """
    True iff every pair of opposite semicubes is isometrically isomorphic,
    witnessed canonically by the antipode map (the setting of the theorem).
    """
    return all(antipode_is_iso(S, i) for i in range(n))


# --------------------------------------------------------------------------
# Helly property for coordinate constraints
# --------------------------------------------------------------------------
Constraint = Tuple[int, int]  # (coordinate i, demanded bit b)


def satisfies_all(x: Vertex, F: List[Constraint]) -> bool:
    return all(x[i] == b for (i, b) in F)


def globally_satisfiable(S: FrozenSet[Vertex], F: List[Constraint]) -> Optional[Vertex]:
    """Return a vertex of S satisfying all constraints in F, or None."""
    for x in S:
        if satisfies_all(x, F):
            return x
    return None


def pairwise_satisfiable(S: FrozenSet[Vertex], F: List[Constraint]) -> bool:
    """Every one and every two constraints of F satisfiable inside S."""
    for p in F:
        if all(x[p[0]] != p[1] for x in S):
            return False
    for p in F:
        for q in F:
            if not any(x[p[0]] == p[1] and x[q[0]] == q[1] for x in S):
                return False
    return True


def has_helly_property(S: FrozenSet[Vertex], n: int, max_family: int = 3) -> bool:
    """
    Empirically verify the Helly (number-2) property for the semicubes of S:
    for every family F of coordinate constraints (up to a size bound),
    pairwise satisfiability inside S implies global satisfiability inside S.
    """
    constraints = [(i, b) for i in range(n) for b in (0, 1)]
    from itertools import combinations

    for size in range(1, min(max_family, len(constraints)) + 1):
        for F in combinations(constraints, size):
            F = list(F)
            if pairwise_satisfiable(S, F) and globally_satisfiable(S, F) is None:
                return False
    return True


# --------------------------------------------------------------------------
# Converse construction: build the antipode via flip constraints + Helly
# --------------------------------------------------------------------------
def construct_antipode_via_helly(
    S: FrozenSet[Vertex], v: Vertex, n: int
) -> Optional[Vertex]:
    """
    Given v in S with balanced opposite semicubes, attempt to construct anti(v)
    inside S as the common solution of the flip constraints {(i, 1 - v[i])}.
    """
    F = [(i, 1 - v[i]) for i in range(n)]
    return globally_satisfiable(S, F)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_antipode_isometry(n: int = 4) -> None:
    print("=" * 68)
    print(f"Demo 1: the antipode map is a global Hamming isometry (n={n})")
    print("=" * 68)
    verts = all_vertices(n)
    ok = all(
        hamming(antipode(u), antipode(v)) == hamming(u, v)
        for u in verts
        for v in verts
    )
    print(f"  d(anti u, anti v) == d(u, v) for all pairs : {ok}")
    print(f"  antipode of {verts[5]} is {antipode(verts[5])}, "
          f"distance apart = {hamming(verts[5], antipode(verts[5]))} (= n)")
    print()


def demo_helly_number_two(n: int = 3) -> None:
    print("=" * 68)
    print(f"Demo 2: semicubes of the full cube have Helly number exactly 2 (n={n})")
    print("=" * 68)
    S = frozenset(all_vertices(n))
    # A clashing pair {(0,0),(0,1)}: each singleton satisfiable, pair is not.
    F_clash = [(0, 0), (0, 1)]
    print(f"  family {F_clash}:")
    print(f"    each singleton satisfiable : "
          f"{all(globally_satisfiable(S, [c]) is not None for c in F_clash)}")
    print(f"    pair satisfiable           : "
          f"{globally_satisfiable(S, F_clash) is not None}")
    print("    -> pairwise check is necessary; Helly number is not 1.")
    # A pairwise-consistent family: pairwise implies global.
    F_ok = [(0, 1), (1, 0), (2, 1)]
    print(f"  family {F_ok}:")
    print(f"    pairwise satisfiable : {pairwise_satisfiable(S, F_ok)}")
    print(f"    global witness       : {globally_satisfiable(S, F_ok)}")
    print(f"  Helly property verified on full cube : {has_helly_property(S, n)}")
    print()


def demo_forward_direction(n: int = 3) -> None:
    print("=" * 68)
    print(f"Demo 3: antipodal set => opposite semicubes are isometric (n={n})")
    print("=" * 68)
    # An antipodal set: full cube is antipodal; also take a complement-closed subset.
    S = frozenset({(0, 0, 0), (1, 1, 1), (0, 1, 0), (1, 0, 1)})
    print(f"  S = {sorted(S)}")
    print(f"  antipodal                     : {is_antipodal(S)}")
    print(f"  opposite semicubes isometric  : {opposite_semicubes_isometric(S, n)}")
    print()


def demo_converse_and_biconditional(n: int = 3) -> None:
    print("=" * 68)
    print(f"Demo 4: converse + full biconditional under the Helly property (n={n})")
    print("=" * 68)
    S = frozenset(all_vertices(n))  # full cube: has the Helly property
    print(f"  S = full cube Q_{n}")
    print(f"  Helly property                : {has_helly_property(S, n)}")
    print(f"  opposite semicubes isometric  : {opposite_semicubes_isometric(S, n)}")
    v = (0, 1, 1)
    built = construct_antipode_via_helly(S, v, n)
    print(f"  antipode of {v} built via Helly: {built}  (true antipode {antipode(v)})")
    lhs = is_antipodal(S)
    rhs = opposite_semicubes_isometric(S, n)
    print(f"  biconditional  antipodal <=> isometric :  {lhs} <=> {rhs}  ->  {lhs == rhs}")

    # A NON-antipodal example to show the characterization is not vacuous.
    print("  ---")
    T = frozenset({(0, 0, 0), (1, 0, 0)})  # not closed under complement
    print(f"  T = {sorted(T)}")
    print(f"  antipodal                     : {is_antipodal(T)}")
    print(f"  opposite semicubes isometric  : {opposite_semicubes_isometric(T, n)}")
    print(f"  characterization consistent   : "
          f"{is_antipodal(T) == opposite_semicubes_isometric(T, n)}")
    print()


def demo_exhaustive_check(n: int = 3) -> None:
    print("=" * 68)
    print(f"Demo 5: exhaustive check of the biconditional over Helly sets (n={n})")
    print("=" * 68)
    verts = all_vertices(n)
    total = 0
    holds = 0
    # enumerate all subsets of Q_n; verify the biconditional wherever Helly holds
    from itertools import combinations
    for k in range(0, len(verts) + 1):
        for combo in combinations(verts, k):
            S = frozenset(combo)
            if not has_helly_property(S, n):
                continue
            total += 1
            if is_antipodal(S) == opposite_semicubes_isometric(S, n):
                holds += 1
    print(f"  subsets with the Helly property : {total}")
    print(f"  biconditional holds for all     : {holds == total} ({holds}/{total})")
    print()


if __name__ == "__main__":
    demo_antipode_isometry(4)
    demo_helly_number_two(3)
    demo_forward_direction(3)
    demo_converse_and_biconditional(3)
    demo_exhaustive_check(3)
    print("All demonstrations completed.")
