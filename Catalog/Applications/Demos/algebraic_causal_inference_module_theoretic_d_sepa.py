#!/usr/bin/env python3
"""
Algebraic Causal Inference: Interactive Demonstration

This demo illustrates the core concepts of algebraic causal inference formalized
in our Lean 4 development:
1. Causal DAGs with topological orderings
2. Interventions as graph surgery (Pearl's do-operator)
3. Algebraic structural causal models
4. Faithfulness and coefficient-edge correspondence
5. Intervention complexity bounds

All results here have been formally verified in Lean 4 with zero sorries.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product

# =============================================================================
# Part 1: Causal DAG with Topological Ordering
# =============================================================================

class CausalDAG:
    """
    A directed acyclic graph with a witnessing topological ordering.
    Corresponds to the Lean 4 structure:
    
        structure CausalDAG (n : ℕ) where
          adj : Fin n → Fin n → Bool
          rank : Fin n → ℕ
          rank_inj : Injective rank
          rank_edge : ∀ i j, adj i j = true → rank i < rank j
    """
    
    def __init__(self, n, edges, labels=None):
        self.n = n
        self.adj = np.zeros((n, n), dtype=bool)
        self.labels = labels or [str(i) for i in range(n)]
        
        for (i, j) in edges:
            self.adj[i][j] = True
        
        # Compute topological ordering (rank)
        self.rank = self._topological_sort()
        
        # Verify DAG property (rank_edge)
        for i in range(n):
            for j in range(n):
                if self.adj[i][j]:
                    assert self.rank[i] < self.rank[j], \
                        f"Edge {i}->{j} violates topological ordering"
    
    def _topological_sort(self):
        """Compute topological ordering using Kahn's algorithm."""
        in_degree = np.sum(self.adj, axis=0)
        queue = [i for i in range(self.n) if in_degree[i] == 0]
        rank = [0] * self.n
        order = 0
        
        while queue:
            node = queue.pop(0)
            rank[node] = order
            order += 1
            for j in range(self.n):
                if self.adj[node][j]:
                    in_degree[j] -= 1
                    if in_degree[j] == 0:
                        queue.append(j)
        
        return rank
    
    def parents(self, j):
        """Parents of vertex j. Corresponds to CausalDAG.parents."""
        return [i for i in range(self.n) if self.adj[i][j]]
    
    def children(self, i):
        """Children of vertex i. Corresponds to CausalDAG.children."""
        return [j for j in range(self.n) if self.adj[i][j]]
    
    def reachable(self, i, j):
        """Check if j is reachable from i. Corresponds to CausalDAG.Reachable."""
        visited = set()
        stack = [i]
        while stack:
            node = stack.pop()
            if node == j and node != i:
                return True
            if node in visited:
                continue
            visited.add(node)
            for k in range(self.n):
                if self.adj[node][k]:
                    stack.append(k)
        return False
    
    def edge_count(self):
        """Total number of edges. Corresponds to CausalDAG.edgeCount."""
        return int(np.sum(self.adj))
    
    def intervention(self, S):
        """
        Perform intervention on set S: remove all incoming edges to S.
        Corresponds to InterventionDAG.
        """
        new_edges = []
        for i in range(self.n):
            for j in range(self.n):
                if self.adj[i][j] and j not in S:
                    new_edges.append((i, j))
        return CausalDAG(self.n, new_edges, self.labels)
    
    def causal_separation(self, X, Y, Z):
        """
        Check if X is separated from Y by Z.
        Corresponds to CausalSeparation.
        """
        intervened = self.intervention(Z)
        for x in X:
            for y in Y:
                if intervened.reachable(x, y):
                    return False
        return True


