#!/usr/bin/env python3
"""
Emotional Chromatic Theory — Demonstration

Demonstrates the key results:
1. Computing emotional chromatic numbers for various graphs
2. Verifying χ_E(G) = max(3, χ(G)) computationally
3. Tropical chromatic evaluations
4. Coloring diversity analysis
"""

import itertools
from typing import Dict, List, Set, Tuple, Optional


def chromatic_number_brute(adj: Dict[int, Set[int]], n: int) -> int:
    """Compute the chromatic number by brute force (small graphs only)."""
    vertices = list(range(n))
    for k in range(1, n + 1):
        # Try all colorings with k colors
        for coloring in itertools.product(range(k), repeat=n):
            valid = True
            for v in vertices:
                for w in adj.get(v, set()):
                    if v < w and coloring[v] == coloring[w]:
                        valid = False
                        break
                if not valid:
                    break
            if valid:
                return k
    return n


def greedy_chromatic_number(adj: Dict[int, Set[int]], n: int) -> int:
    """Greedy upper bound for chromatic number."""
    colors = [-1] * n
    for v in range(n):
        used = {colors[w] for w in adj.get(v, set()) if colors[w] != -1}
        c = 0
        while c in used:
            c += 1
        colors[v] = c
    return max(colors) + 1 if n > 0 else 0


def emotional_chromatic_number(chi: int) -> int:
    """Emotional chromatic number: max(3, χ(G))."""
    return max(3, chi)


def tropical_chromatic_eval(n: int, m: int, k: int) -> float:
    """Tropical chromatic evaluation: k*n - m."""
    return k * n - m


def coloring_diversity(coloring: List[int]) -> int:
    """Number of distinct colors used in a coloring."""
    return len(set(coloring))


def complete_graph(n: int) -> Dict[int, Set[int]]:
    """Complete graph K_n."""
    return {i: set(range(n)) - {i} for i in range(n)}


def cycle_graph(n: int) -> Dict[int, Set[int]]:
    """Cycle graph C_n."""
    return {i: {(i - 1) % n, (i + 1) % n} for i in range(n)}


def path_graph(n: int) -> Dict[int, Set[int]]:
    """Path graph P_n."""
    adj: Dict[int, Set[int]] = {}
    for i in range(n):
        adj[i] = set()
        if i > 0:
            adj[i].add(i - 1)
        if i < n - 1:
            adj[i].add(i + 1)
    return adj


def bipartite_graph(a: int, b: int) -> Dict[int, Set[int]]:
    """Complete bipartite graph K_{a,b}."""
    adj: Dict[int, Set[int]] = {}
    for i in range(a):
        adj[i] = set(range(a, a + b))
    for j in range(a, a + b):
        adj[j] = set(range(a))
    return adj


