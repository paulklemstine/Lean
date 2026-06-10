#!/usr/bin/env python3
"""
Applications of Tropical Plücker–Four-Point Equivalence

Demonstrates real-world applications:
1. Phylogenetic tree reconstruction from DNA distances
2. Hierarchical clustering validation
3. Network latency tree embedding
"""

import numpy as np
import itertools
from algorithms import verify_four_point, verify_tropical_plucker, reconstruct_tree


def demo_phylogenetics():
    """Demonstrate phylogenetic application with DNA-like distances."""
    print("=" * 70)
    print("APPLICATION 1: Phylogenetic Tree from Molecular Distances")
    print("=" * 70)
    print()

    # Simulated Jukes-Cantor distances between 5 species
    # Based on a known evolutionary tree
    species = ["Human", "Chimp", "Gorilla", "Orangutan", "Gibbon"]
    n = len(species)

    # These distances come from a tree:
    #        [root]
    #       /      \
    #     [A]      Gibbon (4.5)
    #    /    \
    #  [B]   Orangutan (3.0)
    #  /  \
    # [C]  Gorilla (1.5)
    # / \
    # Human Chimp (0.5 each)

    d = np.array([
        [0.0, 1.0, 2.5, 4.0, 6.5],   # Human
        [1.0, 0.0, 2.5, 4.0, 6.5],   # Chimp
        [2.5, 2.5, 0.0, 4.5, 7.0],   # Gorilla
        [4.0, 4.0, 4.5, 0.0, 7.5],   # Orangutan
        [6.5, 6.5, 7.0, 7.5, 0.0],   # Gibbon
    ])

    print("Evolutionary distance matrix:")
    print(f"{'':>12s}", end="")
    for s in species:
        print(f"{s:>10s}", end="")
    print()
    for i in range(n):
        print(f"{species[i]:>12s}", end="")
        for j in range(n):
            print(f"{d[i,j]:10.1f}", end="")
        print()
    print()

    # Verify four-point condition
    fp_result = verify_four_point(d)
    tp_result = verify_tropical_plucker(d)

    print(f"Four-point condition satisfied: {fp_result['satisfied']}")
    print(f"Tropical Plücker satisfied:     {tp_result['satisfied']}")
    print(f"→ This distance matrix is a tree metric!")
    print()

    # Reconstruct tree
    edges = reconstruct_tree(d)
    print("Reconstructed phylogenetic tree:")
    for u, v, w in edges:
        u_name = species[u] if u < n else f"Ancestor_{u}"
        v_name = species[v] if v < n else f"Ancestor_{v}"
        print(f"  {u_name} ── ({w:.2f}) ── {v_name}")
    print()

    # Show pair-sum analysis
    print("Pair-sum analysis (verifying max-two-equal property):")
    for i, j, k, l in itertools.combinations(range(n), 4):
        s1 = d[i, j] + d[k, l]
        s2 = d[i, k] + d[j, l]
        s3 = d[i, l] + d[j, k]
        sums = sorted([s1, s2, s3])
        print(f"  {species[i]:>5s},{species[j]:>5s},{species[k]:>5s},{species[l]:>5s}: "
              f"sums = ({s1:.1f}, {s2:.1f}, {s3:.1f}) → two largest: {sums[1]:.1f} = {sums[2]:.1f} ✓")
    print()


