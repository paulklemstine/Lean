"""
Visualization 3: Irreducible Polynomial Landscape

Shows the necklace formula N(n,q) = (1/n)Σ μ(n/d)q^d alongside the
decomposition into self-reciprocal vs non-self-reciprocal irreducibles.
Illustrates the even-degree constraint on self-reciprocal irreducibles.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def mobius(k):
    """Möbius function μ(k)."""
    if k == 1:
        return 1
    factors = {}
    m = k
    for d in range(2, int(m ** 0.5) + 2):
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    for exp in factors.values():
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def divisors(k):
    """All positive divisors of k."""
    divs = []
    for d in range(1, int(k ** 0.5) + 1):
        if k % d == 0:
            divs.append(d)
            if d != k // d:
                divs.append(k // d)
    return sorted(divs)


def count_irreducible(n, q):
    """N(n,q) via necklace formula."""
    total = 0
    for d in divisors(n):
        total += mobius(n // d) * (q ** d)
    return total // n


def count_self_reciprocal_irreducible_approx(n, q):
    """
    Approximate count of irreducible self-reciprocal polynomials of degree n.
    For even n: ≈ N(n/2, q)/2 (via half-polynomial correspondence)
    For odd n ≥ 3: 0 (by the even degree theorem)
    """
    if n % 2 == 1 and n >= 3:
        return 0
    if n == 2:
        # Count irreducible x² + bx + 1 over F_q (self-reciprocal quadratics)
        # These are x² + bx + 1 with discriminant b² - 4 not a square in F_q
        count = 0
        for b in range(q):
            disc = (b * b - 4) % q
            # Check if disc is a non-square (and nonzero for irreducibility)
            if disc == 0:
                continue
            is_square = any((x * x) % q == disc for x in range(q))
            if not is_square:
                count += 1
        return count
    if n % 2 == 0:
        return count_irreducible(n // 2, q) // 2 + (1 if n == 2 else 0)
    return 0


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Plot 1: N(n,q) for various q ---
ns = np.arange(1, 16)
for q, color, marker in [(2, '#2196F3', 'o'), (3, '#4CAF50', 's'),
                           (5, '#FF9800', '^'), (7, '#E91E63', 'D')]:
    counts = [count_irreducible(n, q) for n in ns]
    axes[0, 0].semilogy(ns, counts, f'{marker}-', color=color,
                         label=f'N(n,{q})', markersize=5, linewidth=1.5)
    approx = [q ** n / n for n in ns]
    axes[0, 0].semilogy(ns, approx, '--', color=color, alpha=0.3, linewidth=1)

axes[0, 0].set_xlabel('Degree n', fontsize=11)
axes[0, 0].set_ylabel('Count (log scale)', fontsize=11)
axes[0, 0].set_title('Irreducible Polynomial Count N(n,q)', fontsize=12,
                       fontweight='bold')
axes[0, 0].legend(fontsize=9)
axes[0, 0].grid(True, alpha=0.3, which='both')

# --- Plot 2: Density N(n,q)/q^n ≈ 1/n ---
for q, color in [(2, '#2196F3'), (3, '#4CAF50'), (5, '#FF9800'), (7, '#E91E63')]:
    densities = [count_irreducible(n, q) / q ** n for n in ns]
    axes[0, 1].plot(ns, densities, 'o-', color=color, label=f'F_{q}',
                     markersize=5, linewidth=1.5, alpha=0.8)

axes[0, 1].plot(ns, 1.0 / ns, 'k--', linewidth=2, alpha=0.5, label='1/n')
axes[0, 1].set_xlabel('Degree n', fontsize=11)
axes[0, 1].set_ylabel('Density N(n,q)/q^n', fontsize=11)
axes[0, 1].set_title('Density Converges to 1/n', fontsize=12, fontweight='bold')
axes[0, 1].legend(fontsize=9)
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].set_ylim(0, 1.1)

# --- Plot 3: Self-reciprocal vs total irreducibles ---
q = 5
ns_sr = np.arange(1, 13)
total_irred = [count_irreducible(n, q) for n in ns_sr]
sr_irred = [count_self_reciprocal_irreducible_approx(n, q) for n in ns_sr]
non_sr = [t - s for t, s in zip(total_irred, sr_irred)]

bar_width = 0.35
x = np.arange(len(ns_sr))
axes[1, 0].bar(x - bar_width / 2, non_sr, bar_width, label='Non-self-reciprocal',
                color='#64B5F6', alpha=0.8)
axes[1, 0].bar(x + bar_width / 2, sr_irred, bar_width, label='Self-reciprocal',
                color='#FF7043', alpha=0.8)

# Mark odd degrees with X
for i, n in enumerate(ns_sr):
    if n % 2 == 1 and n >= 3:
        axes[1, 0].annotate('✗', (i + bar_width / 2, 0.5), fontsize=14,
                             ha='center', color='red', fontweight='bold')

axes[1, 0].set_xlabel('Degree n', fontsize=11)
axes[1, 0].set_ylabel('Count', fontsize=11)
axes[1, 0].set_title(f'Irreducible Polynomials over F_{q}:\nSelf-reciprocal vs Total',
                       fontsize=12, fontweight='bold')
axes[1, 0].set_xticks(x)
axes[1, 0].set_xticklabels([str(n) for n in ns_sr])
axes[1, 0].legend(fontsize=9)
axes[1, 0].grid(True, alpha=0.3, axis='y')

# --- Plot 4: The Möbius function and its role ---
ms = np.arange(1, 31)
mu_vals = [mobius(m) for m in ms]
colors_mu = ['#4CAF50' if v == 1 else '#F44336' if v == -1 else '#9E9E9E'
              for v in mu_vals]

axes[1, 1].bar(ms, mu_vals, color=colors_mu, alpha=0.8, edgecolor='white')
axes[1, 1].set_xlabel('n', fontsize=11)
axes[1, 1].set_ylabel('μ(n)', fontsize=11)
axes[1, 1].set_title('Möbius Function μ(n)\n(drives the necklace formula)',
                       fontsize=12, fontweight='bold')
axes[1, 1].set_ylim(-1.5, 1.5)
axes[1, 1].grid(True, alpha=0.3, axis='y')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#4CAF50', alpha=0.8, label='μ(n) = +1 (squarefree, even # primes)'),
    Patch(facecolor='#F44336', alpha=0.8, label='μ(n) = -1 (squarefree, odd # primes)'),
    Patch(facecolor='#9E9E9E', alpha=0.8, label='μ(n) = 0 (has squared prime factor)'),
]
axes[1, 1].legend(handles=legend_elements, fontsize=8, loc='upper right')

plt.suptitle('The Arithmetic of Irreducible Polynomials over Finite Fields',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_polynomial_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_polynomial_landscape.png")
