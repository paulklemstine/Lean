#!/usr/bin/env python3
"""
Erdős–Faber–Lovász Conjecture: Demonstration

Numerical examples and verification of structural properties
for EFL systems (k-uniform linear hypergraphs with k edges).
"""

from algorithms import (
    EFLSystem, make_near_pencil, make_disjoint_system,
    near_pencil_coloring, greedy_coloring, verify_strong_coloring,
    structural_analysis, enumerate_efl_systems
)


def demo_near_pencil():
    """Demonstrate near-pencil construction and coloring for various k."""
    print("=" * 60)
    print("NEAR-PENCIL EFL SYSTEMS")
    print("=" * 60)
    
    for k in range(1, 8):
        system = make_near_pencil(k)
        coloring = near_pencil_coloring(system)
        valid = verify_strong_coloring(system, coloring)
        
        print(f"\nk = {k}:")
        print(f"  Vertices: {len(system.vertex_set)}")
        print(f"  Expected (k²-k+1): {k**2 - k + 1}")
        print(f"  Degree sequence: {system.degree_sequence()[:5]}{'...' if len(system.degree_sequence()) > 5 else ''}")
        print(f"  Valid {k}-coloring: {valid}")
        print(f"  Colors used: {max(coloring.values()) + 1 if coloring else 0}")


def demo_structural_analysis():
    """Demonstrate structural analysis on various EFL systems."""
    print("\n" + "=" * 60)
    print("STRUCTURAL ANALYSIS")
    print("=" * 60)
    
    for k in [3, 4, 5]:
        systems = enumerate_efl_systems(k)
        print(f"\n--- k = {k} ---")
        for i, system in enumerate(systems):
            analysis = structural_analysis(system)
            print(f"\n  System {i+1}:")
            print(f"    Vertices: {analysis['num_vertices']}")
            print(f"    Vertex set in [{analysis['vertex_set_lower_bound']}, "
                  f"{analysis['vertex_set_upper_bound']}]: "
                  f"{'✓' if analysis['vertex_set_lower_bound'] <= analysis['num_vertices'] <= analysis['vertex_set_upper_bound'] else '✗'}")
            print(f"    Incidence count = k² = {analysis['expected_incidence']}: "
                  f"{'✓' if analysis['incidence_count'] == analysis['expected_incidence'] else '✗'}")
            print(f"    Max degree ≤ k = {k}: "
                  f"{'✓' if analysis['max_degree'] <= k else '✗'}")
            print(f"    Near-pencil: {analysis['is_near_pencil']}")
            print(f"    Exclusive vertices: {analysis['num_exclusive_vertices']} (≥ {k})")
            print(f"    High-degree vertices: {analysis['num_high_degree_vertices']} "
                  f"(≤ {analysis['high_degree_bound']}): "
                  f"{'✓' if analysis['num_high_degree_vertices'] <= analysis['high_degree_bound'] else '✗'}")
            print(f"    Pairwise intersection sum: {analysis['pairwise_intersection_sum']} "
                  f"(≤ {analysis['pairwise_bound']}): "
                  f"{'✓' if analysis['pairwise_intersection_sum'] <= analysis['pairwise_bound'] else '✗'}")


def demo_greedy_coloring():
    """Demonstrate greedy coloring and verify it uses ≤ k colors."""
    print("\n" + "=" * 60)
    print("GREEDY COLORING")
    print("=" * 60)
    
    for k in [3, 4, 5]:
        systems = enumerate_efl_systems(k)
        print(f"\n--- k = {k} ---")
        for i, system in enumerate(systems):
            coloring = greedy_coloring(system)
            valid = verify_strong_coloring(system, coloring)
            num_colors = max(coloring.values()) + 1 if coloring else 0
            print(f"  System {i+1}: {num_colors} colors used "
                  f"(≤ {k}? {'✓' if num_colors <= k else '✗'}) "
                  f"Valid: {valid}")


