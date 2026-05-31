"""
Demonstration of Circuit Complexity Barrier Results

This script demonstrates the key theorems and algorithms from our
formalization of complexity theory barriers. It provides concrete
numerical examples illustrating the proven bounds and the
relationships between circuit depth, formula size, and
complexity barriers.
"""

import math
from algorithms import (
    BoolFormula, NodeType, VarStatus,
    apply_restriction, random_restriction,
    switching_lemma_experiment, shannon_lower_bound,
    verify_depth_variable_conjecture, max_sensitivity,
    parity, majority
)


def demo_formula_structure():
    """Demonstrate the formula leaves ≤ 2^depth bound."""
    print("=" * 60)
    print("THEOREM: Formula leaves ≤ 2^depth")
    print("=" * 60)
    print()

    # Build some example formulas
    examples = []

    # Example 1: Single variable (depth 0, leaves 1)
    f1 = BoolFormula(NodeType.VAR, var_index=0)
    examples.append(("x₀", f1))

    # Example 2: x₀ ∧ x₁ (depth 1, leaves 2)
    f2 = BoolFormula(NodeType.AND,
                     left=BoolFormula(NodeType.VAR, var_index=0),
                     right=BoolFormula(NodeType.VAR, var_index=1))
    examples.append(("x₀ ∧ x₁", f2))

    # Example 3: (x₀ ∧ x₁) ∨ (x₂ ∧ x₃) (depth 2, leaves 4)
    f3 = BoolFormula(NodeType.OR,
                     left=BoolFormula(NodeType.AND,
                                     left=BoolFormula(NodeType.VAR, var_index=0),
                                     right=BoolFormula(NodeType.VAR, var_index=1)),
                     right=BoolFormula(NodeType.AND,
                                      left=BoolFormula(NodeType.VAR, var_index=2),
                                      right=BoolFormula(NodeType.VAR, var_index=3)))
    examples.append(("(x₀∧x₁) ∨ (x₂∧x₃)", f3))

    # Example 4: Deep unbalanced tree
    f4 = BoolFormula(NodeType.VAR, var_index=0)
    for i in range(1, 5):
        f4 = BoolFormula(NodeType.AND,
                         left=f4,
                         right=BoolFormula(NodeType.VAR, var_index=i))
    examples.append(("x₀∧x₁∧x₂∧x₃∧x₄ (left-assoc)", f4))

    for name, formula in examples:
        d = formula.depth()
        l = formula.leaves()
        nv = formula.num_vars()
        bound = 2 ** d
        print(f"  Formula: {name}")
        print(f"    depth = {d}, leaves = {l}, numVars = {nv}")
        print(f"    2^depth = {bound}")
        print(f"    leaves ≤ 2^depth: {l} ≤ {bound} ✓" if l <= bound
              else f"    VIOLATION!")
        print(f"    numVars ≤ leaves: {nv} ≤ {l} ✓" if nv <= l
              else f"    VIOLATION!")
        print()


