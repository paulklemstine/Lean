#!/usr/bin/env python3
"""
P vs NP — Visual Demonstration

Demonstrates the exponential gap between P and NP problems by comparing:
1. Sorting (P) vs. Subset Sum (NP-complete)
2. Visualizes the complexity landscape
3. Shows SAT phase transitions

Run: python demo_01_p_vs_np.py
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
import time

# ─────────────────────────────────────────────────────────────
# Demo 1: The Exponential Wall — Sorting vs Subset Sum
# ─────────────────────────────────────────────────────────────

def timing_experiment():
    """Compare polynomial (sorting) vs exponential (subset sum) growth."""
    sizes = list(range(5, 26))
    sort_times = []
    subset_sum_times = []

    for n in sizes:
        # Polynomial: sorting
        arr = np.random.randint(0, 10000, n)
        start = time.perf_counter()
        for _ in range(100):
            sorted(arr)
        sort_times.append((time.perf_counter() - start) / 100)

        # Exponential: brute-force subset sum
        target = sum(arr) // 3
        nums = list(arr)
        start = time.perf_counter()
        found = False
        count = 0
        for r in range(len(nums) + 1):
            if found:
                break
            for subset in combinations(nums, r):
                count += 1
                if sum(subset) == target:
                    found = True
                    break
                if count > 100000:  # cap for safety
                    found = True
                    break
        subset_sum_times.append(time.perf_counter() - start)

    return sizes, sort_times, subset_sum_times


def plot_complexity_comparison():
    """Plot the exponential wall between P and NP."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Empirical timing
    sizes, sort_times, ss_times = timing_experiment()
    ax = axes[0]
    ax.semilogy(sizes, sort_times, 'b-o', label='Sorting (P)', markersize=4)
    ax.semilogy(sizes, ss_times, 'r-s', label='Subset Sum (NP-complete)', markersize=4)
    ax.set_xlabel('Input size n', fontsize=12)
    ax.set_ylabel('Time (seconds, log scale)', fontsize=12)
    ax.set_title('The Exponential Wall', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Theoretical growth rates
    ax = axes[1]
    n = np.linspace(1, 50, 200)
    ax.semilogy(n, n, 'g-', label='O(n)', linewidth=2)
    ax.semilogy(n, n * np.log2(n + 1), 'b-', label='O(n log n)', linewidth=2)
    ax.semilogy(n, n**2, 'c-', label='O(n²)', linewidth=2)
    ax.semilogy(n, n**3, 'm-', label='O(n³)', linewidth=2)
    ax.semilogy(n, 2**n, 'r-', label='O(2ⁿ)', linewidth=3)
    ax.set_xlabel('Input size n', fontsize=12)
    ax.set_ylabel('Operations (log scale)', fontsize=12)
    ax.set_title('Growth Rate Comparison', fontsize=14, fontweight='bold')
    ax.set_ylim(1, 1e15)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: The Complexity Zoo
    ax = axes[2]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')

    # Draw nested ovals for complexity classes
    colors = ['#FFE4E1', '#FFD700', '#90EE90', '#87CEEB', '#DDA0DD']
    labels = ['EXPTIME', 'PSPACE', 'NP', 'P', 'L']
    sizes_oval = [(4.5, 4.5), (3.8, 3.8), (3.0, 3.0), (2.0, 2.0), (0.8, 0.8)]
    center = (5, 5)

    for i, (size, color, label) in enumerate(zip(sizes_oval, colors, labels)):
        ellipse = mpatches.Ellipse(center, size[0] * 2, size[1] * 2,
                                    alpha=0.3, facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(ellipse)
        y_pos = center[1] + size[1] - 0.3
        ax.text(center[0], y_pos, label, ha='center', va='center',
                fontsize=12, fontweight='bold')

    # Add the big question
    ax.text(5, 0.5, 'Does P = NP?', ha='center', va='center',
            fontsize=16, fontweight='bold', color='red',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))

    ax.set_title('The Complexity Zoo', fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('demo_01_p_vs_np.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_01_p_vs_np.png")


# ─────────────────────────────────────────────────────────────
# Demo 2: SAT Phase Transition
# ─────────────────────────────────────────────────────────────

def random_3sat(n_vars, n_clauses):
    """Generate a random 3-SAT instance."""
    clauses = []
    for _ in range(n_clauses):
        vars_chosen = np.random.choice(n_vars, 3, replace=False) + 1
        signs = np.random.choice([-1, 1], 3)
        clauses.append(list(vars_chosen * signs))
    return clauses

def check_sat_brute_force(clauses, n_vars):
    """Check satisfiability by brute force."""
    for assignment_int in range(2**n_vars):
        assignment = [(assignment_int >> i) & 1 for i in range(n_vars)]
        satisfied = True
        for clause in clauses:
            clause_sat = False
            for lit in clause:
                var_idx = abs(lit) - 1
                val = assignment[var_idx]
                if (lit > 0 and val == 1) or (lit < 0 and val == 0):
                    clause_sat = True
                    break
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            return True
    return False

def sat_phase_transition():
    """Demonstrate the SAT phase transition at clause/variable ratio ≈ 4.27."""
    n_vars = 10
    ratios = np.linspace(1, 8, 20)
    n_trials = 50
    sat_fractions = []

    for ratio in ratios:
        n_clauses = int(ratio * n_vars)
        sat_count = 0
        for _ in range(n_trials):
            clauses = random_3sat(n_vars, n_clauses)
            if check_sat_brute_force(clauses, n_vars):
                sat_count += 1
        sat_fractions.append(sat_count / n_trials)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(ratios, sat_fractions, 'b-o', markersize=5, linewidth=2)
    ax.axvline(x=4.27, color='r', linestyle='--', linewidth=2, label='Critical ratio ≈ 4.27')
    ax.fill_betweenx([0, 1], 0, 4.27, alpha=0.1, color='green', label='Typically SAT')
    ax.fill_betweenx([0, 1], 4.27, 8, alpha=0.1, color='red', label='Typically UNSAT')
    ax.set_xlabel('Clause/Variable Ratio (α)', fontsize=14)
    ax.set_ylabel('Fraction Satisfiable', fontsize=14)
    ax.set_title(f'3-SAT Phase Transition (n={n_vars} variables, {n_trials} trials each)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 8)
    ax.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('demo_01b_sat_phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_01b_sat_phase_transition.png")


if __name__ == '__main__':
    print("=" * 60)
    print("P vs NP — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating complexity comparison plots...")
    plot_complexity_comparison()
    print("\n2. Running SAT phase transition experiment...")
    sat_phase_transition()
    print("\nDone! Check the generated PNG files.")
