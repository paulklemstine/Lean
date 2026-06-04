#!/usr/bin/env python3
"""
Proof DAG Structure Demo: Numerical Examples

Demonstrates the key theorems about Stratified Dependency DAGs with
concrete examples, computing hub scores, bottleneck indices, fragility,
and verifying the proven structural properties.
"""

import random
from collections import defaultdict
from typing import List, Tuple, Dict, Set

class StratDAG:
    """A Stratified Dependency DAG: nodes have ranks, edges go up in rank."""

    def __init__(self, n: int, edges: List[Tuple[int, int]], ranks: List[int]):
        self.n = n
        self.edges = set(edges)
        self.ranks = ranks
        # Verify rank condition
        for (i, j) in self.edges:
            assert ranks[i] < ranks[j], f"Edge ({i},{j}) violates rank order: {ranks[i]} >= {ranks[j]}"

    def in_degree(self, j: int) -> int:
        return sum(1 for i in range(self.n) if (i, j) in self.edges)

    def out_degree(self, i: int) -> int:
        return sum(1 for j in range(self.n) if (i, j) in self.edges)

    def hub_score(self, i: int) -> int:
        return self.out_degree(i)

    def edge_count(self) -> int:
        return len(self.edges)

    def depth(self) -> int:
        return max(self.ranks) if self.n > 0 else 0

    def width_at(self, k: int) -> int:
        return sum(1 for r in self.ranks if r == k)

    def num_levels(self) -> int:
        return len(set(self.ranks))

    def dependency_cone(self, i: int) -> Set[int]:
        """All nodes reachable from i via directed edges."""
        visited = set()
        stack = [i]
        while stack:
            node = stack.pop()
            for j in range(self.n):
                if (node, j) in self.edges and j not in visited:
                    visited.add(j)
                    stack.append(j)
        return visited

    def ancestry(self, j: int) -> Set[int]:
        """All nodes that can reach j."""
        visited = set()
        stack = [j]
        while stack:
            node = stack.pop()
            for i in range(self.n):
                if (i, node) in self.edges and i not in visited:
                    visited.add(i)
                    stack.append(i)
        return visited

    def fragility_index(self) -> float:
        if self.n == 0:
            return 0.0
        max_cone = max(len(self.dependency_cone(i)) for i in range(self.n))
        return max_cone / self.n

    def hub_concentration_ratio(self) -> float:
        if self.n == 0 or self.edge_count() == 0:
            return 0.0
        max_out = max(self.out_degree(i) for i in range(self.n))
        avg_out = self.edge_count() / self.n
        return max_out / avg_out


def build_example_math_dag() -> StratDAG:
    """
    Build a small proof DAG modeling a fragment of real analysis:
    0: Axiom of Completeness (rank 0)
    1: Archimedean Property (rank 1)
    2: Monotone Convergence (rank 1)
    3: Bolzano-Weierstrass (rank 2)
    4: Cauchy Criterion (rank 3)
    5: Intermediate Value Theorem (rank 2)
    6: Extreme Value Theorem (rank 3)
    7: Rolle's Theorem (rank 4)
    8: Mean Value Theorem (rank 5)
    9: L'Hôpital's Rule (rank 6)
    """
    n = 10
    ranks = [0, 1, 1, 2, 3, 2, 3, 4, 5, 6]
    edges = [
        (0, 1), (0, 2),         # Completeness → Archimedean, Monotone Conv
        (0, 3), (2, 3),         # Completeness, Monotone → Bolzano-Weierstrass
        (1, 4), (3, 4),         # Archimedean, B-W → Cauchy
        (0, 5),                 # Completeness → IVT
        (3, 6), (5, 6),         # B-W, IVT → EVT
        (5, 7), (6, 7),         # IVT, EVT → Rolle
        (7, 8),                 # Rolle → MVT
        (8, 9),                 # MVT → L'Hôpital
    ]
    return StratDAG(n, edges, ranks)


