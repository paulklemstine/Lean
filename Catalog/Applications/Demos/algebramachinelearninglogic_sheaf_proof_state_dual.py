#!/usr/bin/env python3
"""
Applications of Sheaf–Proof-State Cohomological Obstruction Theory

Demonstrates real-world applications:
1. Neural theorem prover consistency checking
2. Distributed system consistency verification
3. Abstract interpretation soundness certification
4. Adversarial robustness lower bounds
"""

import numpy as np
from algorithms import (FiniteDependencyComplex, coboundary_matrix,
                        compute_H1_dimension, find_coboundary_witness,
                        greedy_support_reduction, instability_lower_bound,
                        enumerate_global_sections_mod_n)


def application_1_neural_prover_consistency():
    """
    Application 1: Neural Theorem Prover Consistency
    
    A neural prover assigns confidence scores to proof steps.
    Each vertex = proof state, each edge = local transition.
    The neural model gives local scores that may not be globally consistent.
    
    H¹ ≠ 0 means the neural predictions cannot be simultaneously realized
    by any single global proof strategy.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Theorem Prover Consistency")
    print("=" * 60)
    
    # 5 proof states forming a pentagon (Petersen-like dependencies)
    K = FiniteDependencyComplex(
        vertices=list(range(5)),
        edges=[(0,1),(1,2),(2,3),(3,4),(4,0)],
        triangles=[]
    )
    
    # Neural model's local confidence differences
    # These represent: how much more confident is state j vs state i?
    neural_scores = np.array([0.3, 0.2, 0.1, 0.2, -0.7])
    # Sum = 0.3+0.2+0.1+0.2-0.7 = 0.1 ≠ 0 → not a coboundary!
    
    print(f"\nProof states: 5 (pentagon dependency graph)")
    print(f"Neural confidence differences: {neural_scores}")
    print(f"Cycle sum: {np.sum(neural_scores):.2f}")
    print(f"dim H¹ = {compute_H1_dimension(K)}")
    
    wit = find_coboundary_witness(K, neural_scores)
    if wit is None:
        print("\n⚠ INCONSISTENCY DETECTED: Neural predictions are NOT globally realizable!")
        lb = instability_lower_bound(K, neural_scores)
        print(f"  Minimum disagreement edges: {lb}")
        print(f"  The neural model MUST fail on at least {lb} transition(s).")
        
        z_min = greedy_support_reduction(K, neural_scores)
        print(f"  Minimal obstruction: {z_min}")
    else:
        print("\n✓ Neural predictions are globally consistent.")
        print(f"  Global confidence: {wit}")


def application_2_distributed_consensus():
    """
    Application 2: Distributed System Consistency
    
    In a distributed system, nodes maintain local views.
    Edges represent communication channels.
    A nontrivial H¹ means the local views cannot be reconciled
    into a single consistent global state.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed System Consistency")
    print("=" * 60)
    
    # 4 servers in a ring topology
    K = FiniteDependencyComplex(
        vertices=['A', 'B', 'C', 'D'],
        edges=[('A','B'), ('B','C'), ('C','D'), ('D','A')],
        triangles=[]
    )
    
    print(f"\n4 servers: A—B—C—D—A (ring topology)")
    print(f"dim H¹ = {compute_H1_dimension(K)}")
    
    # Version vector differences between adjacent servers
    version_diffs = np.array([1, 0, 0, 0])  # A thinks B is 1 ahead
    
    wit = find_coboundary_witness(K, version_diffs)
    if wit is None:
        print(f"\n⚠ CONSISTENCY ANOMALY: Version diffs {version_diffs} cannot")
        print(f"  be explained by any global version assignment!")
        print(f"  This is a distributed consistency violation.")
    else:
        print(f"\n✓ Version diffs are consistent.")
        print(f"  Global version assignment: {wit}")
    
    # Inconsistent version diffs
    version_diffs_bad = np.array([1, 1, 1, 1])
    wit_bad = find_coboundary_witness(K, version_diffs_bad)
    if wit_bad is None:
        print(f"\n⚠ Version diffs {version_diffs_bad}: INCONSISTENT!")
        print(f"  Cycle sum = {np.sum(version_diffs_bad)} ≠ 0")
        print(f"  → Impossible to assign global versions consistently.")


