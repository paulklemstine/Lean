"""
Numerical demonstrations for:

    A Functorial Tropical Lower Bound for Rips Connectivity
    via Valuation-Depth Sublevel Graphs

Core principle
--------------
Vietoris-Rips connectivity at scale eps in a GENERAL metric space only certifies
    dist(x, y) <= n * eps        (n = number of edges traversed; the "Archimedean leak")
but over an ULTRAMETRIC (non-Archimedean / valuation) space the strong triangle
inequality  dist(x, z) <= max(dist(x, y), dist(y, z))  collapses this to
    Reachable_eps(x, y)  <==>  dist(x, y) <= eps.

Hence the connectivity threshold  connThreshold(x, y) := dist(x, y)  is the exact,
tight scale at which x and y merge, and it itself satisfies the tropical (max)
triangle inequality. This file demonstrates each of these facts numerically.

Self-contained: pure standard library, type hints, all functions inlined.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, Hashable, List, Set, Tuple


# ---------------------------------------------------------------------------
# Distance functions
# ---------------------------------------------------------------------------

def two_adic_distance(a: int, b: int) -> float:
    """2-adic distance on the integers: dist(a, b) = 2^(-v_2(a - b)).

    v_2(n) is the exponent of the largest power of 2 dividing n; v_2(0) = +inf,
    so dist(a, a) = 0. This is the prototypical ULTRAMETRIC.
    """
    if a == b:
        return 0.0
    d = abs(a - b)
    v = 0
    while d % 2 == 0:
        d //= 2
        v += 1
    return 2.0 ** (-v)


def euclidean_distance(a: float, b: float) -> float:
    """Ordinary (Archimedean) distance on the real line."""
    return abs(a - b)


# ---------------------------------------------------------------------------
# Rips graph and reachability
# ---------------------------------------------------------------------------

def rips_edges(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    eps: float,
) -> Set[Tuple[Hashable, Hashable]]:
    """Edges of the Rips graph at scale eps: distinct points within distance eps."""
    edges: Set[Tuple[Hashable, Hashable]] = set()
    for x, y in combinations(points, 2):
        if dist(x, y) <= eps:
            edges.add((x, y))
    return edges


def reachable(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    eps: float,
    x: Hashable,
    y: Hashable,
) -> bool:
    """Path-connectivity (reachability) of x and y in the Rips graph at scale eps,
    via breadth-first search over the transitive closure of adjacency."""
    if x == y:
        return True  # empty walk
    adj: Dict[Hashable, List[Hashable]] = {p: [] for p in points}
    for (u, v) in rips_edges(points, dist, eps):
        adj[u].append(v)
        adj[v].append(u)
    seen: Set[Hashable] = {x}
    frontier: List[Hashable] = [x]
    while frontier:
        node = frontier.pop()
        for nb in adj[node]:
            if nb == y:
                return True
            if nb not in seen:
                seen.add(nb)
                frontier.append(nb)
    return False


def connected_components(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    eps: float,
) -> List[Set[Hashable]]:
    """Connected components (pi_0) of the Rips graph at scale eps via union-find."""
    parent: Dict[Hashable, Hashable] = {p: p for p in points}

    def find(p: Hashable) -> Hashable:
        while parent[p] != p:
            parent[p] = parent[parent[p]]
            p = parent[p]
        return p

    def union(p: Hashable, q: Hashable) -> None:
        parent[find(p)] = find(q)

    for (u, v) in rips_edges(points, dist, eps):
        union(u, v)
    groups: Dict[Hashable, Set[Hashable]] = {}
    for p in points:
        groups.setdefault(find(p), set()).add(p)
    return list(groups.values())


def bottleneck_distance(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    x: Hashable,
    y: Hashable,
) -> float:
    """Bottleneck (min-max path) distance: min over paths of the largest edge.

    Equals the smallest eps at which x and y become Rips-connected. Computed by a
    Dijkstra-style relaxation under the (min, max) tropical semiring.
    """
    if x == y:
        return 0.0
    best: Dict[Hashable, float] = {p: float("inf") for p in points}
    best[x] = 0.0
    unvisited: Set[Hashable] = set(points)
    while unvisited:
        u = min(unvisited, key=lambda p: best[p])
        unvisited.remove(u)
        if u == y:
            return best[y]
        for v in unvisited:
            cand = max(best[u], dist(u, v))
            if cand < best[v]:
                best[v] = cand
    return best[y]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_archimedean_leak() -> None:
    """General bound dist(x, y) <= n * eps is tight on the real line; the leak is real."""
    print("=" * 70)
    print("DEMO 1: The Archimedean leak on the real line (NOT ultrametric)")
    print("=" * 70)
    points: List[float] = [0.0, 1.0, 2.0, 3.0, 4.0]
    eps = 1.0
    x, y = 0.0, 4.0
    is_reach = reachable(points, euclidean_distance, eps, x, y)
    print(f"points = {points},  eps = {eps}")
    print(f"Reachable({x}, {y}) at scale {eps}?  {is_reach}")
    print(f"True distance dist({x}, {y}) = {euclidean_distance(x, y)}")
    n = 4  # number of edges in the chain 0-1-2-3-4
    print(f"General bound: dist <= n*eps = {n}*{eps} = {n * eps}  (TIGHT)")
    print(f"Ultrametric conclusion dist <= eps = {eps} would be FALSE here.")
    print("=> Connectivity badly understates distance; short steps chain across a canyon.\n")


def demo_ultrametric_collapse() -> None:
    """Over the 2-adic integers, reachability collapses to the sublevel test dist <= eps."""
    print("=" * 70)
    print("DEMO 2: Ultrametric collapse on the 2-adic integers")
    print("=" * 70)
    points: List[int] = [0, 1, 2, 3, 4, 5, 6, 7]
    for eps in [1.0, 0.5, 0.25]:
        print(f"\n  scale eps = {eps}")
        all_ok = True
        for x, y in combinations(points, 2):
            reach = reachable(points, two_adic_distance, eps, x, y)
            sublevel = two_adic_distance(x, y) <= eps
            if reach != sublevel:
                all_ok = False
                print(f"    MISMATCH at ({x},{y}): reach={reach}, sublevel={sublevel}")
        status = "VERIFIED" if all_ok else "FAILED"
        print(f"    Reachable_eps(x,y) <==> dist(x,y) <= eps  for all pairs: {status}")
    print("\n=> No leak: chaining 2-adically small steps never reaches a distant point.\n")


def demo_threshold_is_tropical() -> None:
    """connThreshold = dist satisfies the tropical (max) triangle inequality on an ultrametric."""
    print("=" * 70)
    print("DEMO 3: The connectivity threshold is tropical (max-subadditive)")
    print("=" * 70)
    points: List[int] = list(range(8))
    worst_slack = float("inf")
    all_ok = True
    for x, y, z in combinations(points, 3):
        lhs = two_adic_distance(x, z)
        rhs = max(two_adic_distance(x, y), two_adic_distance(y, z))
        all_ok = all_ok and (lhs <= rhs + 1e-12)
        worst_slack = min(worst_slack, rhs - lhs)
    print("Checking connThreshold(x,z) <= max(connThreshold(x,y), connThreshold(y,z))")
    print(f"  over all triples of 2-adic integers in {points}:")
    print(f"  strong triangle inequality holds for all triples: {all_ok}")
    print("=> The merge-scale functor lands in the max-plus (tropical) semiring.\n")


def demo_bottleneck_equals_distance() -> None:
    """Bottleneck path distance equals metric distance over an ultrametric."""
    print("=" * 70)
    print("DEMO 4: Bottleneck (min-max path) distance equals true distance")
    print("=" * 70)
    points: List[int] = [0, 1, 2, 3, 4, 5, 6, 7]
    print("  2-adic integers (ultrametric): bottleneck == dist  expected.")
    ok = True
    for x, y in combinations(points, 2):
        b = bottleneck_distance(points, two_adic_distance, x, y)
        d = two_adic_distance(x, y)
        ok = ok and abs(b - d) < 1e-12
    print(f"    bottleneck(x,y) == dist(x,y) for all pairs: {ok}")

    rpts: List[float] = [0.0, 1.0, 2.0, 3.0, 4.0]
    b = bottleneck_distance(rpts, euclidean_distance, 0.0, 4.0)
    d = euclidean_distance(0.0, 4.0)
    print("\n  real line (Archimedean): bottleneck << dist expected.")
    print(f"    bottleneck(0,4) = {b}  vs  dist(0,4) = {d}  (leak factor {d / b:.0f})\n")


def demo_components_are_balls() -> None:
    """Connectivity classes are closed balls; component count is antitone in eps (dendrogram)."""
    print("=" * 70)
    print("DEMO 5: Connectivity classes are closed balls (a dendrogram)")
    print("=" * 70)
    # Cophenetic ultrametric of a 4-leaf tree:
    #   d(a,b)=1, d(c,d)=2, all cross distances = 3.
    labels = ["a", "b", "c", "d"]
    table = {
        ("a", "b"): 1.0, ("c", "d"): 2.0,
        ("a", "c"): 3.0, ("a", "d"): 3.0, ("b", "c"): 3.0, ("b", "d"): 3.0,
    }

    def cophenetic(x: str, y: str) -> float:
        if x == y:
            return 0.0
        return table[(x, y)] if (x, y) in table else table[(y, x)]

    for eps in [0.5, 1.0, 2.0, 3.0]:
        comps = connected_components(labels, cophenetic, eps)
        comps_sorted = sorted([sorted(c) for c in comps])
        print(f"  eps = {eps}:  {len(comps)} component(s)  {comps_sorted}")
    print("=> components merge monotonically as eps grows: 4 -> 3 -> 2 -> 1.")
    print("   Each component is exactly a closed eps-ball; the family is laminar.\n")


def main() -> None:
    demo_archimedean_leak()
    demo_ultrametric_collapse()
    demo_threshold_is_tropical()
    demo_bottleneck_equals_distance()
    demo_components_are_balls()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
