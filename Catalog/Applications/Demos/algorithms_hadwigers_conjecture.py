"""
Algorithms for Hadwiger's Conjecture and Graph Minor Theory.

Implements:
1. Greedy coloring for degenerate graphs
2. Minor model search (branch-set detection)
3. Degeneracy computation
4. Hadwiger number computation for small graphs

All functions are type-hinted and self-contained.
"""

from typing import Optional
from itertools import combinations
from collections import deque


def compute_degeneracy(adj: dict[int, set[int]]) -> tuple[int, list[int]]:
    """
    Compute the degeneracy of a graph and a degeneracy ordering.

    Args:
        adj: Adjacency list representation {vertex: set of neighbors}

    Returns:
        (degeneracy, ordering) where ordering is a degeneracy ordering
    """
    vertices = set(adj.keys())
    remaining = {v: set(adj[v]) for v in vertices}
    ordering: list[int] = []
    degeneracy = 0

    while remaining:
        min_v = min(remaining, key=lambda v: len(remaining[v] & set(remaining.keys())))
        deg = len(remaining[min_v] & set(remaining.keys()))
        degeneracy = max(degeneracy, deg)
        ordering.append(min_v)
        del remaining[min_v]
        for u in list(remaining.keys()):
            remaining[u].discard(min_v)

    return degeneracy, ordering


def greedy_coloring(adj: dict[int, set[int]], ordering: list[int]) -> dict[int, int]:
    """
    Greedy coloring following a given vertex ordering.

    For a degeneracy ordering with degeneracy k, this uses at most k+1 colors.
    """
    coloring: dict[int, int] = {}
    for v in ordering:
        used_colors = {coloring[u] for u in adj[v] if u in coloring}
        color = 0
        while color in used_colors:
            color += 1
        coloring[v] = color
    return coloring


def chromatic_number_exact(adj: dict[int, set[int]]) -> int:
    """
    Compute exact chromatic number by trying colorings with increasing k.
    Uses backtracking search. Only practical for small graphs (≤ 15 vertices).
    """
    vertices = sorted(adj.keys())
    n = len(vertices)
    if n == 0:
        return 0

    def can_color(k: int) -> bool:
        coloring: dict[int, int] = {}
        def backtrack(idx: int) -> bool:
            if idx == n:
                return True
            v = vertices[idx]
            used = {coloring[u] for u in adj[v] if u in coloring}
            for c in range(k):
                if c not in used:
                    coloring[v] = c
                    if backtrack(idx + 1):
                        return True
                    del coloring[v]
            return False
        return backtrack(0)

    for k in range(n + 1):
        if can_color(k):
            return k
    return n


def _is_connected(adj: dict[int, set[int]], subset: set[int]) -> bool:
    """Check if subset induces a connected subgraph."""
    if not subset:
        return False
    start = next(iter(subset))
    visited = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for u in adj.get(v, set()):
            if u in subset and u not in visited:
                visited.add(u)
                queue.append(u)
    return visited == subset


def _has_edge_between(adj: dict[int, set[int]], s1: set[int], s2: set[int]) -> bool:
    """Check if there's an edge between two vertex sets."""
    for u in s1:
        if adj.get(u, set()) & s2:
            return True
    return False