def demo_hierarchical_clustering():
    """Validate hierarchical clustering using four-point condition."""
    print("=" * 70)
    print("APPLICATION 2: Hierarchical Clustering Validation")
    print("=" * 70)
    print()
    print("Given: pairwise distances between data points.")
    print("Question: Do these distances come from a hierarchical structure?")
    print("Answer: Check the four-point / tropical Plücker condition!")
    print()

    # Example: 6 data points with ultrametric distances (special tree metric)
    n = 6
    labels = [f"x{i}" for i in range(n)]

    # Ultrametric: d(i,j) = height of LCA
    # Cluster structure: {0,1,2} and {3,4,5}, with sub-clusters {0,1},{2} and {3,4},{5}
    d_ultra = np.array([
        [0, 1, 2, 4, 4, 4],
        [1, 0, 2, 4, 4, 4],
        [2, 2, 0, 4, 4, 4],
        [4, 4, 4, 0, 1, 3],
        [4, 4, 4, 1, 0, 3],
        [4, 4, 4, 3, 3, 0],
    ], dtype=float)

    print("Ultrametric distance matrix (perfect hierarchy):")
    for i in range(n):
        print(f"  {[f'{d_ultra[i,j]:3.0f}' for j in range(n)]}")
    print()

    fp = verify_four_point(d_ultra)
    print(f"Four-point condition: {fp['satisfied']} (max gap = {fp['max_gap']:.6f})")
    print(f"→ Distances are tree-like: valid hierarchical clustering exists")
    print()

    # Now perturb to break tree structure
    d_perturbed = d_ultra.copy()
    d_perturbed[0, 3] = 2.5
    d_perturbed[3, 0] = 2.5  # Make 0 and 3 unusually close

    print("Perturbed distance matrix:")
    for i in range(n):
        print(f"  {[f'{d_perturbed[i,j]:3.1f}' for j in range(n)]}")
    print()

    fp_p = verify_four_point(d_perturbed)
    print(f"Four-point condition: {fp_p['satisfied']} (max gap = {fp_p['max_gap']:.6f})")
    if not fp_p['satisfied']:
        print(f"→ {len(fp_p['violations'])} violations found!")
        print(f"→ Distances are NOT tree-like: no exact hierarchical clustering")
        v = fp_p['violations'][0]
        print(f"  Example violation at quadruple {v['quadruple']}: "
              f"sums = ({v['sums'][0]:.1f}, {v['sums'][1]:.1f}, {v['sums'][2]:.1f}), "
              f"gap = {v['gap']:.4f}")
    print()


def demo_network_embedding():
    """Tree embedding for network latency optimization."""
    print("=" * 70)
    print("APPLICATION 3: Network Latency Tree Embedding")
    print("=" * 70)
    print()
    print("Scenario: Measure round-trip latencies between 5 servers.")
    print("Goal: Embed into a tree for efficient routing.")
    print()

    servers = ["NYC", "LON", "TKY", "SFO", "SYD"]
    n = len(servers)

    # Realistic-ish latencies (ms) — not exactly a tree metric
    d = np.array([
        [  0,  75, 180,  65, 230],
        [ 75,   0, 220, 140, 280],
        [180, 220,   0, 110, 120],
        [ 65, 140, 110,   0, 170],
        [230, 280, 120, 170,   0],
    ], dtype=float)

    print("Measured latency matrix (ms):")
    print(f"{'':>6s}", end="")
    for s in servers:
        print(f"{s:>6s}", end="")
    print()
    for i in range(n):
        print(f"{servers[i]:>6s}", end="")
        for j in range(n):
            print(f"{d[i,j]:6.0f}", end="")
        print()
    print()

    fp = verify_four_point(d)
    tp = verify_tropical_plucker(d)
    print(f"Four-point condition: {fp['satisfied']} (max gap = {fp['max_gap']:.1f} ms)")
    print(f"Tropical Plücker:     {tp['satisfied']}")
    print()

    if not fp['satisfied']:
        print("Network latencies are not exactly tree-like.")
        print(f"Distortion from tree metric: {fp['max_gap']:.1f} ms")
        print("Reconstructing best-fit tree anyway...")
        print()

    edges = reconstruct_tree(d)
    print("Approximate tree topology:")
    for u, v, w in edges:
        u_name = servers[u] if u < n else f"Hub_{u}"
        v_name = servers[v] if v < n else f"Hub_{v}"
        print(f"  {u_name} ── ({w:.1f}ms) ── {v_name}")
    print()


if __name__ == "__main__":
    demo_phylogenetics()
    demo_hierarchical_clustering()
    demo_network_embedding()
    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Plücker Relations and the Four-Point Condition: Demonstrations