class AlgebraicSCM:
    """
    Algebraic Structural Causal Model over the reals.
    Corresponds to the Lean 4 structure:
    
        structure AlgebraicSCM (R : Type*) [CommRing R] (n : ℕ) where
          dag : CausalDAG n
          coeff : Fin n → Fin n → R
          coeff_zero_of_no_edge : ∀ i j, dag.adj i j = false → coeff i j = 0
    """
    
    def __init__(self, dag, coefficients=None):
        self.dag = dag
        self.n = dag.n
        
        if coefficients is not None:
            self.coeff = np.array(coefficients, dtype=float)
        else:
            # Random coefficients for edges, zero for non-edges
            self.coeff = np.zeros((self.n, self.n))
            for i in range(self.n):
                for j in range(self.n):
                    if dag.adj[i][j]:
                        self.coeff[i][j] = np.random.uniform(0.5, 2.0)
        
        # Enforce coeff_zero_of_no_edge
        for i in range(self.n):
            for j in range(self.n):
                if not dag.adj[i][j]:
                    assert self.coeff[i][j] == 0, \
                        f"Coefficient ({i},{j}) must be zero (no edge)"
    
    def structural_matrix(self):
        """
        The structural equation matrix.
        Corresponds to AlgebraicSCM.structuralMatrix.
        """
        return self.coeff.T
    
    def direct_effect(self, i, j):
        """Direct causal effect. Corresponds to AlgebraicSCM.directEffect."""
        return self.coeff[i][j]
    
    def path_strength_two(self, i, k, j):
        """Length-2 path strength. Corresponds to pathStrengthTwo."""
        return self.coeff[i][k] * self.coeff[k][j]
    
    def is_faithful(self):
        """
        Check algebraic faithfulness.
        Corresponds to AlgebraicFaithfulness.
        """
        for i in range(self.n):
            for j in range(self.n):
                if (self.coeff[i][j] == 0) != (not self.dag.adj[i][j]):
                    return False
        return True
    
    def intervention_complexity(self, src, tgt):
        """
        Intervention complexity (projective intervention dimension).
        Corresponds to interventionComplexity / projectiveInterventionDim.
        """
        confounders = 0
        for v in range(self.n):
            if v != src and v != tgt and self.dag.adj[src][v] and self.dag.adj[v][tgt]:
                confounders += 1
        return confounders
    
    def total_direct_effect_sum(self, i):
        """Sum of all direct effects from i. Corresponds to total_direct_effect_sum."""
        return sum(self.direct_effect(i, j) for j in range(self.n))


# =============================================================================
# Part 2: Concrete Examples (matching Lean 4 verified DAGs)
# =============================================================================

print("=" * 70)
print("ALGEBRAIC CAUSAL INFERENCE — INTERACTIVE DEMONSTRATION")
print("=" * 70)

# Chain DAG: 0 → 1 → 2
print("\n--- Example 1: Chain DAG (0 → 1 → 2) ---")
chain = CausalDAG(3, [(0, 1), (1, 2)], ["X", "M", "Y"])
print(f"Vertices: {chain.labels}")
print(f"Edges: {[(chain.labels[i], chain.labels[j]) for i in range(3) for j in range(3) if chain.adj[i][j]]}")
print(f"Topological rank: {dict(zip(chain.labels, chain.rank))}")
print(f"Edge count: {chain.edge_count()} (proved ≤ n²={3*3})")
print(f"No self-loops: {all(not chain.adj[i][i] for i in range(3))} (Theorem: no_self_edge)")
print(f"Reachable(0,2): {chain.reachable(0, 2)} (Theorem: chainDAG3_reachable_0_2)")
print(f"Parents of vertex 1: {[chain.labels[p] for p in chain.parents(1)]}")

# Fork DAG: 1 ← 0 → 2
print("\n--- Example 2: Fork DAG (Y ← X → Z) ---")
fork = CausalDAG(3, [(0, 1), (0, 2)], ["X", "Y", "Z"])
print(f"Edges: {[(fork.labels[i], fork.labels[j]) for i in range(3) for j in range(3) if fork.adj[i][j]]}")
print(f"Reachable(1,2): {fork.reachable(1, 2)} (Theorem: forkDAG3_not_reachable_1_2)")
print(f"Parent of vertex 1: {[fork.labels[p] for p in fork.parents(1)]} (Theorem: forkDAG3_parent)")

# Collider DAG: 0 → 2 ← 1
print("\n--- Example 3: Collider DAG (X → Z ← Y) ---")
collider = CausalDAG(3, [(0, 2), (1, 2)], ["X", "Y", "Z"])
print(f"Edges: {[(collider.labels[i], collider.labels[j]) for i in range(3) for j in range(3) if collider.adj[i][j]]}")
print(f"Parents of Z: {[collider.labels[p] for p in collider.parents(2)]} (Theorem: colliderDAG3_parents)")

# =============================================================================
# Part 3: Interventions
# =============================================================================

print("\n--- Example 4: Interventions (Pearl's do-operator) ---")
# Intervention on the chain DAG: do(M)
chain_doM = chain.intervention({1})
print(f"Chain DAG after do(M): edges = {[(chain.labels[i], chain.labels[j]) for i in range(3) for j in range(3) if chain_doM.adj[i][j]]}")
print(f"Parents of M after intervention: {chain_doM.parents(1)} (Theorem: target_no_parents)")

