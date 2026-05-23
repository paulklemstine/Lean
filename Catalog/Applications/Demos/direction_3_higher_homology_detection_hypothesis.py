#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Higher-Homology Detection

Demonstrates applications of the topological phase transition theory to:
1. Theorem corpus analysis (detecting structural complexity in math libraries)
2. Knowledge graph topology (identifying higher-order dependencies)
3. Phase transition detection in random graph models
4. Falsifiable conjecture testing (octahedral forcing conjecture)
"""

import random
import numpy as np
from algorithms import (
    FiniteSimpleGraph, compute_invariants, enumerate_triangles,
    enumerate_four_cliques, build_semantic_graph, 
    homological_complexity_profile, scan_threshold_family
)


# ─── Application 1: Synthetic Theorem Corpus Analysis ────────────────

def analyze_theorem_corpus():
    """
    Analyze the topological structure of a synthetic theorem corpus.
    
    Models a mathematical library where theorems are characterized by
    which concepts/techniques they use (feature sets). The semantic
    threshold graph captures similarity structure.
    
    The homological complexity profile reveals:
    - Simple theories: tree-like dependency (β₁ = β₂ = 0)
    - Cyclic theories: circular dependencies (β₁ > 0, β₂ = 0)
    - Deep theories: higher-order structure (β₂ > 0)
    """
    print("=" * 70)
    print("APPLICATION 1: THEOREM CORPUS TOPOLOGY")
    print("=" * 70)
    print()
    
    # Simulate three mathematical domains with different complexity
    
    # Domain A: Linear chain (simple, tree-like)
    domain_a = [
        {0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5},
        {5, 6}, {6, 7}, {7, 8}, {8, 9}, {9, 10}
    ]
    
    # Domain B: Cyclic dependencies
    domain_b = [
        {0, 1, 2}, {1, 2, 3}, {2, 3, 4}, {3, 4, 5},
        {4, 5, 0}, {5, 0, 1}, {0, 3, 6}, {1, 4, 7},
        {2, 5, 8}, {3, 6, 9}
    ]
    
    # Domain C: Rich higher-order structure
    domain_c = [
        {0, 1, 2, 3}, {1, 2, 3, 4}, {2, 3, 4, 5},
        {3, 4, 5, 0}, {0, 2, 4, 6}, {1, 3, 5, 7},
        {0, 1, 4, 5}, {2, 3, 6, 7}, {0, 5, 6, 7},
        {1, 2, 6, 7}
    ]
    
    domains = [
        ("Linear Algebra (chain)", domain_a),
        ("Analysis (cyclic)", domain_b),
        ("Algebraic Topology (rich)", domain_c),
    ]
    
    for name, features in domains:
        profile = homological_complexity_profile(features, range(0, 12))
        print(f"Domain: {name}")
        print(f"  Theorems: {len(features)}")
        print(f"  Complexity class: {profile['complexity_class']}")
        print(f"  Max β₁: {profile['max_cycle_rank']}")
        print(f"  Max β₂: {profile['max_betti_2']}")
        print(f"  Cycle persistence: {profile['persistence_ratio']:.1%}")
        print(f"  Homology windows: {len(profile['windows'])}")
        for w in profile['windows']:
            print(f"    [{w.epsilon_low}, {w.epsilon_high}]: "
                  f"FS_max={w.max_forcing_surplus}, β₂_max={w.max_betti_2}")
        print()


# ─── Application 2: Phase Transition in Erdős–Rényi Graphs ──────────

def erdos_renyi_phase_transition():
    """
    Study the topological phase transition in Erdős–Rényi random graphs G(n,p).
    
    As p increases:
    1. Below p ~ 1/n: forest phase (β₁ = 0)
    2. Near p ~ 1/n: giant component forms, cycles appear (β₁ > 0)
    3. Higher p: triangles form, potential β₂ > 0
    4. Near p ~ 1: complete graph (all Betti numbers vanish)
    
    This is the random-graph analog of the theorem-space phase transition.
    """
    print("=" * 70)
    print("APPLICATION 2: ERDŐS–RÉNYI PHASE TRANSITION")
    print("=" * 70)
    print()
    
    n = 12
    random.seed(42)
    
    print(f"G({n}, p) random graphs — sweeping edge probability p")
    print()
    print(f"{'p':>6} | {'|E|':>4} | {'β₁':>4} | {'|T|':>4} | {'|K₄|':>4} | "
          f"{'χ₂':>4} | {'FS':>4} | {'β₂':>4} | Phase")
    print("-" * 72)
    
    for p_pct in range(0, 105, 5):
        p = p_pct / 100.0
        # Generate random graph
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    edges.append((i, j))
        
        G = FiniteSimpleGraph(n, edges)
        inv = compute_invariants(G)
        
        if inv.betti_2 > 0:
            phase = "★ β₂ > 0 ★"
        elif inv.forcing_surplus > 0 and inv.cycle_rank > 0:
            phase = "FORCING"
        elif inv.cycle_rank > 0:
            phase = "CYCLES"
        elif inv.num_edges == 0:
            phase = "EMPTY"
        else:
            phase = "ACYCLIC"
        
        print(f"{p:6.2f} | {inv.num_edges:4d} | {inv.cycle_rank:4d} | "
              f"{inv.num_triangles:4d} | {inv.num_four_cliques:4d} | "
              f"{inv.two_skeleton_euler:4d} | {inv.forcing_surplus:4d} | "
              f"{inv.betti_2:4d} | {phase}")
    print()


# ─── Application 3: Octahedral Forcing Conjecture Test ───────────────

def test_octahedral_forcing_conjecture():
    """
    Test the octahedral forcing conjecture:
    
    For graphs with β₁ > 0 and normalized triangle surplus 
    (|T| - 2|K₄|)/|E| > c for some constant c > 0,
    does β₂ > 0?
    
    We test this on random graphs and track counterexamples.
    """
    print("=" * 70)
    print("APPLICATION 3: OCTAHEDRAL FORCING CONJECTURE TEST")
    print("=" * 70)
    print()
    
    n = 10
    n_trials = 200
    random.seed(123)
    
    conjecture_holds = 0
    conjecture_vacuous = 0
    counterexamples = 0
    threshold_c = 0.3
    
    print(f"Testing: β₁ > 0 AND NTS > {threshold_c} ⟹ β₂ > 0")
    print(f"Graphs: G({n}, p) for random p, {n_trials} trials")
    print()
    
    for trial in range(n_trials):
        p = random.uniform(0.1, 0.9)
        edges = [(i, j) for i in range(n) for j in range(i+1, n)
                 if random.random() < p]
        G = FiniteSimpleGraph(n, edges)
        inv = compute_invariants(G)
        
        if inv.cycle_rank > 0 and inv.normalized_triangle_surplus > threshold_c:
            if inv.betti_2 > 0:
                conjecture_holds += 1
            else:
                counterexamples += 1
                if counterexamples <= 5:
                    print(f"  Counterexample #{counterexamples}: "
                          f"|E|={inv.num_edges}, β₁={inv.cycle_rank}, "
                          f"|T|={inv.num_triangles}, |K₄|={inv.num_four_cliques}, "
                          f"NTS={inv.normalized_triangle_surplus:.3f}, β₂={inv.betti_2}")
        else:
            conjecture_vacuous += 1
    
    print()
    print(f"Results:")
    print(f"  Hypothesis satisfied: {conjecture_holds + counterexamples}")
    print(f"  Conjecture holds: {conjecture_holds}")
    print(f"  Counterexamples: {counterexamples}")
    print(f"  Hypothesis not met: {conjecture_vacuous}")
    
    if counterexamples > 0:
        print(f"\n  ⚠ CONJECTURE REFUTED at threshold c = {threshold_c}")
        print(f"  The normalized triangle surplus alone is not sufficient")
        print(f"  to force β₂ > 0. Additional structural conditions are needed.")
    else:
        print(f"\n  ✓ Conjecture survived {n_trials} random trials at c = {threshold_c}")
    print()


# ─── Application 4: Specific Graph Families ─────────────────────────

def analyze_graph_families():
    """
    Analyze β₂ for specific graph families with known topology.
    """
    print("=" * 70)
    print("APPLICATION 4: GRAPH FAMILIES WITH KNOWN TOPOLOGY")
    print("=" * 70)
    print()
    
    families = []
    
    # 1. Octahedron (S²): β₂ = 1
    oct_edges = [
        (0,2),(0,3),(0,4),(0,5),
        (1,2),(1,3),(1,4),(1,5),
        (2,4),(2,5),(3,4),(3,5)
    ]
    families.append(("Octahedron (≅ S²)", 6, oct_edges, 1))
    
    # 2. Icosahedron (S²): β₂ = 1
    ico_edges = [
        (0,1),(0,2),(0,3),(0,4),(0,5),
        (1,2),(2,3),(3,4),(4,5),(5,1),
        (1,6),(2,6),(2,7),(3,7),(3,8),
        (4,8),(4,9),(5,9),(5,10),(1,10),
        (6,7),(7,8),(8,9),(9,10),(10,6),
        (6,11),(7,11),(8,11),(9,11),(10,11)
    ]
    families.append(("Icosahedron (≅ S²)", 12, ico_edges, 1))
    
    # 3. Complete bipartite K_{3,3}: β₂ = 0 (planar, cycle-rich but no 2-homology)
    k33_edges = [(i, 3+j) for i in range(3) for j in range(3)]
    families.append(("K_{3,3} (bipartite)", 6, k33_edges, 0))
    
    # 4. Path graph P₅: β₂ = 0, β₁ = 0
    path_edges = [(i, i+1) for i in range(4)]
    families.append(("Path P₅", 5, path_edges, 0))
    
    # 5. Cycle graph C₆: β₂ = 0, β₁ = 1
    cycle_edges = [(i, (i+1) % 6) for i in range(6)]
    families.append(("Cycle C₆", 6, cycle_edges, 0))
    
    print(f"{'Graph':<25} | {'|V|':>3} | {'|E|':>3} | {'|T|':>3} | "
          f"{'β₁':>3} | {'χ₂':>3} | {'FS':>3} | {'β₂':>3} | {'Expected':>8} | Match")
    print("-" * 90)
    
    for name, n, edges, expected_b2 in families:
        G = FiniteSimpleGraph(n, edges)
        inv = compute_invariants(G)
        match = "✓" if inv.betti_2 == expected_b2 else "✗"
        
        print(f"{name:<25} | {inv.num_vertices:3d} | {inv.num_edges:3d} | "
              f"{inv.num_triangles:3d} | {inv.cycle_rank:3d} | "
              f"{inv.two_skeleton_euler:3d} | {inv.forcing_surplus:3d} | "
              f"{inv.betti_2:3d} | {expected_b2:8d} | {match}")
    
    print()
    print("Note: β₂ is computed over GF(2) (mod 2 coefficients).")
    print("For orientable surfaces, this matches the integral β₂.")
    print()


if __name__ == "__main__":
    analyze_theorem_corpus()
    print()
    erdos_renyi_phase_transition()
    print()
    test_octahedral_forcing_conjecture()
    print()
    analyze_graph_families()


#!/usr/bin/env python3
"""
demo.py — Higher-Homology Detection in Theorem-Interaction Graphs