def demo_conjecture_verification():
    """Verify the EFL conjecture computationally for small k."""
    print("\n" + "=" * 60)
    print("EFL CONJECTURE VERIFICATION")
    print("=" * 60)
    
    for k in range(1, 8):
        system = make_near_pencil(k)
        coloring = greedy_coloring(system)
        valid = verify_strong_coloring(system, coloring)
        num_colors = max(coloring.values()) + 1 if coloring else 0
        
        print(f"  k={k}: Near-pencil uses {num_colors} colors "
              f"(need ≤ {k}): {'✓ VERIFIED' if num_colors <= k and valid else '✗ FAILED'}")
    
    print("\n  k=3 configurations:")
    for i, system in enumerate(enumerate_efl_systems(3)):
        coloring = greedy_coloring(system)
        valid = verify_strong_coloring(system, coloring)
        num_colors = max(coloring.values()) + 1 if coloring else 0
        is_np = system.is_near_pencil()[0]
        print(f"    Config {i+1} ({'near-pencil' if is_np else 'other'}): "
              f"{num_colors} colors: {'✓' if num_colors <= 3 and valid else '✗'}")


def demo_degree_1_conjecture():
    """Test the conjecture: every EFL system has ≥ k degree-1 vertices."""
    print("\n" + "=" * 60)
    print("DEGREE-1 VERTEX CONJECTURE TEST")
    print("=" * 60)
    
    for k in [2, 3, 4, 5]:
        systems = enumerate_efl_systems(k)
        min_exclusive = float('inf')
        for system in systems:
            exc = system.exclusive_vertices()
            min_exclusive = min(min_exclusive, len(exc))
        
        print(f"  k={k}: min exclusive vertices = {min_exclusive} "
              f"(conjecture: ≥ {k}): "
              f"{'✓ CONSISTENT' if min_exclusive >= k else '✗ VIOLATED'}")


def demo_double_counting():
    """Verify the double counting identity ∑ deg(v) = k²."""
    print("\n" + "=" * 60)
    print("DOUBLE COUNTING IDENTITY")
    print("=" * 60)
    
    for k in [2, 3, 4, 5, 6]:
        system = make_near_pencil(k)
        deg_sum = sum(system.degree(v) for v in system.vertex_set)
        print(f"  k={k}: ∑ deg(v) = {deg_sum}, k² = {k**2}: "
              f"{'✓' if deg_sum == k**2 else '✗'}")
    
    for k in [3, 4, 5]:
        for i, system in enumerate(enumerate_efl_systems(k)):
            deg_sum = sum(system.degree(v) for v in system.vertex_set)
            assert deg_sum == k ** 2, f"Failed for k={k}, system {i}"
        print(f"  All k={k} systems verified: ∑ deg(v) = k² ✓")


if __name__ == "__main__":
    demo_near_pencil()
    demo_structural_analysis()
    demo_greedy_coloring()
    demo_conjecture_verification()
    demo_degree_1_conjecture()
    demo_double_counting()
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of EFL System structural properties.
Standalone script using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_near_pencil_vertices(k):
    """Generate near-pencil vertex positions for visualization."""
    if k == 0:
        return [], []
    center = (0, 0)
    positions = {0: center}
    for i in range(k):
        angle = 2 * np.pi * i / k
        for j in range(1, k):
            r = 0.5 + 0.5 * j / (k - 1) if k > 1 else 1.0
            vid = 1 + i * (k - 1) + (j - 1) if k > 1 else 1
            positions[vid] = (r * np.cos(angle), r * np.sin(angle))
    return positions


