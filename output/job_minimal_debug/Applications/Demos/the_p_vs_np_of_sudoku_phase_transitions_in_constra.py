"""
Demo: Phase Transitions in Sudoku Constraint Satisfaction

Demonstrates the key mathematical results from the formalization:
1. Constraint degree decomposition (Sudoku = Latin + Box)
2. Phase transition detection via sampling
3. Hardness peak analysis
4. Convergence of constraint degree ratio to 3/2
"""

import random
import math
from algorithms import (
    sudoku_constraint_degree,
    latin_square_constraint_degree,
    box_additional_constraints,
    critical_density,
    constraint_interaction_strength,
    cluster_ratio,
    hardness_function,
    constraint_degree_ratio,
    generate_random_partial_latin_square,
    is_latin_square_completable,
    backtracking_tree_size,
)


def demo_degree_decomposition():
    """Demonstrate the Box-Row Interaction Theorem."""
    print("=" * 60)
    print("THEOREM: Sudoku Degree Decomposition")
    print("  sudokuDegree(n) = latinDegree(n) + boxExtra(n)")
    print("  3n² - 2n - 1 = 2(n² - 1) + (n-1)²")
    print("=" * 60)

    for n in range(2, 10):
        sd = sudoku_constraint_degree(n)
        ld = latin_square_constraint_degree(n)
        ba = box_additional_constraints(n)
        assert sd == ld + ba, f"Decomposition failed for n={n}!"
        grid_size = n * n
        print(f"  n={n} ({grid_size}×{grid_size} grid): "
              f"Sudoku={sd}, Latin={ld}, Box={ba}, "
              f"Verified: {ld}+{ba}={ld+ba} ✓")

    print()


def demo_phase_transition_small():
    """Demonstrate phase transition for 4×4 Latin squares."""
    print("=" * 60)
    print("EXPERIMENT: Phase Transition in 4×4 Latin Squares")
    print(f"  Critical density d_c = {critical_density(4):.4f}")
    print("=" * 60)

    n = 4
    total = n * n
    num_samples = 50

    for num_filled in range(0, total + 1):
        d = num_filled / total
        sat_count = 0

        for _ in range(num_samples):
            partial = generate_random_partial_latin_square(n, num_filled)
            if partial is None:
                continue
            grid = [[-1] * n for _ in range(n)]
            for r, c, v in partial:
                grid[r][c] = v
            if is_latin_square_completable(grid, n):
                sat_count += 1

        sat_prob = sat_count / num_samples
        bar = "█" * int(sat_prob * 40)
        marker = " ← d_c" if abs(d - critical_density(n)) < 0.05 else ""
        print(f"  d={d:.3f} ({num_filled:2d}/{total}): P(sat)={sat_prob:.2f} {bar}{marker}")

    print()


def demo_hardness_peak():
    """Demonstrate the hardness peak theorem."""
    print("=" * 60)
    print("THEOREM: Hardness Peak at d = 1/2")
    print("  H(d) = d(1-d)n⁴ ≤ H(1/2) = n⁴/4")
    print("=" * 60)

    n = 3
    max_h = hardness_function(n, 0.5)
    print(f"  For n={n}: max hardness H(1/2) = {max_h:.1f}")
    print()

    for d_pct in range(0, 105, 5):
        d = d_pct / 100
        h = hardness_function(n, d)
        bar_len = int(h / max_h * 50) if max_h > 0 else 0
        bar = "█" * bar_len
        dc = critical_density(n)
        marker = " ← d_c" if abs(d - dc) < 0.025 else ""
        print(f"  d={d:.2f}: H={h:8.1f} {bar}{marker}")

    print()


def demo_degree_ratio_convergence():
    """Demonstrate convergence of Sudoku/Latin degree ratio to 3/2."""
    print("=" * 60)
    print("THEOREM: Constraint Degree Ratio → 3/2")
    print("  (3n² - 2n - 1) / (2(n² - 1)) → 3/2 as n → ∞")
    print("=" * 60)

    for n in [2, 3, 4, 5, 10, 20, 50, 100, 500, 1000]:
        r = constraint_degree_ratio(n)
        gap = abs(r - 1.5)
        expected_gap = 1 / (n + 1)
        print(f"  n={n:5d}: ratio={r:.8f}, |ratio - 3/2|={gap:.8f}, "
              f"1/(n+1)={expected_gap:.8f}")

    print()


def demo_cluster_ratio():
    """Demonstrate cluster ratio at critical density."""
    print("=" * 60)
    print("THEOREM: Cluster Ratio at Critical Density = 1/n")
    print("=" * 60)

    for n in range(2, 15):
        dc = critical_density(n)
        cr = cluster_ratio(n, dc)
        expected = 1 / n
        print(f"  n={n:3d}: d_c={dc:.6f}, cluster_ratio={cr:.6f}, "
              f"1/n={expected:.6f}, match={abs(cr - expected) < 1e-10}")

    print()


def demo_backtracking_phases():
    """Demonstrate easy/hard phases via backtracking tree size."""
    print("=" * 60)
    print("THEOREM: Easy Phase (effective branching < 1)")
    print("  Tree size shrinks exponentially when eff. branching < 1")
    print("=" * 60)

    depth = 10
    for eff_b in [0.3, 0.5, 0.7, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0]:
        # decompose into branching * (1 - pruning)
        branching = eff_b * 2  # arbitrary decomposition
        pruning = 0.5
        size = backtracking_tree_size(branching, depth, pruning)
        phase = "EASY" if eff_b < 1 else ("CRITICAL" if eff_b == 1.0 else "HARD")
        print(f"  eff_b={eff_b:.1f}: tree_size={size:12.1f}, phase={phase}")

    print()