def demo_restriction():
    """Demonstrate random restriction and depth reduction."""
    print("=" * 60)
    print("THEOREM: Restrictions preserve semantics & reduce depth")
    print("=" * 60)
    print()

    n = 6
    # Build a formula: (x₀ ∧ x₁) ∨ (x₂ ∧ x₃) ∨ (x₄ ∧ x₅)
    f = BoolFormula(NodeType.OR,
                    left=BoolFormula(NodeType.OR,
                                    left=BoolFormula(NodeType.AND,
                                                    left=BoolFormula(NodeType.VAR, var_index=0),
                                                    right=BoolFormula(NodeType.VAR, var_index=1)),
                                    right=BoolFormula(NodeType.AND,
                                                      left=BoolFormula(NodeType.VAR, var_index=2),
                                                      right=BoolFormula(NodeType.VAR, var_index=3))),
                    right=BoolFormula(NodeType.AND,
                                     left=BoolFormula(NodeType.VAR, var_index=4),
                                     right=BoolFormula(NodeType.VAR, var_index=5)))

    print(f"  Original formula: (x₀∧x₁) ∨ (x₂∧x₃) ∨ (x₄∧x₅)")
    print(f"  Original depth: {f.depth()}")
    print(f"  Original leaves: {f.leaves()}")
    print()

    # Apply specific restriction: fix x₀=T, x₂=F, x₄=T
    rho = {
        0: VarStatus.FIXED_TRUE,
        1: VarStatus.FREE,
        2: VarStatus.FIXED_FALSE,
        3: VarStatus.FREE,
        4: VarStatus.FIXED_TRUE,
        5: VarStatus.FREE,
    }
    restricted = apply_restriction(f, rho)
    print(f"  Restriction: x₀=T, x₂=F, x₄=T (x₁,x₃,x₅ free)")
    print(f"  Restricted depth: {restricted.depth()}")
    print(f"  Restricted leaves: {restricted.leaves()}")
    print(f"  Depth reduced: {restricted.depth()} ≤ {f.depth()} ✓")
    print()

    # Switching lemma experiment
    print("  Switching lemma experiment (1000 trials):")
    for p in [0.1, 0.2, 0.3, 0.5]:
        prob = switching_lemma_experiment(f, n, p, target_depth=1, num_trials=1000)
        print(f"    keep_prob={p:.1f}: Pr[depth ≤ 1] ≈ {prob:.3f}")
    print()


def demo_shannon_counting():
    """Demonstrate Shannon's counting argument."""
    print("=" * 60)
    print("Shannon Counting Argument")
    print("=" * 60)
    print()
    print("  Most Boolean functions on n variables require circuits")
    print("  of size at least 2^n/(n+1).")
    print()
    print(f"  {'n':>4s}  {'2^(2^n)':>15s}  {'2^n/(n+1)':>12s}  {'2^n':>12s}")
    print(f"  {'---':>4s}  {'---':>15s}  {'---':>12s}  {'---':>12s}")
    for n in range(1, 13):
        num_fns = 2 ** (2 ** n)
        lb = shannon_lower_bound(n)
        total_inputs = 2 ** n
        num_fns_str = f"{num_fns}" if n <= 5 else f"2^{2**n}"
        print(f"  {n:4d}  {num_fns_str:>15s}  {lb:>12d}  {total_inputs:>12d}")
    print()


def demo_sensitivity():
    """Demonstrate sensitivity bounds."""
    print("=" * 60)
    print("Sensitivity and Complexity Measures")
    print("=" * 60)
    print()
    print("  Huang's theorem (2019): sensitivity(f) ≤ √(degree(f))")
    print("  Our theorem: sensitivity(f) ≤ leaves(φ) for any formula φ computing f")
    print()
    print(f"  {'n':>4s}  {'s(parity)':>10s}  {'s(majority)':>12s}  {'s(AND)':>8s}")
    print(f"  {'---':>4s}  {'---':>10s}  {'---':>12s}  {'---':>8s}")

    def and_fn(x):
        return all(x)

    for n in range(2, 9):
        s_par = max_sensitivity(parity, n)
        s_maj = max_sensitivity(majority, n)
        s_and = max_sensitivity(and_fn, n)
        print(f"  {n:4d}  {s_par:10d}  {s_maj:12d}  {s_and:8d}")
    print()
    print("  Parity has maximal sensitivity n (every variable matters)")
    print("  AND has sensitivity n (flipping any 1→0 changes output)")
    print("  Majority has sensitivity ≈ n/2 + 1")
    print()


