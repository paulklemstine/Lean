#!/usr/bin/env python3
"""
Demo: Erdős–Faber–Lovász Conjecture — Numerical Examples

Demonstrates:
1. Near-pencil construction and coloring for small k
2. Fisher pair-sharing bound verification
3. High-degree vertex analysis
4. Greedy coloring performance
5. Probabilistic coloring estimates
"""

from algorithms import (
    EFLSystem, construct_near_pencil, construct_disjoint_system,
    greedy_rainbow_coloring, verify_strong_coloring,
    fisher_pair_bound, sunflower_core_analysis,
    probabilistic_coloring_bound
)


def demo_near_pencil():
    """Demonstrate near-pencil construction and coloring for small k."""
    print("=" * 60)
    print("NEAR-PENCIL EFL SYSTEMS")
    print("=" * 60)

    for k in range(2, 7):
        system = construct_near_pencil(k)
        assert system.is_valid(), f"Near-pencil with k={k} is not valid!"

        vertices = system.vertex_set()
        coloring = greedy_rainbow_coloring(system)

        print(f"\nk = {k}:")
        print(f"  Edges: {[sorted(e) for e in system.edges]}")
        print(f"  Vertices: {sorted(vertices)}")
        print(f"  |V| = {len(vertices)} (expected: k²-k+1 = {k**2 - k + 1})")
        print(f"  Incidence count = {system.incidence_count()} (expected: k² = {k**2})")

        if coloring:
            max_color = max(coloring.values())
            print(f"  Greedy coloring: {coloring}")
            print(f"  Colors used: {max_color + 1} (bound: k = {k})")
            print(f"  Valid: {verify_strong_coloring(system, coloring)}")
        else:
            print("  Greedy coloring FAILED (needed > k colors)")


def demo_fisher_bound():
    """Verify the Fisher pair-sharing bound."""
    print("\n" + "=" * 60)
    print("FISHER PAIR-SHARING BOUND")
    print("=" * 60)

    for k in range(2, 8):
        # Near-pencil (maximal sharing)
        np = construct_near_pencil(k)
        actual_np, bound_np = fisher_pair_bound(np)
        print(f"\nk = {k}, Near-pencil:")
        print(f"  Σ|eᵢ∩eⱼ| = {actual_np} ≤ k(k-1) = {bound_np}  ✓" if actual_np <= bound_np else "  BOUND VIOLATED!")

        # Disjoint system (no sharing)
        ds = construct_disjoint_system(k)
        actual_ds, bound_ds = fisher_pair_bound(ds)
        print(f"  Disjoint: Σ|eᵢ∩eⱼ| = {actual_ds} ≤ k(k-1) = {bound_ds}")


def demo_degree_analysis():
    """Analyze degree distributions in EFL systems."""
    print("\n" + "=" * 60)
    print("DEGREE ANALYSIS")
    print("=" * 60)

    for k in range(3, 8):
        system = construct_near_pencil(k)
        degrees = sunflower_core_analysis(system)

        deg_dist = {}
        for v, d in degrees.items():
            deg_dist[d] = deg_dist.get(d, 0) + 1

        high_deg = sum(1 for d in degrees.values() if d >= 2)
        bound = k * (k - 1) // 2

        print(f"\nk = {k}, Near-pencil:")
        print(f"  Degree distribution: {dict(sorted(deg_dist.items()))}")
        print(f"  High-degree vertices: {high_deg} ≤ k(k-1)/2 = {bound}  ✓" if high_deg <= bound else "  BOUND VIOLATED!")
        print(f"  Center vertex degree: {max(degrees.values())}")
        print(f"  Degree sum: {sum(degrees.values())} = k² = {k**2}")


def demo_greedy_coloring():
    """Test greedy coloring on various EFL systems."""
    print("\n" + "=" * 60)
    print("GREEDY COLORING PERFORMANCE")
    print("=" * 60)

    for k in range(2, 10):
        # Near-pencil
        np = construct_near_pencil(k)
        coloring = greedy_rainbow_coloring(np)
        if coloring:
            colors = max(coloring.values()) + 1
            status = "✓" if colors <= k else f"✗ (used {colors})"
        else:
            status = "✗ (failed)"
        print(f"k={k}: Near-pencil → {status}")


def demo_probabilistic():
    """Demonstrate probabilistic coloring estimates."""
    print("\n" + "=" * 60)
    print("PROBABILISTIC COLORING PROBABILITY")
    print("=" * 60)
    print("P(random k-coloring of near-pencil is valid)")

    for k in range(2, 8):
        prob = probabilistic_coloring_bound(k, trials=10000)
        print(f"k={k}: P(valid) ≈ {prob:.4f}")


if __name__ == "__main__":
    demo_near_pencil()
    demo_fisher_bound()
    demo_degree_analysis()
    demo_greedy_coloring()
    demo_probabilistic()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The Erdős–Faber–Lovász conjecture states that any EFL system
with parameter k is k-colorable (admits a strong coloring
with k colors).

Key verified structural results:
  • Incidence count = k² (double-counting)
  • Pairwise intersection sum ≤ k(k-1) (Fisher bound)
  • Max degree ≤ k
  • High-degree vertices ≤ k(k-1)/2
  • Edge injectivity for k ≥ 2
  • EFL holds for k ≤ 1 and for disjoint systems
  • Unique intersection vertex (linearity consequence)
""")


#!/usr/bin/env python3
"""
Visualization: EFL System Structure and Coloring

Generates a visualization of the near-pencil EFL system showing:
- The hypergraph structure with edges as colored regions
- The degree distribution
- The Fisher bound verification
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.collections import PatchCollection