def verify_theorems(G: StratDAG, name: str):
    """Verify all proven theorems on a concrete DAG."""
    print(f"\n{'='*60}")
    print(f"  Verifying Theorems: {name}")
    print(f"{'='*60}")
    print(f"  Nodes: {G.n}, Edges: {G.edge_count()}")
    print(f"  Depth: {G.depth()}, Levels: {G.num_levels()}")

    # Theorem: no_self_edge
    for i in range(G.n):
        assert (i, i) not in G.edges, f"Self-edge at {i}!"
    print("  ✓ no_self_edge: No self-loops")

    # Theorem: same_level_independent
    for (i, j) in G.edges:
        assert G.ranks[i] != G.ranks[j], f"Same-level edge ({i},{j})!"
    print("  ✓ same_level_independent: No edges within levels")

    # Theorem: sum_inDegree_eq_edgeCount
    total_in = sum(G.in_degree(j) for j in range(G.n))
    assert total_in == G.edge_count()
    print(f"  ✓ sum_inDegree = edgeCount = {G.edge_count()}")

    # Theorem: sum_outDegree_eq_edgeCount
    total_out = sum(G.out_degree(i) for i in range(G.n))
    assert total_out == G.edge_count()
    print(f"  ✓ sum_outDegree = edgeCount = {G.edge_count()}")

    # Theorem: exists_source
    sources = [i for i in range(G.n) if G.in_degree(i) == 0]
    assert len(sources) > 0
    print(f"  ✓ exists_source: Sources = {sources}")

    # Theorem: exists_sink
    sinks = [i for i in range(G.n) if G.out_degree(i) == 0]
    assert len(sinks) > 0
    print(f"  ✓ exists_sink: Sinks = {sinks}")

    # Theorem: bottleneck_bound
    max_width = max(G.width_at(k) for k in set(G.ranks))
    assert G.n // G.num_levels() <= max_width
    print(f"  ✓ bottleneck_bound: ⌊n/levels⌋ = {G.n // G.num_levels()} ≤ max_width = {max_width}")

    # Theorem: edge_count_le_sq
    assert G.edge_count() <= G.n * G.n
    print(f"  ✓ edge_count ≤ n² = {G.n * G.n}")

    # Theorem: fragilityIndex_le_one
    fi = G.fragility_index()
    assert fi <= 1.0
    print(f"  ✓ fragilityIndex = {fi:.3f} ≤ 1")

    # Theorem: cone_subset_of_reachable
    for (i, j) in G.edges:
        cone_j = G.dependency_cone(j)
        cone_i = G.dependency_cone(i)
        assert cone_j.issubset(cone_i), f"Cone containment fails for ({i},{j})"
    print("  ✓ cone_subset_of_reachable: Verified")

    # Theorem: ancestry_size_ge_inDegree
    for j in range(G.n):
        assert G.in_degree(j) <= len(G.ancestry(j))
    print("  ✓ ancestry_size ≥ inDegree: Verified")

    # Hub analysis
    print(f"\n  Hub Analysis:")
    hub_scores = [(i, G.hub_score(i)) for i in range(G.n)]
    hub_scores.sort(key=lambda x: -x[1])
    for i, score in hub_scores[:5]:
        cone_size = len(G.dependency_cone(i))
        print(f"    Node {i}: hubScore={score}, cone={cone_size}, ancestry={len(G.ancestry(i))}")

    print(f"  Hub concentration ratio: {G.hub_concentration_ratio():.2f}")