def find_minor_model(
    adj_G: dict[int, set[int]],
    k: int
) -> Optional[dict[int, set[int]]]:
    """
    Search for a K_k minor model in graph G using edge contraction.

    Strategy: try contracting sequences of edges to reduce the graph,
    then check if the result contains K_k as a subgraph.

    Args:
        adj_G: Adjacency list of G
        k: Size of complete graph minor to find

    Returns:
        Branch sets {minor_vertex: set of G-vertices} or None if not found
    """
    if k == 0:
        return {}

    vertices = list(adj_G.keys())
    n = len(vertices)

    if k > n:
        return None

    # Try singleton branch sets first (clique search)
    for combo in combinations(vertices, k):
        valid = True
        for i in range(k):
            for j in range(i + 1, k):
                if combo[j] not in adj_G.get(combo[i], set()):
                    valid = False
                    break
            if not valid:
                break
        if valid:
            return {i: {combo[i]} for i in range(k)}

    # Edge contraction approach: contract edges and track branch sets
    # Use BFS-style exploration of contractions
    def try_contractions(
        adj: dict[int, set[int]],
        groups: dict[int, set[int]],  # representative -> original vertices
        depth: int
    ) -> Optional[dict[int, set[int]]]:
        reps = sorted(groups.keys())
        nr = len(reps)

        if nr < k:
            return None

        # Check if current contracted graph has K_k as subgraph
        for combo in combinations(reps, k):
            valid = True
            for i in range(k):
                for j in range(i + 1, k):
                    if combo[j] not in adj.get(combo[i], set()):
                        valid = False
                        break
                if not valid:
                    break
            if valid:
                return {i: groups[combo[i]] for i in range(k)}

        if depth == 0 or nr <= k:
            return None

        # Try contracting each edge
        for u in reps:
            for v in sorted(adj.get(u, set())):
                if v <= u:
                    continue
                if v not in groups:
                    continue
                # Contract u-v: merge v into u
                new_adj: dict[int, set[int]] = {}
                new_groups: dict[int, set[int]] = {}
                for r in reps:
                    if r == v:
                        continue
                    new_groups[r] = set(groups[r])
                    nbrs = set()
                    for nb in adj.get(r, set()):
                        if nb == v:
                            nbrs.add(u)
                        elif nb in groups and nb != r:
                            nbrs.add(nb)
                    if r == u:
                        # u absorbs v's neighbors
                        for nb in adj.get(v, set()):
                            if nb != u and nb != v and nb in groups:
                                nbrs.add(nb)
                        new_groups[r] = groups[u] | groups[v]
                    nbrs.discard(r)
                    new_adj[r] = nbrs

                result = try_contractions(new_adj, new_groups, depth - 1)
                if result is not None:
                    return result

        return None

    # Build initial groups (each vertex is its own group)
    init_groups = {v: {v} for v in vertices}
    max_depth = min(n - k + 1, 6)  # Limit contraction depth
    return try_contractions(adj_G, init_groups, max_depth)


def hadwiger_number(adj: dict[int, set[int]]) -> int:
    """
    Compute the Hadwiger number h(G): largest k such that K_k is a minor of G.
    Only practical for small graphs (≤ 10 vertices).
    """
    n = len(adj)
    for k in range(n, 0, -1):
        if find_minor_model(adj, k) is not None:
            return k
    return 0


def verify_hadwiger_small(n: int) -> bool:
    """
    Verify Hadwiger's conjecture for all graphs on n vertices.
    Returns True if Hadwiger holds for all graphs.
    """
    vertices = list(range(n))
    edges_possible = [(i, j) for i in range(n) for j in range(i + 1, n)]
    num_possible = len(edges_possible)

    for mask in range(2 ** num_possible):
        adj: dict[int, set[int]] = {v: set() for v in vertices}
        for idx in range(num_possible):
            if mask & (1 << idx):
                i, j = edges_possible[idx]
                adj[i].add(j)
                adj[j].add(i)

        chi = chromatic_number_exact(adj)
        if chi > 0:
            model = find_minor_model(adj, chi)
            if model is None:
                edges = [(i, j) for idx, (i, j) in enumerate(edges_possible) if mask & (1 << idx)]
                print(f"  COUNTEREXAMPLE: n={n}, edges={edges}, χ={chi}")
                return False

    return True


if __name__ == "__main__":
    K4 = {i: {j for j in range(4) if j != i} for i in range(4)}
    print("=== K_4 ===")
    print(f"Degeneracy: {compute_degeneracy(K4)}")
    print(f"Chromatic number: {chromatic_number_exact(K4)}")
    print(f"Hadwiger number: {hadwiger_number(K4)}")

    K33 = {0: {3, 4, 5}, 1: {3, 4, 5}, 2: {3, 4, 5},
           3: {0, 1, 2}, 4: {0, 1, 2}, 5: {0, 1, 2}}
    print("\n=== K_{3,3} ===")
    print(f"Chromatic number: {chromatic_number_exact(K33)}")
    print(f"Hadwiger number: {hadwiger_number(K33)}")