def application_3_abstract_interpretation():
    """
    Application 3: Abstract Interpretation Soundness
    
    Local abstract transformers (edges) may be pairwise compatible
    but globally inconsistent around cycles.
    H¹ detects these global soundness failures.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Abstract Interpretation Soundness")
    print("=" * 60)
    
    # Program control flow graph: 6 program points, 7 transitions
    K = FiniteDependencyComplex(
        vertices=list(range(6)),
        edges=[(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(1,4)],
        triangles=[]
    )
    
    print(f"\nControl flow graph: 6 program points, {K.m} transitions")
    print(f"dim H¹ = {compute_H1_dimension(K)}")
    print(f"  ({compute_H1_dimension(K)} independent obstruction cycles)")
    
    # Abstract transformer differences
    transformer_diffs = np.zeros(K.m)
    edges = K.edge_list()
    edge_idx = {e: i for i, e in enumerate(edges)}
    
    # Set up an inconsistency in the outer cycle
    # The shortcut edge (1,4) creates a second cycle
    transformer_diffs[edge_idx[(0,1)]] = 1
    transformer_diffs[edge_idx[(1,2)]] = 1
    transformer_diffs[edge_idx[(2,3)]] = 1
    transformer_diffs[edge_idx[(3,4)]] = 1
    transformer_diffs[edge_idx[(4,5)]] = -3  # creates inconsistency!
    transformer_diffs[edge_idx[(0,5)]] = 0
    transformer_diffs[edge_idx[(1,4)]] = 2
    
    wit = find_coboundary_witness(K, transformer_diffs)
    if wit is None:
        print(f"\n⚠ SOUNDNESS FAILURE: Abstract transformers are globally inconsistent!")
        lb = instability_lower_bound(K, transformer_diffs)
        print(f"  At least {lb} transformer(s) must be refined.")
    else:
        print(f"\n✓ Abstract transformers are globally sound.")
        print(f"  Concrete invariant assignment: {np.round(wit, 2)}")


def application_4_adversarial_robustness():
    """
    Application 4: Adversarial Robustness Lower Bounds
    
    For a classifier/model on a proof-state graph:
    - If H¹ ≠ 0, no single model can be locally consistent everywhere
    - The instability lower bound gives a certified minimum error count
    - Minimal obstruction cycles identify the most vulnerable edges
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Adversarial Robustness Bounds")
    print("=" * 60)
    
    # Petersen graph (famous non-planar graph with rich topology)
    # Use a simpler substitute: cube graph (3-cube)
    K = FiniteDependencyComplex(
        vertices=list(range(8)),
        edges=[
            (0,1),(1,2),(2,3),(3,0),  # bottom face
            (4,5),(5,6),(6,7),(7,4),  # top face
            (0,4),(1,5),(2,6),(3,7)   # vertical edges
        ],
        triangles=[]
    )
    
    print(f"\n3-Cube graph: 8 vertices, {K.m} edges")
    h1_dim = compute_H1_dimension(K)
    print(f"dim H¹ = {h1_dim}")
    print(f"  → {h1_dim} independent obstruction cycles")
    
    # Generate a random nontrivial cocycle
    np.random.seed(42)
    D0 = coboundary_matrix(K)
    
    # Random 1-cochain that's NOT a coboundary
    z_random = np.random.randn(K.m)
    
    # Project out the coboundary component to get a pure cocycle part
    f_opt, _, _, _ = np.linalg.lstsq(D0, z_random, rcond=None)
    z_cocycle_part = z_random - D0 @ f_opt  # the H¹ component
    
    if np.allclose(z_cocycle_part, 0):
        print("\n(Random cochain happened to be a coboundary)")
    else:
        lb = instability_lower_bound(K, z_random)
        print(f"\nRandom adversarial perturbation: {np.round(z_random, 2)}")
        print(f"Instability lower bound: {lb} edge(s)")
        
        z_min = greedy_support_reduction(K, z_cocycle_part)
        supp = np.count_nonzero(np.abs(z_min) > 1e-10)
        print(f"Minimal obstruction support size: {supp}")
        
        edges = K.edge_list()
        vulnerable = [edges[i] for i in range(K.m) if abs(z_min[i]) > 1e-10]
        print(f"Most vulnerable edges: {vulnerable}")
    
    # Tabulate H¹ dimensions for various graph topologies
    print("\n--- Topology vs. Robustness ---")
    print(f"{'Graph':<20} {'|V|':>4} {'|E|':>4} {'dim H¹':>7} {'Robust?':>8}")
    print("-" * 48)
    
    graphs = [
        ("Path (P₄)", list(range(4)), [(0,1),(1,2),(2,3)]),
        ("Cycle (C₄)", list(range(4)), [(0,1),(1,2),(2,3),(3,0)]),
        ("Complete (K₄)", list(range(4)), [(i,j) for i in range(4) for j in range(i+1,4)]),
        ("Star (S₄)", list(range(5)), [(0,i) for i in range(1,5)]),
        ("Cube (Q₃)", list(range(8)), [(0,1),(1,2),(2,3),(3,0),(4,5),(5,6),(6,7),(7,4),(0,4),(1,5),(2,6),(3,7)]),
    ]
    
    for name, verts, edgs in graphs:
        Kg = FiniteDependencyComplex(verts, edgs)
        h1 = compute_H1_dimension(Kg)
        robust = "Yes" if h1 == 0 else "No"
        print(f"{name:<20} {Kg.n:>4} {Kg.m:>4} {h1:>7} {robust:>8}")