def generate_random_dag(n: int, edge_prob: float = 0.3) -> StratDAG:
    """Generate a random stratified DAG."""
    ranks = sorted(random.choices(range(n // 2 + 1), k=n))
    edges = []
    for i in range(n):
        for j in range(n):
            if ranks[i] < ranks[j] and random.random() < edge_prob:
                edges.append((i, j))
    return StratDAG(n, edges, ranks)


def degree_distribution_analysis(G: StratDAG):
    """Analyze the degree distribution of a DAG."""
    print(f"\n  Degree Distribution Analysis (n={G.n}):")
    out_degrees = [G.out_degree(i) for i in range(G.n)]
    in_degrees = [G.in_degree(i) for i in range(G.n)]

    # Histogram
    out_hist: Dict[int, int] = defaultdict(int)
    in_hist: Dict[int, int] = defaultdict(int)
    for d in out_degrees:
        out_hist[d] += 1
    for d in in_degrees:
        in_hist[d] += 1

    print(f"    Out-degree distribution: {dict(sorted(out_hist.items()))}")
    print(f"    In-degree distribution: {dict(sorted(in_hist.items()))}")
    print(f"    Max out-degree: {max(out_degrees)}")
    print(f"    Max in-degree: {max(in_degrees)}")
    print(f"    Avg out-degree: {sum(out_degrees)/len(out_degrees):.2f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Proof DAGs: Network Structure of Mathematics        ║")
    print("║     Stratified Dependency DAG Demo                      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Example 1: Real Analysis proof DAG
    G1 = build_example_math_dag()
    verify_theorems(G1, "Real Analysis Fragment")
    degree_distribution_analysis(G1)

    # Example 2: Random DAG
    random.seed(42)
    G2 = generate_random_dag(50, 0.15)
    verify_theorems(G2, "Random DAG (n=50)")
    degree_distribution_analysis(G2)

    # Example 3: Linear chain (worst case for bottleneck)
    n_chain = 20
    chain_edges = [(i, i+1) for i in range(n_chain - 1)]
    chain_ranks = list(range(n_chain))
    G3 = StratDAG(n_chain, chain_edges, chain_ranks)
    verify_theorems(G3, "Linear Chain (n=20)")

    # Example 4: Star graph (hub-dominated)
    n_star = 15
    star_edges = [(0, i) for i in range(1, n_star)]
    star_ranks = [0] + [1] * (n_star - 1)
    G4 = StratDAG(n_star, star_edges, star_ranks)
    verify_theorems(G4, "Star Hub (n=15)")
    print(f"\n  Star hub fragility: {G4.fragility_index():.3f}")
    print(f"  Star hub concentration: {G4.hub_concentration_ratio():.1f}")

    print("\n\n✅ All theorems verified on all examples!")


#!/usr/bin/env python3
"""
Visualization: Proof DAG Structure

Generates three plots:
1. The real analysis proof DAG as a layered graph
2. Hub score distribution
3. Fragility analysis under hub removal
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict
import random
import math


def compute_ranks_fn(n, edges):
    adj = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)
    in_deg = defaultdict(int)
    for i in range(n):
        in_deg[i] = 0
    for u, v in edges:
        in_deg[v] += 1
    queue = [v for v in range(n) if in_deg[v] == 0]
    order = []
    while queue:
        u = queue.pop(0)
        order.append(u)
        for v in adj[u]:
            in_deg[v] -= 1
            if in_deg[v] == 0:
                queue.append(v)
    ranks = [0] * n
    for u in order:
        for v in adj[u]:
            ranks[v] = max(ranks[v], ranks[u] + 1)
    return ranks


def compute_cones(n, edges):
    adj = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)
    order = []
    in_deg = defaultdict(int)
    for i in range(n):
        in_deg[i] = 0
    for u, v in edges:
        in_deg[v] += 1
    queue = [v for v in range(n) if in_deg[v] == 0]
    while queue:
        u = queue.pop(0)
        order.append(u)
        for v in adj[u]:
            in_deg[v] -= 1
            if in_deg[v] == 0:
                queue.append(v)
    cones = {}
    for u in reversed(order):
        cone = set()
        for v in adj[u]:
            cone.add(v)
            cone |= cones.get(v, set())
        cones[u] = cone
    return cones


def plot_proof_dag():
    """Plot 1: Real analysis proof DAG as layered graph."""
    n = 10
    names = [
        "Completeness\nAxiom", "Archimedean\nProperty", "Monotone\nConvergence",
        "Bolzano-\nWeierstrass", "Cauchy\nCriterion", "Intermediate\nValue Thm",
        "Extreme\nValue Thm", "Rolle's\nTheorem", "Mean Value\nTheorem",
        "L'Hôpital's\nRule"
    ]
    edges = [
        (0, 1), (0, 2), (0, 3), (2, 3), (1, 4), (3, 4),
        (0, 5), (3, 6), (5, 6), (5, 7), (6, 7), (7, 8), (8, 9),
    ]
    ranks = [0, 1, 1, 2, 3, 2, 3, 4, 5, 6]

    # Compute hub scores
    out_deg = defaultdict(int)
    for u, v in edges:
        out_deg[u] += 1
    hub_scores = [out_deg.get(i, 0) for i in range(n)]

    # Layout: x by level position, y by rank
    level_nodes = defaultdict(list)
    for i, r in enumerate(ranks):
        level_nodes[r].append(i)

    pos = {}
    for r, nodes in level_nodes.items():
        for idx, node in enumerate(nodes):
            x = (idx - (len(nodes) - 1) / 2) * 2.5
            y = -r * 1.8
            pos[node] = (x, y)

    fig, ax = plt.subplots(1, 1, figsize=(14, 12))

    # Draw edges
    for u, v in edges:
        x1, y1 = pos[u]
        x2, y2 = pos[v]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="->", color="#555555",
                                     connectionstyle="arc3,rad=0.1",
                                     lw=1.5))

    # Draw nodes
    max_hub = max(hub_scores)
    for i in range(n):
        x, y = pos[i]
        size = 800 + hub_scores[i] * 400
        color_val = hub_scores[i] / max(max_hub, 1)
        color = plt.cm.YlOrRd(0.2 + 0.7 * color_val)
        ax.scatter(x, y, s=size, c=[color], zorder=5,
                   edgecolors='black', linewidths=2)
        ax.text(x, y, names[i], ha='center', va='center',
                fontsize=7, fontweight='bold', zorder=6)

    ax.set_title("Stratified Proof DAG: Real Analysis\n"
                 "Node size ∝ hub score (out-degree), Color ∝ influence",
                 fontsize=14, fontweight='bold')
    ax.set_ylabel("Proof Depth (rank) →", fontsize=12)
    ax.set_xlim(-5, 5)
    ax.axis('off')

    # Add level labels
    for r in sorted(level_nodes.keys()):
        y = -r * 1.8
        ax.text(-4.5, y, f"Level {r}", fontsize=10, color='gray',
                ha='right', va='center')

    plt.tight_layout()
    plt.savefig("proof_dag_structure.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: proof_dag_structure.png")


def plot_hub_analysis():
    """Plot 2: Hub score and fragility analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Generate random DAGs of various sizes and compute hub concentration
    random.seed(42)
    sizes = [20, 50, 100, 200, 500]
    concentrations = []
    fragilities = []

    for n in sizes:
        conc_samples = []
        frag_samples = []
        for _ in range(20):
            ranks = sorted(random.choices(range(n // 3 + 1), k=n))
            edges = []
            for i in range(n):
                for j in range(n):
                    if ranks[i] < ranks[j] and random.random() < 3.0 / n:
                        edges.append((i, j))
            if not edges:
                continue
            out_degs = defaultdict(int)
            for u, v in edges:
                out_degs[u] += 1
            max_out = max(out_degs.values()) if out_degs else 0
            avg_out = len(edges) / n
            if avg_out > 0:
                conc_samples.append(max_out / avg_out)

            cones = compute_cones(n, edges)
            max_cone = max((len(c) for c in cones.values()), default=0)
            frag_samples.append(max_cone / n)

        if conc_samples:
            concentrations.append((n, sum(conc_samples)/len(conc_samples)))
        if frag_samples:
            fragilities.append((n, sum(frag_samples)/len(frag_samples)))

    # Plot hub concentration
    ax1 = axes[0]
    if concentrations:
        xs, ys = zip(*concentrations)
        ax1.plot(xs, ys, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax1.set_xlabel("DAG Size (n)", fontsize=12)
    ax1.set_ylabel("Hub Concentration Ratio", fontsize=12)
    ax1.set_title("Hub Concentration vs DAG Size\n"
                  "(max out-degree / avg out-degree)", fontsize=13, fontweight='bold')
    ax1.set_xscale('log')
    ax1.grid(True, alpha=0.3)

    # Plot fragility
    ax2 = axes[1]
    if fragilities:
        xs, ys = zip(*fragilities)
        ax2.plot(xs, ys, 's-', color='#2ecc71', linewidth=2, markersize=8)
    ax2.set_xlabel("DAG Size (n)", fontsize=12)
    ax2.set_ylabel("Fragility Index", fontsize=12)
    ax2.set_title("Fragility Index vs DAG Size\n"
                  "(max cone / n)", fontsize=13, fontweight='bold')
    ax2.set_xscale('log')
    ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Upper bound = 1')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("hub_analysis.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hub_analysis.png")


def plot_bottleneck():
    """Plot 3: Bottleneck theorem visualization."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Example DAG with clear bottleneck
    n = 30
    # Create a DAG with wide levels and a narrow bottleneck
    ranks = ([0]*5 + [1]*8 + [2]*2 + [3]*7 + [4]*8)
    level_widths = defaultdict(int)
    for r in ranks:
        level_widths[r] += 1

    levels = sorted(level_widths.keys())
    widths = [level_widths[l] for l in levels]
    colors = ['#3498db' if w > n // len(levels) else '#e74c3c' for w in widths]

    bars = ax.barh(levels, widths, color=colors, edgecolor='black', height=0.6)

    # Bottleneck line
    threshold = n // len(levels)
    ax.axvline(x=threshold, color='red', linestyle='--', linewidth=2,
               label=f'Bottleneck bound ⌊n/L⌋ = {threshold}')

    ax.set_xlabel("Width (number of nodes)", fontsize=12)
    ax.set_ylabel("Level (rank)", fontsize=12)
    ax.set_title("Bottleneck Theorem Visualization\n"
                 f"n={n}, L={len(levels)} levels → some level has width ≥ ⌊{n}/{len(levels)}⌋ = {threshold}",
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)

    # Annotate bottleneck level
    min_width = min(widths)
    min_level = levels[widths.index(min_width)]
    ax.annotate(f"Bottleneck!\nwidth={min_width}",
                xy=(min_width, min_level), xytext=(min_width + 3, min_level - 0.5),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=11, color='red', fontweight='bold')

    ax.invert_yaxis()
    ax.grid(True, axis='x', alpha=0.3)
    plt.tight_layout()
    plt.savefig("bottleneck_theorem.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bottleneck_theorem.png")


if __name__ == "__main__":
    plot_proof_dag()
    plot_hub_analysis()
    plot_bottleneck()
    print("\nAll visualizations generated!")
