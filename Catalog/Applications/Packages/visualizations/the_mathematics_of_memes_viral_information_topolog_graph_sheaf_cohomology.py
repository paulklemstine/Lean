#!/usr/bin/env python3
"""
Viral Information Topology: Algorithms
=======================================
Complete implementations of algorithms from the research paper.

Algorithms:
1. Graph Sheaf Cohomology Computation (H⁰ and H¹)
2. Meme Virality Index
3. Propagation Dynamics (Discrete Heat Equation)
4. Phase Transition Detector
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict
from dataclasses import dataclass


# ============================================================================
# Algorithm 1: Graph Sheaf Cohomology
# ============================================================================

@dataclass
class CohomologyResult:
    """Result of computing graph sheaf cohomology."""
    h0_dim: int         # Dimension of H⁰ (number of global sections)
    h1_dim: int         # Dimension of H¹ (obstruction dimension)
    h0_basis: np.ndarray # Basis of H⁰ (kernel of coboundary)
    euler_char: int      # Euler characteristic: |V| - |E|
    betti_0: int         # 0th Betti number (= h0_dim)
    betti_1: int         # 1st Betti number (= h1_dim)


def compute_coboundary_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """
    Compute the coboundary matrix δ: C⁰ → C¹.
    
    For the constant sheaf, δ is the oriented incidence matrix:
    δ[e, v] = +1 if v = tgt(e), -1 if v = src(e), 0 otherwise.
    
    Time: O(|V| · |E|)
    Space: O(|V| · |E|)
    
    Args:
        n: Number of vertices
        edges: List of oriented edges (src, tgt) with src < tgt
    
    Returns:
        Coboundary matrix of shape (|E|, |V|)
    """
    m = len(edges)
    delta = np.zeros((m, n), dtype=float)
    for idx, (u, v) in enumerate(edges):
        delta[idx, u] = -1
        delta[idx, v] = +1
    return delta


def compute_graph_cohomology(n: int, 
                              edges: List[Tuple[int, int]]) -> CohomologyResult:
    """
    Compute H⁰ and H¹ of the constant sheaf on a graph.
    
    H⁰ = ker(δ)  — consistent sections (locally constant functions)
    H¹ = coker(δ) = C¹ / im(δ)
    
    By rank-nullity: dim H⁰ = |V| - rank(δ)
                     dim H¹ = |E| - rank(δ)
    Euler char: χ = dim H⁰ - dim H¹ = |V| - |E|
    
    Time: O(|V|² · |E|) for SVD
    Space: O(|V| · |E|)
    
    Args:
        n: Number of vertices
        edges: List of edges as (u, v) pairs
    
    Returns:
        CohomologyResult with all cohomological data
    """
    m = len(edges)
    
    if m == 0:
        # No edges: H⁰ = C⁰ (everything is consistent), H¹ = 0
        return CohomologyResult(
            h0_dim=n,
            h1_dim=0,
            h0_basis=np.eye(n),
            euler_char=n,
            betti_0=n,
            betti_1=0
        )
    
    # Compute coboundary matrix
    delta = compute_coboundary_matrix(n, edges)
    
    # SVD to find rank
    U, S, Vt = np.linalg.svd(delta, full_matrices=True)
    rank = np.sum(S > 1e-10)
    
    h0_dim = n - rank
    h1_dim = m - rank
    
    # Extract kernel basis (last h0_dim rows of Vt)
    h0_basis = Vt[rank:, :] if h0_dim > 0 else np.zeros((0, n))
    
    return CohomologyResult(
        h0_dim=h0_dim,
        h1_dim=h1_dim,
        h0_basis=h0_basis,
        euler_char=n - m,
        betti_0=h0_dim,
        betti_1=h1_dim
    )


# ============================================================================
# Algorithm 2: Meme Virality Index
# ============================================================================

@dataclass
class MemeSheaf:
    """A meme sheaf over a graph."""
    vertex_dims: List[int]  # Interpretation dimension at each vertex
    edge_dims: Dict[Tuple[int, int], int]  # Compatibility dimension at each edge
    
    @property
    def total_interpretation(self) -> int:
        return sum(self.vertex_dims)
    
    @property
    def total_compatibility(self) -> int:
        return sum(self.edge_dims.values())


def compute_virality_index(sheaf: MemeSheaf, h1_dim: int) -> float:
    """
    Compute the virality index V = total_interpretation / (1 + h1_dim).
    
    Time: O(|V|)
    Space: O(1)
    
    Properties (proven in Lean):
    - V is maximized when h1_dim = 0
    - V is strictly decreasing in h1_dim (when total > 0)
    - V ≤ total_interpretation
    """
    return sheaf.total_interpretation / (1 + h1_dim)


def uniform_meme_sheaf(n: int, edges: List[Tuple[int, int]], 
                        d: int, e: int) -> MemeSheaf:
    """
    Create a uniform meme sheaf: every vertex has dim d, every edge has dim e.
    
    Requires: e ≤ d
    Total interpretation = n * d (proven in Lean as uniform_sheaf_total)
    """
    assert e <= d, "Edge dim must not exceed vertex dim"
    return MemeSheaf(
        vertex_dims=[d] * n,
        edge_dims={(u, v): e for u, v in edges}
    )


# ============================================================================
# Algorithm 3: Propagation Dynamics
# ============================================================================

def propagation_step(adj: Dict[int, Set[int]], 
                      f: np.ndarray, n: int) -> np.ndarray:
    """
    One step of meme propagation (discrete heat equation).
    
    Each vertex updates to the average of its neighbors' values.
    Proven in Lean: consistent sections are fixed points.
    
    Time: O(|V| + |E|)
    Space: O(|V|)
    """
    result = np.zeros(n)
    for i in range(n):
        neighbors = adj.get(i, set())
        if not neighbors:
            result[i] = f[i]
        else:
            result[i] = sum(f[j] for j in neighbors) / len(neighbors)
    return result


def propagate_until_convergence(n: int, edges: List[Tuple[int, int]],
                                 f0: np.ndarray, 
                                 tol: float = 1e-10,
                                 max_steps: int = 10000) -> Tuple[np.ndarray, int]:
    """
    Propagate meme values until convergence to a consistent section.
    
    Time: O(steps · (|V| + |E|))
    Space: O(|V|)
    
    Returns:
        (final_values, num_steps)
    """
    adj: Dict[int, Set[int]] = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    
    f = f0.copy()
    for step in range(max_steps):
        f_new = propagation_step(adj, f, n)
        if np.max(np.abs(f_new - f)) < tol:
            return f_new, step + 1
        f = f_new
    return f, max_steps


# ============================================================================
# Algorithm 4: Phase Transition Detector
# ============================================================================

def find_components_bfs(n: int, adj: Dict[int, Set[int]]) -> List[Set[int]]:
    """
    Find connected components using BFS.
    
    Time: O(|V| + |E|)
    Space: O(|V|)
    """
    visited = set()
    components = []
    for start in range(n):
        if start in visited:
            continue
        component = set()
        queue = [start]
        while queue:
            v = queue.pop(0)
            if v in visited:
                continue
            visited.add(v)
            component.add(v)
            for w in adj[v]:
                if w not in visited:
                    queue.append(w)
        components.append(component)
    return components


def detect_phase_transition(n: int, 
                             p_values: List[float],
                             num_trials: int = 100) -> Dict[float, float]:
    """
    Detect the connectivity phase transition for G(n, p).
    
    For each p, estimate the probability that G(n,p) is connected.
    The transition occurs at p ≈ ln(n)/n.
    
    Time: O(num_trials · |p_values| · n²)
    Space: O(n²)
    
    Returns:
        Dict mapping p → fraction of connected graphs
    """
    results = {}
    threshold = np.log(n) / n
    
    for p in p_values:
        connected_count = 0
        for _ in range(num_trials):
            # Generate random graph
            adj: Dict[int, Set[int]] = defaultdict(set)
            for i in range(n):
                for j in range(i + 1, n):
                    if np.random.random() < p:
                        adj[i].add(j)
                        adj[j].add(i)
            
            components = find_components_bfs(n, adj)
            if len(components) == 1:
                connected_count += 1
        
        results[p] = connected_count / num_trials
    
    return results


# ============================================================================
# Algorithm 5: Full Meme Analysis Pipeline
# ============================================================================

@dataclass
class MemeAnalysis:
    """Complete analysis of a meme on a social network."""
    graph_vertices: int
    graph_edges: int
    num_components: int
    h0_dim: int
    h1_dim: int
    euler_characteristic: int
    virality_index: float
    is_universally_transmissible: bool  # H¹ = 0
    interpretation_diversity: int       # dim H⁰
    convergence_steps: Optional[int]


def analyze_meme(n: int, edges: List[Tuple[int, int]],
                  vertex_dim: int = 1,
                  initial_values: Optional[np.ndarray] = None) -> MemeAnalysis:
    """
    Full analysis pipeline for a meme on a social network.
    
    1. Compute graph structure (components)
    2. Compute sheaf cohomology (H⁰, H¹)
    3. Compute virality index
    4. Run propagation dynamics
    
    Time: O(n² · |E| + propagation_steps · (n + |E|))
    Space: O(n · |E|)
    """
    # Cohomology
    cohom = compute_graph_cohomology(n, edges)
    
    # Sheaf and virality
    sheaf = uniform_meme_sheaf(n, edges, vertex_dim, min(vertex_dim, 1))
    vi = compute_virality_index(sheaf, cohom.h1_dim)
    
    # Propagation
    conv_steps = None
    if initial_values is not None:
        _, conv_steps = propagate_until_convergence(n, edges, initial_values)
    
    return MemeAnalysis(
        graph_vertices=n,
        graph_edges=len(edges),
        num_components=cohom.h0_dim,  # For constant sheaf
        h0_dim=cohom.h0_dim,
        h1_dim=cohom.h1_dim,
        euler_characteristic=cohom.euler_char,
        virality_index=vi,
        is_universally_transmissible=(cohom.h1_dim == 0),
        interpretation_diversity=cohom.h0_dim,
        convergence_steps=conv_steps
    )


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Example 1: Triangle graph
    print("Triangle Graph (K₃):")
    result = compute_graph_cohomology(3, [(0,1), (1,2), (0,2)])
    print(f"  H⁰ dim = {result.h0_dim}, H¹ dim = {result.h1_dim}")
    print(f"  Euler char = {result.euler_char}")
    print(f"  Betti numbers: β₀ = {result.betti_0}, β₁ = {result.betti_1}")
    
    # Example 2: Path graph
    print("\nPath Graph P₅:")
    result = compute_graph_cohomology(5, [(0,1), (1,2), (2,3), (3,4)])
    print(f"  H⁰ dim = {result.h0_dim}, H¹ dim = {result.h1_dim}")
    print(f"  Euler char = {result.euler_char}")
    
    # Example 3: Two triangles (disconnected)
    print("\nTwo Triangles (disconnected):")
    result = compute_graph_cohomology(6, [(0,1), (1,2), (0,2), (3,4), (4,5), (3,5)])
    print(f"  H⁰ dim = {result.h0_dim}, H¹ dim = {result.h1_dim}")
    print(f"  → Two components, each with a cycle")
    
    # Example 4: Full analysis
    print("\nFull Meme Analysis (social network with 10 nodes):")
    edges = [(0,1), (1,2), (2,3), (3,4), (5,6), (6,7), (7,8), (8,9)]
    initial = np.random.randn(10)
    analysis = analyze_meme(10, edges, vertex_dim=3, initial_values=initial)
    print(f"  Vertices: {analysis.graph_vertices}")
    print(f"  Edges: {analysis.graph_edges}")
    print(f"  Components: {analysis.num_components}")
    print(f"  H⁰ dim: {analysis.h0_dim}")
    print(f"  H¹ dim: {analysis.h1_dim}")
    print(f"  Virality: {analysis.virality_index:.2f}")
    print(f"  Universally transmissible: {analysis.is_universally_transmissible}")
    print(f"  Convergence steps: {analysis.convergence_steps}")
    
    # Example 5: Phase transition
    print("\nPhase Transition Detection (n=50):")
    np.random.seed(42)
    results = detect_phase_transition(
        50, 
        [0.02, 0.04, 0.06, 0.08, 0.10, 0.15, 0.20],
        num_trials=50
    )
    threshold = np.log(50) / 50
    print(f"  Theoretical threshold: p* = ln(50)/50 ≈ {threshold:.4f}")
    for p, frac in sorted(results.items()):
        marker = " ← threshold" if abs(p - threshold) < 0.02 else ""
        print(f"  p = {p:.3f}: {frac*100:5.1f}% connected{marker}")
