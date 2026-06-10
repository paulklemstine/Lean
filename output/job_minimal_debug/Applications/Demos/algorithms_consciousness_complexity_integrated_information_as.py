#!/usr/bin/env python3
"""
Algorithms for Integrated Information as a Topological Invariant

Type-hinted implementations of the key algorithms from the paper:
1. Computing Phi for arbitrary connected graphs
2. Computing the coboundary matrix and sheaf cohomology dimensions
3. Graph topology classification by Phi
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import numpy as np
from collections import deque


# ============================================================
# Graph representation
# ============================================================

class Graph:
    """Simple undirected graph on integer vertices."""
    
    def __init__(self, vertices: Set[int], edges: Set[FrozenSet[int]]):
        self.vertices: Set[int] = vertices
        self.edges: Set[FrozenSet[int]] = edges
        # Validate: edges must connect vertices
        for e in edges:
            assert len(e) == 2, f"Edge must have 2 vertices: {e}"
            assert e.issubset(vertices), f"Edge {e} has vertices not in graph"
    
    @property
    def num_vertices(self) -> int:
        return len(self.vertices)
    
    @property
    def num_edges(self) -> int:
        return len(self.edges)
    
    def neighbors(self, v: int) -> Set[int]:
        """Return the set of neighbors of vertex v."""
        result: Set[int] = set()
        for e in self.edges:
            if v in e:
                result |= e - {v}
        return result
    
    def is_connected(self) -> bool:
        """Check if the graph is connected using BFS."""
        if not self.vertices:
            return True
        start = next(iter(self.vertices))
        visited: Set[int] = {start}
        queue: deque[int] = deque([start])
        while queue:
            v = queue.popleft()
            for w in self.neighbors(v):
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return visited == self.vertices
    
    def num_components(self) -> int:
        """Count connected components."""
        visited: Set[int] = set()
        count = 0
        for v in self.vertices:
            if v not in visited:
                count += 1
                queue: deque[int] = deque([v])
                visited.add(v)
                while queue:
                    u = queue.popleft()
                    for w in self.neighbors(u):
                        if w not in visited:
                            visited.add(w)
                            queue.append(w)
        return count


# ============================================================
# Standard graph constructors
# ============================================================

def path_graph(n: int) -> Graph:
    """Path graph P_n on n vertices."""
    vertices = set(range(n))
    edges = {frozenset({i, i + 1}) for i in range(n - 1)}
    return Graph(vertices, edges)


def cycle_graph(n: int) -> Graph:
    """Cycle graph C_n on n vertices (n >= 3)."""
    assert n >= 3
    vertices = set(range(n))
    edges = {frozenset({i, (i + 1) % n}) for i in range(n)}
    return Graph(vertices, edges)


def complete_graph(n: int) -> Graph:
    """Complete graph K_n on n vertices."""
    vertices = set(range(n))
    edges = {frozenset({i, j}) for i in range(n) for j in range(i + 1, n)}
    return Graph(vertices, edges)


def grid_graph(m: int, n: int) -> Graph:
    """Grid graph m x n."""
    vertices = {i * n + j for i in range(m) for j in range(n)}
    edges: Set[FrozenSet[int]] = set()
    for i in range(m):
        for j in range(n):
            v = i * n + j
            if j + 1 < n:
                edges.add(frozenset({v, v + 1}))
            if i + 1 < m:
                edges.add(frozenset({v, v + n}))
    return Graph(vertices, edges)


# ============================================================
# Algorithm 1: Compute Phi (First Betti Number)
# ============================================================

def compute_phi(g: Graph) -> int:
    """
    Compute the integrated information Phi = beta_1 of a connected graph.
    
    Phi = |E| - |V| + c, where c is the number of connected components.
    For a connected graph, Phi = |E| - |V| + 1.
    
    Time complexity: O(|V| + |E|) for BFS to find components.
    
    Pseudocode:
        1. Count vertices |V| and edges |E|
        2. Find connected components c via BFS
        3. Return |E| - |V| + c
    """
    c = g.num_components()
    return g.num_edges - g.num_vertices + c


# ============================================================
# Algorithm 2: Coboundary Matrix and Sheaf Cohomology
# ============================================================

class CellularSheaf:
    """Cellular sheaf on a graph with explicit linear restriction maps."""
    
    def __init__(
        self,
        graph: Graph,
        vertex_dims: Dict[int, int],
        edge_dims: Dict[FrozenSet[int], int],
        restrictions: Dict[Tuple[int, FrozenSet[int]], np.ndarray],
    ):
        """
        Args:
            graph: The underlying graph
            vertex_dims: Dimension of stalk at each vertex
            edge_dims: Dimension of stalk at each edge
            restrictions: Linear maps rho_{v,e}: F(v) -> F(e) for each incidence
        """
        self.graph = graph
        self.vertex_dims = vertex_dims
        self.edge_dims = edge_dims
        self.restrictions = restrictions
    
    @property
    def dim_c0(self) -> int:
        """Dimension of C^0 = direct sum of vertex stalks."""
        return sum(self.vertex_dims.values())
    
    @property
    def dim_c1(self) -> int:
        """Dimension of C^1 = direct sum of edge stalks."""
        return sum(self.edge_dims.values())
    
    def coboundary_matrix(self) -> np.ndarray:
        """
        Assemble the coboundary matrix delta: C^0 -> C^1.
        
        For each edge e = {u, v} with u < v, and each incidence (w, e):
            delta restricted to F(w) -> F(e) is (+/-)rho_{w,e}
        
        Pseudocode:
            1. Order vertices and edges
            2. Compute row/column offsets from stalk dimensions
            3. Fill in restriction map blocks with appropriate signs
        """
        # Order vertices and edges
        vertices = sorted(self.graph.vertices)
        edges = sorted(self.graph.edges, key=lambda e: tuple(sorted(e)))
        
        # Compute offsets
        v_offset: Dict[int, int] = {}
        offset = 0
        for v in vertices:
            v_offset[v] = offset
            offset += self.vertex_dims[v]
        
        e_offset: Dict[FrozenSet[int], int] = {}
        offset = 0
        for e in edges:
            e_offset[e] = offset
            offset += self.edge_dims[e]
        
        # Build matrix
        delta = np.zeros((self.dim_c1, self.dim_c0))
        
        for e in edges:
            u, v = sorted(e)
            ed = self.edge_dims[e]
            
            # Source vertex (positive sign)
            if (u, e) in self.restrictions:
                rho = self.restrictions[(u, e)]
                r, c = e_offset[e], v_offset[u]
                delta[r:r + ed, c:c + self.vertex_dims[u]] = rho
            
            # Target vertex (negative sign)
            if (v, e) in self.restrictions:
                rho = self.restrictions[(v, e)]
                r, c = e_offset[e], v_offset[v]
                delta[r:r + ed, c:c + self.vertex_dims[v]] = -rho
        
        return delta
    
    def compute_cohomology_dims(self) -> Tuple[int, int]:
        """
        Compute dim H^0 and dim H^1.
        
        Pseudocode:
            1. Assemble coboundary matrix delta
            2. Compute rank via SVD
            3. dim H^0 = dim C^0 - rank
            4. dim H^1 = dim C^1 - rank
        """
        delta = self.coboundary_matrix()
        rank = int(np.linalg.matrix_rank(delta))
        dim_h0 = self.dim_c0 - rank
        dim_h1 = self.dim_c1 - rank
        return dim_h0, dim_h1


def constant_sheaf(g: Graph) -> CellularSheaf:
    """Construct the constant sheaf (all stalks dimension 1)."""
    vertex_dims = {v: 1 for v in g.vertices}
    edge_dims = {e: 1 for e in g.edges}
    restrictions: Dict[Tuple[int, FrozenSet[int]], np.ndarray] = {}
    for e in g.edges:
        for v in e:
            restrictions[(v, e)] = np.array([[1.0]])
    return CellularSheaf(g, vertex_dims, edge_dims, restrictions)


def uniform_sheaf(g: Graph, d: int) -> CellularSheaf:
    """Construct a uniform sheaf with all stalks dimension d, identity restrictions."""
    vertex_dims = {v: d for v in g.vertices}
    edge_dims = {e: d for e in g.edges}
    restrictions: Dict[Tuple[int, FrozenSet[int]], np.ndarray] = {}
    for e in g.edges:
        for v in e:
            restrictions[(v, e)] = np.eye(d)
    return CellularSheaf(g, vertex_dims, edge_dims, restrictions)


# ============================================================
# Algorithm 3: Classify Graph by Phi
# ============================================================

def classify_by_phi(g: Graph) -> str:
    """
    Classify a connected graph by its integrated information.
    
    Returns:
        A string classification of the graph's consciousness type.
    """
    p = compute_phi(g)
    n = g.num_vertices
    max_phi = (n - 1) * (n - 2) // 2 if n >= 2 else 0
    
    if p == 0:
        return "ACYCLIC (no integration, feedforward only)"
    elif p == 1:
        return "MINIMAL (single cycle, basic integration)"
    elif p == max_phi:
        return f"MAXIMAL (complete graph, Phi={p})"
    else:
        ratio = p / max_phi if max_phi > 0 else 0
        return f"INTERMEDIATE (Phi={p}, {ratio:.1%} of maximum)"


# ============================================================
# Verification
# ============================================================

def verify_all_theorems():
    """Verify all main theorems computationally."""
    print("Verifying Theorem 1: Trees have Phi = 0")
    for n in range(1, 20):
        g = path_graph(n)
        assert compute_phi(g) == 0, f"Failed for P_{n}"
    print("  ✓ Verified for P_1 through P_19")
    
    print("\nVerifying Theorem 2: Cycles have Phi = 1")
    for n in range(3, 20):
        g = cycle_graph(n)
        assert compute_phi(g) == 1, f"Failed for C_{n}"
    print("  ✓ Verified for C_3 through C_19")
    
    print("\nVerifying Theorem 3: Complete graphs have Phi = (n-1)(n-2)/2")
    for n in range(1, 15):
        g = complete_graph(n)
        expected = (n - 1) * (n - 2) // 2
        actual = compute_phi(g)
        assert actual == expected, f"Failed for K_{n}: {actual} != {expected}"
    print("  ✓ Verified for K_1 through K_14")
    
    print("\nVerifying Euler relation: |V| - |E| = 1 - Phi")
    for n in range(3, 10):
        for graph_fn, name in [(cycle_graph, "C"), (complete_graph, "K")]:
            g = graph_fn(n)
            p = compute_phi(g)
            assert g.num_vertices - g.num_edges == 1 - p
    print("  ✓ Verified for cycles and complete graphs")
    
    print("\nVerifying sheaf cohomology for constant sheaf")
    for g, name in [(path_graph(5), "P_5"), (cycle_graph(5), "C_5"),
                     (complete_graph(4), "K_4"), (complete_graph(5), "K_5")]:
        F = constant_sheaf(g)
        h0, h1 = F.compute_cohomology_dims()
        expected_phi = compute_phi(g)
        print(f"  {name}: H^0={h0}, H^1={h1}, Phi={expected_phi}", end="")
        assert h1 == expected_phi, f"Sheaf H^1 != Phi for {name}"
        if g.is_connected():
            assert h0 == 1, f"H^0 != 1 for connected {name}"
        print(" ✓")
    
    print("\nVerifying uniform sheaf scaling: dim H^1 = d * beta_1")
    for d in [1, 2, 3, 5]:
        for g, name in [(cycle_graph(5), "C_5"), (complete_graph(4), "K_4")]:
            F = uniform_sheaf(g, d)
            _, h1 = F.compute_cohomology_dims()
            expected = d * compute_phi(g)
            assert h1 == expected, f"Failed for d={d}, {name}: {h1} != {expected}"
    print(f"  ✓ Verified for d ∈ {{1,2,3,5}} on C_5 and K_4")
    
    print("\n✓ ALL THEOREMS VERIFIED")


if __name__ == "__main__":
    verify_all_theorems()
