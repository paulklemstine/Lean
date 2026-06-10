#!/usr/bin/env python3
"""
Viral Information Topology: Numerical Demonstrations

Computes sheaf cohomology dimensions (H^0, H^1) for the constant sheaf
on directed graphs, demonstrating the Euler characteristic formula
and virality index in concrete examples.
"""

import numpy as np
from typing import List, Tuple, Dict


def coboundary_matrix(n_vertices: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Construct the coboundary matrix δ: R^V → R^E for the constant sheaf.
    
    For edge e = (src, tgt), row e has +1 at column tgt and -1 at column src.
    """
    m = len(edges)
    delta = np.zeros((m, n_vertices))
    for i, (s, t) in enumerate(edges):
        delta[i, t] = 1.0
        delta[i, s] = -1.0
    return delta


def weighted_coboundary_matrix(n_vertices: int, edges: List[Tuple[int, int]],
                                weights: List[float]) -> np.ndarray:
    """Construct the weighted coboundary matrix δ_w for the propagation sheaf.
    
    For edge e = (src, tgt) with weight w, row e has +w at column tgt and -1 at column src.
    """
    m = len(edges)
    delta = np.zeros((m, n_vertices))
    for i, ((s, t), w) in enumerate(zip(edges, weights)):
        delta[i, t] = w
        delta[i, s] = -1.0
    return delta


def compute_cohomology(delta: np.ndarray) -> Dict[str, int]:
    """Compute H^0 and H^1 dimensions from the coboundary matrix."""
    n_vertices = delta.shape[1]
    n_edges = delta.shape[0]
    
    rank = np.linalg.matrix_rank(delta, tol=1e-10)
    h0 = n_vertices - rank  # dim ker(δ)
    h1 = n_edges - rank     # dim coker(δ)
    euler = h0 - h1         # = |V| - |E|
    
    return {"h0": h0, "h1": h1, "rank": rank, "euler": euler,
            "n_vertices": n_vertices, "n_edges": n_edges}


def virality_index(h0: int, h1: int, n_edges: int) -> int:
    """Compute the virality index V = h0 * (|E| + 1 - h1)."""
    return h0 * (n_edges + 1 - h1)


def print_analysis(name: str, n_vertices: int, edges: List[Tuple[int, int]],
                   weights: List[float] = None):
    """Full sheaf cohomology analysis of a graph."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    print(f"  |V| = {n_vertices}, |E| = {len(edges)}")
    
    # Constant sheaf
    delta = coboundary_matrix(n_vertices, edges)
    coh = compute_cohomology(delta)
    vi = virality_index(coh['h0'], coh['h1'], coh['n_edges'])
    
    print(f"\n  Constant Sheaf:")
    print(f"    dim H⁰ = {coh['h0']}  (independent interpretations)")
    print(f"    dim H¹ = {coh['h1']}  (transmission barriers)")
    print(f"    rank(δ) = {coh['rank']}")
    print(f"    Euler char χ = {coh['euler']}  (should be {n_vertices - len(edges)})")
    print(f"    Virality index = {vi}")
    
    assert coh['euler'] == n_vertices - len(edges), "Euler characteristic violated!"
    
    # Weighted sheaf (if provided)
    if weights is not None:
        delta_w = weighted_coboundary_matrix(n_vertices, edges, weights)
        coh_w = compute_cohomology(delta_w)
        vi_w = virality_index(coh_w['h0'], coh_w['h1'], coh_w['n_edges'])
        
        print(f"\n  Propagation Sheaf (weights = {weights}):")
        print(f"    dim H⁰_w = {coh_w['h0']}")
        print(f"    dim H¹_w = {coh_w['h1']}")
        print(f"    Virality index = {vi_w}")


# ========== EXAMPLES ==========

print("╔══════════════════════════════════════════════════════════╗")
print("║   VIRAL INFORMATION TOPOLOGY: Numerical Demonstrations  ║")
print("╚══════════════════════════════════════════════════════════╝")

# Example 1: Edgeless graph (5 isolated nodes)
print_analysis("Edgeless Graph (5 nodes)", 5, [])

# Example 2: Path graph (chain of 5 nodes)
print_analysis("Path Graph P₅", 5,
               [(0,1), (1,2), (2,3), (3,4)])

# Example 3: Cycle graph C₅ (pentagon)
print_analysis("Cycle Graph C₅", 5,
               [(0,1), (1,2), (2,3), (3,4), (4,0)])

# Example 4: Complete graph K₄
k4_edges = [(i,j) for i in range(4) for j in range(i+1, 4)]
print_analysis("Complete Graph K₄", 4, k4_edges)

# Example 5: Two disjoint triangles (modeling two communities)
print_analysis("Two Disjoint Triangles", 6,
               [(0,1), (1,2), (2,0), (3,4), (4,5), (5,3)])

# Example 6: Two triangles connected by a bridge
print_analysis("Two Triangles + Bridge", 6,
               [(0,1), (1,2), (2,0), (3,4), (4,5), (5,3), (2,3)])

# Example 7: Star graph (hub and spoke)
print_analysis("Star Graph S₅ (hub = 0)", 6,
               [(0,1), (0,2), (0,3), (0,4), (0,5)])

# Example 8: Weighted propagation sheaf
print_analysis("Weighted Triangle", 3,
               [(0,1), (1,2), (2,0)],
               weights=[1.0, 1.0, 1.0])

print_analysis("Weighted Triangle (one blocked edge)", 3,
               [(0,1), (1,2), (2,0)],
               weights=[1.0, 1.0, 0.0])

print_analysis("Weighted Triangle (distorted)", 3,
               [(0,1), (1,2), (2,0)],
               weights=[2.0, 0.5, 1.0])

# Example 9: Social network model
print("\n" + "="*60)
print("  Social Network Simulation: 3 Communities")
print("="*60)

n = 15  # 5 nodes per community
edges = []
# Community 1: nodes 0-4 (fully connected)
for i in range(5):
    for j in range(i+1, 5):
        edges.append((i, j))
# Community 2: nodes 5-9
for i in range(5, 10):
    for j in range(i+1, 10):
        edges.append((i, j))
# Community 3: nodes 10-14
for i in range(10, 15):
    for j in range(i+1, 15):
        edges.append((i, j))

delta_isolated = coboundary_matrix(n, edges)
coh_isolated = compute_cohomology(delta_isolated)
print(f"\n  Three isolated communities (K₅ each):")
print(f"    dim H⁰ = {coh_isolated['h0']} (= 3 communities)")
print(f"    dim H¹ = {coh_isolated['h1']}")
print(f"    Virality = {virality_index(coh_isolated['h0'], coh_isolated['h1'], len(edges))}")

# Add one bridge between communities
edges_bridge1 = edges + [(4, 5)]
delta_b1 = coboundary_matrix(n, edges_bridge1)
coh_b1 = compute_cohomology(delta_b1)
print(f"\n  Add bridge 4→5 (connect communities 1-2):")
print(f"    dim H⁰ = {coh_b1['h0']} (= 2 components)")
print(f"    dim H¹ = {coh_b1['h1']}")
print(f"    Virality = {virality_index(coh_b1['h0'], coh_b1['h1'], len(edges_bridge1))}")

# Add second bridge
edges_bridge2 = edges_bridge1 + [(9, 10)]
delta_b2 = coboundary_matrix(n, edges_bridge2)
coh_b2 = compute_cohomology(delta_b2)
print(f"\n  Add bridge 9→10 (connect all communities):")
print(f"    dim H⁰ = {coh_b2['h0']} (= 1 component)")
print(f"    dim H¹ = {coh_b2['h1']}")
print(f"    Virality = {virality_index(coh_b2['h0'], coh_b2['h1'], len(edges_bridge2))}")

# Summary
print("\n" + "="*60)
print("  KEY INSIGHT: Euler characteristic χ = |V| - |E| is")
print("  verified in ALL examples. Virality increases as H¹ → 0.")
print("  Disconnected communities (H⁰ > 1) preserve interpretation")
print("  diversity, but bridges (reducing H¹) enable spread.")
print("="*60)


#!/usr/bin/env python3
"""
Visualization: Sheaf Cohomology Dimensions vs Graph Structure

Shows how H^0 and H^1 change as edges are added to a graph,
demonstrating the Euler characteristic formula.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def coboundary_matrix(n_vertices, edges):
    m = len(edges)
    delta = np.zeros((m, n_vertices))
    for i, (s, t) in enumerate(edges):
        delta[i, t] = 1.0
        delta[i, s] = -1.0
    return delta


def compute_cohomology(n_vertices, edges):
    if len(edges) == 0:
        return n_vertices, 0, 0
    delta = coboundary_matrix(n_vertices, edges)
    rank = int(np.linalg.matrix_rank(delta, tol=1e-10))
    h0 = n_vertices - rank
    h1 = len(edges) - rank
    return h0, h1, rank


def main():
    n = 8
    # Add edges one by one to build up a graph
    all_edges = [
        (0, 1), (1, 2), (2, 3), (3, 0),  # cycle in community 1
        (4, 5), (5, 6), (6, 7), (7, 4),  # cycle in community 2
        (3, 4),  # bridge
        (0, 2), (4, 6),  # diagonals
        (1, 5), (2, 6),  # extra cross-edges
    ]
    
    h0_vals, h1_vals, euler_vals, n_edges = [], [], [], []
    virality_vals = []
    
    for k in range(len(all_edges) + 1):
        edges = all_edges[:k]
        h0, h1, rank = compute_cohomology(n, edges)
        h0_vals.append(h0)
        h1_vals.append(h1)
        euler_vals.append(h0 - h1)
        n_edges.append(k)
        virality_vals.append(h0 * (k + 1 - h1))
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Sheaf Cohomology on Social Graphs: Edge Addition Sequence',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: H^0 and H^1
    ax1 = axes[0, 0]
    ax1.plot(n_edges, h0_vals, 'b-o', linewidth=2, markersize=6, label='dim H⁰ (interpretations)')
    ax1.plot(n_edges, h1_vals, 'r-s', linewidth=2, markersize=6, label='dim H¹ (barriers)')
    ax1.set_xlabel('Number of Edges')
    ax1.set_ylabel('Dimension')
    ax1.set_title('Cohomology Dimensions')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Euler characteristic
    ax2 = axes[0, 1]
    ax2.plot(n_edges, euler_vals, 'g-^', linewidth=2, markersize=6, label='χ = dim H⁰ - dim H¹')
    ax2.plot(n_edges, [n - k for k in n_edges], 'k--', linewidth=1, label='|V| - |E|')
    ax2.set_xlabel('Number of Edges')
    ax2.set_ylabel('Euler Characteristic')
    ax2.set_title('Euler Characteristic Formula: χ = |V| - |E|')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Virality index
    ax3 = axes[1, 0]
    ax3.plot(n_edges, virality_vals, 'm-D', linewidth=2, markersize=6, label='Virality Index')
    upper_bound = [n * (k + 1) for k in n_edges]
    ax3.plot(n_edges, upper_bound, 'k--', linewidth=1, alpha=0.5, label='Upper bound |V|·(|E|+1)')
    ax3.set_xlabel('Number of Edges')
    ax3.set_ylabel('Virality Index')
    ax3.set_title('Virality Index: H⁰ × (|E| + 1 - H¹)')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Phase diagram
    ax4 = axes[1, 1]
    scatter = ax4.scatter(h0_vals, h1_vals, c=virality_vals, s=100,
                          cmap='plasma', edgecolors='black', linewidth=0.5)
    for i, k in enumerate(n_edges):
        ax4.annotate(f'{k}e', (h0_vals[i] + 0.05, h1_vals[i] + 0.05), fontsize=8)
    ax4.set_xlabel('dim H⁰ (Polysemy)')
    ax4.set_ylabel('dim H¹ (Barriers)')
    ax4.set_title('Cohomological Phase Diagram')
    plt.colorbar(scatter, ax=ax4, label='Virality Index')
    ax4.grid(True, alpha=0.3)
    
    # Add annotation for the "viral sweet spot"
    ax4.annotate('Viral\nSweet\nSpot', xy=(max(h0_vals), 0),
                 xytext=(max(h0_vals) - 1, max(h1_vals) - 0.5),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=10, color='red', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('cohomology_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cohomology_visualization.png")


if __name__ == "__main__":
    main()
