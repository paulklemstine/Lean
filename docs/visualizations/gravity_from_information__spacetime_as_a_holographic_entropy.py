#!/usr/bin/env python3
"""
Visualization: Holographic Entropy and Monogamy
Shows entropy profiles and monogamy constraints.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def holographic_entropy(m, n):
    """Compute holographic entropy for region of size m in boundary of size n.
    Uses the CFT₂ formula: S = (c/3) * log((n/π) * sin(πm/n)), c=1."""
    if m == 0 or m == n:
        return 0.0
    theta = math.pi * m / n
    return max(0, (1.0 / 3.0) * math.log(n * math.sin(theta) / math.pi))


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Holographic Entropy: Information Theory of Spacetime',
                 fontsize=16, fontweight='bold')
    
    # Plot 1: Entropy profile S(m) for different n
    ax = axes[0, 0]
    for n in [16, 32, 64, 128]:
        ms = np.arange(0, n + 1)
        ss = [holographic_entropy(m, n) for m in ms]
        ax.plot(ms / n, ss, linewidth=2, label=f'n={n}')
    ax.set_xlabel('Region Fraction m/n')
    ax.set_ylabel('Entropy S(m)')
    ax.set_title('RT Entropy Profile S(m/n)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Complementarity S(m) = S(n-m)
    ax = axes[0, 1]
    n = 64
    ms = np.arange(0, n + 1)
    ss = [holographic_entropy(m, n) for m in ms]
    ss_comp = [holographic_entropy(n - m, n) for m in ms]
    ax.plot(ms, ss, 'b-', linewidth=2, label='S(A)')
    ax.plot(ms, ss_comp, 'r--', linewidth=2, label='S(Aᶜ)')
    ax.set_xlabel('Region Size |A|')
    ax.set_ylabel('Entropy')
    ax.set_title(f'Complementarity: S(A) = S(Aᶜ)  (n={n})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Subadditivity verification
    ax = axes[1, 0]
    n = 64
    deficits = []
    a_sizes = []
    b_sizes_list = []
    for a in range(1, n // 2 + 1):
        for b in range(1, n - a):
            sa = holographic_entropy(a, n)
            sb = holographic_entropy(b, n)
            sab = holographic_entropy(a + b, n)
            deficit = sa + sb - sab  # Should be >= 0
            deficits.append(deficit)
            a_sizes.append(a)
            b_sizes_list.append(b)
    
    scatter = ax.scatter(a_sizes, b_sizes_list, c=deficits, cmap='viridis',
                        s=1, alpha=0.5)
    plt.colorbar(scatter, ax=ax, label='S(A)+S(B)-S(A∪B)')
    ax.set_xlabel('|A|')
    ax.set_ylabel('|B|')
    ax.set_title(f'Subadditivity Deficit (n={n})')
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Monogamy bound
    ax = axes[1, 1]
    n = 48
    mi_values = []
    bound_values = []
    a_values = []
    for a in range(1, n // 3 + 1):
        for c in range(1, n - 2 * a + 1):
            b = n - a - c
            if b >= 1:
                sa = holographic_entropy(a, n)
                sc = holographic_entropy(c, n)
                sac = holographic_entropy(a + c, n)
                mi = sa + sc - sac
                bound = 2 * sa
                mi_values.append(mi)
                bound_values.append(bound)
                a_values.append(a)
    
    ax.scatter(bound_values, mi_values, c=a_values, cmap='plasma',
              s=5, alpha=0.5)
    max_val = max(max(mi_values), max(bound_values)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='I(A:C) = 2·S(A)')
    ax.set_xlabel('2·S(A) (monogamy bound)')
    ax.set_ylabel('I(A:C) (mutual information)')
    ax.set_title(f'Monogamy: I(A:C) ≤ 2·S(A)  (n={n})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('holographic_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved: holographic_entropy.png")


if __name__ == '__main__':
    main()
