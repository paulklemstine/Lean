"""
Visualization 1: Certificate Density Θ(1/n) Across Classical Group Families

Shows the universal 1/n scaling of certificate density for SL_n across
different field sizes. The curves collapse onto a universal Θ(1/n) envelope,
demonstrating that the density phenomenon is independent of the field.
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
    """Return all positive divisors of k."""
    divs = []
    for d in range(1, int(k ** 0.5) + 1):
        if k % d == 0:
            divs.append(d)
            if d != k // d:
                divs.append(k // d)
    return sorted(divs)


def count_irreducible(n, q):
    """Count monic irreducible polynomials of degree n over F_q."""
    total = 0
    for d in divisors(n):
        total += mobius(n // d) * (q ** d)
    return total // n


def sl_certificate_density(n, q):
    """
    Theoretical SL_n certificate density.
    Number of irreducible polynomials of degree n with constant term (-1)^n
    divided by |SL_n(F_q)|. Approximate as N(n,q)/(q-1) / |SL_n|.
    For density among monic degree-n polynomials: N(n,q)/q^n ≈ 1/n.
    """
    return count_irreducible(n, q) / q ** n


def self_reciprocal_irreducible_density(n, q):
    """
    Theoretical density of irreducible self-reciprocal polynomials
    of degree 2n over F_q, as fraction of all monic degree-2n polynomials.
    Approximately N(n,q)/(2*q^n) for the "half-polynomial" count.
    """
    return count_irreducible(n, q) / (2 * q ** n)


# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# --- Left plot: SL_n density ---
ns = np.arange(1, 21)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
field_sizes = [2, 3, 5, 7, 11]

for i, q in enumerate(field_sizes):
    densities = [sl_certificate_density(n, q) for n in ns]
    ax1.plot(ns, densities, 'o-', color=colors[i], label=f'F_{q}',
             markersize=4, linewidth=1.5, alpha=0.8)

# Reference curve 1/n
ax1.plot(ns, 1.0 / ns, 'k--', linewidth=2, alpha=0.5, label='1/n')
ax1.plot(ns, 1.0 / (2 * ns), 'k:', linewidth=1.5, alpha=0.3, label='1/(2n)')

ax1.set_xlabel('Dimension n', fontsize=12)
ax1.set_ylabel('Certificate Density', fontsize=12)
ax1.set_title('SL_n Certificate Density vs Dimension', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='upper right')
ax1.set_ylim(0, 1.1)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(0, 21, 2))

# --- Right plot: Normalized density (n × density) ---
for i, q in enumerate(field_sizes):
    normalized = [n * sl_certificate_density(n, q) for n in ns]
    ax2.plot(ns, normalized, 'o-', color=colors[i], label=f'F_{q}',
             markersize=4, linewidth=1.5, alpha=0.8)

# Add self-reciprocal curve for Sp comparison
for i, q in enumerate([3, 5, 7]):
    sp_normalized = [n * self_reciprocal_irreducible_density(n, q) for n in ns]
    ax2.plot(ns, sp_normalized, 's--', color=colors[i + 2],
             label=f'Sp (F_{q})', markersize=3, linewidth=1, alpha=0.5)

ax2.axhline(y=1, color='black', linestyle='--', linewidth=1.5, alpha=0.5,
            label='y = 1 (exact 1/n)')
ax2.set_xlabel('Dimension n', fontsize=12)
ax2.set_ylabel('n × Certificate Density', fontsize=12)
ax2.set_title('Normalized Density (should be ~constant)', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=9, loc='upper right', ncol=2)
ax2.set_ylim(0, 1.5)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(0, 21, 2))

plt.tight_layout()
plt.savefig('viz_density_curves.png', dpi=150, bbox_inches='tight')
print("Saved viz_density_curves.png")
