"""
demo.py — Metric Filtration Rank Profiles as Tropical Valuation Objects
=======================================================================

Numerical demonstrations of the single-linkage ultrametric of a finite Rips
filtration, and its max-plus (tropical) structure.

The core objects (all defined inline, no external dependencies beyond the
standard library):

  * `rips_adjacent`  — the Rips graph adjacency at scale epsilon
  * `connected_at`   — connectivity (reachability) at scale epsilon
  * `candidate_scales` — the finite set {0} ∪ {d(a,b)}
  * `conn_threshold` — the single-linkage merge scale (least connecting scale)
  * `single_linkage_mst` — the same data via Kruskal / minimum spanning tree
  * `component_count` — the π₀ rank profile

We verify, on random and hand-built examples, the four structural theorems:
symmetry, the dissimilarity upper bound, reflexivity, and the STRONG triangle
inequality  thr(x,y) ≤ max(thr(x,z), thr(z,y))  — the tropical triangle law.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Callable, Dict, List, Sequence, Tuple

Dissimilarity = Callable[[int, int], float]


# ---------------------------------------------------------------------------
# Rips graph and connectivity
# ---------------------------------------------------------------------------

def rips_adjacent(d: Dissimilarity, eps: float, x: int, y: int) -> bool:
    """Adjacency in the Rips graph at scale `eps`.

    Distinct points are adjacent when at least one directed dissimilarity is
    at most `eps`. (Allows asymmetric `d` via the disjunction.)
    """
    if x == y:
        return False
    return d(x, y) <= eps or d(y, x) <= eps


def connected_at(n: int, d: Dissimilarity, eps: float, x: int, y: int) -> bool:
    """Reachability in the Rips graph at scale `eps` (BFS over n vertices)."""
    if x == y:
        return True
    seen = {x}
    frontier = [x]
    while frontier:
        u = frontier.pop()
        for v in range(n):
            if v not in seen and rips_adjacent(d, eps, u, v):
                if v == y:
                    return True
                seen.add(v)
                frontier.append(v)
    return y in seen


# ---------------------------------------------------------------------------
# Candidate scales and the single-linkage threshold
# ---------------------------------------------------------------------------

def candidate_scales(n: int, d: Dissimilarity) -> List[float]:
    """The finite candidate set {0} ∪ {d(a,b) : a,b}, sorted ascending."""
    scales = {0.0}
    for a in range(n):
        for b in range(n):
            scales.add(float(d(a, b)))
    return sorted(scales)


def conn_threshold(n: int, d: Dissimilarity, x: int, y: int) -> float:
    """The single-linkage merge scale: least candidate scale connecting x, y."""
    for eps in candidate_scales(n, d):
        if connected_at(n, d, eps, x, y):
            return eps
    # Unreachable in theory: d(x,y) itself is always a connecting candidate.
    raise RuntimeError("no connecting scale found (should be impossible)")


# ---------------------------------------------------------------------------
# Single-linkage via minimum spanning tree (Kruskal) — the MST identity
# ---------------------------------------------------------------------------

class UnionFind:
    """Disjoint-set forest with path compression and union by rank."""

    def __init__(self, n: int) -> None:
        self.parent: List[int] = list(range(n))
        self.rank: List[int] = [0] * n

    def find(self, a: int) -> int:
        while self.parent[a] != a:
            self.parent[a] = self.parent[self.parent[a]]
            a = self.parent[a]
        return a

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True


def single_linkage_mst(n: int, d: Dissimilarity) -> Dict[Tuple[int, int], float]:
    """Full merge-scale table via Kruskal on the symmetrized graph.

    Returns thr[(x, y)] for all unordered pairs x < y.  When a Kruskal edge of
    weight w unites two components, w is the merge scale for every cross-pair.
    """
    edges: List[Tuple[float, int, int]] = []
    for a in range(n):
        for b in range(a + 1, n):
            w = min(float(d(a, b)), float(d(b, a)))
            edges.append((w, a, b))
    edges.sort()

    uf = UnionFind(n)
    members: Dict[int, List[int]] = {i: [i] for i in range(n)}
    thr: Dict[Tuple[int, int], float] = {}

    for w, a, b in edges:
        ra, rb = uf.find(a), uf.find(b)
        if ra == rb:
            continue
        for u in members[ra]:
            for v in members[rb]:
                key = (u, v) if u < v else (v, u)
                thr[key] = w
        uf.union(a, b)
        new_root = uf.find(a)
        merged = members[ra] + members[rb]
        members[new_root] = merged
    return thr


# ---------------------------------------------------------------------------
# π₀ rank profile
# ---------------------------------------------------------------------------

def component_count(n: int, d: Dissimilarity, eps: float) -> int:
    """Number of connected components of the Rips graph at scale `eps`."""
    uf = UnionFind(n)
    for a in range(n):
        for b in range(a + 1, n):
            if rips_adjacent(d, eps, a, b):
                uf.union(a, b)
    return len({uf.find(i) for i in range(n)})


def rank_profile(n: int, d: Dissimilarity) -> List[Tuple[float, int]]:
    """The step function eps -> #components, sampled at every candidate scale."""
    return [(eps, component_count(n, d, eps)) for eps in candidate_scales(n, d)]


# ---------------------------------------------------------------------------
# Verification of the structural theorems
# ---------------------------------------------------------------------------