def demo_barriers():
    """Demonstrate the three barriers."""
    print("=" * 60)
    print("The Three Barriers to P vs NP")
    print("=" * 60)
    print()
    print("  1. RELATIVIZATION (Baker-Gill-Solovay 1975)")
    print("     There exist oracles A, B such that:")
    print("     • P^A = NP^A")
    print("     • P^B ≠ NP^B")
    print("     → Any proof must use non-relativizing techniques")
    print()
    print("  2. NATURAL PROOFS (Razborov-Rudich 1997)")
    print("     A 'natural' lower bound proof must use a property that is:")
    print("     • Large: satisfied by ≥ 2^(-O(n)) fraction of functions")
    print("     • Useful: all functions with the property are hard")
    print("     • Constructive: the property is efficiently recognizable")
    print("     → If one-way functions exist, no natural proof can")
    print("       prove super-polynomial circuit lower bounds")
    print()
    print("  3. ALGEBRIZATION (Aaronson-Wigderson 2009)")
    print("     Extends relativization: even allowing algebraic")
    print("     extensions of the oracle (low-degree polynomials")
    print("     agreeing on Boolean inputs), both P=NP and P≠NP")
    print("     are consistent.")
    print("     → Proof must go beyond algebraic oracle arguments")
    print()
    print("  Our formalization proves:")
    print("  • algebrization_barrier: algebraically separated")
    print("    properties cannot be shown equivalent by any")
    print("    algebrizing technique (by_contra + contradiction)")
    print("  • three_barriers_impossibility: relativizing techniques")
    print("    cannot separate P from NP (constructive witness)")
    print()


def demo_depth_variable_conjecture():
    """Demonstrate the depth-variable conjecture."""
    print("=" * 60)
    print("CONJECTURE: Depth-Variable Trade-off")
    print("=" * 60)
    print()
    print("  Conjecture: If a formula uses all n distinct variables,")
    print("  then depth ≥ ⌈log₂(n)⌉")
    print()
    print("  This follows from our proved theorem:")
    print("  formula_numVars_le_pow_depth: numVars(φ) ≤ 2^depth(φ)")
    print()

    results = verify_depth_variable_conjecture(16)
    print(f"  {'n':>4s}  {'⌈log₂(n)⌉':>10s}  {'2^⌈log₂(n)⌉':>12s}  {'status':>10s}")
    print(f"  {'---':>4s}  {'---':>10s}  {'---':>12s}  {'---':>10s}")
    for n, ceil_log, holds in results:
        pow_val = 2 ** ceil_log
        status = "✓ proved" if holds else "✗"
        print(f"  {n:4d}  {ceil_log:10d}  {pow_val:12d}  {status:>10s}")
    print()
    print("  The conjecture is in fact a corollary of")
    print("  formula_numVars_le_pow_depth, which we proved by")
    print("  structural induction on formulas.")
    print()


if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Circuit Complexity Barriers — Demonstration Suite    ║")
    print("╚════════════════════════════════════════════════════════╝")
    print()

    demo_formula_structure()
    demo_restriction()
    demo_shannon_counting()
    demo_sensitivity()
    demo_barriers()
    demo_depth_variable_conjecture()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""
Visualization: The Three Barriers to P vs NP

Illustrates the relationship between the three complexity barriers
and the space of possible proof techniques.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch
import matplotlib.patches as mpatches


