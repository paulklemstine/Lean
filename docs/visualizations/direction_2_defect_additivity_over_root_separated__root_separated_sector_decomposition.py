#!/usr/bin/env python3
"""
algorithms.py — Algorithms for root-separated defect decomposition.

Implements:
1. Defect computation for rooted graph subsets
2. Root-separation detection
3. Decomposition into root-separated sectors
4. Interaction energy computation
"""

from collections import deque
from typing import Set, Tuple, List, Dict, Optional


class RootedGraph:
    """A simple undirected graph with a distinguished root vertex.
    
    Attributes:
        vertices: Set of vertex labels (integers)
        adj: Symmetric adjacency set of (u,v) pairs
        root: Distinguished root vertex
    """
    
    def __init__(self, vertices: Set[int], edges: List[Tuple[int, int]], root: int):
        self.vertices = set(vertices)
        self.adj: Set[Tuple[int, int]] = set()
        for u, v in edges:
            self.adj.add((u, v))
            self.adj.add((v, u))
        self.root = root
    
    def neighbors(self, v: int) -> Set[int]:
        """Return neighbors of v."""
        return {w for w in self.vertices if (v, w) in self.adj}
    
    def delete_vertex(self, v: int) -> 'RootedGraph':
        """Return graph with vertex v deleted."""
        new_verts = self.vertices - {v}
        new_edges = [(u, w) for (u, w) in self.adj if u != v and w != v and u < w]
        return RootedGraph(new_verts, new_edges, self.root if self.root != v else -1)


def bfs_component(start: int, vertices: Set[int], adj: Set[Tuple[int, int]]) -> Set[int]:
    """BFS to find the connected component containing `start`."""
    visited = set()
    queue = deque([start])
    while queue:
        u = queue.popleft()
        if u in visited:
            continue
        visited.add(u)
        for w in vertices:
            if w not in visited and (u, w) in adj:
                queue.append(w)
    return visited


def connected_components(vertices: Set[int], adj: Set[Tuple[int, int]]) -> List[Set[int]]:
    """Compute connected components of the graph (vertices, adj).
    
    Time complexity: O(|V| + |E|)
    Space complexity: O(|V|)
    """
    visited = set()
    components = []
    for v in vertices:
        if v not in visited:
            comp = bfs_component(v, vertices, adj)
            visited.update(comp)
            components.append(comp)
    return components


def induced_edge_count(S: Set[int], adj: Set[Tuple[int, int]]) -> int:
    """Count edges in the induced subgraph G[S].
    
    Time: O(|S|²)
    """
    count = 0
    S_list = sorted(S)
    for i, u in enumerate(S_list):
        for v in S_list[i+1:]:
            if (u, v) in adj:
                count += 1
    return count


def induced_component_count(S: Set[int], adj: Set[Tuple[int, int]]) -> int:
    """Count connected components of G[S].
    
    Time: O(|S|² )
    """
    if not S:
        return 0
    return len(connected_components(S, adj))


def cycle_rank(S: Set[int], adj: Set[Tuple[int, int]]) -> int:
    """Compute β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|.
    
    The first Betti number / cycle rank of the induced subgraph.
    
    Time: O(|S|²)
    """
    e = induced_edge_count(S, adj)
    c = induced_component_count(S, adj)
    return e + c - len(S)


def root_component_count(G: RootedGraph, S: Set[int]) -> int:
    """Compute κ(G,q,S): the number of connected components of G-{q}
    that contain at least one vertex of S.
    
    Time: O(|V| + |E|)
    """
    V_minus_q = G.vertices - {G.root}
    comps = connected_components(V_minus_q, G.adj)
    return sum(1 for c in comps if c & S)


def structural_defect(G: RootedGraph, S: Set[int]) -> int:
    """Compute δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1.
    
    The structural defect of a rooted subset.
    
    Time: O(|V| + |E|)
    
    >>> G = RootedGraph({0,1,2,3}, [(0,1),(0,2),(0,3)], root=0)
    >>> structural_defect(G, {1})  # singleton in a star
    0
    >>> structural_defect(G, {1,2})  # two leaves in different components
    1
    """
    b = cycle_rank(S, G.adj)
    k = root_component_count(G, S)
    return b + k - 1


def is_root_separated(G: RootedGraph, S1: Set[int], S2: Set[int]) -> bool:
    """Check if S1 and S2 are root-separated w.r.t. G.root.
    
    Root-separated means:
    1. S1 ∩ S2 = ∅
    2. q ∉ S1 ∪ S2
    3. No vertex in S1 is reachable from any vertex in S2 in G-{q}
    
    Time: O(|V| + |E|)
    
    >>> G = RootedGraph({0,1,2,3}, [(0,1),(0,2),(0,3)], root=0)
    >>> is_root_separated(G, {1}, {2})
    True
    >>> is_root_separated(G, {1}, {1})
    False
    """
    if S1 & S2:
        return False
    if G.root in S1 or G.root in S2:
        return False
    V_minus_q = G.vertices - {G.root}
    comps = connected_components(V_minus_q, G.adj)
    for c in comps:
        if (c & S1) and (c & S2):
            return False
    return True


