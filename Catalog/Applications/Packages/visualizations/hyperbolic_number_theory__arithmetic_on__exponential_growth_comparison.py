"""
Visualization: Exponential Growth of Hyperbolic Lattice Points

Compares the growth of lattice points in hyperbolic space (exponential, 3^n)
vs. Euclidean space (polynomial, (2n+1)^d). This exponential growth is the
geometric signature of negative curvature and is proven formally as
hypGrowth_closed_form.
"""

import numpy as np
import matplotlib.pyplot as plt


def hyp_growth(n):
    """Hyperbolic lattice growth: 3^n for n >= 1, 1 for n = 0."""
    if n == 0:
        return 1
    return 3**n


def euclidean_growth_1d(n):
    """Euclidean lattice growth in 1D: 2n + 1."""
    return 2 * n + 1


def euclidean_growth_2d(n):
    """Euclidean lattice growth in 2D: ~π*n²."""
    return int(np.pi * n**2) + 1 if n > 0 else 1


def prim_word_count(n):
    """Primitive word count (hyperbolic primes)."""
    if n == 0: return 0
    if n == 1: return 2
    return 2 * 3**(n - 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Growth comparison (log scale)
ax = axes[0, 0]
ns = np.arange(0, 13)
hyp = [hyp_growth(n) for n in ns]
euc1 = [euclidean_growth_1d(n) for n in ns]
euc2 = [euclidean_growth_2d(n) for n in ns]

ax.semilogy(ns, hyp, 'ro-', linewidth=2, markersize=6, label='Hyperbolic (3ⁿ)')
ax.semilogy(ns, euc1, 'b^-', linewidth=2, markersize=6, label='Euclidean 1D (2n+1)')
ax.semilogy(ns, euc2, 'gs-', linewidth=2, markersize=6, label='Euclidean 2D (~πn²)')
ax.set_xlabel('Radius n', fontsize=11)
ax.set_ylabel('Number of lattice points', fontsize=11)
ax.set_title('Growth: Hyperbolic vs. Euclidean', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Growth ratio
ax = axes[0, 1]
ratios = [hyp_growth(n) / euclidean_growth_2d(n) for n in range(1, 13)]
ax.bar(range(1, 13), ratios, color='coral', alpha=0.8, edgecolor='darkred')
ax.set_xlabel('Radius n', fontsize=11)
ax.set_ylabel('Ratio (Hyperbolic / Euclidean 2D)', fontsize=11)
ax.set_title('Hyperbolic Advantage Factor', fontsize=12)
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: Primitive words (hyperbolic primes)
ax = axes[1, 0]
ns_prim = np.arange(1, 11)
prims = [prim_word_count(n) for n in ns_prim]
three_n_over_n = [3**n / n for n in ns_prim]

ax.semilogy(ns_prim, prims, 'ro-', linewidth=2, markersize=6,
            label='Primitive words π_H(n)')
ax.semilogy(ns_prim, three_n_over_n, 'b--', linewidth=2,
            label='3ⁿ/n (PNT prediction)')
ax.set_xlabel('Word length n', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Hyperbolic Prime Number Theorem', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 4: Kesten bound
ax = axes[1, 1]
ds = np.arange(1, 21)
kesten = [np.sqrt(2*d - 1) / d for d in ds]
ax.plot(ds, kesten, 'mo-', linewidth=2, markersize=5, label='Kesten bound √(2d-1)/d')
ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='ρ = 1 (amenability)')
ax.axhline(y=np.sqrt(3)/2, color='green', linestyle=':', linewidth=1.5,
           label=f'PSL(2,ℤ): √3/2 ≈ {np.sqrt(3)/2:.4f}')
ax.set_xlabel('Number of generators d', fontsize=11)
ax.set_ylabel('Spectral radius bound ρ', fontsize=11)
ax.set_title('Kesten Spectral Bound', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory: Growth, Primes, and Spectral Theory',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig("viz_growth.png", dpi=150, bbox_inches='tight')
plt.close()