def verify_ultrametric(n: int, d: Dissimilarity, tol: float = 1e-9) -> Dict[str, bool]:
    """Check symmetry, upper bound, reflexivity, and the strong triangle law."""
    def thr(x: int, y: int) -> float:
        return conn_threshold(n, d, x, y)

    symmetry = all(
        abs(thr(x, y) - thr(y, x)) <= tol
        for x in range(n) for y in range(n)
    )
    upper_bound = all(
        thr(x, y) <= d(x, y) + tol
        for x in range(n) for y in range(n)
    )
    reflexive = all(abs(thr(x, x)) <= tol for x in range(n))  # assumes d >= 0
    strong_triangle = all(
        thr(x, y) <= max(thr(x, z), thr(z, y)) + tol
        for x in range(n) for y in range(n) for z in range(n)
    )
    return {
        "symmetry": symmetry,
        "upper_bound": upper_bound,
        "reflexive": reflexive,
        "strong_triangle": strong_triangle,
    }


def matches_mst(n: int, d: Dissimilarity, tol: float = 1e-9) -> bool:
    """The sweep threshold equals the Kruskal/MST merge scale on all pairs."""
    table = single_linkage_mst(n, d)
    for x in range(n):
        for y in range(x + 1, n):
            if abs(conn_threshold(n, d, x, y) - table[(x, y)]) > tol:
                return False
    return True


# ---------------------------------------------------------------------------
# Example builders
# ---------------------------------------------------------------------------

def from_matrix(m: Sequence[Sequence[float]]) -> Dissimilarity:
    """Turn a square matrix into a dissimilarity function."""
    return lambda x, y: float(m[x][y])


def random_metric(n: int, seed: int = 0) -> Dissimilarity:
    """A random *symmetric*, nonnegative, zero-diagonal dissimilarity."""
    rng = random.Random(seed)
    m = [[0.0] * n for _ in range(n)]
    for a in range(n):
        for b in range(a + 1, n):
            w = round(rng.uniform(0.1, 9.9), 2)
            m[a][b] = m[b][a] = w
    return from_matrix(m)


def random_asymmetric(n: int, seed: int = 0) -> Dissimilarity:
    """A random *asymmetric*, nonnegative, zero-diagonal dissimilarity."""
    rng = random.Random(seed)
    m = [[0.0] * n for _ in range(n)]
    for a in range(n):
        for b in range(n):
            if a != b:
                m[a][b] = round(rng.uniform(0.1, 9.9), 2)
    return from_matrix(m)


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_chain_beats_direct() -> None:
    """A hand-built example where a chain of neighbors connects two distant
    points well below their direct dissimilarity — the essence of single-linkage.
    """
    banner("Example 1: a chain of neighbors beats the direct distance")
    # Points 0-1-2-3 on a line, each adjacent pair close (1.0), but the
    # endpoints 0 and 3 are far apart directly (9.0).
    INF = 9.0
    m = [
        [0.0, 1.0, INF, INF],
        [1.0, 0.0, 1.0, INF],
        [INF, 1.0, 0.0, 1.0],
        [INF, INF, 1.0, 0.0],
    ]
    d = from_matrix(m)
    n = 4
    print("Direct dissimilarity d(0,3) =", d(0, 3))
    print("Merge scale  thr(0,3)       =", conn_threshold(n, d, 0, 3))
    print("  -> connected through 0-1-2-3 at scale 1.0, far below 9.0")
    print("Structural theorems:", verify_ultrametric(n, d))
    print("Matches MST/Kruskal table:", matches_mst(n, d))


def demo_rank_profile() -> None:
    banner("Example 2: the π₀ rank profile (component count vs. scale)")
    d = random_metric(6, seed=7)
    n = 6
    print("scale  ->  #components")
    for eps, k in rank_profile(n, d):
        print(f"  {eps:5.2f}  ->  {k}")
    print("(antitone: components only ever merge as the scale rises)")


def demo_random_batches() -> None:
    banner("Example 3: random verification batches")
    print("Symmetric metrics:")
    for seed in range(5):
        d = random_metric(7, seed=seed)
        res = verify_ultrametric(7, d)
        ok = all(res.values()) and matches_mst(7, d)
        print(f"  seed={seed}: {res}  mst={matches_mst(7, d)}  ALL_OK={ok}")

    print("Asymmetric dissimilarities (output is still a symmetric ultrametric):")
    for seed in range(5):
        d = random_asymmetric(7, seed=seed)
        res = verify_ultrametric(7, d)
        # reflexivity uses d>=0; the diagonal is 0 here, so it holds.
        ok = res["symmetry"] and res["strong_triangle"] and res["reflexive"]
        print(f"  seed={seed}: symmetry={res['symmetry']} "
              f"strong_triangle={res['strong_triangle']} OK={ok}")


def demo_idempotence() -> None:
    banner("Example 4: idempotence on an ultrametric input")
    # Build an ultrametric from a tiny dendrogram on {0,1,2,3}:
    #   {0,1} merge at 1, {2,3} merge at 2, the two pairs merge at 3.
    m = [
        [0.0, 1.0, 3.0, 3.0],
        [1.0, 0.0, 3.0, 3.0],
        [3.0, 3.0, 0.0, 2.0],
        [3.0, 3.0, 2.0, 0.0],
    ]
    d = from_matrix(m)
    n = 4
    same = all(
        abs(conn_threshold(n, d, x, y) - d(x, y)) <= 1e-9
        for x in range(n) for y in range(n)
    )
    print("Input is an ultrametric; thr(d) == d on all pairs:", same)


def main() -> None:
    demo_chain_beats_direct()
    demo_rank_profile()
    demo_random_batches()
    demo_idempotence()
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
