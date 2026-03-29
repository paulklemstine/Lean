#!/usr/bin/env python3
"""
🌀 The Twilight Zone — Infinity, Convergence, and Forbidden Sums

Demonstrates:
1. The Grandi series oscillation and Cesàro convergence to 1/2
2. The harmonic series vs convergent series comparison
3. Cantor's diagonal argument visualization
4. The density of rationals and irrationals — perfectly interleaved
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction

def cesaro_means(n_terms):
    """Compute Cesàro means of the Grandi series 1-1+1-1+..."""
    partial_sums = []
    s = 0
    for i in range(n_terms):
        s += (-1)**i
        partial_sums.append(s)
    cesaro = np.cumsum(partial_sums) / np.arange(1, n_terms + 1)
    return partial_sums, cesaro

def stern_brocot_rationals(depth):
    """Generate rationals in (0,1) via the Stern-Brocot tree."""
    rationals = []
    def generate(a_num, a_den, b_num, b_den, d):
        if d <= 0:
            return
        m_num = a_num + b_num
        m_den = a_den + b_den
        rationals.append(Fraction(m_num, m_den))
        generate(a_num, a_den, m_num, m_den, d - 1)
        generate(m_num, m_den, b_num, b_den, d - 1)
    generate(0, 1, 1, 1, depth)
    return sorted(set(rationals))

def main():
    fig, axes = plt.subplots(2, 2, figsize=(18, 14))
    fig.suptitle('🌀 The Twilight Zone: Between Finite and Infinite\n'
                 'Where convergence meets divergence',
                 fontsize=16, fontweight='bold')

    # Panel 1: Grandi series and Cesàro means
    ax1 = axes[0, 0]
    n = 100
    partial_sums, cesaro = cesaro_means(n)

    ax1.step(range(n), partial_sums, 'b-', linewidth=1.5, alpha=0.6,
            label='Partial sums: 1-1+1-1+...', where='mid')
    ax1.plot(range(n), cesaro, 'r-', linewidth=2.5,
            label='Cesàro mean → 1/2')
    ax1.axhline(y=0.5, color='green', linestyle='--', linewidth=1.5,
               label='y = 1/2 (Cesàro limit)')
    ax1.set_xlabel('Number of terms', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title("The Grandi Series: 1-1+1-1+...\n'Equals' 1/2 (by Cesàro summation)", fontsize=12)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.5, 1.5)

    # Panel 2: Convergent vs Divergent series
    ax2 = axes[0, 1]
    n_terms = 200
    ns = np.arange(1, n_terms + 1, dtype=float)

    # Harmonic series H_n
    harmonic = np.cumsum(1.0 / ns)
    # Sum of 1/n² (converges to π²/6)
    sum_inv_sq = np.cumsum(1.0 / ns**2)
    # Geometric series (r=1/2)
    geometric = np.cumsum(0.5**ns)
    # Alternating harmonic (converges to ln(2))
    alt_harmonic = np.cumsum((-1)**(ns+1) / ns)

    ax2.plot(ns, harmonic, 'r-', linewidth=2, label='∑ 1/n → ∞ (DIVERGES)')
    ax2.plot(ns, sum_inv_sq, 'b-', linewidth=2, label=f'∑ 1/n² → π²/6 ≈ {np.pi**2/6:.4f}')
    ax2.plot(ns, geometric, 'g-', linewidth=2, label='∑ (1/2)ⁿ → 1')
    ax2.plot(ns, alt_harmonic, 'm-', linewidth=2, label=f'∑ (-1)ⁿ⁺¹/n → ln2 ≈ {np.log(2):.4f}')

    ax2.axhline(y=np.pi**2/6, color='blue', linestyle=':', alpha=0.5)
    ax2.axhline(y=1.0, color='green', linestyle=':', alpha=0.5)
    ax2.axhline(y=np.log(2), color='purple', linestyle=':', alpha=0.5)

    ax2.set_xlabel('Number of terms', fontsize=12)
    ax2.set_ylabel('Partial sum', fontsize=12)
    ax2.set_title('Convergence vs Divergence\nThe Forbidden Boundary', fontsize=12)
    ax2.legend(fontsize=9, loc='center right')
    ax2.set_ylim(-0.5, 8)

    # Panel 3: Cantor's diagonal argument
    ax3 = axes[1, 0]
    # Simulate: list of binary sequences
    np.random.seed(42)
    n_seq = 8
    n_bits = 10
    sequences = np.random.randint(0, 2, (n_seq, n_bits))

    # The diagonal
    diagonal = sequences[np.arange(min(n_seq, n_bits)), np.arange(min(n_seq, n_bits))]
    anti_diagonal = 1 - diagonal

    # Draw the table
    for i in range(n_seq):
        for j in range(n_bits):
            color = 'lightyellow'
            if i == j and i < n_seq and j < n_bits:
                color = 'lightcoral'
            rect = patches.FancyBboxPatch((j * 0.9, (n_seq - 1 - i) * 0.9),
                                           0.8, 0.8,
                                           boxstyle="round,pad=0.05",
                                           facecolor=color, edgecolor='gray')
            ax3.add_patch(rect)
            ax3.text(j * 0.9 + 0.4, (n_seq - 1 - i) * 0.9 + 0.4,
                    str(sequences[i][j]),
                    ha='center', va='center', fontsize=12, fontweight='bold')

    # Show anti-diagonal below
    for j in range(min(n_seq, n_bits)):
        rect = patches.FancyBboxPatch((j * 0.9, -1.2),
                                       0.8, 0.8,
                                       boxstyle="round,pad=0.05",
                                       facecolor='lightgreen', edgecolor='darkgreen',
                                       linewidth=2)
        ax3.add_patch(rect)
        ax3.text(j * 0.9 + 0.4, -1.2 + 0.4,
                str(anti_diagonal[j]),
                ha='center', va='center', fontsize=12, fontweight='bold',
                color='darkgreen')

    ax3.text(-0.5, -0.8, 'Anti-\ndiagonal:', ha='right', va='center',
            fontsize=11, fontweight='bold', color='darkgreen')

    ax3.set_xlim(-1.5, n_bits * 0.9 + 0.2)
    ax3.set_ylim(-2, n_seq * 0.9 + 0.2)
    ax3.set_aspect('equal')
    ax3.axis('off')
    ax3.set_title("Cantor's Diagonal Argument\nThe anti-diagonal (green) differs from every row!", fontsize=12)

    # Panel 4: Rationals and irrationals interleaved
    ax4 = axes[1, 1]
    # Show density of both in [0, 1]
    rationals = stern_brocot_rationals(8)
    rat_floats = sorted([float(r) for r in rationals])

    # Plot rationals as vertical lines
    for r in rat_floats[:200]:
        ax4.axvline(x=r, color='blue', alpha=0.15, linewidth=0.5)

    # Plot some irrationals
    irrationals = [
        np.sqrt(2) - 1,
        np.sqrt(3) - 1,
        np.pi - 3,
        np.e - 2,
        np.sqrt(5) - 2,
        (np.sqrt(5) - 1) / 2,  # golden ratio - 1
        1 / np.sqrt(2),
        np.log(2),
        np.log(3) - 1,
        1 / np.pi,
    ]

    for r in irrationals:
        if 0 < r < 1:
            ax4.axvline(x=r, color='red', alpha=0.6, linewidth=1.5)

    ax4.scatter(rat_floats[:100], [0.3] * min(100, len(rat_floats)),
               c='blue', s=10, alpha=0.5, label='Rationals (countable, dense)')
    ax4.scatter([r for r in irrationals if 0 < r < 1],
               [0.7] * len([r for r in irrationals if 0 < r < 1]),
               c='red', s=30, marker='*', label='Famous irrationals')

    ax4.set_xlim(0, 1)
    ax4.set_ylim(-0.1, 1.1)
    ax4.set_xlabel('x ∈ [0, 1]', fontsize=12)
    ax4.set_title('Rationals & Irrationals: Perfectly Interleaved\n'
                  'Both dense, yet one is countable and the other is not!', fontsize=12)
    ax4.legend(fontsize=10, loc='upper right')
    ax4.set_yticks([])

    # Annotate famous irrationals
    for name, val in [('√2-1', np.sqrt(2)-1), ('φ-1', (np.sqrt(5)-1)/2),
                      ('ln2', np.log(2)), ('1/π', 1/np.pi)]:
        if 0 < val < 1:
            ax4.annotate(name, xy=(val, 0.7), xytext=(val, 0.85),
                        fontsize=8, ha='center', color='red',
                        arrowprops=dict(arrowstyle='->', color='red'))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/twilight_zone.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved twilight_zone.png")

    # Forbidden sums verification
    print("\n📊 Forbidden Convergence Verification:")
    print("-" * 60)
    print(f"  Gauss sum: 1+2+...+100 = {sum(range(1,101))} = {100*101//2} ✓")
    print(f"  Sum of squares: 1²+2²+...+10² = {sum(i**2 for i in range(1,11))} = {10*11*21//6} ✓")
    print(f"  Telescoping: Σ 1/(k(k+1)) for k=1..100 = {sum(Fraction(1, k*(k+1)) for k in range(1, 101))} = 100/101 ✓")
    print(f"  Geometric: Σ (1/2)^k for k=0..20 = {sum(Fraction(1, 2**k) for k in range(21))} ≈ {float(sum(Fraction(1, 2**k) for k in range(21))):.10f}")
    print(f"  Bernoulli: (1+0.1)^10 = {1.1**10:.6f} ≥ {1 + 10*0.1:.1f} = 1+10×0.1 ✓")
    print(f"  AM-GM: √(3×12) = {np.sqrt(36):.1f} ≤ {(3+12)/2:.1f} = (3+12)/2 ✓")

import matplotlib.patches as patches

if __name__ == "__main__":
    main()