if __name__ == "__main__":
    print("\n🔬 CSP Phase Transition Demo\n")
    demo_degree_decomposition()
    demo_degree_ratio_convergence()
    demo_cluster_ratio()
    demo_hardness_peak()
    demo_backtracking_phases()
    demo_phase_transition_small()
    print("✅ All demonstrations complete.")


"""
Visualization: Phase Transition in Constraint Satisfaction

Standalone script generating publication-quality plots of the CSP
phase transition, constraint degree decomposition, and convergence behavior.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sudoku_constraint_degree(n):
    return 3 * n**2 - 2 * n - 1

def latin_square_constraint_degree(n):
    return 2 * (n**2 - 1)

def box_additional_constraints(n):
    return (n - 1) ** 2

def critical_density(n):
    return (n**2 - 1) / n**2

def hardness_function(n, d):
    return d * (1 - d) * n**4

def constraint_degree_ratio(n):
    return (3*n**2 - 2*n - 1) / (2*(n**2 - 1))

def cluster_ratio(n, d):
    return (1 - d) * n


def plot_degree_decomposition():
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = np.arange(2, 20)
    sudoku = [sudoku_constraint_degree(n) for n in ns]
    latin = [latin_square_constraint_degree(n) for n in ns]
    box = [box_additional_constraints(n) for n in ns]

    ax.bar(ns - 0.2, latin, 0.4, label='Latin Square (row+col)', color='#2196F3', alpha=0.8)
    ax.bar(ns + 0.2, box, 0.4, bottom=[latin[i] for i in range(len(ns))],
           label='Box Extra', color='#FF5722', alpha=0.8)
    ax.bar(ns + 0.2, latin, 0.4, label='_', color='#2196F3', alpha=0.3)
    ax.plot(ns, sudoku, 'ko-', markersize=5, label='Sudoku Total', linewidth=2)

    ax.set_xlabel('Box size n', fontsize=14)
    ax.set_ylabel('Constraint Degree', fontsize=14)
    ax.set_title('Sudoku = Latin Square + Box Constraints\n'
                 'sudokuDegree(n) = 2(n²-1) + (n-1)²', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_degree_decomposition.png', dpi=150)
    plt.close()
    print("Saved: viz_degree_decomposition.png")


def plot_ratio_convergence():
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = np.arange(2, 200)
    ratios = [constraint_degree_ratio(n) for n in ns]
    gaps = [abs(r - 1.5) for r in ratios]
    expected = [1/(n+1) for n in ns]

    ax.plot(ns, ratios, 'b-', linewidth=2, label='Sudoku/Latin degree ratio')
    ax.axhline(y=1.5, color='r', linestyle='--', linewidth=1.5, label='Limit = 3/2')
    ax.fill_between(ns, ratios, 1.5, alpha=0.1, color='blue')

    ax.set_xlabel('Box size n', fontsize=14)
    ax.set_ylabel('Degree Ratio', fontsize=14)
    ax.set_title('Constraint Degree Ratio Converges to 3/2\n'
                 '|ratio - 3/2| = 1/(n+1)', fontsize=14)
    ax.legend(fontsize=12, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1.0, 1.6)
    plt.tight_layout()
    plt.savefig('viz_ratio_convergence.png', dpi=150)
    plt.close()
    print("Saved: viz_ratio_convergence.png")


def plot_hardness_landscape():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    for idx, n in enumerate([3, 5, 9]):
        ax = axes[idx]
        ds = np.linspace(0, 1, 200)
        hs = [hardness_function(n, d) for d in ds]
        dc = critical_density(n)

        ax.plot(ds, hs, 'b-', linewidth=2)
        ax.axvline(x=dc, color='r', linestyle='--', linewidth=1.5,
                   label=f'd_c = {dc:.3f}')
        ax.axvline(x=0.5, color='g', linestyle=':', linewidth=1.5,
                   label='d = 1/2 (max)')

        h_at_dc = hardness_function(n, dc)
        ax.plot(dc, h_at_dc, 'ro', markersize=8)
        ax.plot(0.5, hardness_function(n, 0.5), 'g^', markersize=8)

        ax.set_xlabel('Density d', fontsize=12)
        ax.set_ylabel('H(d)', fontsize=12)
        ax.set_title(f'n={n} ({n**2}×{n**2} grid)', fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Hardness Function H(d) = d(1-d)n⁴', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_hardness_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_hardness_landscape.png")


def plot_cluster_ratio():
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = np.arange(2, 30)
    crs = [1/n for n in ns]
    dcs = [critical_density(n) for n in ns]

    ax2 = ax.twinx()
    ax.bar(ns, crs, color='#4CAF50', alpha=0.7, label='Cluster ratio at d_c')
    ax2.plot(ns, dcs, 'ro-', markersize=4, linewidth=2, label='Critical density d_c')

    ax.set_xlabel('Grid size n', fontsize=14)
    ax.set_ylabel('Cluster ratio 1/n', fontsize=14, color='#4CAF50')
    ax2.set_ylabel('Critical density d_c', fontsize=14, color='red')
    ax.set_title('Solution Clustering at Phase Transition\n'
                 'Cluster ratio = 1/n → 0 as grid grows', fontsize=14)
    ax.legend(loc='upper left', fontsize=12)
    ax2.legend(loc='upper right', fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_cluster_ratio.png', dpi=150)
    plt.close()
    print("Saved: viz_cluster_ratio.png")


if __name__ == "__main__":
    plot_degree_decomposition()
    plot_ratio_convergence()
    plot_hardness_landscape()
    plot_cluster_ratio()
    print("\nAll visualizations generated.")