def decompose_into_sectors(G: RootedGraph, S: Set[int]) -> List[Set[int]]:
    """Decompose S into maximal root-separated sectors.
    
    Each sector is the intersection of S with a connected component of G-{q}.
    The resulting sectors are pairwise root-separated.
    
    Time: O(|V| + |E|)
    
    Returns:
        List of non-empty sets, each a root-separated sector of S.
    
    >>> G = RootedGraph({0,1,2,3,4}, [(0,1),(0,2),(1,2),(0,3),(0,4)], root=0)
    >>> sectors = decompose_into_sectors(G, {1,2,3,4})
    >>> len(sectors)
    3
    """
    if not S or G.root in S:
        return [S] if S else []
    
    V_minus_q = G.vertices - {G.root}
    comps = connected_components(V_minus_q, G.adj)
    sectors = []
    for c in comps:
        sector = S & c
        if sector:
            sectors.append(sector)
    return sectors


def defect_interaction(G: RootedGraph, S1: Set[int], S2: Set[int]) -> int:
    """Compute the defect interaction I_q(S1, S2) = δ(S1∪S2) - δ(S1) - δ(S2).
    
    For root-separated pieces, this is always 1.
    For non-separated pieces, it can vary.
    
    Time: O(|V| + |E|)
    """
    return structural_defect(G, S1 | S2) - structural_defect(G, S1) - structural_defect(G, S2)


def verify_decomposition_law(G: RootedGraph, S1: Set[int], S2: Set[int]) -> Dict:
    """Verify the decomposition law δ(S1∪S2) = δ(S1) + δ(S2) + 1
    for a given root-separated pair.
    
    Returns a dictionary with:
        - is_separated: whether the pair is root-separated
        - defect_union: δ(S1∪S2)
        - defect_sum_plus_one: δ(S1) + δ(S2) + 1
        - holds: whether the law holds
        - interaction: the interaction energy
    """
    sep = is_root_separated(G, S1, S2)
    d_union = structural_defect(G, S1 | S2)
    d1 = structural_defect(G, S1)
    d2 = structural_defect(G, S2)
    expected = d1 + d2 + 1
    
    return {
        "is_separated": sep,
        "defect_union": d_union,
        "defect_S1": d1,
        "defect_S2": d2,
        "defect_sum_plus_one": expected,
        "holds": d_union == expected,
        "interaction": d_union - d1 - d2,
        "beta1_union": cycle_rank(S1 | S2, G.adj),
        "beta1_S1": cycle_rank(S1, G.adj),
        "beta1_S2": cycle_rank(S2, G.adj),
        "kappa_union": root_component_count(G, S1 | S2),
        "kappa_S1": root_component_count(G, S1),
        "kappa_S2": root_component_count(G, S2),
    }


if __name__ == "__main__":
    # Example: Star graph K_{1,4} with root at center
    print("=== Star Graph K_{1,4} ===")
    G = RootedGraph({0, 1, 2, 3, 4}, [(0,1),(0,2),(0,3),(0,4)], root=0)
    
    print(f"Vertices: {G.vertices}, Root: {G.root}")
    print(f"Sectors of {{1,2,3,4}}: {decompose_into_sectors(G, {1,2,3,4})}")
    
    result = verify_decomposition_law(G, {1,2}, {3,4})
    print(f"\nS₁={{1,2}}, S₂={{3,4}}:")
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    # Example: Path graph 1-0-2-3
    print("\n=== Path Graph 1-0-2-3 ===")
    G2 = RootedGraph({0,1,2,3}, [(1,0),(0,2),(2,3)], root=0)
    result2 = verify_decomposition_law(G2, {1}, {2,3})
    print(f"S₁={{1}}, S₂={{2,3}}:")
    for k, v in result2.items():
        print(f"  {k}: {v}")
    
    # Example: Cycle with pendant
    print("\n=== Cycle C₄ with pendant ===")
    G3 = RootedGraph({0,1,2,3,4}, [(0,1),(1,2),(2,3),(3,0),(0,4)], root=0)
    result3 = verify_decomposition_law(G3, {1,2,3}, {4})
    print(f"S₁={{1,2,3}}, S₂={{4}}:")
    for k, v in result3.items():
        print(f"  {k}: {v}")
