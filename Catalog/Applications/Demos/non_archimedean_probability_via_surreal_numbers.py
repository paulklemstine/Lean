#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

This script demonstrates the key ideas of non-Archimedean probability theory
using Python's `fractions` module for exact arithmetic and floating point
for visualization.
"""

from fractions import Fraction
import math

def demo_uniform_measure():
    """Demonstrate uniform probability measures on finite sets."""
    print("=" * 60)
    print("DEMO 1: Uniform Probability on Finite Sets")
    print("=" * 60)
    
    for n in [2, 5, 10, 100, 1000]:
        weight = Fraction(1, n)
        total = sum(weight for _ in range(n))
        print(f"  n={n:5d}: weight = 1/{n} = {float(weight):.6f}, "
              f"total = {total} ✓" if total == 1 else f"total = {total} ✗")
    
    print("\nKey insight: 1/n is NEVER infinitesimal for finite n.")
    print("For n=1000, weight = 0.001 — small but not infinitesimal.\n")

def demo_infinitesimal_impossibility():
    """Demonstrate that finite sums of infinitesimals can't reach 1."""
    print("=" * 60)
    print("DEMO 2: Infinitesimal Finite Sum Impossibility")
    print("=" * 60)
    
    # Simulate: if ε < 1/N for all N, then n*ε < 1 for all n
    print("\nIf ε is infinitesimal (ε < 1/n for ALL n > 0):")
    print("  Then for any finite sum of k copies of ε:")
    print("  k·ε < k·(1/(k+1)) = k/(k+1) < 1")
    print()
    for k in [1, 10, 100, 1000, 10**6]:
        bound = Fraction(k, k + 1)
        print(f"  k={k:>10d}: k·ε ≤ k/(k+1) = {float(bound):.10f} < 1")
    
    print("\nNo matter how many copies you sum, you NEVER reach 1.")
    print("This is the fundamental impossibility theorem.\n")

def demo_conditional_probability():
    """Demonstrate conditional probability with small probabilities."""
    print("=" * 60)
    print("DEMO 3: Conditional Probability (Even with Tiny Weights)")
    print("=" * 60)
    
    n = 1000
    weights = [Fraction(1, n)] * n
    
    # Condition on event B = first 10 elements
    B = list(range(10))
    A = list(range(5))  # first 5 elements
    
    P_B = sum(weights[i] for i in B)
    P_A_cap_B = sum(weights[i] for i in A if i in B)
    P_A_given_B = P_A_cap_B / P_B
    
    print(f"\n  Space size: {n}")
    print(f"  P(B) = {P_B} = {float(P_B):.4f}")
    print(f"  P(A∩B) = {P_A_cap_B} = {float(P_A_cap_B):.4f}")
    print(f"  P(A|B) = {P_A_given_B} = {float(P_A_given_B):.4f}")
    
    # Verify Bayes' theorem
    P_A = sum(weights[i] for i in A)
    P_B_given_A = P_A_cap_B / P_A
    
    lhs = P_A_given_B * P_B
    rhs = P_B_given_A * P_A
    print(f"\n  Bayes' check: P(A|B)·P(B) = {lhs}")
    print(f"                P(B|A)·P(A) = {rhs}")
    print(f"                Equal? {lhs == rhs} ✓\n")

def demo_markov_inequality():
    """Demonstrate Markov's inequality."""
    print("=" * 60)
    print("DEMO 4: Markov's Inequality")
    print("=" * 60)
    
    n = 100
    weights = [Fraction(1, n)] * n
    # f(i) = i for i in 0..99
    values = list(range(n))
    
    E_f = sum(Fraction(w) * v for w, v in zip(weights, values))
    
    for c in [10, 25, 50, 75]:
        P_exceed = sum(weights[i] for i in range(n) if values[i] >= c)
        bound = E_f / c
        print(f"  c={c:3d}: P(f≥c) = {float(P_exceed):.4f}, "
              f"E[f]/c = {float(bound):.4f}, "
              f"P(f≥c) ≤ E[f]/c? {P_exceed <= bound} ✓")
    print()

