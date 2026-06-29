"""
Daisy Cubes: numerical demonstrations of the structural theorems.

Self-contained, dependency-free Python (standard library only).

We model a vertex of the hypercube Q_n as a frozenset of integers drawn from
{0, ..., n-1} (the set of "switches that are up").  The Hamming distance is the
size of the symmetric difference.  A daisy cube is a *down-closed* family of
such vertices.

This script demonstrates, with concrete numbers, every formalized result:

  * hdist / d(A,B) = |A symmetric-difference B|
  * IsDaisy            : down-closedness
  * downClosure / dc(X): smallest daisy cube containing X
  * isDaisy_iff_downClosure_le : fixed-point characterization
  * IsDaisy.inter / .union / .iInter : lattice closure
  * IsDaisy.empty_mem  : nonempty daisy cube contains the origin
  * IsDaisy.inter_mem  : meet closure
  * meet_on_geodesic   : d(A,B) = d(A, A&B) + d(A&B, B)
  * not_join_closed    : {{}, {0}, {1}} is a daisy cube but not join-closed
  * forbidden family   : (P3^r [] Q_s) \\ {u, v}
  * Dedekind link      : #daisy subcubes of Q_n = M(n)
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = FrozenSet[int]
Family = Set[Vertex]


# --------------------------------------------------------------------------- #
# Core hypercube metric
# --------------------------------------------------------------------------- #
def hdist(a: Vertex, b: Vertex) -> int:
    """Hamming distance d(A,B) = |A symmetric-difference B|."""
    return len(a ^ b)


def all_vertices(n: int) -> List[Vertex]:
    """All 2^n vertices of Q_n as frozensets of {0,...,n-1}."""
    verts: List[Vertex] = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            verts.append(frozenset(combo))
    return verts


# --------------------------------------------------------------------------- #
# Daisy cubes and the down-closure operator
# --------------------------------------------------------------------------- #
def is_daisy(family: Iterable[Vertex]) -> bool:
    """IsDaisy: a family is down-closed iff every subset of a member is a member."""
    fam: Family = set(family)
    for a in fam:
        elems = sorted(a)
        # It suffices to check single-element removals (Theorem: fixed-point test),
        # but we verify the full down-set here for transparency.
        for k in range(len(elems) + 1):
            for combo in combinations(elems, k):
                if frozenset(combo) not in fam:
                    return False
    return True


def down_closure(generators: Iterable[Vertex]) -> Family:
    """dc(X): the smallest daisy cube containing X (union of intervals [0, C])."""
    closure: Family = set()
    frontier: List[Vertex] = list(generators)
    while frontier:
        a = frontier.pop()
        if a in closure:
            continue
        closure.add(a)
        for x in a:
            frontier.append(a - {x})
    return closure


def fixed_point_test(family: Iterable[Vertex]) -> bool:
    """isDaisy_iff_downClosure_le: D is a daisy cube iff dc(D) == D."""
    fam: Family = set(family)
    return down_closure(fam) == fam


# --------------------------------------------------------------------------- #
# Lattice closure
# --------------------------------------------------------------------------- #
def daisy_inter(d1: Family, d2: Family) -> Family:
    """IsDaisy.inter: intersection of daisy cubes is a daisy cube."""
    return d1 & d2


def daisy_union(d1: Family, d2: Family) -> Family:
    """IsDaisy.union: union of daisy cubes is a daisy cube."""
    return d1 | d2


# --------------------------------------------------------------------------- #
# The forbidden family  (P3^r [] Q_s) \ {u, v}
# --------------------------------------------------------------------------- #
GridVertex = Tuple[Tuple[int, ...], Tuple[int, ...]]  # (P3^r coords, Q_s coords)


def forbidden_family(r: int, s: int) -> Tuple[List[GridVertex], List[Tuple[GridVertex, GridVertex]]]:
    """
    Construct G_{r,s} = (P3^r [] Q_s) \\ {u, v}.

    P3^r vertices are {0,1,2}^r; Q_s vertices are {0,1}^s.  We delete the two
    antipodal P3^r-corners (all-0 and all-2) in the same Q_s copy (w = all-0).
    Returns (vertices, edges).
    """
    grid = list(product(range(3), repeat=r))
    cube = list(product(range(2), repeat=s))
    w0 = tuple([0] * s)
    u = (tuple([0] * r), w0)
    v = (tuple([2] * r), w0)
    removed = {u, v}

    verts: List[GridVertex] = [(g, w) for g in grid for w in cube if (g, w) not in removed]
    vset = set(verts)

    def adjacent(p: GridVertex, q: GridVertex) -> bool:
        (g1, w1), (g2, w2) = p, q
        if w1 == w2:
            diff = [i for i in range(r) if g1[i] != g2[i]]
            return len(diff) == 1 and abs(g1[diff[0]] - g2[diff[0]]) == 1
        if g1 == g2:
            return sum(1 for i in range(s) if w1[i] != w2[i]) == 1
        return False

    edges: List[Tuple[GridVertex, GridVertex]] = []
    for p, q in combinations(verts, 2):
        if adjacent(p, q) and p in vset and q in vset:
            edges.append((p, q))
    return verts, edges


# --------------------------------------------------------------------------- #
# Dedekind connection: count daisy subcubes of Q_n (down-closed families)
# --------------------------------------------------------------------------- #
def count_daisy_subcubes(n: int) -> int:
    """
    Number of daisy cubes inside Q_n for a fixed coordinate embedding
    = number of down-closed families = Dedekind number M(n)
    (OEIS A000372: 2, 3, 6, 20, 168, ...).
    Brute force; feasible for n <= 3 (n=4 already explores 2^16 subsets).
    """
    verts = all_vertices(n)
    count = 0
    for mask in range(1 << len(verts)):
        family = {verts[i] for i in range(len(verts)) if (mask >> i) & 1}
        if is_daisy(family):
            count += 1
    return count


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_distance_and_meet() -> None:
    print("=" * 70)
    print("meet_on_geodesic:  d(A,B) = d(A, A&B) + d(A&B, B)")
    print("=" * 70)
    examples: List[Tuple[Vertex, Vertex]] = [
        (frozenset({0, 1, 2}), frozenset({2, 3})),
        (frozenset({0, 1, 3, 4}), frozenset({1, 4, 5})),
        (frozenset(), frozenset({0, 1, 2})),
    ]
    for a, b in examples:
        m = a & b
        lhs = hdist(a, b)
        rhs = hdist(a, m) + hdist(m, b)
        print(f"  A={set(a)}, B={set(b)}, A&B={set(m)}: "
              f"d(A,B)={lhs}  ==  {hdist(a, m)}+{hdist(m, b)}={rhs}  -> {lhs == rhs}")
    print()


def demo_down_closure() -> None:
    print("=" * 70)
    print("down_closure & fixed-point characterization")
    print("=" * 70)
    gens: Family = {frozenset({0, 1}), frozenset({1, 2})}
    dc = down_closure(gens)
    print("  generators X =", sorted(map(sorted, gens)))
    print("  dc(X)        =", sorted(map(sorted, dc)))
    print("  is_daisy(dc(X))            :", is_daisy(dc))
    print("  fixed_point_test(dc(X))    :", fixed_point_test(dc))
    not_daisy = {frozenset({0, 1}), frozenset({1, 2})}
    print("  is_daisy(X) (X not closed) :", is_daisy(not_daisy))
    print()


def demo_lattice() -> None:
    print("=" * 70)
    print("Lattice closure: intersection and union stay daisy cubes")
    print("=" * 70)
    d1 = down_closure({frozenset({0, 1})})
    d2 = down_closure({frozenset({1, 2})})
    inter = daisy_inter(d1, d2)
    union = daisy_union(d1, d2)
    print("  d1 = dc({0,1}),  d2 = dc({1,2})")
    print("  is_daisy(d1 & d2):", is_daisy(inter), " | is_daisy(d1 | d2):", is_daisy(union))
    print("  origin in nonempty daisy cube d1:", frozenset() in d1, "(empty_mem)")
    print()


def demo_join_failure() -> None:
    print("=" * 70)
    print("not_join_closed: a daisy cube need not contain joins")
    print("=" * 70)
    d: Family = {frozenset(), frozenset({0}), frozenset({1})}  # the path P3
    print("  D = {{}, {0}, {1}}  is_daisy:", is_daisy(d))
    join = frozenset({0}) | frozenset({1})
    print("  {0} in D:", frozenset({0}) in d, " {1} in D:", frozenset({1}) in d)
    print("  join {0,1} in D:", join in d, " -> daisy cubes are NOT join-closed")
    # but meet IS present:
    meet = frozenset({0}) & frozenset({1})
    print("  meet {} in D:", meet in d, "  (IsDaisy.inter_mem holds)")
    print()


def demo_forbidden_family() -> None:
    print("=" * 70)
    print("Forbidden family  G_{r,s} = (P3^r [] Q_s) \\ {u, v}")
    print("=" * 70)
    for r, s in [(2, 1), (2, 2), (3, 1)]:
        verts, edges = forbidden_family(r, s)
        full = 3 ** r * 2 ** s
        print(f"  r={r}, s={s}: |V(P3^r [] Q_s)|={full}, "
              f"after deleting 2 antipodes |V|={len(verts)}, |E|={len(edges)}")
    print()


def demo_dedekind() -> None:
    print("=" * 70)
    print("Dedekind link: #daisy subcubes of Q_n = M(n) (A000372)")
    print("=" * 70)
    known = {0: 2, 1: 3, 2: 6, 3: 20}
    for n in range(0, 4):
        c = count_daisy_subcubes(n)
        print(f"  n={n}: counted={c}, Dedekind M({n})={known[n]}, match={c == known[n]}")
    print()


def main() -> None:
    demo_distance_and_meet()
    demo_down_closure()
    demo_lattice()
    demo_join_failure()
    demo_forbidden_family()
    demo_dedekind()


if __name__ == "__main__":
    main()
