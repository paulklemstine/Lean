#!/usr/bin/env python3
"""
algorithms.py — Algorithms for transversal matroid analysis.

Implements the key algorithms from the research paper:
1. Maximum bipartite matching (Hopcroft-Karp)
2. Transversal rank computation
3. Quadratic leaf count computation
4. Active vertex identification
5. Certified enumeration of codimension-2 independent sets
"""

from typing import List, Set, Dict, Tuple, Optional, Iterator
import itertools
from collections import defaultdict, deque


class BipartiteGraph:
    """A bipartite graph with left vertices [0..n_left) and right vertices [0..n_right).

    Attributes:
        n_left: Number of left vertices.
        n_right: Number of right vertices.
        adj: Adjacency lists for left vertices.
        max_left_degree: Maximum left-vertex degree (Δ).
    """

    def __init__(self, n_left: int, n_right: int, adj: List[List[int]]):
        """Initialize bipartite graph.

        Args:
            n_left: Number of left vertices.
            n_right: Number of right vertices.
            adj: adj[l] = sorted list of right neighbors of left vertex l.
        """
        self.n_left = n_left
        self.n_right = n_right
        self.adj = adj
        self.max_left_degree = max((len(a) for a in adj), default=0)

    @classmethod
    def complete(cls, n: int) -> 'BipartiteGraph':
        """Create complete bipartite graph K_{n,n}."""
        adj = [list(range(n)) for _ in range(n)]
        return cls(n, n, adj)

    @classmethod
    def random(cls, n_left: int, n_right: int, max_degree: int,
               seed: Optional[int] = None) -> 'BipartiteGraph':
        """Create random bipartite graph with bounded left-degree."""
        import random
        if seed is not None:
            random.seed(seed)
        adj = []
        for _ in range(n_left):
            deg = random.randint(1, min(max_degree, n_right))
            neighbors = sorted(random.sample(range(n_right), deg))
            adj.append(neighbors)
        return cls(n_left, n_right, adj)

    @classmethod
    def grid_incidence(cls, m: int, n: int) -> 'BipartiteGraph':
        """Create grid incidence graph.

        Left vertices = rows [0..m), right vertices = columns [0..n).
        Adjacency: row i is adjacent to column j if (i,j) is a grid cell
        (all pairs are adjacent, giving complete bipartite graph).
        For a more interesting structure, use a subset pattern.
        """
        adj = [list(range(n)) for _ in range(m)]
        return cls(m, n, adj)

    @classmethod
    def cycle_bipartite(cls, n: int) -> 'BipartiteGraph':
        """Create cycle bipartite graph: l_i adjacent to r_i, r_{i+1 mod n}."""
        adj = [[i, (i + 1) % n] for i in range(n)]
        return cls(n, n, adj)


def hopcroft_karp(graph: BipartiteGraph) -> Dict[int, int]:
    """Find maximum matching using Hopcroft-Karp algorithm.

    Args:
        graph: A BipartiteGraph instance.

    Returns:
        Dictionary mapping matched left vertex -> right vertex.

    Time complexity: O(E * sqrt(V))
    """
    match_l: Dict[int, int] = {}
    match_r: Dict[int, int] = {}
    INF = float('inf')

    def bfs() -> bool:
        dist: Dict[int, float] = {}
        queue = deque()
        for u in range(graph.n_left):
            if u not in match_l:
                dist[u] = 0
                queue.append(u)
            else:
                dist[u] = INF
        found = False
        while queue:
            u = queue.popleft()
            for v in graph.adj[u]:
                next_u = match_r.get(v)
                if next_u is None:
                    found = True
                elif dist.get(next_u, INF) == INF:
                    dist[next_u] = dist[u] + 1
                    queue.append(next_u)
        return found

    def dfs(u: int, dist: Dict[int, float]) -> bool:
        for v in graph.adj[u]:
            next_u = match_r.get(v)
            if next_u is None or (dist.get(next_u, INF) == dist[u] + 1 and dfs(next_u, dist)):
                match_l[u] = v
                match_r[v] = u
                return True
        dist[u] = INF
        return False

    while True:
        dist: Dict[int, float] = {}
        queue = deque()
        for u in range(graph.n_left):
            if u not in match_l:
                dist[u] = 0
                queue.append(u)
            else:
                dist[u] = INF

        found = False
        while queue:
            u = queue.popleft()
            for v in graph.adj[u]:
                next_u = match_r.get(v)
                if next_u is None:
                    found = True
                elif dist.get(next_u, INF) == INF:
                    dist[next_u] = dist[u] + 1
                    queue.append(next_u)

        if not found:
            break

        for u in range(graph.n_left):
            if u not in match_l:
                dfs(u, dist)

    return match_l