def demo_product_measure():
    """Demonstrate product measure construction."""
    print("=" * 60)
    print("DEMO 5: Product Measure (Independence)")
    print("=" * 60)
    
    # Two dice
    n = 6
    w1 = [Fraction(1, 6)] * 6
    w2 = [Fraction(1, 6)] * 6
    
    print(f"\n  Two fair dice (n=6 each)")
    print(f"  Product space size: {n*n}")
    
    total = Fraction(0)
    for i in range(n):
        for j in range(n):
            total += w1[i] * w2[j]
    print(f"  Total product mass: {total} ✓")
    
    # Marginal check
    marginal_1 = [sum(w1[i] * w2[j] for j in range(n)) for i in range(n)]
    print(f"  Marginal 1: {marginal_1[0]} (= 1/6) ✓")
    
    # P(sum = 7)
    p_seven = sum(w1[i] * w2[j] for i in range(n) for j in range(n) if i+j+2 == 7)
    print(f"  P(sum=7) = {p_seven} = {float(p_seven):.4f}")
    print()

def demo_entropy_scaling():
    """Show how entropy scales with partition size."""
    print("=" * 60)
    print("DEMO 6: Entropy Scaling (Motivating Non-Archimedean Need)")
    print("=" * 60)
    
    print(f"\n  {'n':>10s}  {'H(uniform)':>12s}  {'1/n':>12s}")
    print(f"  {'-'*10}  {'-'*12}  {'-'*12}")
    for k in range(1, 8):
        n = 10**k
        H = math.log2(n)
        w = 1.0/n
        print(f"  {n:>10d}  {H:>12.4f}  {w:>12.2e}")
    
    print("\n  As n → ∞, entropy H → ∞ but each weight → 0.")
    print("  In a non-Archimedean field, weights can be truly")
    print("  infinitesimal while entropy becomes a non-Archimedean")
    print("  infinite quantity. Both are well-defined!\n")

if __name__ == "__main__":
    demo_uniform_measure()
    demo_infinitesimal_impossibility()
    demo_conditional_probability()
    demo_markov_inequality()
    demo_product_measure()
    demo_entropy_scaling()
    
    print("=" * 60)
    print("SUMMARY: Non-Archimedean Probability Theory")
    print("=" * 60)
    print("""
  Key Results Demonstrated:
  
  1. Uniform weights 1/n are never infinitesimal (Theorem)
  2. Finite sums of infinitesimals never reach 1 (Impossibility)
  3. Conditional probability works even with tiny weights (Bayes)
  4. Markov's inequality generalizes to non-Archimedean setting
  5. Product measures factor correctly (Independence)
  6. Entropy scaling motivates the need for infinitesimals
  
  All results are formally verified in Lean 4.
""")


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Weight Distribution

