#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Higher-Homology Detection in Clique Complexes

Implements the core computational methods for:
1. Clique complex invariant computation (triangles, 4-cliques, Euler characteristic)
2. Forcing surplus computation and certification
3. Second Betti number via Smith normal form / boundary matrix rank
4. Higher-Homology Window detection in threshold families
5. Homological complexity profiling

All algorithms operate on finite simple graphs represented as adjacency sets.

Time complexity:
  - Triangle enumeration: O(|V| · d²) where d = max degree
  - 4-clique enumeration: O(|V| · d³)
  - β₂ computation: O(|T|² · |E|) via Gaussian elimination
  - Full profile scan: O(ε_max · (|V|² + |T|² · |E|))
"""

from typing import List, Tuple, Set, Dict, Optional, NamedTuple
from collections import defaultdict
import numpy as np


# ─── Data Types ───────────────────────────────────────────────────────

class GraphInvariants(NamedTuple):
    """Complete set of clique complex invariants for a graph."""
    num_vertices: int
    num_edges: int
    num_triangles: int
    num_four_cliques: int
    cycle_rank: int
    two_skeleton_euler: int
    forcing_surplus: int
    betti_2: int
    tetrahedron_defect: int
    normalized_triangle_surplus: float


class PhaseClassification(NamedTuple):
    """Phase classification of a threshold graph."""
    threshold: float
    phase: str  # "ISOLATED", "TREE", "CYCLE", "TRIANGLE_RICH", "HIGHER_HOMOLOGY", "SATURATED"
    invariants: GraphInvariants


class HomologyWindow(NamedTuple):
    """A detected higher-homology window in a threshold family."""
    epsilon_low: float
    epsilon_high: float
    max_forcing_surplus: int
    max_betti_2: int
    window_width: float


# ─── Core Graph Operations ───────────────────────────────────────────

class FiniteSimpleGraph:
    """
    Efficient finite simple graph for clique complex computations.
    
    Vertices are integers {0, ..., n-1}.
    Adjacency stored as sorted adjacency lists for fast intersection.
    
    Time complexity:
      - Construction: O(|E|)
      - Adjacency query: O(log d) where d = degree
      - Triangle enumeration: O(Σ_v d(v)²) ≤ O(|V| · d_max²)
    """
    
    def __init__(self, n: int, edges: Optional[List[Tuple[int, int]]] = None):
        self.n = n
        self._adj: Dict[int, Set[int]] = defaultdict(set)
        self._edges: Optional[List[Tuple[int, int]]] = None
        
        if edges:
            for u, v in edges:
                if u != v:
                    self._adj[u].add(v)
                    self._adj[v].add(u)
    
    def has_edge(self, u: int, v: int) -> bool:
        """O(1) adjacency query."""
        return v in self._adj[u]
    
    def neighbors(self, v: int) -> Set[int]:
        """Return neighbors of v."""
        return self._adj[v]
    
    def degree(self, v: int) -> int:
        return len(self._adj[v])
    
    @property
    def edges(self) -> List[Tuple[int, int]]:
        if self._edges is None:
            self._edges = []
            for u in range(self.n):
                for v in self._adj[u]:
                    if u < v:
                        self._edges.append((u, v))
        return self._edges
    
    @property
    def num_edges(self) -> int:
        return len(self.edges)


# ─── Algorithm 1: Clique Enumeration ─────────────────────────────────

def enumerate_triangles(G: FiniteSimpleGraph) -> List[Tuple[int, int, int]]:
    """
    Enumerate all triangles (3-cliques) in G.
    
    Algorithm: For each edge (u,v) with u < v, iterate over
    common neighbors w > v.
    
    Time: O(|E| · d_max) where d_max is maximum degree.
    Space: O(|T|) for output.
    
    >>> G = FiniteSimpleGraph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)])
    >>> len(enumerate_triangles(G))
    4
    """
    triangles = []
    for u in range(G.n):
        nu = G.neighbors(u)
        for v in nu:
            if v > u:
                nv = G.neighbors(v)
                for w in nu & nv:
                    if w > v:
                        triangles.append((u, v, w))
    return triangles


def enumerate_four_cliques(G: FiniteSimpleGraph) -> List[Tuple[int, int, int, int]]:
    """
    Enumerate all 4-cliques in G.
    
    Algorithm: For each triangle (u,v,w), find vertices x > w
    adjacent to all three.
    
    Time: O(|T| · d_max).
    Space: O(|K₄|) for output.
    
    >>> G = FiniteSimpleGraph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)])
    >>> len(enumerate_four_cliques(G))
    1
    """
    four_cliques = []
    for u, v, w in enumerate_triangles(G):
        common = G.neighbors(u) & G.neighbors(v) & G.neighbors(w)
        for x in common:
            if x > w:
                four_cliques.append((u, v, w, x))
    return four_cliques


# ─── Algorithm 2: Connected Components ───────────────────────────────

def connected_components(G: FiniteSimpleGraph) -> int:
    """
    Count connected components via BFS.
    
    Time: O(|V| + |E|).
    Space: O(|V|).
    """
    visited = [False] * G.n
    count = 0
    for start in range(G.n):
        if not visited[start]:
            count += 1
            stack = [start]
            while stack:
                v = stack.pop()
                if not visited[v]:
                    visited[v] = True
                    for nb in G.neighbors(v):
                        if not visited[nb]:
                            stack.append(nb)
    return count


# ─── Algorithm 3: Full Invariant Computation ─────────────────────────

def compute_invariants(G: FiniteSimpleGraph) -> GraphInvariants:
    """
    Compute all clique complex invariants of G.
    
    This is the main computational entry point. Returns a complete
    set of invariants including the second Betti number.
    
    Time: O(|E| · d² + |T|² · |E|) — dominated by β₂ computation.
    Space: O(|T| · |E|) for boundary matrices.
    
    >>> G = FiniteSimpleGraph(6, [(0,2),(0,3),(0,4),(0,5),(1,2),(1,3),(1,4),(1,5),(2,4),(2,5),(3,4),(3,5)])
    >>> inv = compute_invariants(G)
    >>> inv.betti_2
    1
    """
    triangles = enumerate_triangles(G)
    four_cliques = enumerate_four_cliques(G)
    n_comp = connected_components(G)
    
    V = G.n
    E = G.num_edges
    T = len(triangles)
    K4 = len(four_cliques)
    
    cr = E - V + n_comp
    chi2 = V - E + T
    fs = chi2 - 1
    td = T - 4 * K4
    nts = (T - 2 * K4) / E if E > 0 else 0.0
    
    b2 = _compute_betti_2(G, triangles, four_cliques)
    
    return GraphInvariants(
        num_vertices=V, num_edges=E,
        num_triangles=T, num_four_cliques=K4,
        cycle_rank=cr, two_skeleton_euler=chi2,
        forcing_surplus=fs, betti_2=b2,
        tetrahedron_defect=td,
        normalized_triangle_surplus=nts
    )


def _compute_betti_2(
    G: FiniteSimpleGraph,
    triangles: List[Tuple[int, int, int]],
    four_cliques: List[Tuple[int, int, int, int]]
) -> int:
    """
    Compute β₂ of the clique complex via boundary matrix ranks over GF(2).
    
    β₂ = dim(ker ∂₂) - dim(im ∂₃)
       = (|T| - rank(∂₂)) - rank(∂₃)
    
    Time: O(|T|² · |E| + |K₄|² · |T|) for Gaussian elimination.
    """
    if not triangles:
        return 0
    
    edges = G.edges
    edge_idx = {}
    for i, (u, v) in enumerate(edges):
        edge_idx[(min(u,v), max(u,v))] = i
    
    tri_idx = {t: i for i, t in enumerate(triangles)}
    
    # ∂₂: C₂ → C₁
    d2 = np.zeros((len(edges), len(triangles)), dtype=np.int8)
    for j, (a, b, c) in enumerate(triangles):
        for u, v in [(a,b), (a,c), (b,c)]:
            key = (min(u,v), max(u,v))
            if key in edge_idx:
                d2[edge_idx[key], j] ^= 1
    
    # ∂₃: C₃ → C₂
    d3 = np.zeros((len(triangles), len(four_cliques)), dtype=np.int8)
    for j, (a, b, c, d) in enumerate(four_cliques):
        for face in [(a,b,c), (a,b,d), (a,c,d), (b,c,d)]:
            sf = tuple(sorted(face))
            if sf in tri_idx:
                d3[tri_idx[sf], j] ^= 1
    
    rank_d2 = _gf2_rank(d2)
    rank_d3 = _gf2_rank(d3) if four_cliques else 0
    
    return max(0, len(triangles) - rank_d2 - rank_d3)


def _gf2_rank(M: np.ndarray) -> int:
    """
    Compute rank of matrix M over GF(2) via Gaussian elimination.
    
    Time: O(rows · cols · min(rows, cols)).
    Space: O(rows · cols) for working copy.
    """
    M = M.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        M[[rank, pivot]] = M[[pivot, rank]]
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


# ─── Algorithm 4: Threshold Family Analysis ──────────────────────────

def build_semantic_graph(
    feature_sets: List[Set[int]],
    epsilon: int
) -> FiniteSimpleGraph:
    """
    Build semantic threshold graph at parameter epsilon.
    
    Two vertices are adjacent iff |A Δ B| ≤ epsilon.
    
    Time: O(|V|² · |F|) where |F| is average feature set size.
    """
    n = len(feature_sets)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            sd = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            if sd <= epsilon:
                edges.append((i, j))
    return FiniteSimpleGraph(n, edges)


def scan_threshold_family(
    feature_sets: List[Set[int]],
    epsilon_range: range
) -> List[PhaseClassification]:
    """
    Scan a threshold family and classify topological phases.
    
    Algorithm:
    1. For each threshold ε, build the semantic graph.
    2. Compute all clique complex invariants.
    3. Classify the topological phase.
    
    Time: O(|ε_range| · (|V|² + |T|² · |E|)).
    
    Returns list of PhaseClassification for each threshold.
    """
    results = []
    for eps in epsilon_range:
        G = build_semantic_graph(feature_sets, eps)
        inv = compute_invariants(G)
        
        if inv.num_edges == 0:
            phase = "ISOLATED"
        elif inv.cycle_rank == 0 and inv.num_triangles == 0:
            phase = "TREE"
        elif inv.cycle_rank > 0 and inv.num_triangles == 0:
            phase = "CYCLE"
        elif inv.betti_2 > 0:
            phase = "HIGHER_HOMOLOGY"
        elif inv.cycle_rank > 0 and inv.forcing_surplus > 0:
            phase = "FORCING_WINDOW"
        elif inv.cycle_rank > 0:
            phase = "TRIANGLE_RICH"
        else:
            phase = "SATURATED"
        
        results.append(PhaseClassification(eps, phase, inv))
    
    return results


def detect_homology_windows(
    phases: List[PhaseClassification]
) -> List[HomologyWindow]:
    """
    Detect higher-homology windows in a phase scan.
    
    A window is a maximal contiguous band where either:
    - forcing_surplus > 0 and cycle_rank > 0, or
    - betti_2 > 0
    
    Returns list of HomologyWindow instances.
    """
    windows = []
    in_window = False
    start = None
    max_fs = 0
    max_b2 = 0
    
    for pc in phases:
        is_window = (
            (pc.invariants.cycle_rank > 0 and pc.invariants.forcing_surplus > 0) or
            pc.invariants.betti_2 > 0
        )
        
        if is_window and not in_window:
            in_window = True
            start = pc.threshold
            max_fs = pc.invariants.forcing_surplus
            max_b2 = pc.invariants.betti_2
        elif is_window and in_window:
            max_fs = max(max_fs, pc.invariants.forcing_surplus)
            max_b2 = max(max_b2, pc.invariants.betti_2)
        elif not is_window and in_window:
            windows.append(HomologyWindow(
                epsilon_low=start,
                epsilon_high=phases[phases.index(pc) - 1].threshold,
                max_forcing_surplus=max_fs,
                max_betti_2=max_b2,
                window_width=phases[phases.index(pc) - 1].threshold - start
            ))
            in_window = False
    
    if in_window:
        windows.append(HomologyWindow(
            epsilon_low=start,
            epsilon_high=phases[-1].threshold,
            max_forcing_surplus=max_fs,
            max_betti_2=max_b2,
            window_width=phases[-1].threshold - start
        ))
    
    return windows


# ─── Algorithm 5: Homological Complexity Profile ─────────────────────

def homological_complexity_profile(
    feature_sets: List[Set[int]],
    epsilon_range: range
) -> Dict[str, any]:
    """
    Compute the complete homological complexity profile of a theorem space.
    
    Returns a dictionary with:
    - 'phases': list of PhaseClassification
    - 'windows': list of HomologyWindow
    - 'max_cycle_rank': maximum β₁ across all thresholds
    - 'max_betti_2': maximum β₂ across all thresholds
    - 'complexity_class': "LOW", "MEDIUM", or "HIGH"
    - 'persistence_ratio': fraction of thresholds with positive cycle rank
    """
    phases = scan_threshold_family(feature_sets, epsilon_range)
    windows = detect_homology_windows(phases)
    
    max_cr = max(pc.invariants.cycle_rank for pc in phases)
    max_b2 = max(pc.invariants.betti_2 for pc in phases)
    persistence = sum(1 for pc in phases if pc.invariants.cycle_rank > 0) / len(phases)
    
    if max_b2 > 0:
        complexity = "HIGH"
    elif any(w.max_forcing_surplus > 0 for w in windows):
        complexity = "MEDIUM"
    else:
        complexity = "LOW"
    
    return {
        'phases': phases,
        'windows': windows,
        'max_cycle_rank': max_cr,
        'max_betti_2': max_b2,
        'complexity_class': complexity,
        'persistence_ratio': persistence,
    }


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATION")
    print("=" * 60)
    
    # Octahedron: known to have β₂ = 1
    oct_edges = [
        (0,2),(0,3),(0,4),(0,5),
        (1,2),(1,3),(1,4),(1,5),
        (2,4),(2,5),(3,4),(3,5)
    ]
    G = FiniteSimpleGraph(6, oct_edges)
    inv = compute_invariants(G)
    
    print(f"\nOctahedron graph:")
    print(f"  Vertices: {inv.num_vertices}")
    print(f"  Edges: {inv.num_edges}")
    print(f"  Triangles: {inv.num_triangles}")
    print(f"  4-cliques: {inv.num_four_cliques}")
    print(f"  Cycle rank (β₁ of graph): {inv.cycle_rank}")
    print(f"  2-skeleton Euler char: {inv.two_skeleton_euler}")
    print(f"  Forcing surplus: {inv.forcing_surplus}")
    print(f"  Second Betti number (β₂): {inv.betti_2}")
    print(f"  Tetrahedron defect: {inv.tetrahedron_defect}")
    
    # Threshold family analysis
    print("\n" + "=" * 60)
    print("THRESHOLD FAMILY ANALYSIS")
    print("=" * 60)
    
    features = [
        {0,1,2,3}, {1,2,3,4}, {2,3,4,5}, {3,4,5,6},
        {0,2,4,6}, {1,3,5,7}, {0,1,6,7}, {2,5,6,7}
    ]
    
    profile = homological_complexity_profile(features, range(0, 10))
    print(f"\nComplexity class: {profile['complexity_class']}")
    print(f"Max cycle rank: {profile['max_cycle_rank']}")
    print(f"Max β₂: {profile['max_betti_2']}")
    print(f"Persistence ratio: {profile['persistence_ratio']:.2f}")
    print(f"Homology windows: {len(profile['windows'])}")
    
    for w in profile['windows']:
        print(f"  Window [{w.epsilon_low}, {w.epsilon_high}]: "
              f"max FS={w.max_forcing_surplus}, max β₂={w.max_betti_2}")