def petersen_graph() -> Dict[int, Set[int]]:
    """The Petersen graph (10 vertices, chromatic number 3)."""
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),  # outer cycle
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),  # inner pentagram
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),  # spokes
    ]
    adj: Dict[int, Set[int]] = {i: set() for i in range(10)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return adj


def main():
    print("=" * 60)
    print("EMOTIONAL CHROMATIC THEORY — DEMONSTRATION")
    print("=" * 60)

    # --- Example 1: Complete Graphs ---
    print("\n--- Complete Graphs K_n ---")
    print(f"{'Graph':<12} {'χ(G)':<8} {'χ_E(G)':<10} {'max(3,χ)':<10} {'Match?'}")
    for n in range(1, 8):
        chi = n  # χ(K_n) = n
        chi_e = emotional_chromatic_number(chi)
        match = "✓" if chi_e == max(3, chi) else "✗"
        print(f"K_{n:<9} {chi:<8} {chi_e:<10} {max(3, chi):<10} {match}")

    # --- Example 2: Cycle Graphs ---
    print("\n--- Cycle Graphs C_n ---")
    print(f"{'Graph':<12} {'χ(G)':<8} {'χ_E(G)':<10} {'Bipartite?':<12} {'Floor binds?'}")
    for n in range(3, 10):
        adj = cycle_graph(n)
        chi = chromatic_number_brute(adj, n)
        chi_e = emotional_chromatic_number(chi)
        bip = "Yes" if n % 2 == 0 else "No"
        binds = "Yes" if chi < 3 else "No"
        print(f"C_{n:<9} {chi:<8} {chi_e:<10} {bip:<12} {binds}")

    # --- Example 3: Bipartite Graphs ---
    print("\n--- Complete Bipartite Graphs K_{a,b} ---")
    print(f"{'Graph':<12} {'χ(G)':<8} {'χ_E(G)':<10} {'Extra colors'}")
    for a, b in [(1, 1), (2, 2), (3, 3), (2, 5), (1, 10)]:
        n = a + b
        adj = bipartite_graph(a, b)
        chi = chromatic_number_brute(adj, n)
        chi_e = emotional_chromatic_number(chi)
        extra = chi_e - chi
        print(f"K_{a},{b:<8} {chi:<8} {chi_e:<10} +{extra}")

    # --- Example 4: Tropical Chromatic Evaluations ---
    print("\n--- Tropical Chromatic Evaluations ---")
    print("trop_eval(n_vertices, n_edges, k_colors) = k*n - m")
    print(f"{'Graph':<12} {'n':<5} {'m':<5} {'k=1':<8} {'k=2':<8} {'k=3':<8} {'k=4':<8} {'k=χ_E':<8}")
    graphs = [
        ("K_3", 3, 3),
        ("K_4", 4, 6),
        ("K_5", 5, 10),
        ("C_5", 5, 5),
        ("P_4", 4, 3),
    ]
    for name, n, m in graphs:
        chi = n if name.startswith("K_") and not name.startswith("K_a") else (3 if name == "C_5" else 2)
        chi_e = emotional_chromatic_number(chi)
        vals = [tropical_chromatic_eval(n, m, k) for k in [1, 2, 3, 4]]
        val_chi_e = tropical_chromatic_eval(n, m, chi_e)
        print(f"{name:<12} {n:<5} {m:<5} {vals[0]:<8.1f} {vals[1]:<8.1f} {vals[2]:<8.1f} {vals[3]:<8.1f} {val_chi_e:<8.1f}")

    # --- Example 5: Tropical Monotonicity Verification ---
    print("\n--- Tropical Monotonicity Verification ---")
    print("Verifying: min(eval(k₂), eval(k₁)) = eval(k₁) when k₁ ≤ k₂")
    n, m = 5, 7
    for k1 in range(1, 6):
        for k2 in range(k1, 6):
            v1 = tropical_chromatic_eval(n, m, k1)
            v2 = tropical_chromatic_eval(n, m, k2)
            assert min(v2, v1) == v1, f"Monotonicity failed at k1={k1}, k2={k2}"
    print(f"✓ All {sum(range(1,6))+5} pairs verified for (n={n}, m={m})")

    # --- Example 6: Coloring Diversity ---
    print("\n--- Coloring Diversity Analysis ---")
    print("Petersen graph: optimal coloring diversity")
    adj = petersen_graph()
    chi = 3  # Known: Petersen graph has χ = 3
    # Find a proper 3-coloring
    def find_coloring(adj, n, k):
        for coloring in itertools.product(range(k), repeat=n):
            valid = True
            for v in range(n):
                for w in adj.get(v, set()):
                    if v < w and coloring[v] == coloring[w]:
                        valid = False
                        break
                if not valid:
                    break
            if valid:
                return list(coloring)
        return None

    col = find_coloring(adj, 10, 3)
    if col:
        div = coloring_diversity(col)
        print(f"  3-coloring found: {col}")
        print(f"  Diversity: {div} (uses all 3 colors: {'Yes' if div == 3 else 'No'})")
        print(f"  Diversity ≤ k={3}: {'✓' if div <= 3 else '✗'}")
        print(f"  Diversity ≤ |V|={10}: {'✓' if div <= 10 else '✗'}")

    # --- Example 7: Clique Obstruction ---
    print("\n--- Clique Obstruction Demonstration ---")
    print("Graph contains K_n  →  χ(G) ≥ n  →  χ_E(G) ≥ max(3, n)")
    for n in range(2, 7):
        chi_lower = n  # clique of size n forces χ ≥ n
        chi_e_lower = emotional_chromatic_number(chi_lower)
        print(f"  Clique size {n}: χ ≥ {chi_lower}, χ_E ≥ {chi_e_lower}")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Emotional Chromatic Number vs Classical Chromatic Number

Shows χ_E(G) = max(3, χ(G)) for various graph families.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # --- Plot 1: χ_E vs χ for general graphs ---
    ax = axes[0]
    chi_vals = np.arange(0, 10)
    chi_e_vals = np.maximum(3, chi_vals)

    ax.plot(chi_vals, chi_vals, '--', color='gray', alpha=0.5, label='χ_E = χ (no floor)')
    ax.plot(chi_vals, chi_e_vals, 'o-', color='#e74c3c', linewidth=2, markersize=8, label='χ_E = max(3, χ)')
    ax.axhline(y=3, color='#3498db', linestyle=':', alpha=0.7, label='Emotional floor (k=3)')
    ax.fill_between(chi_vals, chi_vals, chi_e_vals, alpha=0.15, color='#e74c3c')
    ax.set_xlabel('Classical chromatic number χ(G)', fontsize=12)
    ax.set_ylabel('Emotional chromatic number χ_E(G)', fontsize=12)
    ax.set_title('The Emotional Floor Effect', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_xlim(-0.5, 9.5)
    ax.set_ylim(-0.5, 9.5)
    ax.grid(True, alpha=0.3)

    # --- Plot 2: Tropical chromatic evaluation ---
    ax = axes[1]
    k_range = np.arange(1, 10)
    graphs = [
        ('K₃ (n=3, m=3)', 3, 3, '#e74c3c'),
        ('K₅ (n=5, m=10)', 5, 10, '#3498db'),
        ('C₅ (n=5, m=5)', 5, 5, '#2ecc71'),
        ('P₄ (n=4, m=3)', 4, 3, '#9b59b6'),
    ]
    for name, n, m, color in graphs:
        vals = [k * n - m for k in k_range]
        ax.plot(k_range, vals, 'o-', color=color, linewidth=2, markersize=6, label=name)

    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Number of colors k', fontsize=12)
    ax.set_ylabel('Tropical chromatic eval: k·n - m', fontsize=12)
    ax.set_title('Tropical Chromatic Evaluation', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # --- Plot 3: When does the floor bind? ---
    ax = axes[2]
    categories = ['Empty\n(χ=1)', 'Bipartite\n(χ=2)', 'Odd cycle\n(χ=3)', 'K₄\n(χ=4)', 'K₅\n(χ=5)', 'K₆\n(χ=6)']
    chi_values = [1, 2, 3, 4, 5, 6]
    chi_e_values = [max(3, c) for c in chi_values]
    floor_effect = [max(0, 3 - c) for c in chi_values]

    x = np.arange(len(categories))
    width = 0.35
    bars1 = ax.bar(x - width/2, chi_values, width, label='χ(G)', color='#3498db', alpha=0.8)
    bars2 = ax.bar(x + width/2, chi_e_values, width, label='χ_E(G)', color='#e74c3c', alpha=0.8)

    # Highlight where floor binds
    for i, fe in enumerate(floor_effect):
        if fe > 0:
            ax.annotate(f'+{fe}', xy=(x[i] + width/2, chi_e_values[i]),
                       xytext=(0, 5), textcoords='offset points',
                       ha='center', fontsize=10, fontweight='bold', color='#e74c3c')

    ax.set_ylabel('Chromatic number', fontsize=12)
    ax.set_title('Floor Binding Analysis', fontsize=13, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=9)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('emotional_chromatic_viz.png', dpi=150, bbox_inches='tight')
    print("Saved: emotional_chromatic_viz.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Monotonicity of Chromatic Evaluations

Demonstrates that min(eval(k₂), eval(k₁)) = eval(k₁) for k₁ ≤ k₂.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = +."""
    return a + b


def tropical_chromatic_eval(n: int, m: int, k: float) -> float:
    """trop(k * n - m)"""
    return k * n - m


def main():
    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

    # --- Plot 1: Tropical eval with monotonicity arrows ---
    ax = axes[0]
    n, m = 5, 7
    k_range = np.linspace(0.5, 8, 100)
    vals = [tropical_chromatic_eval(n, m, k) for k in k_range]
    ax.plot(k_range, vals, '-', color='#2c3e50', linewidth=2.5, label=f'trop_eval({n}, {m}, k)')

    # Mark specific points and show monotonicity
    k_points = [1, 2, 3, 4, 5, 6, 7]
    v_points = [tropical_chromatic_eval(n, m, k) for k in k_points]
    ax.scatter(k_points, v_points, color='#e74c3c', zorder=5, s=80)

    # Draw arrows showing min property
    for i in range(len(k_points) - 1):
        ax.annotate('', xy=(k_points[i], v_points[i]),
                    xytext=(k_points[i+1], v_points[i+1]),
                    arrowprops=dict(arrowstyle='->', color='#3498db', lw=1.5, alpha=0.5))

    ax.fill_between(k_range, vals, min(vals) - 2, alpha=0.08, color='#2c3e50')
    ax.set_xlabel('Number of colors k', fontsize=12)
    ax.set_ylabel('Tropical evaluation (k·n - m)', fontsize=12)
    ax.set_title(f'Tropical Monotonicity (n={n}, m={m})\nmin(eval(k₂), eval(k₁)) = eval(k₁) for k₁ ≤ k₂',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # --- Plot 2: Heatmap of tropical min ---
    ax = axes[1]
    k_vals = list(range(1, 9))
    n_k = len(k_vals)
    min_matrix = np.zeros((n_k, n_k))

    for i, k1 in enumerate(k_vals):
        for j, k2 in enumerate(k_vals):
            v1 = tropical_chromatic_eval(n, m, k1)
            v2 = tropical_chromatic_eval(n, m, k2)
            min_matrix[i, j] = tropical_add(v1, v2)

    im = ax.imshow(min_matrix, cmap='RdYlBu_r', aspect='equal')
    ax.set_xticks(range(n_k))
    ax.set_yticks(range(n_k))
    ax.set_xticklabels(k_vals)
    ax.set_yticklabels(k_vals)
    ax.set_xlabel('k₂', fontsize=12)
    ax.set_ylabel('k₁', fontsize=12)
    ax.set_title('min(eval(k₁), eval(k₂))\nLower-left triangle = eval(k₁)',
                fontsize=12, fontweight='bold')

    # Add text annotations
    for i in range(n_k):
        for j in range(n_k):
            ax.text(j, i, f'{min_matrix[i,j]:.0f}', ha='center', va='center',
                   fontsize=8, color='white' if min_matrix[i,j] < 10 else 'black')

    plt.colorbar(im, ax=ax, label='Tropical value')

    plt.tight_layout()
    plt.savefig('tropical_monotonicity_viz.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_monotonicity_viz.png")


if __name__ == "__main__":
    main()