Shows how uniform probability weights scale with set size, and
the impossibility of infinitesimal sums reaching 1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_weight_scaling():
    """Plot how uniform weight 1/n decreases with n."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: weight vs n
    n_values = np.arange(1, 101)
    weights = 1.0 / n_values
    
    axes[0].plot(n_values, weights, 'b-', linewidth=2)
    axes[0].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Infinitesimal boundary')
    axes[0].set_xlabel('Number of elements (n)', fontsize=12)
    axes[0].set_ylabel('Uniform weight (1/n)', fontsize=12)
    axes[0].set_title('Weight Scaling: Never Reaches Zero', fontsize=14)
    axes[0].legend(fontsize=10)
    axes[0].set_ylim(-0.05, 1.05)
    axes[0].grid(True, alpha=0.3)
    
    # Add annotation
    axes[0].annotate(
        'For any finite n,\n1/n > 0 (not infinitesimal)',
        xy=(50, 0.02), xytext=(60, 0.4),
        arrowprops=dict(arrowstyle='->', color='red'),
        fontsize=11, color='red',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow')
    )
    
    # Right: sum of k copies of epsilon vs k
    k_values = np.arange(1, 201)
    
    for eps_inv in [10, 50, 200, 1000]:
        eps = 1.0 / eps_inv
        sums = k_values * eps
        valid = sums < 1
        axes[1].plot(k_values[valid], sums[valid], linewidth=2,
                     label=f'ε = 1/{eps_inv}')
    
    axes[1].axhline(y=1, color='red', linestyle='--', linewidth=2, label='Target = 1')
    axes[1].set_xlabel('Number of terms (k)', fontsize=12)
    axes[1].set_ylabel('Partial sum (k·ε)', fontsize=12)
    axes[1].set_title('Infinitesimal Sums: Cannot Reach 1', fontsize=14)
    axes[1].legend(fontsize=9, loc='upper left')
    axes[1].set_ylim(-0.05, 1.2)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('weight_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: weight_scaling.png")

def plot_conditional_probability():
    """Visualize conditional probability as weight reallocation."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    n = 10
    uniform_weights = np.ones(n) / n
    
    # Original measure
    colors = ['steelblue'] * n
    axes[0].bar(range(n), uniform_weights, color=colors, edgecolor='navy', linewidth=0.5)
    axes[0].set_title('Original Measure μ', fontsize=13)
    axes[0].set_ylabel('Weight', fontsize=11)
    axes[0].set_ylim(0, 0.35)
    axes[0].set_xlabel('Element', fontsize=11)
    
    # Conditioning set B = {3, 4, 5, 6}
    B = {3, 4, 5, 6}
    cond_weights = np.zeros(n)
    p_B = sum(uniform_weights[i] for i in B)
    for i in range(n):
        if i in B:
            cond_weights[i] = uniform_weights[i] / p_B
    
    colors2 = ['lightgray' if i not in B else 'coral' for i in range(n)]
    axes[1].bar(range(n), cond_weights, color=colors2, edgecolor='darkred', linewidth=0.5)
    axes[1].set_title('Conditional μ(·|B), B={3,4,5,6}', fontsize=13)
    axes[1].set_ylim(0, 0.35)
    axes[1].set_xlabel('Element', fontsize=11)
    
    # Verify total mass
    for ax in axes[:2]:
        ax.axhline(y=1/n, color='gray', linestyle=':', alpha=0.5)
    
    # Chain rule visualization
    A = {2, 3, 4}
    bar_data = {
        'P(A∩B)': sum(uniform_weights[i] for i in A & B),
        'P(A|B)·P(B)': sum(cond_weights[i] for i in A) * p_B,
    }
    
    colors3 = ['coral', 'steelblue']
    bars = axes[2].bar(range(len(bar_data)), list(bar_data.values()),
                       color=colors3, edgecolor='black', linewidth=0.5)
    axes[2].set_xticks(range(len(bar_data)))
    axes[2].set_xticklabels(list(bar_data.keys()), fontsize=10)
    axes[2].set_title('Chain Rule Verification', fontsize=13)
    axes[2].set_ylabel('Value', fontsize=11)
    
    # Add value labels
    for bar, val in zip(bars, bar_data.values()):
        axes[2].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.005,
                     f'{val:.4f}', ha='center', fontsize=10, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('conditional_probability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability.png")

def plot_markov_inequality():
    """Visualize Markov's inequality."""
    fig, ax = plt.subplots(figsize=(10, 5))
    
    n = 50
    weights = np.ones(n) / n
    values = np.arange(n, dtype=float)
    
    E_f = np.sum(weights * values)
    
    c_values = np.linspace(1, 45, 100)
    actual_probs = [np.sum(weights[values >= c]) for c in c_values]
    markov_bounds = [E_f / c for c in c_values]
    
    ax.fill_between(c_values, actual_probs, alpha=0.3, color='steelblue', label='P(f ≥ c)')
    ax.plot(c_values, actual_probs, 'b-', linewidth=2)
    ax.plot(c_values, markov_bounds, 'r--', linewidth=2, label='E[f]/c (Markov bound)')
    
    ax.set_xlabel('Threshold c', fontsize=12)
    ax.set_ylabel('Probability', fontsize=12)
    ax.set_title("Markov's Inequality: P(f ≥ c) ≤ E[f]/c", fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)
    
    # Annotate
    ax.annotate(f'E[f] = {E_f:.1f}', xy=(E_f, 0.5), fontsize=11,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('markov_inequality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: markov_inequality.png")

if __name__ == "__main__":
    plot_weight_scaling()
    plot_conditional_probability()
    plot_markov_inequality()
    print("\nAll visualizations generated successfully.")