def draw_near_pencil(k: int, ax: plt.Axes) -> None:
    """Draw the near-pencil EFL system as a star diagram."""
    # Center vertex
    center = (0, 0)

    # Compute petal positions
    angles = np.linspace(0, 2 * np.pi, k, endpoint=False) - np.pi / 2
    petal_radius = 2.0
    vertex_radius = 0.15

    # Colors for edges
    cmap = plt.cm.Set3
    edge_colors = [cmap(i / max(k, 1)) for i in range(k)]

    # Draw edges as wedge-shaped regions
    for i in range(k):
        angle = angles[i]
        # Draw petal vertices along a line from center
        for j in range(k - 1):
            r = petal_radius * (j + 1) / (k - 1) if k > 1 else petal_radius
            x = r * np.cos(angle)
            y = r * np.sin(angle)
            # Spread petals slightly
            spread = 0.3
            dx = spread * np.cos(angle + np.pi / 2) * (j % 2 * 2 - 1) * (j // 2 + 1) / k
            dy = spread * np.sin(angle + np.pi / 2) * (j % 2 * 2 - 1) * (j // 2 + 1) / k

            circle = plt.Circle((x + dx, y + dy), vertex_radius,
                                color=edge_colors[i], ec='black', lw=1.5, zorder=3)
            ax.add_patch(circle)
            ax.plot([0, x + dx], [0, y + dy], color=edge_colors[i],
                    alpha=0.3, lw=2, zorder=1)

    # Draw center vertex
    circle = plt.Circle(center, vertex_radius * 1.3,
                        color='red', ec='black', lw=2, zorder=4)
    ax.add_patch(circle)
    ax.text(0, 0, '★', ha='center', va='center', fontsize=10, zorder=5)

    ax.set_xlim(-petal_radius - 1, petal_radius + 1)
    ax.set_ylim(-petal_radius - 1, petal_radius + 1)
    ax.set_aspect('equal')
    ax.set_title(f'Near-Pencil (k={k})\n{k**2 - k + 1} vertices, {k} edges',
                 fontsize=12, fontweight='bold')
    ax.axis('off')


def plot_degree_distribution(ax: plt.Axes) -> None:
    """Plot degree distribution for near-pencils of various k."""
    ks = range(2, 11)
    deg1_counts = [k * (k - 1) for k in ks]
    degk_counts = [1 for _ in ks]

    ax.bar([k - 0.15 for k in ks], deg1_counts, 0.3, label='Degree 1', color='steelblue')
    ax.bar([k + 0.15 for k in ks], degk_counts, 0.3, label=f'Degree k', color='coral')
    ax.set_xlabel('k', fontsize=12)
    ax.set_ylabel('Number of vertices', fontsize=12)
    ax.set_title('Degree Distribution in Near-Pencil', fontsize=12, fontweight='bold')
    ax.legend()
    ax.set_xticks(list(ks))


def plot_fisher_bound(ax: plt.Axes) -> None:
    """Plot the Fisher pair-sharing bound vs actual sharing."""
    ks = range(2, 16)
    bounds = [k * (k - 1) for k in ks]
    # Near-pencil achieves equality
    actuals_np = [k * (k - 1) for k in ks]
    # Disjoint achieves 0
    actuals_disj = [0 for _ in ks]

    ax.fill_between(list(ks), bounds, alpha=0.2, color='red', label='Bound region')
    ax.plot(list(ks), bounds, 'r-', lw=2, label='Bound k(k-1)')
    ax.plot(list(ks), actuals_np, 'bo-', lw=2, label='Near-pencil (tight)')
    ax.plot(list(ks), actuals_disj, 'gs-', lw=2, label='Disjoint (0)')
    ax.set_xlabel('k', fontsize=12)
    ax.set_ylabel('Σ|eᵢ ∩ eⱼ| (ordered pairs)', fontsize=12)
    ax.set_title('Fisher Pair-Sharing Bound', fontsize=12, fontweight='bold')
    ax.legend()


def plot_vertex_count(ax: plt.Axes) -> None:
    """Plot vertex count extremes for EFL systems."""
    ks = range(1, 16)
    max_vertices = [k ** 2 for k in ks]  # disjoint
    near_pencil = [k ** 2 - k + 1 for k in ks]  # near-pencil
    min_vertices = [k for k in ks]  # all identical (only for k=1)

    ax.plot(list(ks), max_vertices, 'rs-', lw=2, label='Disjoint (k²)')
    ax.plot(list(ks), near_pencil, 'bo-', lw=2, label='Near-pencil (k²-k+1)')
    ax.plot(list(ks), min_vertices, 'g^-', lw=2, label='Minimum (k)')
    ax.fill_between(list(ks), min_vertices, max_vertices, alpha=0.1, color='blue')
    ax.set_xlabel('k', fontsize=12)
    ax.set_ylabel('|V|', fontsize=12)
    ax.set_title('Vertex Count Range for EFL Systems', fontsize=12, fontweight='bold')
    ax.legend()


def main():
    fig = plt.figure(figsize=(16, 12))

    # Near-pencil diagrams for k=3,4,5
    for idx, k in enumerate([3, 4, 5]):
        ax = fig.add_subplot(2, 3, idx + 1)
        draw_near_pencil(k, ax)

    # Analysis plots
    ax4 = fig.add_subplot(2, 3, 4)
    plot_degree_distribution(ax4)

    ax5 = fig.add_subplot(2, 3, 5)
    plot_fisher_bound(ax5)

    ax6 = fig.add_subplot(2, 3, 6)
    plot_vertex_count(ax6)

    plt.suptitle('Erdős–Faber–Lovász Conjecture: Structural Analysis',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('efl_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved efl_analysis.png")


if __name__ == "__main__":
    main()
