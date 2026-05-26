#!/usr/bin/env python3
"""
Visualization: Symplectic Structure and Certificate Elements

Illustrates the symplectic form, its preservation by symplectic matrices,
and the connection between certificate density in GL_n and Sp_{2n}.
Shows the "half-density" phenomenon: Sp_{2n} certificates have density
~1/(2n) compared to GL_n's ~1/n.
"""

import matplotlib.pyplot as plt
import numpy as np


def mobius(n):
    if n == 1:
        return 1
    factors = {}
    temp = n
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            factors[p] = factors.get(p, 0) + 1
            temp //= p
    if temp > 1:
        factors[temp] = 1
    for exp in factors.values():
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def necklace_count(q, n):
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d
    return total // n


fig = plt.figure(figsize=(16, 12))

# Panel 1: Symplectic form matrix heatmap
ax1 = fig.add_subplot(2, 2, 1)
n = 4
J = np.zeros((2*n, 2*n))
for i in range(n):
    J[i, i+n] = 1
    J[i+n, i] = -1

im = ax1.imshow(J, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax1.set_title(f'Standard Symplectic Form $J_{{2 \\times {n}}}$', fontsize=13)
ax1.set_xlabel('Column index')
ax1.set_ylabel('Row index')
for i in range(2*n):
    for j in range(2*n):
        val = int(J[i,j])
        if val != 0:
            ax1.text(j, i, str(val), ha='center', va='center',
                    fontsize=11, fontweight='bold',
                    color='white' if abs(val) > 0.5 else 'black')
plt.colorbar(im, ax=ax1, shrink=0.8)

# Panel 2: Density comparison across group families
ax2 = fig.add_subplot(2, 2, 2)
n_range = np.arange(1, 16)

gl_density = [1/n for n in n_range]
sp_density = [1/(2*n) for n in n_range]
orth_density = [1/(2*n) for n in n_range]  # same asymptotic for orthogonal

ax2.plot(n_range, gl_density, 'o-', color='#3498db', label='$GL_n$: $\\delta \\approx 1/n$',
         markersize=5, linewidth=2)
ax2.plot(n_range, sp_density, 's-', color='#e74c3c', label='$Sp_{2n}$: $\\delta \\approx 1/(2n)$',
         markersize=5, linewidth=2)
ax2.fill_between(n_range, gl_density, sp_density, alpha=0.1, color='purple')

ax2.set_xlabel('Parameter $n$', fontsize=12)
ax2.set_ylabel('Certificate density $\\delta$', fontsize=12)
ax2.set_title('Certificate Density: $GL_n$ vs $Sp_{2n}$ vs $O_{2n}$')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Annotate the gap
ax2.annotate('Self-reciprocal\nconstraint halves\nthe density',
            xy=(5, 1/(2*5)), xytext=(8, 0.3),
            arrowprops=dict(arrowstyle='->', color='purple', lw=1.5),
            fontsize=10, color='purple', ha='center')

# Panel 3: Irreducible polynomial count: standard vs self-reciprocal
ax3 = fig.add_subplot(2, 2, 3)
q = 5

n_range_count = range(1, 9)
standard_counts = [necklace_count(q, n) for n in n_range_count]
# SRI count ≈ necklace_count(q, n) / 2 for the self-reciprocal constraint
# More precisely, SRI(q,n) = (1/(2n)) * Σ_{d|n} μ(n/d) q^d
sri_formula = []
for n in n_range_count:
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d
    sri_formula.append(total / (2*n))

qn_over_n = [q**n / n for n in n_range_count]
qn_over_2n = [q**n / (2*n) for n in n_range_count]

ax3.semilogy(list(n_range_count), standard_counts, 'o-', color='#3498db',
             label='Irreducible deg-$n$ (standard)', linewidth=2)
ax3.semilogy(list(n_range_count), sri_formula, 's-', color='#e74c3c',
             label='Self-reciprocal irred. deg-$2n$', linewidth=2)
ax3.semilogy(list(n_range_count), qn_over_n, '--', color='#3498db',
             alpha=0.4, label='$q^n/n$')
ax3.semilogy(list(n_range_count), qn_over_2n, '--', color='#e74c3c',
             alpha=0.4, label='$q^n/(2n)$')

ax3.set_xlabel('$n$', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title(f'Irreducible Polynomial Counts over $\\mathbb{{F}}_{{{q}}}$')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: The self-reciprocal compression ratio
ax4 = fig.add_subplot(2, 2, 4)

# For several field sizes, show how the ratio SRI(q,n) * 2n / q^n converges to 1
q_values = [3, 5, 7, 11]
colors = ['#2ecc71', '#9b59b6', '#e67e22', '#1abc9c']

for q, color in zip(q_values, colors):
    ratios = []
    ns = []
    for n in range(1, 8):
        total = 0
        for d in range(1, n + 1):
            if n % d == 0:
                total += mobius(n // d) * q**d
        sri = total / (2 * n)
        ratio = sri * (2 * n) / q**n
        ratios.append(ratio)
        ns.append(n)
    ax4.plot(ns, ratios, 'o-', color=color, label=f'$q={q}$', markersize=6, linewidth=2)

ax4.axhline(y=1, color='black', linestyle='--', alpha=0.5, linewidth=1)
ax4.set_xlabel('$n$', fontsize=12)
ax4.set_ylabel('$SRI(q,n) \\cdot 2n \\, / \\, q^n$', fontsize=12)
ax4.set_title('Convergence: $SRI(q,n) \\cdot 2n / q^n \\to 1$')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0.5, 1.5)

plt.tight_layout()
plt.savefig('symplectic_structure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved symplectic_structure_visualization.png")