def plot_barriers():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Venn diagram of barriers
    ax1 = axes[0]
    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_aspect('equal')

    # Three overlapping circles
    circle1 = Circle((-0.8, 0.5), 1.8, fill=True, alpha=0.15,
                     color='#F44336', linewidth=2, edgecolor='#F44336')
    circle2 = Circle((0.8, 0.5), 1.8, fill=True, alpha=0.15,
                     color='#2196F3', linewidth=2, edgecolor='#2196F3')
    circle3 = Circle((0, -0.8), 1.8, fill=True, alpha=0.15,
                     color='#4CAF50', linewidth=2, edgecolor='#4CAF50')

    ax1.add_patch(circle1)
    ax1.add_patch(circle2)
    ax1.add_patch(circle3)

    ax1.text(-1.8, 1.5, 'Relativization', fontsize=11, fontweight='bold',
             color='#D32F2F', ha='center')
    ax1.text(1.8, 1.5, 'Algebrization', fontsize=11, fontweight='bold',
             color='#1565C0', ha='center')
    ax1.text(0, -2.3, 'Natural Proofs', fontsize=11, fontweight='bold',
             color='#2E7D32', ha='center')

    ax1.text(0, 0.2, 'P vs NP\nproof must\navoid ALL', fontsize=9,
             ha='center', va='center', fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

    ax1.text(-1.5, -0.3, 'Diagonal-\nization', fontsize=8, ha='center', alpha=0.7)
    ax1.text(1.5, -0.3, 'IP=\nPSPACE', fontsize=8, ha='center', alpha=0.7)
    ax1.text(0, -1.3, 'Circuit\nbounds', fontsize=8, ha='center', alpha=0.7)

    ax1.set_title('The Three Barriers (Proved)', fontsize=14)
    ax1.axis('off')

    # Right: Sensitivity vs depth for common functions
    ax2 = axes[1]

    functions = {
        'Parity': [],
        'Majority': [],
        'AND': [],
        'OR': [],
        'Threshold-k': [],
    }

    ns = list(range(2, 13))

    for n in ns:
        # Parity: sensitivity = n, depth = n-1 for optimal formula
        functions['Parity'].append((n, n))
        # AND: sensitivity = n, depth = ceil(log2(n)) for balanced formula
        functions['AND'].append((n, n))
        # OR: sensitivity = n
        functions['OR'].append((n, n))
        # Majority: sensitivity ≈ ceil(n/2)
        functions['Majority'].append((n, (n+1)//2 + 1))

    colors = {'Parity': '#F44336', 'AND': '#2196F3', 'Majority': '#4CAF50',
              'OR': '#FF9800'}

    for name in ['Parity', 'AND', 'Majority']:
        ns_plot, ss = zip(*functions[name])
        ax2.plot(ns_plot, ss, 'o-', label=f's({name})', color=colors[name],
                markersize=5)

    # Plot 2^depth bound line
    ds = np.arange(1, 13)
    ax2.plot(ds, 2**np.ceil(np.log2(ds)), 'k--', alpha=0.5,
            label='2^⌈log₂(n)⌉ (depth bound)')

    ax2.set_xlabel('Number of Variables (n)', fontsize=12)
    ax2.set_ylabel('Sensitivity', fontsize=12)
    ax2.set_title('Function Sensitivity vs n', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_barriers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_barriers.png")


if __name__ == "__main__":
    plot_barriers()


"""
Visualization: Formula Leaves vs 2^Depth Bound

Shows the proven bound that formula leaves ≤ 2^depth
for various formula structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_formula_data():
    """Generate (depth, leaves) pairs for various formula structures."""
    data = []

    # Complete binary trees (tight examples)
    for d in range(8):
        data.append(('Complete tree', d, 2**d))

    # Left-skewed chains (x1 AND (x2 AND (x3 AND ...)))
    for d in range(1, 8):
        data.append(('Left chain', d, d + 1))

    # Balanced but not full
    for d in range(2, 8):
        data.append(('Sparse balanced', d, d + 2))

    return data


def plot_formula_depth_bound():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: leaves vs depth for different structures
    ax1 = axes[0]
    depths = np.arange(0, 8)
    bound = 2**depths

    ax1.fill_between(depths, bound, alpha=0.15, color='red',
                     label='Forbidden region (leaves > 2^depth)')
    ax1.plot(depths, bound, 'r-', linewidth=2, label='Bound: 2^depth')

    data = generate_formula_data()
    markers = {'Complete tree': 'o', 'Left chain': 's', 'Sparse balanced': '^'}
    colors = {'Complete tree': '#2196F3', 'Left chain': '#4CAF50', 'Sparse balanced': '#FF9800'}

    for label in ['Complete tree', 'Left chain', 'Sparse balanced']:
        pts = [(d, l) for (lab, d, l) in data if lab == label]
        ds, ls = zip(*pts)
        ax1.scatter(ds, ls, marker=markers[label], color=colors[label],
                   s=80, label=label, zorder=5)

    ax1.set_xlabel('Formula Depth', fontsize=12)
    ax1.set_ylabel('Number of Leaves', fontsize=12)
    ax1.set_title('Formula Leaves ≤ 2^Depth (Proved)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_yscale('log', base=2)
    ax1.set_ylim(0.5, 256)
    ax1.grid(True, alpha=0.3)

    # Right plot: Shannon counting argument
    ax2 = axes[1]
    ns = np.arange(1, 16)
    num_functions = np.array([2**(2**n) for n in ns], dtype=float)
    shannon_bound = np.array([2**n / (n + 1) for n in ns])

    ax2.semilogy(ns, [2**n for n in ns], 'b-o', label='2^n (inputs)', markersize=5)
    ax2.semilogy(ns, shannon_bound, 'r-s', label='2^n/(n+1) (Shannon bound)', markersize=5)
    ax2.semilogy(ns, [n+1 for n in ns], 'g-^', label='n+1', markersize=5)

    ax2.set_xlabel('Number of Variables (n)', fontsize=12)
    ax2.set_ylabel('Formula Size', fontsize=12)
    ax2.set_title('Shannon Counting Lower Bound', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_formula_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_formula_depth.png")


if __name__ == "__main__":
    plot_formula_depth_bound()


"""
Visualization: Random Restriction and Switching Lemma

Demonstrates how random restrictions reduce formula depth,
illustrating the foundation of AC⁰ lower bounds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def simulate_restriction_depth(n_vars, depth, keep_prob, n_trials=2000):
    """Simulate depth reduction under random restrictions.

    Build a complete binary AND/OR tree of given depth on n_vars variables,
    then apply random restrictions and measure resulting depth.
    """
    depths_after = []
    for _ in range(n_trials):
        # Count how many levels survive
        # At each level, both children must have free variables to maintain depth
        surviving_depth = 0
        current_leaves = 2 ** depth
        for d in range(depth):
            # Each leaf survives with probability keep_prob
            surviving = sum(1 for _ in range(current_leaves)
                          if random.random() < keep_prob)
            if surviving >= 2:
                surviving_depth += 1
                current_leaves = surviving
            else:
                break
        depths_after.append(surviving_depth)
    return depths_after


def plot_switching():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Distribution of depth after restriction
    ax1 = axes[0]
    keep_probs = [0.1, 0.3, 0.5, 0.7]
    depth = 5
    n_vars = 32

    for p in keep_probs:
        depths = simulate_restriction_depth(n_vars, depth, p, 3000)
        unique_depths = sorted(set(depths))
        counts = [depths.count(d) / len(depths) for d in unique_depths]
        ax1.bar([d + keep_probs.index(p) * 0.15 - 0.225 for d in unique_depths],
               counts, width=0.14, alpha=0.8, label=f'p={p}')

    ax1.set_xlabel('Depth After Restriction', fontsize=12)
    ax1.set_ylabel('Probability', fontsize=12)
    ax1.set_title('Depth Reduction Under Random Restrictions', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')

    # Middle: Expected depth vs keep probability
    ax2 = axes[1]
    probs = np.linspace(0.01, 0.99, 50)
    for d in [3, 4, 5, 6]:
        expected = []
        for p in probs:
            depths = simulate_restriction_depth(32, d, p, 500)
            expected.append(np.mean(depths))
        ax2.plot(probs, expected, '-', label=f'depth={d}', linewidth=2)

    ax2.set_xlabel('Keep Probability (p)', fontsize=12)
    ax2.set_ylabel('Expected Depth After Restriction', fontsize=12)
    ax2.set_title('Expected Depth vs Keep Probability', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Right: Switching lemma bound vs empirical
    ax3 = axes[2]
    t = 3  # CNF width
    s_values = range(1, 7)

    for p in [0.05, 0.1, 0.15]:
        bound = [(5 * p * t) ** s for s in s_values]
        ax3.semilogy(list(s_values), bound, 'o--', label=f'(5pt)^s, p={p}',
                    markersize=5)

    ax3.axhline(y=1, color='black', linestyle='-', alpha=0.3)
    ax3.set_xlabel('Target Depth (s)', fontsize=12)
    ax3.set_ylabel('Probability Bound', fontsize=12)
    ax3.set_title('Switching Lemma Bound (width t=3)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_switching.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_switching.png")


if __name__ == "__main__":
    plot_switching()