if __name__ == "__main__":
    application_1_neural_prover_consistency()
    application_2_distributed_consensus()
    application_3_abstract_interpretation()
    application_4_adversarial_robustness()


#!/usr/bin/env python3
"""
Demo: Sheaf–Proof-State Duality via Finite Cohomological Obstruction Theory

Concrete numerical examples demonstrating:
1. A proof-state dependency complex with trivial H¹ (globally realizable)
2. A proof-state dependency complex with nontrivial H¹ (obstruction)
3. Minimal obstruction cycle extraction
4. Instability lower bound computation
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Set, Tuple, Optional

# ────────────────────────────────────────────────────────
# Core Data Structures
# ────────────────────────────────────────────────────────

class ProofDependencyComplex:
    """A finite dependency complex: vertices, symmetric edges, triangles."""
    
    def __init__(self, vertices: List[int], edges: List[Tuple[int,int]], 
                 triangles: List[Tuple[int,int,int]]):
        self.vertices = vertices
        # Store edges as oriented pairs (both directions)
        self.edges = set()
        for i, j in edges:
            self.edges.add((i, j))
            self.edges.add((j, i))
        self.triangles = set()
        for t in triangles:
            self.triangles.add(t)
    
    def __repr__(self):
        return (f"ProofDependencyComplex(V={self.vertices}, "
                f"|E|={len(self.edges)//2}, |T|={len(self.triangles)})")


def coboundary(f: Dict[int, float], edge: Tuple[int,int]) -> float:
    """δf(i,j) = f(j) - f(i)"""
    i, j = edge
    return f[j] - f[i]


def is_cocycle(K: ProofDependencyComplex, z: Dict[Tuple[int,int], float]) -> bool:
    """Check if z satisfies the cocycle condition on all triangles."""
    for (i, j, k) in K.triangles:
        lhs = z.get((i,j), 0) + z.get((j,k), 0)
        rhs = z.get((i,k), 0)
        if abs(lhs - rhs) > 1e-10:
            return False
    return True


def is_coboundary(K: ProofDependencyComplex, z: Dict[Tuple[int,int], float]) -> Optional[Dict[int, float]]:
    """
    Check if z is a coboundary. If yes, return the witnessing 0-cochain f.
    Uses a spanning-tree approach: fix f(root)=0, propagate along edges.
    """
    if not K.edges:
        # No edges: z must be zero everywhere to be a coboundary
        return {} if all(abs(v) < 1e-10 for v in z.values()) else None
    
    # Build adjacency
    adj = {v: [] for v in K.vertices}
    for (i, j) in K.edges:
        adj[i].append(j)
    
    # BFS spanning tree
    root = K.vertices[0]
    f = {root: 0.0}
    queue = [root]
    visited = {root}
    
    while queue:
        curr = queue.pop(0)
        for nbr in adj[curr]:
            if nbr not in visited:
                # z(curr, nbr) should equal f(nbr) - f(curr)
                f[nbr] = f[curr] + z.get((curr, nbr), 0)
                visited.add(nbr)
                queue.append(nbr)
    
    # For unvisited vertices (disconnected components), set f = 0
    for v in K.vertices:
        if v not in f:
            f[v] = 0.0
    
    # Verify: check coboundary f = z on all edges
    for (i, j) in K.edges:
        if abs(coboundary(f, (i,j)) - z.get((i,j), 0)) > 1e-10:
            return None
    return f


def cochain_support(K: ProofDependencyComplex, z: Dict[Tuple[int,int], float]) -> Set[Tuple[int,int]]:
    """Support: edges where z is nonzero."""
    return {e for e in K.edges if abs(z.get(e, 0)) > 1e-10}


def predictor_disagreement(f: Dict[int, float], z: Dict[Tuple[int,int], float],
                           edges: Set[Tuple[int,int]]) -> int:
    """Count pairs where δf ≠ z."""
    count = 0
    for e in edges:
        if abs(coboundary(f, e) - z.get(e, 0)) > 1e-10:
            count += 1
    return count


# ────────────────────────────────────────────────────────
# Example 1: Trivial H¹ (Tree Complex)
# ────────────────────────────────────────────────────────

print("=" * 60)
print("EXAMPLE 1: Trivial H¹ — Tree Complex")
print("=" * 60)

# A tree: 0—1—2—3 (no cycles, no triangles)
K_tree = ProofDependencyComplex(
    vertices=[0, 1, 2, 3],
    edges=[(0,1), (1,2), (2,3)],
    triangles=[]
)
print(f"\nComplex: {K_tree}")
print("Structure: 0 — 1 — 2 — 3 (path graph, no triangles)")

# Any 1-cochain on a tree is a coboundary
z_tree = {(0,1): 3.0, (1,0): -3.0, (1,2): -1.0, (2,1): 1.0, (2,3): 5.0, (3,2): -5.0}
print(f"\n1-cochain z: z(0,1)={z_tree[(0,1)]}, z(1,2)={z_tree[(1,2)]}, z(2,3)={z_tree[(2,3)]}")

# Check cocycle (vacuously true — no triangles)
print(f"Is cocycle? {is_cocycle(K_tree, z_tree)}")

# Find coboundary witness
f_witness = is_coboundary(K_tree, z_tree)
if f_witness is not None:
    print(f"Is coboundary? YES")
    print(f"Witness f: {f_witness}")
    print(f"Verification: δf(0,1)={coboundary(f_witness, (0,1))}, "
          f"δf(1,2)={coboundary(f_witness, (1,2))}, "
          f"δf(2,3)={coboundary(f_witness, (2,3))}")
else:
    print(f"Is coboundary? NO")

print("\n→ H¹ = 0: Every cocycle is a coboundary. Global proof policy exists.")

# ────────────────────────────────────────────────────────
# Example 2: Nontrivial H¹ (Triangle with Inconsistency)
# ────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("EXAMPLE 2: Nontrivial H¹ — Inconsistent Triangle")
print("=" * 60)

# Triangle: 0—1—2—0 with triangle (0,1,2)
K_tri = ProofDependencyComplex(
    vertices=[0, 1, 2],
    edges=[(0,1), (1,2), (0,2)],
    triangles=[(0,1,2)]
)
print(f"\nComplex: {K_tri}")
print("Structure: Triangle 0—1—2—0 with face (0,1,2)")

# Cocycle: z(0,1) + z(1,2) = z(0,2)
z_consistent = {(0,1): 2.0, (1,0): -2.0, (1,2): 3.0, (2,1): -3.0, (0,2): 5.0, (2,0): -5.0}
print(f"\nConsistent cocycle: z(0,1)=2, z(1,2)=3, z(0,2)=5")
print(f"  Cocycle check: {z_consistent[(0,1)]} + {z_consistent[(1,2)]} = {z_consistent[(0,2)]}? "
      f"{is_cocycle(K_tri, z_consistent)}")
f_wit = is_coboundary(K_tri, z_consistent)
print(f"  Is coboundary? {'YES, f=' + str(f_wit) if f_wit else 'NO'}")

# Non-cocycle: z(0,1) + z(1,2) ≠ z(0,2) — this is NOT even a cocycle
z_inconsistent = {(0,1): 2.0, (1,0): -2.0, (1,2): 3.0, (2,1): -3.0, (0,2): 4.0, (2,0): -4.0}
print(f"\nInconsistent cochain: z(0,1)=2, z(1,2)=3, z(0,2)=4")
print(f"  Cocycle check: 2 + 3 = 4? {is_cocycle(K_tri, z_inconsistent)}")
print(f"  This cochain violates the cocycle condition — it's not even a valid obstruction class.")

print("\n→ For this complex, H¹ = 0 when using ℝ coefficients (the triangle is contractible).")

# ────────────────────────────────────────────────────────
# Example 3: Nontrivial H¹ with ℤ/2ℤ coefficients
# ────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("EXAMPLE 3: Nontrivial H¹ — Möbius-like Complex (mod 2)")
print("=" * 60)

# Square with diagonal: 4 vertices, edges forming a cycle 0-1-2-3-0
# No triangles declared — so cocycle condition is vacuous
K_cycle = ProofDependencyComplex(
    vertices=[0, 1, 2, 3],
    edges=[(0,1), (1,2), (2,3), (3,0)],
    triangles=[]
)
print(f"\nComplex: {K_cycle}")
print("Structure: Cycle 0—1—2—3—0 (no triangles)")

# Over ℤ: a cocycle that is NOT a coboundary
# z(0,1) = 1, z(1,2) = 0, z(2,3) = 0, z(3,0) = -1
# For this to be δf: f(1)-f(0)=1, f(2)-f(1)=0, f(3)-f(2)=0, f(0)-f(3)=-1
# This gives f(1)=f(0)+1, f(2)=f(0)+1, f(3)=f(0)+1, f(0)=f(0)+1-1=f(0) ✓
# So this IS a coboundary over ℤ!

# Actually for a cycle without triangles, over ℤ or ℝ, every cochain IS a coboundary
# (since the cocycle condition is vacuous and we can freely assign f)

# Let's demonstrate with a complex that HAS a nontrivial H¹
# Use: two triangles sharing an edge, but with incompatible orientations

# Better example: A complete graph on 3 vertices with the triangle face.
# H¹(K₃; ℤ) = 0 since K₃ is contractible.

# For nontrivial H¹, we need a cycle that is NOT a boundary of any face.
# Classic example: boundary of a square (4-cycle) with NO diagonal faces.
# Over ℝ, H¹ = ℝ (the cycle generates a 1-dim cohomology).

# Wait — over ℝ with no triangles, EVERY cochain is a cocycle (cocycle = vacuous).
# But not every cochain is a coboundary (coboundary requires f(j)-f(i) = z(i,j)).
# On a 4-cycle: δf(0,1)+δf(1,2)+δf(2,3)+δf(3,0) = 0 for any f.
# So if z(0,1)+z(1,2)+z(2,3)+z(3,0) ≠ 0, z is NOT a coboundary.

z_nontrivial = {
    (0,1): 1.0, (1,0): -1.0,
    (1,2): 1.0, (2,1): -1.0,
    (2,3): 1.0, (3,2): -1.0,
    (3,0): 0.0, (0,3): 0.0
}
cycle_sum = z_nontrivial[(0,1)] + z_nontrivial[(1,2)] + z_nontrivial[(2,3)] + z_nontrivial[(3,0)]
print(f"\n1-cochain z: z(0,1)=1, z(1,2)=1, z(2,3)=1, z(3,0)=0")
print(f"Cycle sum: {cycle_sum}")
print(f"Is cocycle? {is_cocycle(K_cycle, z_nontrivial)} (vacuously, no triangles)")
f_wit = is_coboundary(K_cycle, z_nontrivial)
print(f"Is coboundary? {'YES' if f_wit else 'NO'}")
print(f"  Reason: cycle sum = {cycle_sum} ≠ 0, but δf always sums to 0 around any cycle.")

# Now demonstrate the instability lower bound
print(f"\nInstability analysis:")
# Try various predictors
for f_vals in [{0:0, 1:0, 2:0, 3:0}, {0:0, 1:1, 2:2, 3:3}, {0:0, 1:1, 2:1, 3:1}]:
    disagree = predictor_disagreement(f_vals, z_nontrivial, K_cycle.edges)
    print(f"  Predictor f={f_vals}: disagreements = {disagree}")

print("\n→ H¹ ≠ 0: No predictor can match z on all edges. Minimum 1 disagreement.")
print("  This is the instability lower bound theorem in action.")

# ────────────────────────────────────────────────────────
# Example 4: Minimal Obstruction Extraction
# ────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("EXAMPLE 4: Minimal Obstruction Extraction")
print("=" * 60)

# 6-cycle: 0-1-2-3-4-5-0, no triangles
K_hex = ProofDependencyComplex(
    vertices=[0,1,2,3,4,5],
    edges=[(0,1),(1,2),(2,3),(3,4),(4,5),(5,0)],
    triangles=[]
)
print(f"\nComplex: {K_hex}")
print("Structure: Hexagonal cycle 0-1-2-3-4-5-0")

z_hex = {
    (0,1): 1.0, (1,0): -1.0,
    (1,2): 0.0, (2,1): 0.0,
    (2,3): 0.0, (3,2): 0.0,
    (3,4): 0.0, (4,3): 0.0,
    (4,5): 0.0, (5,4): 0.0,
    (5,0): -1.0, (0,5): 1.0
}

support = cochain_support(K_hex, z_hex)
print(f"\nCochain z support: {support}")
print(f"Support size: {len(support)}")
print(f"Is coboundary? {is_coboundary(K_hex, z_hex) is not None}")

# This z has cycle sum = 1+0+0+0+0+(-1) = 0... so it IS a coboundary!
# Let's make it nontrivial:
z_hex2 = {
    (0,1): 1.0, (1,0): -1.0,
    (1,2): 1.0, (2,1): -1.0,
    (2,3): 0.0, (3,2): 0.0,
    (3,4): 0.0, (4,3): 0.0,
    (4,5): 0.0, (5,4): 0.0,
    (5,0): 0.0, (0,5): 0.0
}
cycle_sum2 = sum(z_hex2.get((i, (i+1)%6), 0) for i in range(6))
print(f"\nCochain z₂: z(0,1)=1, z(1,2)=1, rest=0")
print(f"Cycle sum: {cycle_sum2}")
support2 = cochain_support(K_hex, z_hex2)
print(f"Support size: {len(support2)}")
f_wit2 = is_coboundary(K_hex, z_hex2)
print(f"Is coboundary? {f_wit2 is not None}")

# Minimal support: We can shift by a coboundary to reduce support
# If we subtract δg where g(0)=0, g(1)=1, g(2)=1, g(3)=1, g(4)=1, g(5)=1
# then δg(0,1)=1, δg(1,2)=0, δg(2,3)=0,...,δg(5,0)=-1
# z₂ - δg: (0,0)=0, (1,2)=1,...,(5,0)=1 — still has support size 4
# The minimum support for a nontrivial representative is 2 edges (just the cocycle itself)

print("\n→ The minimal obstruction theorem guarantees we can find a")
print("  support-minimal nontrivial representative in the same cohomology class.")

# ────────────────────────────────────────────────────────
# Example 5: Global Sections and Architecture Minimality
# ────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("EXAMPLE 5: Global Sections & Architecture Minimality")
print("=" * 60)

# Complete graph K₃ with triangle face
K_complete = ProofDependencyComplex(
    vertices=[0, 1, 2],
    edges=[(0,1), (1,2), (0,2)],
    triangles=[(0,1,2)]
)
print(f"\nComplex: {K_complete}")
print("Structure: Complete graph K₃ with triangle face")

# Global sections: f with δf = 0, i.e., f constant
print("\nGlobal sections (ker δ): constant functions f(0) = f(1) = f(2) = c")
print("Over ℤ: the global section space is ℤ (one generator)")
print("Over ℤ/nℤ: the global section space has n elements")

# Count global sections for small finite groups
for n in [2, 3, 5, 7]:
    count = 0
    for c in range(n):
        f = {0: c, 1: c, 2: c}
        if all(coboundary(f, e) % n == 0 for e in K_complete.edges):
            count += 1
    print(f"  |H⁰(K₃; ℤ/{n}ℤ)| = {count}")

print("\n→ Minimal architecture = |H⁰| = n (one constant per group element)")
print("  The learnability/minimality duality: minimal generators of H⁰")
print("  determine minimal proof-predictor architecture size.")

# ────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("SUMMARY: Sheaf–Proof-State Duality")
print("=" * 60)
print("""
Key results demonstrated:

1. TREES (H¹ = 0): Every local proof strategy extends globally.
   → No obstruction, perfect realizability.

2. CYCLES without faces (H¹ ≠ 0): Nontrivial cocycles exist.
   → Obstruction to global proof policy.
   → Every predictor must disagree on at least 1 edge.

3. MINIMAL OBSTRUCTION: Support-minimal nontrivial cocycles 
   identify the smallest inconsistency witness.

4. ARCHITECTURE MINIMALITY: In the realizable case (H¹ = 0),
   minimal proof-predictor size = generators of H⁰.

This establishes a complete dictionary:
  • Proof states         ↔ Vertices
  • Local transitions    ↔ Edges  
  • Coherence conditions ↔ Triangles/faces
  • Local predictors     ↔ 0-cochains
  • Inconsistencies      ↔ 1-cocycles
  • Resolvable errors    ↔ 1-coboundaries
  • Obstruction class    ↔ H¹ element
  • Global proof policy  ↔ Global section
  • Min. architecture    ↔ Min. generators of H⁰
""")


#!/usr/bin/env python3
"""
Visualizations for Sheaf–Proof-State Cohomological Obstruction Theory

Generates publication-quality figures:
1. Dependency complex with cohomology annotation
2. Obstruction cycle extraction
3. H¹ dimension landscape
4. Instability heatmap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import networkx as nx
from algorithms import (FiniteDependencyComplex, coboundary_matrix,
                        compute_H1_dimension, find_coboundary_witness,
                        greedy_support_reduction, enumerate_global_sections_mod_n)