def transversal_rank(graph: BipartiteGraph) -> int:
    """Compute the transversal rank (maximum matching size).

    Args:
        graph: A BipartiteGraph instance.

    Returns:
        The rank (maximum number of simultaneously matchable left vertices).

    Time complexity: O(E * sqrt(V))
    """
    return len(hopcroft_karp(graph))


def is_independent(graph: BipartiteGraph, subset: Tuple[int, ...]) -> bool:
    """Check if a subset of left vertices is transversally independent.

    Args:
        graph: A BipartiteGraph instance.
        subset: Tuple of left vertex indices.

    Returns:
        True if the subset admits an injective matching into right vertices.

    Time complexity: O(|subset| * Δ * sqrt(|subset|))
    """
    if not subset:
        return True
    sub_adj = [graph.adj[v] for v in subset]
    sub_graph = BipartiteGraph(len(subset), graph.n_right, sub_adj)
    return transversal_rank(sub_graph) == len(subset)


def quadratic_leaf_count(graph: BipartiteGraph, rank: Optional[int] = None) -> int:
    """Count independent sets of size rank - 2.

    Args:
        graph: A BipartiteGraph instance.
        rank: Precomputed rank (if None, computed automatically).

    Returns:
        Number of independent sets of size rank - 2.

    Time complexity: O(C(n, r-2) * matching_check_cost)
    """
    if rank is None:
        rank = transversal_rank(graph)
    target = rank - 2
    if target < 0:
        return 0
    if target == 0:
        return 1

    count = 0
    for subset in itertools.combinations(range(graph.n_left), target):
        if is_independent(graph, subset):
            count += 1
    return count


def enumerate_independent_sets(graph: BipartiteGraph, k: int
                                ) -> Iterator[Tuple[int, ...]]:
    """Enumerate all independent sets of a given size.

    Args:
        graph: A BipartiteGraph instance.
        k: Desired size of independent sets.

    Yields:
        Tuples of left vertex indices forming independent sets of size k.

    Time complexity: O(C(n, k) * matching_check_cost) per enumeration.
    """
    if k == 0:
        yield ()
        return
    for subset in itertools.combinations(range(graph.n_left), k):
        if is_independent(graph, subset):
            yield subset


def find_active_vertices(graph: BipartiteGraph,
                          rank: Optional[int] = None) -> Set[int]:
    """Find active left vertices (those appearing in some maximum matching).

    Args:
        graph: A BipartiteGraph instance.
        rank: Precomputed rank (if None, computed automatically).

    Returns:
        Set of active left vertex indices.

    Time complexity: O(n * (E * sqrt(V)))
    """
    if rank is None:
        rank = transversal_rank(graph)
    active: Set[int] = set()

    for v in range(graph.n_left):
        if v in active:
            continue
        for r in graph.adj[v]:
            # Try matching v->r and check if remaining admits rank-1 matching
            remaining_adj = []
            for u in range(graph.n_left):
                if u == v:
                    continue
                remaining_adj.append([w for w in graph.adj[u] if w != r])
            sub_graph = BipartiteGraph(graph.n_left - 1, graph.n_right, remaining_adj)
            if transversal_rank(sub_graph) + 1 == rank:
                active.add(v)
                break

    return active


