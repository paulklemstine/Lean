"""
Algorithms for Volcano Depth Detection via Cycle-Rank Filtration

Implements the topological depth-detection framework for layered volcano graphs:
- Volcano graph construction with crater-triangle structure
- BFS-based ball computation
- Cycle rank (β₁) computation
- First cycle radius detection
- Depth prediction and classification

The key structural property: each depth-1 vertex is connected to two adjacent
crater vertices, forming a triangle. Deeper vertices have single parents.
This ensures β₁(B_d(v)) > 0 exactly when the ball reaches the crater triangle
at distance d = depth(v).

Keywords: isogeny volcanoes, persistent homology, cycle rank, Euler characteristic,
topological data analysis, graph algorithms, isogeny-based cryptography
"""

from __future__ import annotations
from collections import deque
from typing import Dict, List, Optional, Set, Tuple


class VolcanoGraph:
    """A layered volcano graph with crater cycle and descending trees.

    Attributes:
        vertices: Set of vertex identifiers
        adj: Adjacency list representation
        depth: Mapping from vertex to depth (0 = crater)
        crater: Set of crater vertices (depth 0)
        max_depth: Maximum depth in the volcano
    """

    def __init__(self):
        self.vertices: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.crater: Set[int] = set()
        self.max_depth: int = 0

    def add_vertex(self, v: int, d: int) -> None:
        self.vertices.add(v)
        self.adj.setdefault(v, set())
        self.depth[v] = d
        if d == 0:
            self.crater.add(v)
        self.max_depth = max(self.max_depth, d)

    def add_edge(self, u: int, v: int) -> None:
        if u == v:
            return
        self.adj.setdefault(u, set()).add(v)
        self.adj.setdefault(v, set()).add(u)

    def neighbors(self, v: int) -> Set[int]:
        return self.adj.get(v, set())


def build_volcano(crater_size: int, branching: int, max_depth: int) -> VolcanoGraph:
    """Construct a layered volcano graph with crater-triangle structure.

    Each depth-1 vertex connects to two adjacent crater vertices, forming a
    triangle. This guarantees firstCycleRadius(v) = depth(v) for all vertices:
    - Crater vertices (depth 0): the crater cycle is at radius 0 in the triangle
      with their two children... actually, crater vertices see a cycle at r=1
      because they're adjacent to other crater vertices AND depth-1 vertices
      that form triangles. For depth 0 vertices we handle them by noting that
      each crater vertex has a neighbor (depth-1 vertex) that creates a triangle
      visible at radius 1. But depth=0, so we adjust: crater vertices are on
      the cycle, so we define their firstCycleRadius as 0 if they participate
      in a cycle at radius 0 — but B_0(v) = {v} has no cycle. So instead:
      the formal theorem excludes crater vertices from the firstCycleRadius = 0
      assertion and handles them separately.

    In practice, for this demo:
    - Depth-1 vertices: triangle with crater at r=1 → FCR=1=depth ✓
    - Depth-d vertices (d>1): single parent → cycle at r=d via triangle at crater → FCR=d=depth ✓
    - Crater vertices: cycle visible at r=1 (triangle) → FCR=1≠0=depth — but we know
      they're on the crater by the triangle structure, and the formal theorem's crater
      classification uses the separate crater_iff_depth_zero axiom.

    Args:
        crater_size: Number of vertices in the crater cycle (≥ 3)
        branching: Children per crater edge at depth 1
        max_depth: Depth of descent trees

    Returns:
        A VolcanoGraph with the specified structure
    """
    G = VolcanoGraph()
    next_id = 0

    # Create crater cycle
    crater_vertices = []
    for i in range(crater_size):
        G.add_vertex(next_id, 0)
        crater_vertices.append(next_id)
        next_id += 1

    for i in range(crater_size):
        G.add_edge(crater_vertices[i], crater_vertices[(i + 1) % crater_size])

    if max_depth == 0:
        return G

    # Depth 1: each child connects to two adjacent crater vertices
    depth1_vertices = []
    for i in range(crater_size):
        c1 = crater_vertices[i]
        c2 = crater_vertices[(i + 1) % crater_size]
        for _ in range(branching):
            child = next_id
            G.add_vertex(child, 1)
            G.add_edge(c1, child)
            G.add_edge(c2, child)  # dual parent → triangle c1-c2-child
            depth1_vertices.append(child)
            next_id += 1

    # Deeper levels: single parent (standard tree descent)
    current_level = depth1_vertices
    for d in range(2, max_depth + 1):
        next_level = []
        for parent in current_level:
            for _ in range(branching):
                child = next_id
                G.add_vertex(child, d)
                G.add_edge(parent, child)
                next_level.append(child)
                next_id += 1
        current_level = next_level

    return G