Demonstrates the topological phase transition from persistent 1-cycles
to emergent 2-dimensional homology in clique complexes of threshold
graph families.

Computes:
  - Graph cycle rank (β₁ of graph = cyclomatic number)
  - Triangle count (2-simplices in clique complex)
  - 4-clique count (3-simplices)
  - Forcing surplus = |V| - |E| + |T| - 1
  - Normalized triangle surplus
  - Second Betti number via boundary matrix rank

Visualizes the topological phase transition across threshold parameters.
"""

import itertools
import numpy as np
from collections import defaultdict

# ─── Core Graph Data Structure ────────────────────────────────────────

class SimpleGraph:
    """A finite simple graph on vertices {0, ..., n-1}."""
    
    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                if u != v:
                    self.adj[u].add(v)
                    self.adj[v].add(u)
    
    @property
    def vertices(self):
        return list(range(self.n))
    
    @property
    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v, u) not in seen:
                    seen.add((u, v))
        return list(seen)
    
    @property
    def num_vertices(self):
        return self.n
    
    @property
    def num_edges(self):
        return len(self.edges)


# ─── Clique Complex Invariants ────────────────────────────────────────

def find_triangles(G):
    """Find all triangles (3-cliques) in graph G."""
    triangles = []
    for u in range(G.n):
        for v in G.adj[u]:
            if v > u:
                for w in G.adj[u]:
                    if w > v and w in G.adj[v]:
                        triangles.append((u, v, w))
    return triangles

def find_four_cliques(G):
    """Find all 4-cliques in graph G."""
    four_cliques = []
    for u in range(G.n):
        for v in G.adj[u]:
            if v > u:
                for w in G.adj[u]:
                    if w > v and w in G.adj[v]:
                        for x in G.adj[u]:
                            if x > w and x in G.adj[v] and x in G.adj[w]:
                                four_cliques.append((u, v, w, x))
    return four_cliques

def triangle_count(G):
    return len(find_triangles(G))

def four_clique_count(G):
    return len(find_four_cliques(G))

def two_skeleton_euler(G):
    """χ₂ = |V| - |E| + |T|"""
    return G.num_vertices - G.num_edges + triangle_count(G)

def forcing_surplus(G):
    """forcingSurplus = χ₂ - 1 = |V| - |E| + |T| - 1"""
    return two_skeleton_euler(G) - 1

def graph_cycle_rank(G):
    """Cyclomatic number = |E| - |V| + c (connected components)."""
    visited = [False] * G.n
    components = 0
    for start in range(G.n):
        if not visited[start]:
            components += 1
            stack = [start]
            while stack:
                node = stack.pop()
                if not visited[node]:
                    visited[node] = True
                    for nb in G.adj[node]:
                        if not visited[nb]:
                            stack.append(nb)
    return G.num_edges - G.num_vertices + components

def normalized_triangle_surplus(G):
    """(|T| - 2|K₄|) / |E|"""
    E = G.num_edges
    if E == 0:
        return 0.0
    T = triangle_count(G)
    K4 = four_clique_count(G)
    return (T - 2 * K4) / E

def tetrahedron_defect(G):
    """|T| - 4|K₄|"""
    return triangle_count(G) - 4 * four_clique_count(G)


# ─── Second Betti Number via Boundary Matrices ───────────────────────

def compute_betti_2(G):
    """
    Compute β₂ of the clique complex of G using boundary matrix ranks.
    
    For the clique complex:
      ∂₂: C₂ → C₁ maps triangles to edges
      ∂₃: C₃ → C₂ maps tetrahedra to triangles
    
    β₂ = dim(ker ∂₂) - dim(im ∂₃)
       = (|T| - rank(∂₂)) - rank(∂₃)
    """
    triangles = find_triangles(G)
    four_cliques = find_four_cliques(G)
    edges = G.edges
    
    if not triangles:
        return 0
    
    # Build edge index
    edge_idx = {}
    for i, (u, v) in enumerate(edges):
        edge_idx[(u, v)] = i
        edge_idx[(v, u)] = i
    
    # Build triangle index
    tri_idx = {t: i for i, t in enumerate(triangles)}
    
    # ∂₂ matrix: edges × triangles (over Z₂ for simplicity)
    d2 = np.zeros((len(edges), len(triangles)), dtype=int)
    for j, (a, b, c) in enumerate(triangles):
        for u, v in [(a, b), (a, c), (b, c)]:
            if (u, v) in edge_idx:
                d2[edge_idx[(u, v)], j] = 1
    
    # ∂₃ matrix: triangles × 4-cliques (over Z₂)
    d3 = np.zeros((len(triangles), len(four_cliques)), dtype=int)
    for j, (a, b, c, d) in enumerate(four_cliques):
        faces = [(a, b, c), (a, b, d), (a, c, d), (b, c, d)]
        for face in faces:
            sf = tuple(sorted(face))
            if sf in tri_idx:
                d3[tri_idx[sf], j] = 1
    
    # Compute ranks over Z₂ (mod 2)
    rank_d2 = _z2_rank(d2 % 2)
    rank_d3 = _z2_rank(d3 % 2) if four_cliques else 0
    
    beta2 = len(triangles) - rank_d2 - rank_d3
    return max(0, beta2)

def _z2_rank(M):
    """Compute rank of matrix M over GF(2) via Gaussian elimination."""
    M = M.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        M[[rank, pivot]] = M[[pivot, rank]]
        # Eliminate
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


# ─── Semantic Feature Space ──────────────────────────────────────────

def symm_diff_card(A, B):
    """Cardinality of symmetric difference of two sets."""
    return len(A.symmetric_difference(B))

def semantic_graph(feature_sets, epsilon):
    """Build threshold graph: adjacent if symm_diff_card ≤ epsilon."""
    n = len(feature_sets)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if symm_diff_card(feature_sets[i], feature_sets[j]) <= epsilon:
                edges.append((i, j))
    return SimpleGraph(n, edges)


# ─── Demo: Topological Phase Transition ──────────────────────────────

def demo_phase_transition():
    """
    Demonstrate topological phase transition in a theorem-interaction graph.
    
    We create a synthetic theorem space with feature sets that exhibit
    clustering, then sweep the threshold parameter to observe:
    1. Fragmented phase (low ε): disconnected, β₁ = 0
    2. Cycle phase (medium ε): connected with cycles, β₁ > 0
    3. Higher-homology phase (high ε): β₂ > 0 emerges
    4. Collapse phase (very high ε): complete graph, β₁ = β₂ = 0
    """
    print("=" * 70)
    print("TOPOLOGICAL PHASE TRANSITION IN THEOREM-INTERACTION GRAPHS")
    print("=" * 70)
    print()
    
    # Create synthetic theorem space: 8 theorems with overlapping features
    np.random.seed(42)
    n_theorems = 8
    n_features = 12
    
    # Design feature sets with controlled overlap structure
    feature_sets = [
        {0, 1, 2, 3, 4},        # Theorem 0: core algebra
        {1, 2, 3, 5, 6},        # Theorem 1: algebra + analysis
        {2, 3, 4, 6, 7},        # Theorem 2: algebra + topology
        {3, 4, 5, 7, 8},        # Theorem 3: mixed
        {5, 6, 7, 8, 9},        # Theorem 4: analysis core
        {6, 7, 8, 9, 10},       # Theorem 5: analysis + number theory
        {7, 8, 9, 10, 11},      # Theorem 6: number theory
        {0, 4, 8, 9, 11},       # Theorem 7: cross-domain bridge
    ]
    
    print(f"Theorem space: {n_theorems} theorems, {n_features} features")
    print(f"Feature sets designed with overlapping cluster structure")
    print()
    
    # Sweep threshold parameter
    print(f"{'ε':>3} | {'|E|':>4} | {'β₁(G)':>6} | {'|T|':>4} | {'|K₄|':>4} | "
          f"{'χ₂':>4} | {'FS':>4} | {'β₂':>4} | {'NTS':>6} | Phase")
    print("-" * 80)
    
    for eps in range(0, 12):
        G = semantic_graph(feature_sets, eps)
        
        cr = graph_cycle_rank(G)
        tc = triangle_count(G)
        fc = four_clique_count(G)
        chi2 = two_skeleton_euler(G)
        fs = forcing_surplus(G)
        b2 = compute_betti_2(G)
        nts = normalized_triangle_surplus(G)
        
        # Classify phase
        if cr == 0 and tc == 0:
            if G.num_edges == 0:
                phase = "ISOLATED"
            else:
                phase = "TREE-LIKE"
        elif cr > 0 and tc == 0:
            phase = "CYCLE (1D)"
        elif cr > 0 and tc > 0 and b2 == 0:
            phase = "TRIANGLE-RICH"
        elif b2 > 0:
            phase = "★ HIGHER-HOMOLOGY ★"
        elif cr == 0 and tc > 0:
            phase = "SATURATED"
        else:
            phase = "MIXED"
        
        print(f"{eps:3d} | {G.num_edges:4d} | {cr:6d} | {tc:4d} | {fc:4d} | "
              f"{chi2:4d} | {fs:4d} | {b2:4d} | {nts:6.3f} | {phase}")
    
    print()
    print("Legend:")
    print("  ε = threshold parameter")
    print("  |E| = edge count")
    print("  β₁(G) = graph cycle rank (cyclomatic number)")
    print("  |T| = triangle count (2-simplices)")
    print("  |K₄| = 4-clique count (3-simplices)")
    print("  χ₂ = 2-skeleton Euler characteristic = |V| - |E| + |T|")
    print("  FS = forcing surplus = χ₂ - 1")
    print("  β₂ = second Betti number (computed via boundary matrices)")
    print("  NTS = normalized triangle surplus = (|T| - 2|K₄|)/|E|")
    print()


def demo_euler_surplus_theorem():
    """
    Demonstrate the Euler surplus theorem:
    For connected graphs with no 4-cliques, if χ₂ > 1 then β₂ > 0.
    """
    print("=" * 70)
    print("EULER SURPLUS THEOREM VERIFICATION")
    print("=" * 70)
    print()
    print("Theorem: For a connected graph G with no 4-cliques,")
    print("  if |V| - |E| + |T| > 1, then β₂(Cl(G)) > 0.")
    print()
    
    # Example 1: Octahedron graph (K_{2,2,2})
    # 6 vertices, 12 edges, 8 triangles, 0 four-cliques
    # χ₂ = 6 - 12 + 8 = 2 > 1, so β₂ > 0
    edges_oct = [
        (0,2),(0,3),(0,4),(0,5),
        (1,2),(1,3),(1,4),(1,5),
        (2,4),(2,5),(3,4),(3,5)
    ]
    G_oct = SimpleGraph(6, edges_oct)
    
    print("Example 1: Octahedron graph (6 vertices)")
    print(f"  |V| = {G_oct.num_vertices}, |E| = {G_oct.num_edges}, "
          f"|T| = {triangle_count(G_oct)}, |K₄| = {four_clique_count(G_oct)}")
    print(f"  χ₂ = {two_skeleton_euler(G_oct)}, FS = {forcing_surplus(G_oct)}")
    print(f"  β₂ = {compute_betti_2(G_oct)}")
    print(f"  Theorem applies: FS > 0 → β₂ > 0 ✓" if forcing_surplus(G_oct) > 0 and compute_betti_2(G_oct) > 0 else "")
    print()
    
    # Example 2: Triangulated torus (minimal)
    # 7 vertices, 21 edges, 14 triangles
    # This has β₂ = 1 (torus has H₂ = Z)
    # We use the Heawood-style triangulation
    edges_torus = [
        (0,1),(0,2),(0,3),(0,4),(0,5),(0,6),
        (1,2),(1,3),(1,4),(1,5),(1,6),
        (2,3),(2,4),(2,5),(2,6),
        (3,4),(3,5),(3,6),
        (4,5),(4,6),
        (5,6)
    ]
    G_torus = SimpleGraph(7, edges_torus)
    
    print("Example 2: Complete graph K₇ (7 vertices)")
    tc = triangle_count(G_torus)
    fc = four_clique_count(G_torus)
    print(f"  |V| = {G_torus.num_vertices}, |E| = {G_torus.num_edges}, "
          f"|T| = {tc}, |K₄| = {fc}")
    print(f"  χ₂ = {two_skeleton_euler(G_torus)}, FS = {forcing_surplus(G_torus)}")
    print(f"  β₂ = {compute_betti_2(G_torus)}")
    if fc > 0:
        print(f"  Note: has {fc} four-cliques, so full theorem needs ∂₃ analysis")
    print()
    
    # Example 3: Cycle of triangles with shared edges forming a closed surface
    # Build a triangulated sphere-like structure
    # Icosahedron: 12 vertices, 30 edges, 20 triangles, 0 four-cliques
    # χ₂ = 12 - 30 + 20 = 2, β₂ = 1
    edges_ico = [
        (0,1),(0,2),(0,3),(0,4),(0,5),
        (1,2),(2,3),(3,4),(4,5),(5,1),
        (1,6),(2,6),(2,7),(3,7),(3,8),
        (4,8),(4,9),(5,9),(5,10),(1,10),
        (6,7),(7,8),(8,9),(9,10),(10,6),
        (6,11),(7,11),(8,11),(9,11),(10,11)
    ]
    G_ico = SimpleGraph(12, edges_ico)
    
    print("Example 3: Icosahedron (12 vertices)")
    print(f"  |V| = {G_ico.num_vertices}, |E| = {G_ico.num_edges}, "
          f"|T| = {triangle_count(G_ico)}, |K₄| = {four_clique_count(G_ico)}")
    print(f"  χ₂ = {two_skeleton_euler(G_ico)}, FS = {forcing_surplus(G_ico)}")
    print(f"  β₂ = {compute_betti_2(G_ico)}")
    print(f"  Theorem applies: FS > 0 → β₂ > 0 ✓" if forcing_surplus(G_ico) > 0 and compute_betti_2(G_ico) > 0 else "")
    print()


def demo_forcing_invariant():
    """
    Demonstrate the forcing invariant as a topological complexity measure
    for theorem corpora.
    """
    print("=" * 70)
    print("HOMOLOGICAL COMPLEXITY PROFILE")
    print("=" * 70)
    print()
    print("Computing the homological complexity profile for three")
    print("synthetic mathematical domains:")
    print()
    
    domains = {
        "Linear Algebra": [
            {0,1,2,3}, {1,2,3,4}, {2,3,4,5}, {3,4,5,6},
            {0,2,4,6}, {1,3,5,7}, {0,1,6,7}, {2,5,6,7}
        ],
        "Number Theory": [
            {0,1,2}, {1,2,3}, {2,3,4}, {3,4,5},
            {4,5,6}, {5,6,7}, {6,7,0}, {7,0,1}
        ],
        "Algebraic Topology": [
            {0,1,2,3,4}, {1,2,3,4,5}, {2,3,4,5,6}, {3,4,5,6,7},
            {4,5,6,7,8}, {0,1,5,6,7}, {0,2,4,7,8}, {1,3,6,8,0}
        ],
    }
    
    for domain_name, features in domains.items():
        print(f"Domain: {domain_name} ({len(features)} theorems)")
        print(f"  {'ε':>3} | {'β₁(G)':>6} | {'|T|':>4} | {'FS':>4} | {'β₂':>4} | Assessment")
        print(f"  " + "-" * 55)
        
        max_fs = -999
        max_b2 = 0
        for eps in range(0, 10):
            G = semantic_graph(features, eps)
            cr = graph_cycle_rank(G)
            tc = triangle_count(G)
            fs = forcing_surplus(G)
            b2 = compute_betti_2(G)
            max_fs = max(max_fs, fs)
            max_b2 = max(max_b2, b2)
            
            assessment = ""
            if cr > 0 and fs > 0:
                assessment = "← HIGHER-HOMOLOGY WINDOW"
            elif cr > 0:
                assessment = "← cycle phase"
            
            print(f"  {eps:3d} | {cr:6d} | {tc:4d} | {fs:4d} | {b2:4d} | {assessment}")
        
        complexity = "HIGH" if max_b2 > 0 else ("MEDIUM" if max_fs > 0 else "LOW")
        print(f"  Homological complexity: {complexity}")
        print()


def demo_four_clique_triangle_theorem():
    """Demonstrate: every 4-clique contributes exactly 4 triangles."""
    print("=" * 70)
    print("FOUR-CLIQUE TRIANGLE THEOREM")
    print("=" * 70)
    print()
    print("Theorem: Every 4-clique contributes exactly C(4,3) = 4 triangles.")
    print()
    
    # Build K₄
    G = SimpleGraph(4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)])
    tris = find_triangles(G)
    fours = find_four_cliques(G)
    
    print(f"K₄ (complete graph on 4 vertices):")
    print(f"  Edges: {G.edges}")
    print(f"  Triangles: {tris}")
    print(f"  4-cliques: {fours}")
    print(f"  |T| = {len(tris)}, |K₄| = {len(fours)}")
    print(f"  Ratio |T|/|K₄| = {len(tris)/max(1,len(fours))}")
    print()
    
    # Build K₅ (two overlapping K₄'s share triangles)
    G5 = SimpleGraph(5, [(i,j) for i in range(5) for j in range(i+1,5)])
    tris5 = find_triangles(G5)
    fours5 = find_four_cliques(G5)
    
    print(f"K₅ (complete graph on 5 vertices):")
    print(f"  |T| = {len(tris5)}, |K₄| = {len(fours5)}")
    print(f"  Each K₄ has 4 triangles, but triangles are shared between K₄'s")
    print(f"  Tetrahedron defect = |T| - 4|K₄| = {len(tris5) - 4*len(fours5)}")
    print()


if __name__ == "__main__":
    demo_phase_transition()
    print()
    demo_euler_surplus_theorem()
    print()
    demo_forcing_invariant()
    print()
    demo_four_clique_triangle_theorem()