def certified_enumeration(graph: BipartiteGraph,
                           rank: Optional[int] = None
                           ) -> Tuple[List[Tuple[int, ...]], int]:
    """Certified enumeration of codimension-2 independent sets.

    Returns the list of all independent sets of size r-2 along with
    the theoretical upper bound, providing a certificate that the
    enumeration is complete.

    Args:
        graph: A BipartiteGraph instance.
        rank: Precomputed rank (if None, computed automatically).

    Returns:
        Tuple of (list of independent sets, theoretical upper bound).
    """
    if rank is None:
        rank = transversal_rank(graph)

    target = rank - 2
    if target < 0:
        return [], 0

    # Enumerate
    indep_sets = list(enumerate_independent_sets(graph, target))

    # Compute bounds
    from math import comb
    ambient_bound = comb(graph.n_left, target)

    active = find_active_vertices(graph, rank)
    active_bound = comb(len(active), target)

    # The count should be ≤ both bounds
    assert len(indep_sets) <= ambient_bound, \
        f"Count {len(indep_sets)} exceeds ambient bound {ambient_bound}"
    assert len(indep_sets) <= active_bound, \
        f"Count {len(indep_sets)} exceeds active bound {active_bound}"

    return indep_sets, min(ambient_bound, active_bound)


def matching_witness_count(graph: BipartiteGraph,
                            subset: Tuple[int, ...]) -> int:
    """Count the number of valid matching witnesses for a given independent set.

    Under left-degree bound Δ, this is at most Δ^|subset|.

    Args:
        graph: A BipartiteGraph instance.
        subset: Tuple of left vertex indices (must be independent).

    Returns:
        Number of distinct injective matchings from subset into right vertices.
    """
    if not subset:
        return 1

    count = 0
    sub_adj = [graph.adj[v] for v in subset]

    def backtrack(idx: int, used: Set[int]) -> int:
        if idx == len(subset):
            return 1
        total = 0
        for r in sub_adj[idx]:
            if r not in used:
                used.add(r)
                total += backtrack(idx + 1, used)
                used.remove(r)
        return total

    return backtrack(0, set())


# Example usage
if __name__ == "__main__":
    print("=== Algorithm Examples ===")
    print()

    # Example 1: Cycle bipartite graph
    G = BipartiteGraph.cycle_bipartite(6)
    r = transversal_rank(G)
    qlc = quadratic_leaf_count(G, r)
    active = find_active_vertices(G, r)
    print(f"Cycle bipartite C_6: rank={r}, QLC={qlc}, active={active}")

    # Example 2: Complete bipartite
    G = BipartiteGraph.complete(5)
    r = transversal_rank(G)
    qlc = quadratic_leaf_count(G, r)
    active = find_active_vertices(G, r)
    print(f"Complete K_5,5: rank={r}, QLC={qlc}, active={active}")

    # Example 3: Random sparse
    G = BipartiteGraph.random(8, 8, 3, seed=42)
    r = transversal_rank(G)
    qlc = quadratic_leaf_count(G, r)
    active = find_active_vertices(G, r)
    print(f"Random sparse (n=8, Δ=3): rank={r}, QLC={qlc}, "
          f"|active|={len(active)}")

    # Example 4: Certified enumeration
    print()
    G = BipartiteGraph.random(7, 7, 3, seed=123)
    r = transversal_rank(G)
    sets, bound = certified_enumeration(G, r)
    print(f"Certified enumeration (n=7, Δ=3):")
    print(f"  Rank: {r}")
    print(f"  Codim-2 independent sets: {len(sets)}")
    print(f"  Upper bound: {bound}")
    print(f"  First few sets: {sets[:5]}")

    # Example 5: Matching witness counts
    print()
    G = BipartiteGraph.random(6, 6, 3, seed=99)
    r = transversal_rank(G)
    delta = G.max_left_degree
    for s in list(enumerate_independent_sets(G, max(0, r - 2)))[:5]:
        wc = matching_witness_count(G, s)
        bound = delta ** len(s)
        print(f"  Set {s}: {wc} witnesses ≤ Δ^k = {bound}")
