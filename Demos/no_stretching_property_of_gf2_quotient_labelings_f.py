"""
Numerical demonstrations of the No-Stretching Property of GF(2) quotient
labelings from edge partitions.

Given a connected graph G whose edges are partitioned into t classes, we build a
vertex labeling into the quotient group Q = (Z/2Z)^t / C, where C is the
cycle-class parity space. The labeling never *stretches* distances into the Cayley
graph H of Q on the class generators:

        d_H(label(u), label(v)) <= d_G(u, v)   for all u, v.

We also reproduce the separating triangle showing that the coordinate hypercube
with Hamming distance is the WRONG target (it reports a stretch), while the Cayley
graph is the correct one.

Self-contained: standard library only.
"""

from __future__ import annotations

from collections import deque
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

# A GF(2) vector is a tuple of 0/1 ints. Edges are frozensets of two vertices.
Vec = Tuple[int, ...]
Edge = FrozenSet[int]
Graph = Dict[int, Set[int]]


# --------------------------------------------------------------------------- #
# GF(2) linear algebra
# --------------------------------------------------------------------------- #
def xor(a: Vec, b: Vec) -> Vec:
    """Coordinate-wise XOR of two GF(2) vectors of equal length."""
    return tuple((x ^ y) for x, y in zip(a, b))


def gf2_rank(rows: List[Vec]) -> int:
    """Rank over GF(2) of the matrix whose rows are `rows` (Gaussian elimination)."""
    basis: List[Vec] = []
    for row in rows:
        cur = row
        for b in basis:
            lead = next((i for i, v in enumerate(b) if v), None)
            if lead is not None and cur[lead]:
                cur = xor(cur, b)
        if any(cur):
            basis.append(cur)
    return len(basis)


def unit(i: int, t: int) -> Vec:
    """The i-th standard basis vector e_i in GF(2)^t."""
    return tuple(1 if j == i else 0 for j in range(t))


# --------------------------------------------------------------------------- #
# Graph distance (BFS)
# --------------------------------------------------------------------------- #
def bfs_dist(adj: Graph, source: int) -> Dict[int, int]:
    """Single-source shortest-path distances via breadth-first search."""
    dist = {source: 0}
    q = deque([source])
    while q:
        u = q.popleft()
        for w in adj[u]:
            if w not in dist:
                dist[w] = dist[u] + 1
                q.append(w)
    return dist


def all_pairs_dist(adj: Graph) -> Dict[Tuple[int, int], int]:
    """All-pairs shortest-path distances."""
    out: Dict[Tuple[int, int], int] = {}
    for s in adj:
        for t_, d in bfs_dist(adj, s).items():
            out[(s, t_)] = d
    return out


# --------------------------------------------------------------------------- #
# Quotient labeling from an edge partition
# --------------------------------------------------------------------------- #
def build_labels(
    adj: Graph, edge_class: Dict[Edge, int], t: int
) -> Tuple[Dict[int, Vec], List[Vec]]:
    """
    Build the ambient GF(2)^t labels by spanning-tree traversal, and collect the
    fundamental-cycle parity vectors (rows of the cycle-class parity matrix A).
    Returns (labels, cycle_rows).
    """
    root = next(iter(adj))
    labels: Dict[int, Vec] = {root: unit_zero(t)}
    tree_edges: Set[Edge] = set()
    q = deque([root])
    while q:
        u = q.popleft()
        for w in adj[u]:
            e = frozenset({u, w})
            if w not in labels:
                labels[w] = xor(labels[u], unit(edge_class[e], t))
                tree_edges.add(e)
                q.append(w)
    cycle_rows: List[Vec] = []
    for u in adj:
        for w in adj[u]:
            if u < w:
                e = frozenset({u, w})
                if e not in tree_edges:
                    # fundamental cycle parity: label(u) + label(w) + e_class
                    cycle_rows.append(xor(xor(labels[u], labels[w]),
                                          unit(edge_class[e], t)))
    return labels, cycle_rows


def unit_zero(t: int) -> Vec:
    """The zero vector in GF(2)^t."""
    return tuple(0 for _ in range(t))


def quotient_dim(t: int, cycle_rows: List[Vec]) -> int:
    """dim Q = t - rank(A), the quotient dimension (Quotient Dimension Theorem)."""
    return t - gf2_rank(cycle_rows)


# --------------------------------------------------------------------------- #
# Cayley graph distance on the class generators
# --------------------------------------------------------------------------- #
def coset_repr(vec: Vec, cycle_rows: List[Vec]) -> Vec:
    """
    Canonical coset representative of `vec` modulo the span of `cycle_rows`,
    obtained by reducing against a row-echelon basis of C.
    """
    basis: List[Vec] = []
    for row in cycle_rows:
        cur = row
        for b in basis:
            lead = next(i for i, v in enumerate(b) if v)
            if cur[lead]:
                cur = xor(cur, b)
        if any(cur):
            basis.append(cur)
    rep = vec
    for b in basis:
        lead = next(i for i, v in enumerate(b) if v)
        if rep[lead]:
            rep = xor(rep, b)
    return rep


