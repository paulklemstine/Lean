#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Numerical Demonstrations

Computes key quantities in hypergraph Ramsey theory:
- Probabilistic lower bounds R_r(k,k) via the Erdos counting argument
- Tower function growth rates
- The gap between lower and upper bounds across uniformities
"""

from math import comb, log2


def tower(h, n):
    """Tower function: tower(0,n) = n, tower(h+1,n) = 2^tower(h,n)."""
    result = n
    for _ in range(h):
        if result > 300:
            return float('inf')
        result = 2 ** result
    return result


def prob_lower_exponent(r, k):
    """Exponent in the probabilistic lower bound: C(k,r)."""
    if k < r:
        return 0
    return comb(k, r)


def graph_ramsey_upper(k):
    """Upper bound C(2k-2, k-1) for R_2(k,k)."""
    if k <= 1:
        return k
    return comb(2*k - 2, k - 1)


def main():
    print("HYPERGRAPH RAMSEY THEORY: BEYOND GRAPHS")
    print("=" * 60)
    
    # Table of probabilistic lower bound exponents
    print("\nProbabilistic Lower Bound Exponents C(k,r)")
    print("R_r(k,k) >= 2^{C(k,r)/k}")
    print("-" * 60)
    header = "r\\k"
    print(f"  {header:>4}", end="")
    for k in range(3, 9):
        print(f"  {k:>6}", end="")
    print()
    for r in range(2, 6):
        print(f"  {r:>4}", end="")
        for k in range(3, 9):
            if k < r:
                print(f"  {'---':>6}", end="")
            else:
                exp = comb(k, r)
                print(f"  {exp:>6}", end="")
        print()
    
    # Tower growth
    print("\n" + "=" * 60)
    print("Tower Growth: Upper Bounds for R_r(k,k)")
    print("Starting from R_2(3,3) = 6:")
    N = 6
    for h in range(5):
        r = 2 + h
        k = 3 + h
        bound = tower(h, N)
        if bound < 1e18:
            print(f"  R_{r}({k},{k}) <= tower({h}, {N}) = {bound}")
        else:
            print(f"  R_{r}({k},{k}) <= tower({h}, {N}) [astronomically large]")
    
    # Gap analysis for R_3(k,k)
    print("\n" + "=" * 60)
    print("Gap Analysis for R_3(k,k)")
    print("Lower bound exponent: C(k,3)")
    print("Upper bound exponent: R_2(k-1,k-1) <= C(2k-4,k-2)")
    for k in range(4, 9):
        lower = comb(k, 3)
        upper = graph_ramsey_upper(k - 1)
        ratio = upper / lower if lower > 0 else float('inf')
        print(f"  k={k}: lower=2^{lower}, upper=2^{upper}, gap={ratio:.1f}x")
    
    # Specific known values
    print("\n" + "=" * 60)
    print("Known Values and Bounds")
    print("  R_2(3,3) = 6")
    print("  R_2(4,4) = 18")
    print("  R_2(5,5): between 43 and 48")
    print("  R_3(4,4) = 13")
    print("  R_3(5,5): between 34 and 55")
    
    # Exponent comparison
    print("\n" + "=" * 60)
    print("Exponent Growth with Uniformity (k=8)")
    for r in range(2, 8):
        if r <= 8:
            exp = comb(8, r)
            print(f"  C(8,{r}) = {exp:>5}  ->  R_{r}(8,8) >= 2^{exp/8:.0f}")
    
    print("\nKEY INSIGHT: Each uniformity level increases the exponent")
    print("in the lower bound polynomially, but the upper bound")
    print("grows as a tower of exponentials. The gap is a central")
    print("open problem in combinatorics.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tower Growth of Hypergraph Ramsey Numbers

Shows how R_r(k,k) grows with uniformity r, demonstrating the
tower-type explosion predicted by the stepping-up lemma.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2, log

def prob_lower_exponent(r: int, k: int) -> float:
    """log₂ of the probabilistic lower bound for R_r(k,k)."""
    if k < r:
        return 0
    return comb(k, r) / k

def graph_ramsey_upper(k: int) -> float:
    """log₂ of the upper bound C(2k-2, k-1) for R_2(k,k)."""
    if k <= 1:
        return 0
    return log2(comb(2 * k - 2, k - 1))

def make_plot():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Plot 1: Probabilistic lower bounds across uniformities
    ax1 = axes[0]
    ks = np.arange(4, 16)
    for r in [2, 3, 4, 5]:
        bounds = [comb(int(k), r) for k in ks if int(k) >= r]
        valid_ks = [k for k in ks if int(k) >= r]
        ax1.semilogy(valid_ks, bounds, 'o-', label=f'r={r}: C(k,{r})', linewidth=2, markersize=5)
    
    ax1.set_xlabel('Clique size k', fontsize=12)
    ax1.set_ylabel('Exponent C(k,r) in bound 2^{C(k,r)/k}', fontsize=12)
    ax1.set_title('Probabilistic Lower Bound Exponents\nfor R_r(k,k)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Gap between lower and upper bounds for R_3(k,k)
    ax2 = axes[1]
    ks = np.arange(4, 12)
    lower_exp = [comb(int(k), 3) for k in ks]
    upper_exp = [comb(2*(int(k)-1)-2, int(k)-2) for k in ks]
    
    ax2.semilogy(ks, lower_exp, 's-', color='blue', label='Lower: C(k,3)', linewidth=2, markersize=8)
    ax2.semilogy(ks, upper_exp, '^-', color='red', label='Upper: C(2k-4,k-2)', linewidth=2, markersize=8)
    ax2.fill_between(ks, lower_exp, upper_exp, alpha=0.15, color='purple')
    
    ax2.set_xlabel('Clique size k', fontsize=12)
    ax2.set_ylabel('Exponent (log scale)', fontsize=12)
    ax2.set_title('Gap in R₃(k,k) Bounds\nSingle vs Double Exponential', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.annotate('OPEN\nPROBLEM', xy=(8, 100), fontsize=14, color='purple',
                ha='center', va='center', fontweight='bold', alpha=0.5)
    
    # Plot 3: Tower function growth
    ax3 = axes[2]
    heights = [0, 1, 2, 3]
    base_values = [3, 4, 5, 6]
    
    for base in base_values:
        tower_vals = []
        for h in heights:
            val = base
            for _ in range(h):
                val = 2 ** val
                if val > 1e100:
                    val = 1e100
                    break
            tower_vals.append(val)
        
        # Use log-log scale
        log_vals = [log2(max(v, 1)) for v in tower_vals]
        ax3.plot(heights, log_vals, 'D-', label=f'base={base}', linewidth=2, markersize=8)
    
    ax3.set_xlabel('Tower height h (= r - 2)', fontsize=12)
    ax3.set_ylabel('log₂(tower(h, base))', fontsize=12)
    ax3.set_title('Tower Function Growth\ntower(h, n) = 2↑↑h(n)', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    ax3.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig('Applications/HypergraphRamsey/tower_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tower_growth.png")

def make_pascal_plot():
    """Visualize Pascal's triangle highlighting C(k,r) growth."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    max_k = 12
    for k in range(max_k + 1):
        for r in range(k + 1):
            val = comb(k, r)
            color_intensity = min(1.0, log2(val + 1) / 10)
            circle = plt.Circle((r - k/2, -k), 0.4, 
                              color=plt.cm.YlOrRd(color_intensity),
                              ec='black', linewidth=0.5)
            ax.add_patch(circle)
            ax.text(r - k/2, -k, str(val), ha='center', va='center', 
                   fontsize=max(6, 10 - k//3))
    
    # Highlight the ascending diagonal (r fixed)
    for r in [2, 3]:
        xs = [r - k/2 for k in range(r, max_k + 1)]
        ys = [-k for k in range(r, max_k + 1)]
        ax.plot(xs, ys, '--', linewidth=2, alpha=0.7,
               label=f'r={r}: C(k,{r}) exponent line')
    
    ax.set_xlim(-max_k/2 - 1, max_k/2 + 1)
    ax.set_ylim(-max_k - 1, 1)
    ax.set_aspect('equal')
    ax.set_title("Pascal's Triangle: C(k,r) as Ramsey Exponents\n"
                "Each C(k,r) is the exponent in R_r(k,k) ≥ 2^{C(k,r)/k}", fontsize=14)
    ax.legend(loc='upper right', fontsize=10)
    ax.axis('off')
    
    plt.savefig('Applications/HypergraphRamsey/pascal_ramsey.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved pascal_ramsey.png")

if __name__ == "__main__":
    make_plot()
    make_pascal_plot()