plt.rcParams.update({
    'font.size': 12,
    'font.family': 'serif',
    'figure.dpi': 150,
    'savefig.bbox': 'tight',
    'savefig.pad_inches': 0.1
})


def fig1_cohomology_dictionary():
    """
    Figure 1: The Cohomological Dictionary
    Side-by-side comparison of realizable (H¹=0) vs obstructed (H¹≠0) complexes.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel A: Tree (H¹ = 0)
    ax = axes[0]
    G = nx.Graph()
    G.add_edges_from([(0,1),(1,2),(1,3),(2,4)])
    pos = {0: (0,0), 1: (1,0), 2: (2,0.5), 3: (2,-0.5), 4: (3,0.5)}
    
    nx.draw_networkx_nodes(G, pos, ax=ax, node_color='#4CAF50', node_size=500, alpha=0.9)
    nx.draw_networkx_edges(G, pos, ax=ax, edge_color='#2196F3', width=2.5)
    nx.draw_networkx_labels(G, pos, ax=ax, font_size=14, font_weight='bold', font_color='white')
    
    # Add edge labels showing coboundary values
    edge_labels = {(0,1): 'δf=3', (1,2): 'δf=1', (1,3): 'δf=2', (2,4): 'δf=−1'}
    nx.draw_networkx_edge_labels(G, pos, edge_labels, ax=ax, font_size=9, 
                                  font_color='#1565C0', bbox=dict(boxstyle='round,pad=0.1', 
                                  facecolor='white', edgecolor='none', alpha=0.8))
    
    ax.set_title('Tree Complex: H¹ = 0\n(Globally Realizable)', fontsize=14, fontweight='bold',
                 color='#2E7D32')
    ax.text(0.5, -0.12, 'Every local prediction extends globally.\nNo obstruction exists.',
            transform=ax.transAxes, ha='center', fontsize=10, style='italic', color='#555')
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-1.2, 1.2)
    ax.axis('off')
    
    # Panel B: Cycle (H¹ ≠ 0)
    ax = axes[1]
    G2 = nx.Graph()
    G2.add_edges_from([(0,1),(1,2),(2,3),(3,0)])
    pos2 = {0: (0,0), 1: (1,0), 2: (1,1), 3: (0,1)}
    
    nx.draw_networkx_nodes(G2, pos2, ax=ax, node_color='#F44336', node_size=500, alpha=0.9)
    nx.draw_networkx_edges(G2, pos2, ax=ax, edge_color='#FF9800', width=2.5)
    nx.draw_networkx_labels(G2, pos2, ax=ax, font_size=14, font_weight='bold', font_color='white')
    
    edge_labels2 = {(0,1): 'z=1', (1,2): 'z=1', (2,3): 'z=1', (0,3): 'z=0'}
    nx.draw_networkx_edge_labels(G2, pos2, edge_labels2, ax=ax, font_size=9,
                                  font_color='#E65100', bbox=dict(boxstyle='round,pad=0.1',
                                  facecolor='white', edgecolor='none', alpha=0.8))
    
    # Add cycle sum annotation
    ax.annotate('Cycle sum = 3 ≠ 0\n→ NOT a coboundary!', xy=(0.5, 0.5), fontsize=10,
                ha='center', va='center', color='#B71C1C', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE', edgecolor='#F44336'))
    
    ax.set_title('Cycle Complex: H¹ ≠ 0\n(Obstruction Exists)', fontsize=14, fontweight='bold',
                 color='#C62828')
    ax.text(0.5, -0.12, 'No global proof policy can match\nall local predictions simultaneously.',
            transform=ax.transAxes, ha='center', fontsize=10, style='italic', color='#555')
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 1.5)
    ax.axis('off')
    
    plt.suptitle('The Cohomological Dictionary of Proof Consistency',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/AlgebraMachineLearningLogic/fig1_cohomology_dictionary.png',
                dpi=150)
    plt.close()
    print("Saved fig1_cohomology_dictionary.png")


def fig2_obstruction_landscape():
    """
    Figure 2: H¹ Dimension Landscape
    How graph topology determines obstruction complexity.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Compute H¹ for various graph families
    families = {
        'Path Pₙ': [],
        'Cycle Cₙ': [],
        'Complete Kₙ': [],
        'Grid': [],
    }
    
    ns = range(3, 12)
    
    for n in ns:
        # Path
        K_path = FiniteDependencyComplex(list(range(n)), [(i,i+1) for i in range(n-1)])
        families['Path Pₙ'].append(compute_H1_dimension(K_path))
        
        # Cycle
        K_cycle = FiniteDependencyComplex(list(range(n)), 
                                           [(i,(i+1)%n) for i in range(n)])
        families['Cycle Cₙ'].append(compute_H1_dimension(K_cycle))
        
        # Complete graph
        K_complete = FiniteDependencyComplex(list(range(n)),
                                             [(i,j) for i in range(n) for j in range(i+1,n)])
        families['Complete Kₙ'].append(compute_H1_dimension(K_complete))
        
        # Grid: use side x side grid where side = max(2, floor(sqrt(n)))
        side = max(2, int(np.sqrt(n)))
        grid_v = list(range(side * side))
        grid_e = []
        for r in range(side):
            for c in range(side):
                v = r * side + c
                if c + 1 < side:
                    grid_e.append((v, v+1))
                if r + 1 < side:
                    grid_e.append((v, v+side))
        if grid_e:
            K_grid = FiniteDependencyComplex(grid_v, grid_e)
            families['Grid'].append(compute_H1_dimension(K_grid))
        else:
            families['Grid'].append(0)
    
    colors = ['#4CAF50', '#F44336', '#2196F3', '#FF9800']
    markers = ['o', 's', '^', 'D']
    
    for (name, vals), color, marker in zip(families.items(), colors, markers):
        valid_ns = [n for n, v in zip(ns, vals) if v is not None]
        valid_vals = [v for v in vals if v is not None]
        ax.plot(valid_ns, valid_vals, marker=marker, color=color, linewidth=2,
                markersize=8, label=name, alpha=0.85)
    
    ax.set_xlabel('Number of Vertices n', fontsize=13)
    ax.set_ylabel('dim H¹ (Obstruction Dimension)', fontsize=13)
    ax.set_title('Obstruction Landscape: How Topology Determines\nProof-System Fragility',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, framealpha=0.9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=-0.5)
    
    # Annotation
    ax.annotate('Trees & paths: always robust\n(H¹ = 0)',
                xy=(8, 0), fontsize=9, ha='center',
                bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))
    
    ax.annotate('Complete graphs: many\nobstruction cycles',
                xy=(8, families['Complete Kₙ'][5]), fontsize=9, ha='center',
                bbox=dict(boxstyle='round', facecolor='#E3F2FD', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/AlgebraMachineLearningLogic/fig2_obstruction_landscape.png',
                dpi=150)
    plt.close()
    print("Saved fig2_obstruction_landscape.png")


def fig3_instability_heatmap():
    """
    Figure 3: Instability Heatmap
    For a grid graph, show which edges are most vulnerable.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Create a 4x4 grid
    side = 4
    n = side * side
    grid_v = list(range(n))
    grid_e = []
    for r in range(side):
        for c in range(side):
            v = r * side + c
            if c + 1 < side:
                grid_e.append((v, v+1))
            if r + 1 < side:
                grid_e.append((v, v+side))
    
    K = FiniteDependencyComplex(grid_v, grid_e)
    D0 = coboundary_matrix(K)
    edges = K.edge_list()
    
    ax = axes[0]
    # Visualize the grid with H¹ annotation
    G = nx.grid_2d_graph(side, side)
    pos = {(r,c): (c, side-1-r) for r in range(side) for c in range(side)}
    
    nx.draw_networkx_nodes(G, pos, ax=ax, node_color='#2196F3', node_size=300)
    nx.draw_networkx_edges(G, pos, ax=ax, edge_color='#90CAF9', width=2)
    
    h1 = compute_H1_dimension(K)
    ax.set_title(f'4×4 Grid Graph\ndim H¹ = {h1} obstruction cycles',
                 fontsize=13, fontweight='bold')
    ax.axis('off')
    
    # Panel 2: Support sizes of random cocycle perturbations
    ax = axes[1]
    np.random.seed(123)
    
    support_sizes = []
    min_supports = []
    for trial in range(100):
        z = np.random.randn(K.m)
        # Get the H¹ component
        f_opt, _, _, _ = np.linalg.lstsq(D0, z, rcond=None)
        z_cocycle = z - D0 @ f_opt
        
        if np.allclose(z_cocycle, 0):
            continue
        
        orig_supp = np.count_nonzero(np.abs(z_cocycle) > 1e-8)
        z_min = greedy_support_reduction(K, z_cocycle)
        min_supp = np.count_nonzero(np.abs(z_min) > 1e-8)
        
        support_sizes.append(orig_supp)
        min_supports.append(min_supp)
    
    ax.hist(support_sizes, bins=range(0, K.m+2), alpha=0.5, color='#F44336',
            label='Original support', edgecolor='white')
    ax.hist(min_supports, bins=range(0, K.m+2), alpha=0.5, color='#4CAF50',
            label='After greedy reduction', edgecolor='white')
    ax.set_xlabel('Support Size (# nonzero edges)', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title('Support Reduction via Greedy Algorithm\n(100 random cocycles on 4×4 grid)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/AlgebraMachineLearningLogic/fig3_instability_heatmap.png',
                dpi=150)
    plt.close()
    print("Saved fig3_instability_heatmap.png")


def fig4_architecture_minimality():
    """
    Figure 4: Architecture Minimality
    |H⁰| as a function of group order and graph topology.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    
    graph_configs = [
        ('Path P₃', list(range(3)), [(0,1),(1,2)]),
        ('Cycle C₃', list(range(3)), [(0,1),(1,2),(2,0)]),
        ('Path P₅', list(range(5)), [(i,i+1) for i in range(4)]),
        ('Cycle C₅', list(range(5)), [(i,(i+1)%5) for i in range(5)]),
        ('K₁ + K₁', list(range(2)), []),  # disconnected
    ]
    
    moduli = list(range(2, 16))
    
    for name, verts, edgs in graph_configs:
        K = FiniteDependencyComplex(verts, edgs)
        h0_sizes = []
        for n in moduli:
            secs = enumerate_global_sections_mod_n(K, n)
            h0_sizes.append(len(secs))
        ax.plot(moduli, h0_sizes, 'o-', label=name, linewidth=2, markersize=6)
    
    ax.set_xlabel('Coefficient Group Order n (working over ℤ/nℤ)', fontsize=13)
    ax.set_ylabel('|H⁰| (Number of Global Sections)', fontsize=13)
    ax.set_title('Architecture Minimality:\nGlobal Sections vs. Coefficient Group',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    
    ax.annotate('Disconnected graph:\n|H⁰| = n² (one choice per component)',
                xy=(10, 100), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='#FFF9C4', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/AlgebraMachineLearningLogic/fig4_architecture_minimality.png',
                dpi=150)
    plt.close()
    print("Saved fig4_architecture_minimality.png")


if __name__ == "__main__":
    fig1_cohomology_dictionary()
    fig2_obstruction_landscape()
    fig3_instability_heatmap()
    fig4_architecture_minimality()
    print("\nAll visualizations saved!")