# Intervention idempotence
chain_doM_doM = chain_doM.intervention({1})
print(f"Idempotent: do(M) twice = do(M) once: {np.array_equal(chain_doM.adj, chain_doM_doM.adj)} (Theorem: idempotent_adj)")

# Empty intervention
chain_empty = chain.intervention(set())
print(f"Empty intervention = identity: {np.array_equal(chain.adj, chain_empty.adj)} (Theorem: empty_adj)")

# =============================================================================
# Part 4: Algebraic SCM and Faithfulness
# =============================================================================

print("\n--- Example 5: Algebraic SCM and Faithfulness ---")

# Create a faithful SCM on the chain
coeff_matrix = np.zeros((3, 3))
coeff_matrix[0][1] = 0.7  # X → M with strength 0.7
coeff_matrix[1][2] = 1.3  # M → Y with strength 1.3
chain_scm = AlgebraicSCM(chain, coeff_matrix)

print(f"Structural coefficients:")
for i in range(3):
    for j in range(3):
        if chain_scm.coeff[i][j] != 0:
            print(f"  {chain.labels[i]} → {chain.labels[j]}: {chain_scm.coeff[i][j]:.1f}")

print(f"Structural matrix (zero diagonal - Theorem structural_matrix_zero_diag):")
B = chain_scm.structural_matrix()
for i in range(3):
    print(f"  {[f'{B[i][j]:5.1f}' for j in range(3)]}")

print(f"Diagonal is zero: {all(B[i][i] == 0 for i in range(3))}")
print(f"Is faithful: {chain_scm.is_faithful()} (Theorem: syzygy_free_iff_faithful)")

# Path strengths
print(f"\nDirect effect X→M: {chain_scm.direct_effect(0, 1):.1f}")
print(f"Direct effect M→Y: {chain_scm.direct_effect(1, 2):.1f}")
print(f"Direct effect X→Y: {chain_scm.direct_effect(0, 2):.1f} (zero - no direct edge)")
print(f"Length-2 path X→M→Y strength: {chain_scm.path_strength_two(0, 1, 2):.2f}")

# =============================================================================
# Part 5: Intervention Complexity Bounds
# =============================================================================

print("\n--- Example 6: Intervention Complexity Bounds ---")

# Create a DAG with confounders: X → C₁, X → C₂, C₁ → Y, C₂ → Y
n = 6
edges_complex = [
    (0, 1), (0, 2), (0, 3),  # X → C₁, C₂, C₃
    (1, 4), (2, 4), (3, 4),  # C₁, C₂, C₃ → M
    (4, 5),                    # M → Y
    (0, 4), (1, 5), (2, 5),  # Additional edges
]
labels = ["X", "C₁", "C₂", "C₃", "M", "Y"]
complex_dag = CausalDAG(n, edges_complex, labels)

coeff_complex = np.zeros((n, n))
for (i, j) in edges_complex:
    coeff_complex[i][j] = np.random.uniform(0.3, 1.5)

complex_scm = AlgebraicSCM(complex_dag, coeff_complex)

src, tgt = 0, 5  # X → Y
complexity = complex_scm.intervention_complexity(src, tgt)
print(f"DAG: {labels}")
print(f"Edge count: {complex_dag.edge_count()} ≤ n²={n*n} (Theorem: edge_count_le_sq)")
print(f"Intervention complexity (X→Y): {complexity}")
print(f"  ≤ n={n} (Theorem: projective_intervention_dim_bound)")
print(f"  ≤ out-degree of X = {len(complex_dag.children(src))} (Theorem: degree_intervention_bound)")

# =============================================================================
# Part 6: Causal Separation
# =============================================================================

print("\n--- Example 7: Causal Separation ---")
print(f"Chain: X separated from Y by {{M}}? {chain.causal_separation({0}, {2}, {1})}")
print(f"Chain: X separated from Y by {{}}? {chain.causal_separation({0}, {2}, set())}")
print(f"Fork: Y separated from Z by {{X}}? {fork.causal_separation({1}, {2}, {0})}")
print(f"Fork: Y separated from Z by {{}}? {fork.causal_separation({1}, {2}, set())}")
print(f"Empty right: X separated from ∅ by anything? {chain.causal_separation({0}, set(), {1})} (Theorem: empty_right)")
print(f"Empty left: ∅ separated from Y by anything? {chain.causal_separation(set(), {2}, {1})} (Theorem: empty_left)")