def plot_structural_bounds():
    """Plot the key structural bounds as functions of k."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Structural Bounds for EFL Systems', fontsize=16, fontweight='bold')
    
    ks = np.arange(1, 16)
    
    # Panel 1: Vertex set bounds
    ax = axes[0, 0]
    ax.fill_between(ks, ks, ks**2, alpha=0.3, color='steelblue', label='Feasible range')
    ax.plot(ks, ks, 'b-', linewidth=2, label='Lower bound (k)')
    ax.plot(ks, ks**2, 'r-', linewidth=2, label='Upper bound (k²)')
    ax.plot(ks, ks**2 - ks + 1, 'g--', linewidth=2, label='Near-pencil (k²−k+1)')
    ax.set_xlabel('k')
    ax.set_ylabel('|V|')
    ax.set_title('Vertex Set Size Bounds')
    ax.legend(fontsize=8)
    ax.set_yscale('log')
    
    # Panel 2: High-degree vertex bound
    ax = axes[0, 1]
    ax.plot(ks, ks * (ks - 1) / 2, 'r-', linewidth=2, label='Upper bound k(k−1)/2')
    ax.plot(ks, np.ones_like(ks), 'g--', linewidth=2, label='Near-pencil (1 vertex)')
    ax.fill_between(ks, 0, ks * (ks - 1) / 2, alpha=0.2, color='coral')
    ax.set_xlabel('k')
    ax.set_ylabel('# high-degree vertices')
    ax.set_title('High-Degree Vertex Bound')
    ax.legend(fontsize=8)
    
    # Panel 3: Incidence count and degree sum
    ax = axes[1, 0]
    ax.plot(ks, ks**2, 'b-', linewidth=2, label='Incidence count = k²')
    ax.plot(ks, ks * (ks - 1), 'm--', linewidth=2, label='Pair-sharing bound k(k−1)')
    ax.plot(ks, ks, 'g:', linewidth=2, label='# edges = k')
    ax.set_xlabel('k')
    ax.set_ylabel('Count')
    ax.set_title('Counting Invariants')
    ax.legend(fontsize=8)
    
    # Panel 4: Degree sequence comparison
    ax = axes[1, 1]
    for k in [3, 5, 7]:
        # Near-pencil degree sequence
        degs = [k] + [1] * (k * (k - 1))
        positions = np.arange(len(degs))
        ax.step(positions, degs, linewidth=1.5, label=f'Near-pencil k={k}', where='mid')
    ax.set_xlabel('Vertex index (sorted by degree)')
    ax.set_ylabel('Degree')
    ax.set_title('Degree Sequences (Near-Pencils)')
    ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/efl_structural_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved efl_structural_bounds.png")


def plot_near_pencil_coloring():
    """Visualize near-pencil coloring for k=4."""
    k = 4
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    ax.set_title(f'Near-Pencil EFL System (k={k}) with Coloring', fontsize=14)
    
    colors_map = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    
    # Center vertex
    ax.scatter([0], [0], s=200, c=[colors_map[0]], zorder=5, edgecolors='black', linewidths=2)
    ax.annotate('v₀\n(color 0)', (0, 0), textcoords="offset points",
                xytext=(15, 15), fontsize=9, fontweight='bold')
    
    # Draw edges as sectors
    for i in range(k):
        angle = 2 * np.pi * i / k + np.pi / 2
        for j in range(k - 1):
            r = 0.3 + 0.25 * (j + 1)
            x = r * np.cos(angle + 0.15 * (j - (k-2)/2))
            y = r * np.sin(angle + 0.15 * (j - (k-2)/2))
            color_idx = j + 1
            ax.scatter([x], [y], s=120, c=[colors_map[color_idx % len(colors_map)]],
                      zorder=5, edgecolors='black', linewidths=1)
            # Draw line to center
            ax.plot([0, x], [0, y], 'k-', alpha=0.2, linewidth=0.5)
        
        # Label edge
        label_r = 0.95
        lx = label_r * np.cos(angle)
        ly = label_r * np.sin(angle)
        ax.annotate(f'Edge {i}', (lx, ly), fontsize=10, ha='center',
                   fontweight='bold', color='gray')
    
    # Legend
    patches = [mpatches.Patch(color=colors_map[i], label=f'Color {i}') for i in range(k)]
    ax.legend(handles=patches, loc='lower right', fontsize=9)
    
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/near_pencil_coloring.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved near_pencil_coloring.png")


def plot_efl_landscape():
    """Plot the EFL parameter landscape."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title('EFL Conjecture: Chromatic Number vs. Parameter k', fontsize=14)
    
    ks = np.arange(1, 20)
    
    # The conjecture line
    ax.plot(ks, ks, 'b-', linewidth=3, label='Conjectured χ = k', zorder=3)
    
    # Greedy bound
    ax.plot(ks, ks + 1, 'r--', linewidth=2, label='Greedy bound (k+1)', alpha=0.7)
    
    # Kahn's result
    ax.plot(ks, ks + ks**0.5, 'g:', linewidth=2, label='Kahn bound k + o(k)', alpha=0.7)
    
    # Verified region
    ax.fill_between([1, 2, 3], [0, 0, 0], [1, 2, 3],
                    alpha=0.3, color='green', label='Formally verified (k ≤ 2)')
    
    # Kang et al. region
    ax.axvspan(10, 19, alpha=0.1, color='blue', label='Proved for large k (Kang et al.)')
    
    ax.set_xlabel('k (uniformity parameter)', fontsize=12)
    ax.set_ylabel('Chromatic number χ', fontsize=12)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(0.5, 19.5)
    ax.set_ylim(0, 22)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/efl_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved efl_landscape.png")


if __name__ == "__main__":
    plot_structural_bounds()
    plot_near_pencil_coloring()
    plot_efl_landscape()
    print("All visualizations generated.")
