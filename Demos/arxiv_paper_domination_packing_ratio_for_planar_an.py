"""
Numerical demonstrations for the domination-packing ratio.

For a finite simple graph G on vertex set V, the radius-1 ball at v is
    B(v) = {v} union {u : u ~ v},
gamma(G) is the least size of a set meeting every B(v) via domination
(a transversal of the ball hypergraph), and rho(G) is the largest number
of pairwise disjoint balls (a matching of the same hypergraph).

This script verifies, by exhaustive computation on small instances:

  1. rho(G) <= gamma(G) for every graph (trivial duality).
  2. gamma <= (Delta + 1) * rho for every graph (degree bound).
  3. The Wagner graph V8 has rho = 1, gamma = 3, and k disjoint copies
     have rho = k, gamma = 3k, so the ratio 3 persists at every scale.
  4. The 4-cycle is a unit disk graph with gamma = 2, rho = 1.
  5. gamma = rho for paths, interval graphs and forests, with the
     earliest-endpoint and deepest-vertex greedy sweeps producing a
     dominating set and a packing of equal size.
  6. Spread graphs have rho = 1 and gamma >= k - t + 1, so the ratio is
     unbounded over all finite graphs.
  7. The local packing bound of the plane: how many points, pairwise more
     than 1 apart, fit in a disk of radius 2 (the volume count gives 25).

Everything is self-contained: only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


# ---------------------------------------------------------------------------
# Basic graph utilities
# ---------------------------------------------------------------------------


def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build an undirected simple graph on {0, ..., n-1} from an edge list."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            raise ValueError("loops are not allowed")
        g[u].add(v)
        g[v].add(u)
    return g


def ball(g: Graph, v: Vertex) -> FrozenSet[Vertex]:
    """The radius-1 ball (closed neighbourhood) of v."""
    return frozenset({v} | g[v])


def is_dominating(g: Graph, d: Iterable[Vertex]) -> bool:
    """Does d meet the ball of every vertex?"""
    covered: Set[Vertex] = set()
    for x in d:
        covered |= ball(g, x)
    return covered == set(g)


def is_packing(g: Graph, p: Sequence[Vertex]) -> bool:
    """Are the balls of the vertices of p pairwise disjoint?"""
    for a, b in combinations(p, 2):
        if ball(g, a) & ball(g, b):
            return False
    return True


def domination_number(g: Graph) -> int:
    """gamma(G), by exhaustive search over subsets in increasing size."""
    vertices = list(g)
    for size in range(len(vertices) + 1):
        for cand in combinations(vertices, size):
            if is_dominating(g, cand):
                return size
    raise RuntimeError("unreachable: the whole vertex set dominates")


def packing_number(g: Graph) -> int:
    """rho(G), by exhaustive search over subsets in decreasing size."""
    vertices = list(g)
    for size in range(len(vertices), -1, -1):
        for cand in combinations(vertices, size):
            if is_packing(g, cand):
                return size
    raise RuntimeError("unreachable: the empty set is a packing")


def max_degree(g: Graph) -> int:
    return max((len(nbrs) for nbrs in g.values()), default=0)


# ---------------------------------------------------------------------------
# 1-2. Trivial duality and the degree bound, on random graphs
# ---------------------------------------------------------------------------


def random_graph(n: int, p: float, rng: random.Random) -> Graph:
    edges = [(u, v) for u, v in combinations(range(n), 2) if rng.random() < p]
    return make_graph(n, edges)


def check_duality_and_degree_bound(trials: int = 200, n: int = 8) -> None:
    print("1-2. rho <= gamma and gamma <= (Delta+1)*rho on random graphs")
    rng = random.Random(20260820)
    worst_ratio = 0.0
    for _ in range(trials):
        g = random_graph(n, rng.uniform(0.05, 0.6), rng)
        gam, rho = domination_number(g), packing_number(g)
        assert rho <= gam, (rho, gam)
        assert gam <= (max_degree(g) + 1) * rho, (gam, max_degree(g), rho)
        worst_ratio = max(worst_ratio, gam / rho)
    print(f"    {trials} random graphs on {n} vertices: both inequalities hold")
    print(f"    largest observed gamma/rho: {worst_ratio:.3f}")
    print()


# ---------------------------------------------------------------------------
# 3. The Wagner graph V8 and its disjoint copies
# ---------------------------------------------------------------------------


def wagner_graph() -> Graph:
    """V8 = Moebius ladder M4: the 8-cycle plus the four main diagonals."""
    edges = [(i, (i + 1) % 8) for i in range(8)] + [(i, i + 4) for i in range(4)]
    return make_graph(8, edges)


def disjoint_copies(g: Graph, k: int) -> Graph:
    """k disjoint copies of g, on vertices i*n + a for copy i and vertex a."""
    n = len(g)
    edges: List[Tuple[int, int]] = []
    for i in range(k):
        for a in g:
            for b in g[a]:
                if a < b:
                    edges.append((i * n + a, i * n + b))
    return make_graph(k * n, edges)


def check_wagner() -> None:
    print("3. The Wagner graph V8 and the persistence of the ratio 3")
    w = wagner_graph()
    gam, rho = domination_number(w), packing_number(w)
    print(f"    V8: gamma = {gam}, rho = {rho}, ratio = {gam / rho:.0f}")
    assert (gam, rho) == (3, 1)
    meeting = all(ball(w, u) & ball(w, v) for u, v in combinations(range(8), 2))
    print(f"    every two closed neighbourhoods of V8 meet: {meeting}")
    for k in (1, 2, 3):
        wk = disjoint_copies(w, k)
        # gamma and rho are additive over components; verified directly for k <= 2
        rho_k = packing_number(wk) if k <= 3 else k
        gam_k = domination_number(wk) if k <= 2 else 3 * k
        print(f"    k = {k} copies: rho = {rho_k}, gamma = {gam_k}"
              f"{'' if k <= 2 else ' (gamma by additivity)'}")
        assert rho_k == k
        assert gam_k == 3 * k
    print("    no bound gamma <= c*rho + b can hold with c < 3:")
    for c, b in ((2, 5), (2, 50)):
        k = b + 1
        print(f"        c = {c}, b = {b}: at k = {k}, gamma = {3 * k} > "
              f"{c * k + b} = c*rho + b")
        assert 3 * k > c * k + b
    print()


# ---------------------------------------------------------------------------
# 4. The 4-cycle as a unit disk graph
# ---------------------------------------------------------------------------


def unit_disk_graph(points: Sequence[Tuple[float, float]]) -> Graph:
    """Vertices are points; distinct points adjacent iff at distance <= 1."""
    n = len(points)
    edges = [
        (i, j)
        for i, j in combinations(range(n), 2)
        if math.dist(points[i], points[j]) <= 1.0
    ]
    return make_graph(n, edges)


def check_cycle4() -> None:
    print("4. The 4-cycle is a unit disk graph with gamma = 2, rho = 1")
    pts = [(0.0, 0.0), (0.8, 0.0), (0.8, 0.84), (0.0, 0.84)]
    g = unit_disk_graph(pts)
    sides = [math.dist(pts[i], pts[(i + 1) % 4]) for i in range(4)]
    diags = [math.dist(pts[0], pts[2]), math.dist(pts[1], pts[3])]
    print(f"    sides {['%.2f' % s for s in sides]} (all <= 1), "
          f"diagonals {['%.2f' % d for d in diags]} (both > 1)")
    gam, rho = domination_number(g), packing_number(g)
    print(f"    gamma = {gam}, rho = {rho}: the ratio already exceeds 1 in the plane")
    assert (gam, rho) == (2, 1)
    print()


# ---------------------------------------------------------------------------
# 5. Interval graphs, paths and forests: gamma = rho by a greedy sweep
# ---------------------------------------------------------------------------


def interval_graph(iv: Sequence[Tuple[float, float]]) -> Graph:
    """Distinct vertices adjacent iff their closed intervals intersect."""
    n = len(iv)
    edges = [
        (i, j)
        for i, j in combinations(range(n), 2)
        if iv[i][0] <= iv[j][1] and iv[j][0] <= iv[i][1]
    ]
    return make_graph(n, edges)


def interval_greedy(iv: Sequence[Tuple[float, float]]) -> Tuple[List[int], List[int]]:
    """Earliest-endpoint sweep: returns (dominating set D, packing P), |D| = |P|.

    Repeatedly take the undominated vertex u whose interval ends first, put
    into D the vertex d whose interval ends last among those meeting u, bank
    u into P, and delete everything d dominates.
    """
    g = interval_graph(iv)
    remaining: Set[int] = set(range(len(iv)))
    dom: List[int] = []
    pack: List[int] = []
    while remaining:
        u = min(remaining, key=lambda x: iv[x][1])
        meeting = [x for x in range(len(iv)) if iv[x][0] <= iv[u][1] <= iv[x][1]
                   or (iv[x][0] <= iv[u][1] and iv[u][0] <= iv[x][1])]
        d = max(meeting, key=lambda x: iv[x][1])
        dom.append(d)
        pack.append(u)
        remaining -= set(ball(g, d))
    return dom, pack


def path_graph(n: int) -> Graph:
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


def rooted_forest_greedy(g: Graph) -> Tuple[List[int], List[int]]:
    """Deepest-vertex sweep on a forest: returns (dominating set, packing).

    Root each component, repeatedly take the deepest undominated vertex u,
    put its parent into D (or u itself if u is a root), bank u into P, and
    delete the ball of the chosen dominator.
    """
    parent: Dict[int, Optional[int]] = {}
    depth: Dict[int, int] = {}
    seen: Set[int] = set()
    for r in g:
        if r in seen:
            continue
        parent[r], depth[r] = None, 0
        seen.add(r)
        queue = [r]
        while queue:
            x = queue.pop(0)
            for y in g[x]:
                if y not in seen:
                    seen.add(y)
                    parent[y], depth[y] = x, depth[x] + 1
                    queue.append(y)
    remaining: Set[int] = set(g)
    dom: List[int] = []
    pack: List[int] = []
    while remaining:
        u = max(remaining, key=lambda x: depth[x])
        d = parent[u] if parent[u] is not None else u
        dom.append(d)
        pack.append(u)
        remaining -= set(ball(g, d))
    return dom, pack


def random_forest(n: int, rng: random.Random) -> Graph:
    """A uniformly grown random forest on n vertices (each vertex attaches to
    an earlier vertex or starts a new component)."""
    edges: List[Tuple[int, int]] = []
    for v in range(1, n):
        if rng.random() < 0.75:
            edges.append((rng.randrange(v), v))
    return make_graph(n, edges)


def check_collapse() -> None:
    print("5. gamma = rho for paths, interval graphs and forests")
    for n in range(1, 13):
        g = path_graph(n)
        gam, rho = domination_number(g), packing_number(g)
        assert gam == rho == (n + 2) // 3
    print("    paths P_1..P_12: gamma = rho = ceil(n/3) in every case")

    rng = random.Random(7)
    for _ in range(60):
        n = rng.randint(1, 8)
        iv = []
        for _ in range(n):
            a = rng.uniform(0, 10)
            iv.append((a, a + rng.uniform(0, 3)))
        g = interval_graph(iv)
        gam, rho = domination_number(g), packing_number(g)
        dom, pack = interval_greedy(iv)
        assert gam == rho
        assert is_dominating(g, dom) and is_packing(g, pack)
        assert len(dom) == len(pack) == gam
    print("    60 random interval graphs: gamma = rho, and the earliest-endpoint")
    print("    sweep returns a dominating set and a packing of that common size")

    for _ in range(60):
        g = random_forest(rng.randint(1, 9), rng)
        gam, rho = domination_number(g), packing_number(g)
        dom, pack = rooted_forest_greedy(g)
        assert gam == rho, (gam, rho)
        assert is_dominating(g, dom) and is_packing(g, pack)
        assert len(dom) == len(pack) == gam
    print("    60 random forests: the Meir-Moon equality gamma = rho holds, with")
    print("    the deepest-vertex sweep certifying both sides simultaneously")

    c4 = make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
    print(f"    by contrast the 4-cycle (not a forest): gamma = "
          f"{domination_number(c4)}, rho = {packing_number(c4)}")
    print()


# ---------------------------------------------------------------------------
# 6. Spread graphs: the ratio is unbounded over all finite graphs
# ---------------------------------------------------------------------------


def spread_graph(k: int, t: int) -> Graph:
    """Clique of k indices, all t-subsets as an independent set, i ~ S iff i in S.

    Indices are 0..k-1; the subset S is the vertex k + (its index in the list).
    """
    subsets = list(combinations(range(k), t))
    edges: List[Tuple[int, int]] = [(i, j) for i, j in combinations(range(k), 2)]
    for s_idx, s in enumerate(subsets):
        for i in s:
            edges.append((i, k + s_idx))
    return make_graph(k + len(subsets), edges)


def check_spread() -> None:
    print("6. Spread graphs: rho = 1 while gamma grows without bound")
    for m in (1, 2, 3):
        k, t = 2 * m, m + 1
        g = spread_graph(k, t)
        rho = packing_number(g)
        gam = domination_number(g)
        print(f"    m = {m} (k = {k} indices, t = {t}): "
              f"|V| = {len(g)}, rho = {rho}, gamma = {gam} >= {k - t + 1} = k-t+1")
        assert rho == 1
        assert gam >= k - t + 1
    print("    the ratio gamma/rho is therefore unbounded over all finite graphs")
    print()


# ---------------------------------------------------------------------------
# 7. The local packing bound of the plane
# ---------------------------------------------------------------------------


def greedy_separated_points_in_disk(radius: float, sep: float,
                                    samples: int, rng: random.Random) -> int:
    """Greedily place points in a disk of the given radius, keeping them
    pairwise more than `sep` apart; returns how many were placed."""
    chosen: List[Tuple[float, float]] = []
    for _ in range(samples):
        theta = rng.uniform(0, 2 * math.pi)
        r = radius * math.sqrt(rng.random())
        p = (r * math.cos(theta), r * math.sin(theta))
        if all(math.dist(p, q) > sep for q in chosen):
            chosen.append(p)
    return len(chosen)


def hexagonal_separated_points_in_disk(radius: float, sep: float) -> int:
    """Count points of a triangular lattice of spacing slightly above `sep`
    that lie in the closed disk of the given radius, centred at a lattice point."""
    spacing = sep * 1.0000001
    count = 0
    reach = int(math.ceil(2 * radius / spacing)) + 2
    for i in range(-reach, reach + 1):
        for j in range(-reach, reach + 1):
            x = spacing * (i + j / 2.0)
            y = spacing * (math.sqrt(3) / 2.0) * j
            if math.hypot(x, y) <= radius + 1e-12:
                count += 1
    return count


def nineteen_point_configuration() -> List[Tuple[float, float]]:
    """An explicit set of 19 points in the closed disk of radius 2 that are
    pairwise more than 1 apart: the centre, a ring of 6 at radius 1.05, and a
    ring of 12 at radius 2 rotated by 15 degrees."""
    pts: List[Tuple[float, float]] = [(0.0, 0.0)]
    for j in range(6):
        a = 2 * math.pi * j / 6
        pts.append((1.05 * math.cos(a), 1.05 * math.sin(a)))
    for j in range(12):
        a = 2 * math.pi * (j + 0.5) / 12
        pts.append((2.0 * math.cos(a), 2.0 * math.sin(a)))
    return pts


def check_local_packing_bound() -> None:
    print("7. The local packing bound of the plane")
    print("    volume comparison: at most ((2*2+1)/1)^2 = 25 points, pairwise")
    print("    more than 1 apart, fit in a disk of radius 2; hence gamma <= 25*rho")
    rng = random.Random(11)
    best = max(greedy_separated_points_in_disk(2.0, 1.0, 4000, rng)
               for _ in range(40))
    hexa = hexagonal_separated_points_in_disk(2.0, 1.0)
    print(f"    best random greedy arrangement found: {best} points")
    print(f"    triangular-lattice arrangement:       {hexa} points")
    cfg = nineteen_point_configuration()
    min_sep = min(math.dist(p, q) for p, q in combinations(cfg, 2))
    max_rad = max(math.hypot(*p) for p in cfg)
    print(f"    explicit centre + 6 + 12 arrangement:  {len(cfg)} points, "
          f"minimum separation {min_sep:.4f} > 1, maximum radius {max_rad:.4f} <= 2")
    assert min_sep > 1.0 and max_rad <= 2.0 + 1e-12
    print("    (so the volume count 25 is lossy; the sharp value of this finite")
    print("     plane-packing constant is what would improve the theorem)")
    # the one-dimensional analogue is sharp at 4
    quad = [0.0, 1.1, 2.2, 3.3]
    sep_ok = all(abs(a - b) > 1 for a, b in combinations(quad, 2))
    near_ok = all(abs(x - 2.0) <= 2 for x in quad)
    print(f"    on the line the bound 4 is optimal: the points {quad} lie within")
    print(f"    distance 2 of 2 ({near_ok}) and are pairwise > 1 apart ({sep_ok})")
    assert sep_ok and near_ok
    print()


# ---------------------------------------------------------------------------
# Unit disk graphs: the bound gamma <= 25*rho in practice
# ---------------------------------------------------------------------------


def check_unit_disk_instances() -> None:
    print("8. Random unit disk graphs: gamma <= 25*rho, with a large margin")
    rng = random.Random(4242)
    worst = 0.0
    for _ in range(120):
        n = rng.randint(4, 9)
        pts = [(rng.uniform(0, 2.5), rng.uniform(0, 2.5)) for _ in range(n)]
        g = unit_disk_graph(pts)
        gam, rho = domination_number(g), packing_number(g)
        assert gam <= 25 * rho
        worst = max(worst, gam / rho)
    print(f"    120 instances: the bound always holds; largest ratio seen "
          f"{worst:.3f}")
    print("    (the proven ceiling is 25, the best published constant is")
    print("     18*sqrt(3)/pi = %.3f, and the best known lower bound is 3)"
          % (18 * math.sqrt(3) / math.pi))
    print()


def main() -> None:
    print("=" * 72)
    print("The domination-packing ratio: numerical demonstrations")
    print("=" * 72)
    print()
    check_duality_and_degree_bound()
    check_wagner()
    check_cycle4()
    check_collapse()
    check_spread()
    check_local_packing_bound()
    check_unit_disk_instances()
    print("All checks passed.")


if __name__ == "__main__":
    main()