# =============================================================================
# Part 7: Semi-Graphoid Axioms Verification
# =============================================================================

print("\n--- Example 8: Semi-Graphoid Axioms ---")
print("The conditional independence relation satisfies:")
print("  1. Symmetry: X ⊥ Y | Z ↔ Y ⊥ X | Z")
print("     Chain: {X} ⊥ {Y}|{M} =", chain.causal_separation({0}, {2}, {1}))
print("     Chain: {Y} ⊥ {X}|{M} =", chain.causal_separation({2}, {0}, {1}))
print("  2. Decomposition: verified by semigraphoid_decomp_singleton")
print("  3. Weak Union: verified by semigraphoid_weak_union_singleton")
print("  4. Contraction: verified by SemiGraphoidAxioms.contraction")

# =============================================================================
# Part 8: Visualization
# =============================================================================

def draw_dag(dag, ax, title, highlight_edges=None):
    """Draw a DAG with topological ordering."""
    n = dag.n
    # Layout nodes in topological order
    positions = {}
    rank_groups = {}
    for i in range(n):
        r = dag.rank[i]
        if r not in rank_groups:
            rank_groups[r] = []
        rank_groups[r].append(i)
    
    for r, nodes in rank_groups.items():
        for idx, node in enumerate(nodes):
            x = r * 2.0
            y = -(idx - (len(nodes) - 1) / 2) * 1.5
            positions[node] = (x, y)
    
    # Draw edges
    for i in range(n):
        for j in range(n):
            if dag.adj[i][j]:
                x1, y1 = positions[i]
                x2, y2 = positions[j]
                color = 'red' if highlight_edges and (i, j) in highlight_edges else '#333333'
                lw = 2.5 if highlight_edges and (i, j) in highlight_edges else 1.5
                ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                           arrowprops=dict(arrowstyle="->", color=color, lw=lw))
    
    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.35, color='#4A90D9', ec='#2C5F8A', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, dag.labels[i], ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)
    
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-1, max(p[0] for p in positions.values()) + 1)
    ax.set_ylim(min(p[1] for p in positions.values()) - 1,
                max(p[1] for p in positions.values()) + 1)
    ax.set_aspect('equal')
    ax.axis('off')

# Create the visualization
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Algebraic Causal Inference: Core DAG Structures\n(Formally Verified in Lean 4, Zero Sorries)",
             fontsize=14, fontweight='bold')

# Row 1: Basic DAGs
draw_dag(chain, axes[0, 0], "Chain: X → M → Y")
draw_dag(fork, axes[0, 1], "Fork: Y ← X → Z")
draw_dag(collider, axes[0, 2], "Collider: X → Z ← Y")

# Row 2: Interventions
draw_dag(chain_doM, axes[1, 0], "Chain after do(M)")
draw_dag(chain.intervention({0}), axes[1, 1], "Chain after do(X)")
draw_dag(complex_dag, axes[1, 2], "Complex DAG (6 nodes)")

plt.tight_layout()
plt.savefig('algebraic_causal_inference_demo.png', dpi=150, bbox_inches='tight')
print("\n✓ Saved visualization to algebraic_causal_inference_demo.png")

# =============================================================================
# Part 9: Complexity Scaling
# =============================================================================

print("\n--- Example 9: Complexity Scaling ---")
print(f"{'n':>4} {'Max Edges':>10} {'n²':>6} {'Query Bound':>12}")
print("-" * 36)
for n in [3, 5, 10, 20, 50, 100]:
    max_edges = n * (n - 1) // 2
    query_bound = n * n
    print(f"{n:>4} {max_edges:>10} {n**2:>6} {query_bound:>12}")

print("\nAll bounds formally verified in Lean 4:")
print("  • edge_count ≤ n² (Theorem: edge_count_le_sq)")
print("  • query_count = n² (Theorem: causal_discovery_query_upper_bound)")
print("  • intervention_dim ≤ n (Theorem: projective_intervention_dim_bound)")
print("  • intervention_dim ≤ Δ (Theorem: degree_intervention_bound)")

print("\n" + "=" * 70)
print("All results formally verified in Lean 4 with ZERO sorries.")
print("Standard axioms only: propext, Classical.choice, Quot.sound.")
print("=" * 70)