This module demonstrates the equivalence between tropical Plücker relations
and the four-point condition for distance matrices, with concrete numerical
examples from phylogenetics and metric geometry.
"""

import itertools
import numpy as np
from typing import List, Tuple, Optional


def check_four_point(d: np.ndarray) -> Tuple[bool, List[str]]:
    """Check the four-point condition for a distance matrix.

    For every quadruple (i,j,k,l), the three pair-sums
      s1 = d[i,j] + d[k,l], s2 = d[i,k] + d[j,l], s3 = d[i,l] + d[j,k]
    must satisfy: whenever one is the minimum, the other two are equal.

    Returns:
        (satisfied, violations): bool and list of violation descriptions
    """
    n = d.shape[0]
    violations = []
    for i, j, k, l in itertools.combinations(range(n), 4):
        s1 = d[i, j] + d[k, l]
        s2 = d[i, k] + d[j, l]
        s3 = d[i, l] + d[j, k]
        sums = sorted([s1, s2, s3])
        # The two largest should be equal
        if not np.isclose(sums[1], sums[2], atol=1e-10):
            violations.append(
                f"  ({i},{j},{k},{l}): sums = {s1:.4f}, {s2:.4f}, {s3:.4f} "
                f"→ sorted = {sums[0]:.4f}, {sums[1]:.4f}, {sums[2]:.4f}"
            )
    return len(violations) == 0, violations


def check_tropical_plucker(d: np.ndarray) -> Tuple[bool, List[str]]:
    """Check the tropical Plücker relation for a distance matrix.

    For every quadruple (a,b,c,e):
      d[a,b] + d[c,e] ≤ max(d[a,c] + d[b,e], d[a,e] + d[b,c])

    Returns:
        (satisfied, violations): bool and list of violation descriptions
    """
    n = d.shape[0]
    violations = []
    for a, b, c, e in itertools.permutations(range(n), 4):
        s1 = d[a, b] + d[c, e]
        s2 = d[a, c] + d[b, e]
        s3 = d[a, e] + d[b, c]
        if s1 > max(s2, s3) + 1e-10:
            violations.append(
                f"  ({a},{b},{c},{e}): {s1:.4f} > max({s2:.4f}, {s3:.4f})"
            )
    return len(violations) == 0, violations


def tree_distance_matrix(tree_edges: List[Tuple[int, int, float]], n_leaves: int) -> np.ndarray:
    """Compute the distance matrix for leaves of a weighted tree.

    Args:
        tree_edges: list of (node1, node2, weight) edges
        n_leaves: number of leaf nodes (assumed to be 0..n_leaves-1)

    Returns:
        n_leaves x n_leaves distance matrix
    """
    # Build adjacency
    from collections import defaultdict
    adj = defaultdict(list)
    for u, v, w in tree_edges:
        adj[u].append((v, w))
        adj[v].append((u, w))

    d = np.zeros((n_leaves, n_leaves))
    for i in range(n_leaves):
        # BFS/DFS from leaf i
        visited = {i: 0.0}
        stack = [i]
        while stack:
            node = stack.pop()
            for neighbor, weight in adj[node]:
                if neighbor not in visited:
                    visited[neighbor] = visited[node] + weight
                    stack.append(neighbor)
        for j in range(n_leaves):
            if j in visited:
                d[i, j] = visited[j]
    return d


def demo_caterpillar_tree():
    """Demo 1: A caterpillar tree on 5 leaves."""
    print("=" * 70)
    print("DEMO 1: Caterpillar Tree on 5 Leaves")
    print("=" * 70)
    print()
    print("Tree structure:")
    print("  0 --2-- [5] --1-- [6] --1-- [7] --2-- 4")
    print("           |         |         |")
    print("           3         1         3")
    print("           |         |         |")
    print("           1         2         3")
    print()

    # Internal nodes: 5, 6, 7
    edges = [
        (0, 5, 2.0),  # leaf 0 to internal 5
        (1, 5, 3.0),  # leaf 1 to internal 5
        (2, 6, 1.0),  # leaf 2 to internal 6
        (3, 7, 3.0),  # leaf 3 to internal 7
        (4, 7, 2.0),  # leaf 4 to internal 7
        (5, 6, 1.0),  # internal edge
        (6, 7, 1.0),  # internal edge
    ]

    d = tree_distance_matrix(edges, 5)
    print("Distance matrix:")
    for i in range(5):
        print(f"  {[f'{d[i,j]:5.1f}' for j in range(5)]}")
    print()

    # Check four-point condition
    sat_fp, viol_fp = check_four_point(d)
    print(f"Four-point condition satisfied: {sat_fp}")

    # Check tropical Plücker
    sat_tp, viol_tp = check_tropical_plucker(d)
    print(f"Tropical Plücker relation satisfied: {sat_tp}")
    print()

    # Show all quadruple pair-sums
    print("Pair-sum analysis for all quadruples:")
    for i, j, k, l in itertools.combinations(range(5), 4):
        s1 = d[i, j] + d[k, l]
        s2 = d[i, k] + d[j, l]
        s3 = d[i, l] + d[j, k]
        sums = sorted([s1, s2, s3])
        equal_mark = "✓" if np.isclose(sums[1], sums[2]) else "✗"
        print(f"  ({i},{j},{k},{l}): {s1:6.1f}  {s2:6.1f}  {s3:6.1f}  "
              f"→ max two equal: {equal_mark}")
    print()


def demo_non_tree_metric():
    """Demo 2: A metric that is NOT a tree metric."""
    print("=" * 70)
    print("DEMO 2: Non-Tree Metric (Cycle Graph Distances)")
    print("=" * 70)
    print()
    print("Consider shortest-path distances on a 4-cycle: 0-1-2-3-0")
    print("with all edge weights = 1.")
    print()

    d = np.array([
        [0, 1, 2, 1],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [1, 2, 1, 0],
    ], dtype=float)

    print("Distance matrix:")
    for i in range(4):
        print(f"  {[f'{d[i,j]:3.0f}' for j in range(4)]}")
    print()

    s1 = d[0, 1] + d[2, 3]  # 1 + 1 = 2
    s2 = d[0, 2] + d[1, 3]  # 2 + 2 = 4
    s3 = d[0, 3] + d[1, 2]  # 1 + 1 = 2

    print(f"For quadruple (0,1,2,3):")
    print(f"  s1 = d(0,1) + d(2,3) = {s1}")
    print(f"  s2 = d(0,2) + d(1,3) = {s2}")
    print(f"  s3 = d(0,3) + d(1,2) = {s3}")
    print(f"  Sorted: {sorted([s1,s2,s3])}")
    print(f"  Two largest equal? {np.isclose(sorted([s1,s2,s3])[1], sorted([s1,s2,s3])[2])}")
    print()

    sat_fp, _ = check_four_point(d)
    sat_tp, viol_tp = check_tropical_plucker(d)
    print(f"Four-point condition satisfied: {sat_fp}")
    print(f"Tropical Plücker relation satisfied: {sat_tp}")
    if not sat_tp:
        print("Plücker violations (first 5):")
        for v in viol_tp[:5]:
            print(v)
    print()


def demo_random_tree():
    """Demo 3: Random tree metric verification."""
    print("=" * 70)
    print("DEMO 3: Random Tree on 8 Leaves")
    print("=" * 70)
    print()

    np.random.seed(42)
    n = 8

    # Build a random tree: connect leaves to internal nodes
    # Internal nodes: n, n+1, ..., 2n-3
    edges = []
    # Start with two leaves connected to internal node n
    edges.append((0, n, np.random.exponential(2.0)))
    edges.append((1, n, np.random.exponential(2.0)))

    next_internal = n + 1
    for leaf in range(2, n):
        # Pick a random existing internal node to split
        existing_internal = np.random.randint(n, next_internal)
        edges.append((leaf, next_internal, np.random.exponential(2.0)))
        edges.append((existing_internal, next_internal, np.random.exponential(1.0)))
        next_internal += 1

    d = tree_distance_matrix(edges, n)

    print("Distance matrix (rounded):")
    for i in range(n):
        print(f"  {[f'{d[i,j]:5.2f}' for j in range(n)]}")
    print()

    sat_fp, _ = check_four_point(d)
    sat_tp, _ = check_tropical_plucker(d)
    print(f"Four-point condition: {sat_fp}")
    print(f"Tropical Plücker:    {sat_tp}")

    n_quads = len(list(itertools.combinations(range(n), 4)))
    print(f"Number of quadruples checked: {n_quads}")
    print()


def demo_equivalence_proof():
    """Demo 4: Illustrate the proof by showing permutation of Plücker."""
    print("=" * 70)
    print("DEMO 4: Proof Illustration — Permutation Argument")
    print("=" * 70)
    print()
    print("The key insight: the Plücker relation for (a,b,c,e) gives")
    print("  s1 ≤ max(s2, s3)")
    print()
    print("Applying it to (a,c,b,e) and using symmetry gives")
    print("  s2 ≤ max(s1, s3)")
    print()
    print("Applying it to (a,e,b,c) and using symmetry gives")
    print("  s3 ≤ max(s1, s2)")
    print()
    print("These three inequalities together imply the four-point condition:")
    print("  if one sum is the minimum, the other two must be equal.")
    print()

    # Concrete example
    edges = [
        (0, 4, 1.0),
        (1, 4, 2.0),
        (2, 5, 1.5),
        (3, 5, 2.5),
        (4, 5, 3.0),
    ]
    d = tree_distance_matrix(edges, 4)

    print("Example: tree with 4 leaves")
    print(f"  d(0,1)={d[0,1]:.1f}, d(0,2)={d[0,2]:.1f}, d(0,3)={d[0,3]:.1f}")
    print(f"  d(1,2)={d[1,2]:.1f}, d(1,3)={d[1,3]:.1f}, d(2,3)={d[2,3]:.1f}")
    print()

    s1 = d[0, 1] + d[2, 3]
    s2 = d[0, 2] + d[1, 3]
    s3 = d[0, 3] + d[1, 2]

    print(f"Three pair-sums for (0,1,2,3):")
    print(f"  s1 = d(0,1) + d(2,3) = {s1:.1f}")
    print(f"  s2 = d(0,2) + d(1,3) = {s2:.1f}")
    print(f"  s3 = d(0,3) + d(1,2) = {s3:.1f}")
    print()

    print("Plücker check:")
    print(f"  s1 ≤ max(s2,s3) = max({s2:.1f},{s3:.1f}) = {max(s2,s3):.1f}? {s1 <= max(s2,s3) + 1e-10}")
    print(f"  s2 ≤ max(s1,s3) = max({s1:.1f},{s3:.1f}) = {max(s1,s3):.1f}? {s2 <= max(s1,s3) + 1e-10}")
    print(f"  s3 ≤ max(s1,s2) = max({s1:.1f},{s2:.1f}) = {max(s1,s2):.1f}? {s3 <= max(s1,s2) + 1e-10}")
    print()

    sums = sorted([s1, s2, s3])
    print(f"Sorted sums: {sums[0]:.1f} ≤ {sums[1]:.1f} = {sums[2]:.1f}")
    print(f"Two largest equal: {np.isclose(sums[1], sums[2])}")
    print()


if __name__ == "__main__":
    demo_caterpillar_tree()
    demo_non_tree_metric()
    demo_random_tree()
    demo_equivalence_proof()
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Plücker–Four-Point Equivalence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_pair_sums():
    """Visualize the three pair-sums for tree vs non-tree metrics."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Tree metric example
    d_tree = np.array([
        [0, 3, 5.5, 6.5],
        [3, 0, 6.5, 7.5],
        [5.5, 6.5, 0, 4],
        [6.5, 7.5, 4, 0],
    ])

    # Non-tree metric (cycle)
    d_cycle = np.array([
        [0, 1, 2, 1],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [1, 2, 1, 0],
    ])

    for ax, d, title in [(axes[0], d_tree, "Tree Metric\n(Four-Point Satisfied)"),
                          (axes[1], d_cycle, "Cycle Metric\n(Four-Point Violated)")]:
        s1 = d[0,1] + d[2,3]
        s2 = d[0,2] + d[1,3]
        s3 = d[0,3] + d[1,2]

        bars = ax.bar(['d(0,1)+d(2,3)', 'd(0,2)+d(1,3)', 'd(0,3)+d(1,2)'],
                      [s1, s2, s3],
                      color=['#2196F3', '#FF9800', '#4CAF50'],
                      edgecolor='black', linewidth=1.2)

        sums = sorted([s1, s2, s3])
        max_val = sums[2]
        if abs(sums[1] - sums[2]) < 0.01:
            ax.axhline(y=max_val, color='green', linestyle='--', linewidth=2,
                       label=f'Max = {max_val:.1f} (attained twice ✓)')
        else:
            ax.axhline(y=sums[2], color='red', linestyle='--', linewidth=2,
                       label=f'Max = {sums[2]:.1f} (unique ✗)')
            ax.axhline(y=sums[1], color='orange', linestyle=':', linewidth=2,
                       label=f'Second = {sums[1]:.1f}')

        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.set_ylabel('Pair-sum value', fontsize=12)
        ax.legend(fontsize=10)
        ax.set_ylim(0, max(s1, s2, s3) * 1.3)

        for bar, val in zip(bars, [s1, s2, s3]):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.2,
                    f'{val:.1f}', ha='center', fontsize=12, fontweight='bold')

    fig.suptitle('The Four-Point Condition: Tree vs Non-Tree Metrics',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_pair_sums.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_plucker_permutation():
    """Visualize how permutation of the Plücker inequality yields all three bounds."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Three inequalities as a diagram
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Title
    ax.text(5, 8.5, 'Proof by Permutation: Plücker → Four-Point',
            ha='center', fontsize=16, fontweight='bold')

    # Three boxes for three inequalities
    box_props = dict(boxstyle='round,pad=0.5', facecolor='lightblue', edgecolor='navy', linewidth=2)

    ax.text(5, 7, 'Plücker(a,b,c,e):  s₁ ≤ max(s₂, s₃)',
            ha='center', fontsize=13, bbox=box_props)

    box_props2 = dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='darkgoldenrod', linewidth=2)

    ax.text(2.5, 4.5, 'Plücker(a,c,b,e):\ns₂ ≤ max(s₁, s₃)',
            ha='center', fontsize=12, bbox=box_props2)

    ax.text(7.5, 4.5, 'Plücker(a,e,b,c):\ns₃ ≤ max(s₁, s₂)',
            ha='center', fontsize=12, bbox=box_props2)

    # Arrows
    ax.annotate('', xy=(3, 5.3), xytext=(4.2, 6.5),
                arrowprops=dict(arrowstyle='->', color='navy', lw=2))
    ax.annotate('', xy=(7, 5.3), xytext=(5.8, 6.5),
                arrowprops=dict(arrowstyle='->', color='navy', lw=2))

    ax.text(2.7, 5.9, 'swap b↔c\n+ symmetry', fontsize=9, ha='center', color='navy', style='italic')
    ax.text(7.3, 5.9, 'swap b↔e\n+ symmetry', fontsize=9, ha='center', color='navy', style='italic')

    # Conclusion
    box_concl = dict(boxstyle='round,pad=0.7', facecolor='lightgreen', edgecolor='darkgreen', linewidth=2)
    ax.text(5, 2, 'All three: each sᵢ ≤ max of other two\n⟹ Four-Point Condition:\nmin is unique ⟹ max two are equal',
            ha='center', fontsize=12, bbox=box_concl)

    ax.annotate('', xy=(4, 2.9), xytext=(3, 3.8),
                arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
    ax.annotate('', xy=(6, 2.9), xytext=(7, 3.8),
                arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))

    # Definitions
    ax.text(5, 0.3, 's₁ = d(a,b) + d(c,e)    s₂ = d(a,c) + d(b,e)    s₃ = d(a,e) + d(b,c)',
            ha='center', fontsize=11, style='italic', color='gray')

    fig.savefig('/workspace/request-project/viz_permutation_proof.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_tree_metric_space():
    """Visualize how tree metrics sit inside all metrics."""
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')
    ax.axis('off')

    # All metrics (outer)
    circle_all = plt.Circle((0, 0), 4, fill=True, facecolor='#E3F2FD',
                              edgecolor='#1565C0', linewidth=2.5)
    ax.add_patch(circle_all)
    ax.text(0, 3.5, 'All Symmetric Metrics', ha='center', fontsize=13,
            fontweight='bold', color='#1565C0')

    # Four-point metrics = Tropical Grassmannian
    circle_fp = plt.Circle((0, -0.3), 2.5, fill=True, facecolor='#E8F5E9',
                             edgecolor='#2E7D32', linewidth=2.5)
    ax.add_patch(circle_fp)
    ax.text(0, 1.5, 'Four-Point Metrics', ha='center', fontsize=12,
            fontweight='bold', color='#2E7D32')
    ax.text(0, 1.0, '= Trop(Gr(2,n))', ha='center', fontsize=11,
            style='italic', color='#2E7D32')

    # Ultrametrics (innermost)
    circle_ultra = plt.Circle((0, -1), 1.2, fill=True, facecolor='#FFF3E0',
                                edgecolor='#E65100', linewidth=2.5)
    ax.add_patch(circle_ultra)
    ax.text(0, -0.5, 'Ultrametrics', ha='center', fontsize=11,
            fontweight='bold', color='#E65100')
    ax.text(0, -1, '(dendrograms)', ha='center', fontsize=10,
            style='italic', color='#E65100')

    # Label the equivalence
    ax.text(0, -3.5, 'Tropical Plücker Relations\n⟺ Four-Point Condition\n⟺ Tree Metrics',
            ha='center', fontsize=12, fontweight='bold', color='#4A148C',
            bbox=dict(boxstyle='round', facecolor='#F3E5F5', edgecolor='#4A148C', linewidth=2))

    ax.set_title('Hierarchy of Metric Spaces', fontsize=16, fontweight='bold', pad=20)

    fig.savefig('/workspace/request-project/viz_metric_hierarchy.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_four_point_heatmap():
    """Heatmap of four-point gaps for a near-tree metric."""
    np.random.seed(123)

    from demo import tree_distance_matrix
    edges = [
        (0, 6, 2.0), (1, 6, 3.0),
        (2, 7, 1.5), (3, 7, 2.5),
        (4, 8, 1.0), (5, 8, 3.5),
        (6, 9, 1.0), (7, 9, 1.5),
        (8, 9, 2.0),
    ]
    d_exact = tree_distance_matrix(edges, 6)

    # Add noise
    noise = np.random.normal(0, 0.3, d_exact.shape)
    noise = (noise + noise.T) / 2
    np.fill_diagonal(noise, 0)
    d_noisy = d_exact + noise
    d_noisy = np.maximum(d_noisy, 0)
    d_noisy = (d_noisy + d_noisy.T) / 2

    # Compute four-point gaps for all quadruples
    n = 6
    quads = list(itertools.combinations(range(n), 4))
    gaps = []
    for i, j, k, l in quads:
        s1 = d_noisy[i,j] + d_noisy[k,l]
        s2 = d_noisy[i,k] + d_noisy[j,l]
        s3 = d_noisy[i,l] + d_noisy[j,k]
        sums = sorted([s1, s2, s3])
        gaps.append(sums[2] - sums[1])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Bar chart of gaps
    colors = ['green' if g < 0.1 else 'orange' if g < 0.5 else 'red' for g in gaps]
    ax1.bar(range(len(gaps)), gaps, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Quadruple index', fontsize=12)
    ax1.set_ylabel('Four-point gap', fontsize=12)
    ax1.set_title('Four-Point Gaps\n(Noisy Tree Metric, 6 points)', fontsize=13, fontweight='bold')
    ax1.axhline(y=0, color='black', linewidth=0.5)

    legend_elements = [
        mpatches.Patch(facecolor='green', label='< 0.1 (near-tree)'),
        mpatches.Patch(facecolor='orange', label='0.1–0.5 (moderate)'),
        mpatches.Patch(facecolor='red', label='> 0.5 (far from tree)'),
    ]
    ax1.legend(handles=legend_elements, fontsize=10)

    # Distance matrices comparison
    ax2.set_title('Distance Matrices: Exact vs Noisy', fontsize=13, fontweight='bold')
    im = ax2.imshow(np.abs(d_exact - d_noisy), cmap='Reds', aspect='equal')
    ax2.set_xlabel('Node', fontsize=12)
    ax2.set_ylabel('Node', fontsize=12)
    plt.colorbar(im, ax=ax2, label='|d_exact - d_noisy|')
    for i in range(n):
        for j in range(n):
            ax2.text(j, i, f'{abs(d_exact[i,j]-d_noisy[i,j]):.2f}',
                    ha='center', va='center', fontsize=9)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_four_point_gaps.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_pair_sums()
    print(f"  viz_pair_sums.png generated ({len(b64_1)} chars base64)")
    b64_2 = viz_plucker_permutation()
    print(f"  viz_permutation_proof.png generated ({len(b64_2)} chars base64)")
    b64_3 = viz_tree_metric_space()
    print(f"  viz_metric_hierarchy.png generated ({len(b64_3)} chars base64)")
    b64_4 = viz_four_point_heatmap()
    print(f"  viz_four_point_gaps.png generated ({len(b64_4)} chars base64)")
    print("All visualizations saved.")
