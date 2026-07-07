"""
demo.py
=======

Numerical demonstrations for:

    "The Helly Number of Semicubes, and the Opposite-Semicube Property
     in Cartesian Products of Partial Cubes"

We work in the hypercube Q(n) whose vertices are binary strings of length n,
encoded as frozensets of coordinates that are "true" (i.e. equal to 1).

A *semicube* is a pair (i, b) with i a coordinate and b in {True, False};
it denotes the set of all vertices whose i-th coordinate equals b.

The results demonstrated here:

  * Lemma 1 -- opposite semicubes (i, True) and (i, False) are disjoint.
  * Proposition 3 -- semicubes on distinct coordinates always intersect.
  * Theorem A -- a pairwise-intersecting family of semicubes has a common
    vertex (Helly number 2), given by the canonical witness.
  * Corollary B -- for a Cartesian product the family solves factorwise.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

# A vertex of Q(n) is the frozenset of "true" coordinates.
Vertex = FrozenSet[int]
# A semicube is (coordinate, bit).
Semicube = Tuple[int, bool]


# --------------------------------------------------------------------------
# Basic hypercube / semicube machinery
# --------------------------------------------------------------------------
def all_vertices(n: int) -> List[Vertex]:
    """All 2^n vertices of Q(n) as frozensets of coordinates in range(n)."""
    verts: List[Vertex] = []
    for bits in product((False, True), repeat=n):
        verts.append(frozenset(i for i, b in enumerate(bits) if b))
    return verts


def in_semicube(v: Vertex, sc: Semicube) -> bool:
    """Does vertex v lie in the semicube sc = (i, b)?  (i in v) == b."""
    i, b = sc
    return (i in v) == b


def semicube_set(n: int, sc: Semicube) -> Set[Vertex]:
    """The explicit vertex set of a semicube (used for brute-force checks)."""
    return {v for v in all_vertices(n) if in_semicube(v, sc)}


# --------------------------------------------------------------------------
# The core algorithm: consistency by coordinate folding (Theorem A)
# --------------------------------------------------------------------------
def semicube_common_vertex(family: Iterable[Semicube]) -> Optional[Vertex]:
    """
    Decide whether a family of semicubes has a common vertex, and if so return
    the canonical witness v = { i : (i, True) in family }.

    Returns None exactly when some coordinate is demanded in both directions
    (the unique obstruction, Lemma 1 + Lemma 2).  Runs in O(|family|).
    """
    assignment: Dict[int, bool] = {}
    for i, b in family:
        if i in assignment:
            if assignment[i] != b:
                return None  # opposite pair -> inconsistent
        else:
            assignment[i] = b
    return frozenset(i for i, b in assignment.items() if b)


def is_pairwise_intersecting(n: int, family: List[Semicube]) -> bool:
    """Brute-force check that every pair of semicubes shares a vertex."""
    for sc1, sc2 in combinations(family, 2):
        s1, s2 = semicube_set(n, sc1), semicube_set(n, sc2)
        if not (s1 & s2):
            return False
    return True


def has_global_common_vertex(n: int, family: List[Semicube]) -> bool:
    """Brute-force check for a vertex lying in every semicube of the family."""
    return any(all(in_semicube(v, sc) for sc in family) for v in all_vertices(n))


# --------------------------------------------------------------------------
# Product decomposition (Corollary B)
# --------------------------------------------------------------------------
def product_common_vertex(
    left_dim: int, right_dim: int, family: List[Semicube]
) -> Optional[Tuple[Optional[Vertex], Optional[Vertex]]]:
    """
    Solve a family of semicubes in Q(left_dim) x Q(right_dim).

    Coordinates 0..left_dim-1 belong to the left factor; coordinates
    left_dim..left_dim+right_dim-1 belong to the right factor.  We split the
    family and solve each factor independently (Corollary B).  Returns the pair
    of witnesses, or None if either factor is inconsistent.
    """
    left = [(i, b) for (i, b) in family if i < left_dim]
    right = [(i - left_dim, b) for (i, b) in family if i >= left_dim]
    vl = semicube_common_vertex(left)
    vr = semicube_common_vertex(right)
    if (left and vl is None) or (right and vr is None):
        return None
    return (vl, vr)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_opposite_disjoint(n: int = 3) -> None:
    print("=" * 70)
    print("Lemma 1: opposite semicubes are disjoint")
    print("=" * 70)
    for i in range(n):
        s_true = semicube_set(n, (i, True))
        s_false = semicube_set(n, (i, False))
        inter = s_true & s_false
        print(f"  coordinate {i}: |H(i,True)|={len(s_true)}, "
              f"|H(i,False)|={len(s_false)}, intersection={len(inter)}")
    print()


def demo_cross_intersect(n: int = 3) -> None:
    print("=" * 70)
    print("Proposition 3: semicubes on distinct coordinates always intersect")
    print("=" * 70)
    ok = True
    for i, j in combinations(range(n), 2):
        for b, c in product((True, False), repeat=2):
            inter = semicube_set(n, (i, b)) & semicube_set(n, (j, c))
            if not inter:
                ok = False
            print(f"  H({i},{b}) & H({j},{c}): {len(inter)} common vertices")
    print(f"  ALL cross pairs intersect: {ok}")
    print()


def demo_helly(n: int = 4) -> None:
    print("=" * 70)
    print("Theorem A: pairwise-intersecting => globally intersecting (Helly 2)")
    print("=" * 70)
    families = [
        [(0, True), (1, False), (3, True)],          # consistent
        [(0, True), (1, False), (0, True)],          # consistent (repeat)
        [(0, True), (2, True), (0, False)],          # opposite pair -> not
    ]
    for fam in families:
        pw = is_pairwise_intersecting(n, fam)
        witness = semicube_common_vertex(fam)
        glob = has_global_common_vertex(n, fam)
        agree = (witness is not None) == glob == pw
        print(f"  family {fam}")
        print(f"    pairwise-intersecting (brute)   : {pw}")
        print(f"    global common vertex (brute)    : {glob}")
        print(f"    canonical witness (Theorem A)   : "
              f"{sorted(witness) if witness is not None else None}")
        if witness is not None:
            print(f"    witness lies in every semicube  : "
                  f"{all(in_semicube(witness, sc) for sc in fam)}")
        print(f"    all three notions agree          : {agree}")
    print()


def demo_product() -> None:
    print("=" * 70)
    print("Corollary B: product Q(2) x Q(2) solves factorwise")
    print("=" * 70)
    left_dim, right_dim = 2, 2
    fam = [(0, True), (3, False)]  # coord 0 left, coord 3 right
    res = product_common_vertex(left_dim, right_dim, fam)
    print(f"  family {fam} in Q(2) x Q(2)")
    if res is not None:
        vl, vr = res
        print(f"    left witness  : {sorted(vl) if vl is not None else set()}")
        print(f"    right witness : "
              f"{sorted(vr) if vr is not None else set()}")
        # reassemble into a Q(4) vertex to cross-check
        combined = set(vl or set()) | {i + left_dim for i in (vr or set())}
        combined_v = frozenset(combined)
        print(f"    combined vertex in Q(4): {sorted(combined_v)}")
        print(f"    lies in every semicube : "
              f"{all(in_semicube(combined_v, sc) for sc in fam)}")
    print()


def demo_exhaustive_verification(n: int = 4, max_family: int = 3) -> None:
    """
    Exhaustively verify Theorem A on Q(n): for every family (with up to
    max_family semicubes) that is pairwise intersecting, the folding witness
    exists and is genuinely common; and every non-pairwise family is rejected.
    """
    print("=" * 70)
    print(f"Exhaustive check of Theorem A on Q({n}), families up to size "
          f"{max_family}")
    print("=" * 70)
    all_scs: List[Semicube] = [(i, b) for i in range(n) for b in (True, False)]
    checked = 0
    for k in range(1, max_family + 1):
        for fam in combinations(all_scs, k):
            fam_list = list(fam)
            pw = is_pairwise_intersecting(n, fam_list)
            witness = semicube_common_vertex(fam_list)
            glob = has_global_common_vertex(n, fam_list)
            # Theorem A: pairwise <=> global <=> witness found
            assert pw == glob == (witness is not None), fam_list
            if witness is not None:
                assert all(in_semicube(witness, sc) for sc in fam_list)
            checked += 1
    print(f"  verified {checked} families; Theorem A holds in every case.")
    print()


if __name__ == "__main__":
    demo_opposite_disjoint(n=3)
    demo_cross_intersect(n=3)
    demo_helly(n=4)
    demo_product()
    demo_exhaustive_verification(n=4, max_family=3)
    print("All demonstrations completed successfully.")