def cayley_dist(
    a: Vec, b: Vec, generators: List[Vec], cycle_rows: List[Vec]
) -> int:
    """
    Distance in the Cayley graph of Q = GF(2)^t / C on the class generators:
    the minimum number of generators (with repetition) summing to a - b in Q.
    BFS over coset representatives.
    """
    start = coset_repr(a, cycle_rows)
    target = coset_repr(b, cycle_rows)
    if start == target:
        return 0
    seen = {start}
    q = deque([(start, 0)])
    gens = [coset_repr(g, cycle_rows) for g in generators]
    while q:
        cur, d = q.popleft()
        for g in gens:
            nxt = coset_repr(xor(cur, g), cycle_rows)
            if nxt == target:
                return d + 1
            if nxt not in seen:
                seen.add(nxt)
                q.append((nxt, d + 1))
    raise ValueError("target unreachable (should not happen for a partition)")


def hamming(a: Vec, b: Vec) -> int:
    """Hamming distance = number of differing coordinates (coordinate hypercube)."""
    return sum(1 for x, y in zip(a, b) if x != y)


# --------------------------------------------------------------------------- #
# Verification driver
# --------------------------------------------------------------------------- #
def verify_no_stretch(
    adj: Graph, edge_class: Dict[Edge, int], t: int, name: str
) -> None:
    """Check d_H(label u, label v) <= d_G(u, v) for all pairs, and report."""
    labels, cycle_rows = build_labels(adj, edge_class, t)
    generators = [unit(i, t) for i in range(t)]
    dims = quotient_dim(t, cycle_rows)
    dg = all_pairs_dist(adj)

    print(f"=== {name} ===")
    print(f"  t = {t} classes, rank(A) = {gf2_rank(cycle_rows)}, "
          f"dim Q = t - rank(A) = {dims}")
    ok = True
    for u, v in combinations(sorted(adj), 2):
        dH = cayley_dist(labels[u], labels[v], generators, cycle_rows)
        d = dg[(u, v)]
        status = "OK" if dH <= d else "STRETCH!"
        if dH > d:
            ok = False
        print(f"  ({u},{v}): d_G = {d}, d_H(Cayley) = {dH}   [{status}]")
    print(f"  No-Stretching holds for all pairs: {ok}\n")


def separating_triangle() -> None:
    """
    The triangle K_3 with three distinct edge classes: the Cayley target gives no
    stretch, but the coordinate hypercube (Hamming) stretches the edge {0,2}.
    """
    print("=== Separating triangle K_3 (Cayley correct vs. Hamming wrong) ===")
    # Quotient labels worked out in the paper (Q = GF(2)^2).
    gen = {0: (1, 0), 1: (0, 1), 2: (1, 1)}
    lab = {0: (0, 0), 1: (1, 0), 2: (1, 1)}
    generators = [gen[0], gen[1], gen[2]]
    # No cycle rows here: we work directly in the already-quotiented GF(2)^2.
    for u, v in [(0, 1), (1, 2), (0, 2)]:
        dH = cayley_dist(lab[u], lab[v], generators, [])
        dHam = hamming(lab[u], lab[v])
        print(f"  edge ({u},{v}): label diff {xor(lab[u], lab[v])}, "
              f"d_Cayley = {dH}, d_Hamming = {dHam}, d_G = 1")
    print("  -> Cayley matches d_G = 1 on every edge; Hamming reports 2 on {0,2}.\n")


def main() -> None:
    # Example 1: triangle K_3, three classes.
    tri: Graph = {0: {1, 2}, 1: {0, 2}, 2: {0, 1}}
    tri_class = {frozenset({0, 1}): 0, frozenset({1, 2}): 1, frozenset({0, 2}): 2}
    verify_no_stretch(tri, tri_class, 3, "Triangle K_3, 3 classes")

    # Example 2: 4-cycle C_4 with two opposite-edge classes (a genuine hypercube).
    c4: Graph = {0: {1, 3}, 1: {0, 2}, 2: {1, 3}, 3: {2, 0}}
    c4_class = {
        frozenset({0, 1}): 0, frozenset({2, 3}): 0,   # opposite edges share a class
        frozenset({1, 2}): 1, frozenset({3, 0}): 1,
    }
    verify_no_stretch(c4, c4_class, 2, "4-cycle C_4, 2 classes (isometric to a square)")

    # Example 3: complete graph K_4, each edge its own class (heavy folding).
    k4: Graph = {i: {j for j in range(4) if j != i} for i in range(4)}
    edges = list(combinations(range(4), 2))
    k4_class = {frozenset(e): i for i, e in enumerate(edges)}
    verify_no_stretch(k4, k4_class, 6, "Complete graph K_4, 6 classes")

    # The separating triangle: Cayley vs. Hamming.
    separating_triangle()


if __name__ == "__main__":
    main()