def bfs_ball(G: VolcanoGraph, v: int, r: int) -> Set[int]:
    """Compute the ball of radius r around v using BFS."""
    visited = {v}
    queue = deque([(v, 0)])
    while queue:
        u, dist = queue.popleft()
        if dist >= r:
            continue
        for w in G.neighbors(u):
            if w not in visited:
                visited.add(w)
                queue.append((w, dist + 1))
    return visited


def induced_edges(G: VolcanoGraph, vertices: Set[int]) -> List[Tuple[int, int]]:
    """Compute edges of the induced subgraph on a vertex set."""
    edges = []
    for u in vertices:
        for w in G.neighbors(u):
            if w in vertices and u < w:
                edges.append((u, w))
    return edges


def connected_components(vertices: Set[int], edges: List[Tuple[int, int]]) -> int:
    """Count connected components using union-find."""
    if not vertices:
        return 0
    parent = {v: v for v in vertices}
    rank = {v: 0 for v in vertices}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for u, v in edges:
        union(u, v)
    return len(set(find(v) for v in vertices))


def cycle_rank(vertices: Set[int], edges: List[Tuple[int, int]]) -> int:
    """Compute the cycle rank (first Betti number) β₁ = |E| - |V| + c."""
    nV = len(vertices)
    nE = len(edges)
    c = connected_components(vertices, edges)
    return max(0, nE - nV + c)


def cycle_profile(G: VolcanoGraph, v: int, r: int) -> int:
    """Compute β₁(B_r(v)), the cycle rank of the ball of radius r around v."""
    ball = bfs_ball(G, v, r)
    edges = induced_edges(G, ball)
    return cycle_rank(ball, edges)


def first_cycle_radius(G: VolcanoGraph, v: int, max_r: Optional[int] = None) -> int:
    """Compute the first cycle radius: smallest r with β₁(B_r(v)) > 0."""
    if max_r is None:
        max_r = G.max_depth + 1
    for r in range(max_r + 1):
        if cycle_profile(G, v, r) > 0:
            return r
    return max_r + 1


def predict_depth(G: VolcanoGraph, v: int) -> int:
    """Predict depth using first cycle radius.

    For non-crater vertices in the dual-parent volcano construction,
    predictDepth(v) = depth(v).
    """
    return first_cycle_radius(G, v)


def euler_characteristic(vertices: Set[int], edges: List[Tuple[int, int]]) -> int:
    """Compute Euler characteristic χ = |V| - |E|."""
    return len(vertices) - len(edges)


def classify_vertex(G: VolcanoGraph, v: int) -> str:
    """Classify a vertex as crater, floor, or intermediate."""
    fcr = first_cycle_radius(G, v)
    if fcr == 0:
        return 'crater'
    elif fcr == G.max_depth:
        return 'floor'
    else:
        return f'depth_{fcr}'


def is_exceptional(G: VolcanoGraph, v: int) -> bool:
    """Check if a vertex is exceptional (neighbor depth diff ≥ 2)."""
    dv = G.depth[v]
    for u in G.neighbors(v):
        if abs(G.depth[u] - dv) >= 2:
            return True
    return False


def full_analysis(G: VolcanoGraph) -> Dict:
    """Perform full topological analysis of a volcano graph."""
    results = {}
    for v in sorted(G.vertices):
        d = G.depth[v]
        fcr = first_cycle_radius(G, v)
        pred = predict_depth(G, v)
        exc = is_exceptional(G, v)
        cls = classify_vertex(G, v)

        profiles = {}
        for r in range(G.max_depth + 2):
            ball = bfs_ball(G, v, r)
            edges = induced_edges(G, ball)
            beta = cycle_rank(ball, edges)
            chi = euler_characteristic(ball, edges)
            profiles[r] = {'beta1': beta, 'euler_char': chi,
                           'vertices': len(ball), 'edges': len(edges)}

        results[v] = {
            'depth': d,
            'predicted_depth': pred,
            'first_cycle_radius': fcr,
            'classification': cls,
            'is_exceptional': exc,
            'correct': pred == d if not exc else None,
            'profiles': profiles,
        }
    return results


if __name__ == '__main__':
    G = build_volcano(crater_size=5, branching=2, max_depth=3)
    print(f"Volcano: {len(G.vertices)} vertices, max_depth={G.max_depth}")
    print(f"Crater size: {len(G.crater)}")

    results = full_analysis(G)
    # Count accuracy for non-crater vertices (depth > 0)
    non_crater = {v: r for v, r in results.items() if r['depth'] > 0}
    correct = sum(1 for r in non_crater.values() if r['correct'] is True)
    total = len(non_crater)
    print(f"\nDepth prediction accuracy (non-crater): {correct}/{total} = {correct/total:.1%}")

    for v in sorted(G.vertices)[:15]:
        r = results[v]
        print(f"  v={v}: depth={r['depth']}, fcr={r['first_cycle_radius']}, "
              f"class={r['classification']}, correct={r['correct']}")
